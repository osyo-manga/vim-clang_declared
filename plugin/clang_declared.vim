if exists('g:loaded_clang_declared')
  finish
endif
let g:loaded_clang_declared = 1

let s:save_cpo = &cpo
set cpo&vim


let g:clang_declared_c_index_test_cmd = get(g:, "clang_declared_c_index_test_cmd", "c-index-test.exe")
let g:clnag_declared_c_index_test_option = get(g:, "clang_declared_c_index_test_option", "")
let g:clang_declared_debug_mode = get(g:, "clang_declared_debug_mode", 0)


command! -nargs=0 ClangDeclaredOpen :call clang_declared#open("edit", expand("%"), getpos(".")[1], getpos(".")[2])

command! -nargs=0 ClangDeclaredOpenTabDrop :call clang_declared#open("tab drop", expand("%"), getpos(".")[1], getpos(".")[2])


let &cpo = s:save_cpo
unlet s:save_cpo
