let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#breakpoint#define() "{{{
  return s:di_source
endfunction "}}}


let s:di_source = {
      \ 'name' : 'breakpoint',
      \ }


function! s:di_source.gather_candidates(args, context) "{{{
  " Get command list.
  redir => st_result
  silent! breaklist
  redir END

  let li_result = map(
        \ split(st_result, '\n'),
        \ 'split(v:val, "\\s\\+")')
  call echomsg(string(li_result))

  return []
endfunction "}}}


"function! s:di_source.hooks.on_syntax(args, context)
"endfunction


"function! s:di_source.hooks.on_close(args, context)
"endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

