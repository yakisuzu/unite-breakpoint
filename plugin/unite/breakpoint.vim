let s:save_cpo = &cpo
set cpo&vim

command! BreakToggle call s:break_toggle()
command! -nargs=* -complete=file
      \ BreakaddFile call s:breakadd_file(<f-args>)
command! -nargs=1 -complete=function
      \ BreakaddFunc call s:breakadd_func(<q-args>)
command! -nargs=*
      \ Breakdel call s:breakdel(<q-args>)

function! s:break_toggle() "{{{
  for di_break in unite#sources#breakpoint#get_breaklist()
    if fnamemodify(di_break.name, ':p') == expand('%:p')
          \ && di_break.line_no == line('.')
      call s:breakdel(di_break.break_no)
      return 0
    endif
  endfor
  call s:breakadd_file()
endfunction "}}}
function! s:breakadd_file(...) "{{{
  let li_cmd = ['breakadd', 'file']
  if a:0 == 2
    let li_cmd = li_cmd + a:000
  elseif a:0 == 1
    let li_cmd = li_cmd + ['1', a:1]
  elseif a:0 == 0
    let li_cmd = li_cmd + [line('.'), expand('%:p')]
  else
    echomsg 'args count is fail'
    return 1
  endif

  try
    exe join(li_cmd)
  catch /.*/
    echo 'breakadd is fail'
  endtry
endfunction "}}}
function! s:breakadd_func(st_arg) "{{{
  let st_func = substitute(a:st_arg, '(.*$', '', '')
  let li_cmd = ['breakadd', 'func', st_func]
  try
    exe join(li_cmd)
  catch /.*/
    echo 'breakadd is fail'
  endtry
endfunction "}}}
function! s:breakdel(st_arg) "{{{
  let li_cmd = ['breakdel', empty(a:st_arg) ? 'here' : a:st_arg]
  try
    exe join(li_cmd)
  catch /.*/
    echo 'breakdel is fail'
  endtry
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

