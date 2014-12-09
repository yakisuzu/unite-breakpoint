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

  " [['1', 'file', 'XXX', 'gyo', 'YY'], ['2', 'func', 'AAA', 'gyo', 'BB']]
  let li_result = map(
        \ split(st_result, '\n'),
        \ 'split(v:val, "\\s\\+")')

  if len(li_result) == 1 && len(li_result[0]) == 1
    " no breakpoint
    return []
  endif

  let nu_no_len = len(max(map(copy(li_result), 'v:val[0]')))
  let nu_row_no_len = len(max(map(copy(li_result), 'v:val[4]')))
  let st_fmt = '%'. nu_no_len. 'd:[L%0'. nu_row_no_len. 'd] %s'

  let li_return = []
  for li_row in li_result
    let st_no = li_row[0]
    let nu_is_file = li_row[1] == 'file'
    let st_file = li_row[2]
    let st_row_no = li_row[4]

    let di_row = {}
    let di_row.word = printf(st_fmt, st_no, st_row_no, st_file)
    " TODO: make kind to jump of function
    let di_row.kind = nu_is_file ? 'jump_list' : 'common'
    let di_row.action__path = st_file
    let di_row.action__line = st_row_no
    call add(li_return, di_row)
  endfor

  return li_return
endfunction "}}}

" TODO: sort
" TODO: preview

let &cpo = s:save_cpo
unlet s:save_cpo

