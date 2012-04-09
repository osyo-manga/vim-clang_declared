let s:save_cpo = &cpo
set cpo&vim


function! s:c_index_test(filename, lnum, col)
	let file = a:filename
	let file_path = fnamemodify(a:filename, ":p")
	let options = join(map(filter(split(&path, ","), "isdirectory(v:val)"), "'-I'.v:val"), " ")
	let cmd = g:clang_declared_c_index_test_cmd." -cursor-at=".file_path.":".(a:lnum).":".(a:col)."  ".options." ".g:clang_declared_c_index_test_option." ".file
	return system(cmd)
endfunction


function! clang_declared#parse_c_index_test_result(result)
	let line = a:result
	let mx='\(\f\+\):\s*\(\d\+\):\s*\(\d\+\)'
	let l = matchstr(line, mx)
	let file = substitute(l, mx, '\1', '')
	let lnum = substitute(l, mx, '\2', '')
	let col = substitute(l, mx, '\3', '')

	if empty(lnum) || empty(col)
		return {}
	endif
	return { "lnum" : lnum+0, "col" : col+0 }
endfunction


function! clang_declared#search(filename, lnum, col)
	let result = s:c_index_test(a:filename, a:lnum, a:col)
	if g:clang_declared_debug_mode
		echo result
	endif

	let declared_pos = clang_declared#parse_c_index_test_result(result)
	if empty(declared_pos)
		return {}
	endif

	let func_name = expand("<cword>")
	let includes = neocomplcache#sources#include_complete#get_current_include_files()
	for header in includes+[a:filename]
		let lines = readfile(header)
		if len(lines) >= declared_pos.lnum
\		&& len(lines[declared_pos.lnum-1]) >= declared_pos.col
\		&& match(lines[declared_pos.lnum-1], func_name, declared_pos.col-1) == declared_pos.col-1
			return {
		\		"funcname" : func_name,
		\		"lnum" : declared_pos.lnum,
		\		"col" : declared_pos.col,
		\		"filename" : header
		\	}
		endif
	endfor

	return {}
endfunction


function! clang_declared#open(open_cmd, filename, lnum, col)
	echo "Search declared..."
	let declared = clang_declared#search(expand("%"), getpos(".")[1], getpos(".")[2])
	if empty(declared)
		echo "Not found"
		return
	endif
	if a:filename != declared.filename
		execute a:open_cmd." ".substitute(declared.filename, "\\", "/", "g")
	endif
	
	call cursor(declared.lnum, declared.col)
endfunction


let &cpo = s:save_cpo
