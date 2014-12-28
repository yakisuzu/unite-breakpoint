let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#breakpoint#define() "{{{
  return s:di_source
endfunction "}}}
function! unite#sources#breakpoint#get_breaklist() "{{{
  " Get breaklist
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

  return map(li_result, '{
        \   "break_no": get(v:val, 0, 0)
        \ , "is_file": get(v:val, 1, "") == "file"
        \ , "name": get(v:val, 2, "")
        \ , "line_no": get(v:val,  4, 0)
        \ }')
endfunction "}}}

let s:di_source = {
      \ 'name' : 'breakpoint',
      \ }

function! s:di_source.gather_candidates(args, context) "{{{
  let li_breaklist = unite#sources#breakpoint#get_breaklist()
  if empty(li_breaklist)
    return []
  endif

  let nu_break_no_len = len(max(map(copy(li_breaklist), 'v:val.break_no')))
  let nu_line_no_len = len(max(map(copy(li_breaklist), 'v:val.line_no')))
  let li_fmt = [
        \   '%s'
        \ , 'L%0'. nu_line_no_len. 'd'
        \ , 'B%0'. nu_break_no_len. 'd'
        \ , '(%s)'
        \ ]

  let li_candidates = []
  for di_break in li_breaklist
    let di_line = {}
    let di_line.word = printf(
          \   join(li_fmt)
          \ , fnamemodify(di_break.name, ':t')
          \ , di_break.line_no
          \ , di_break.break_no
          \ , fnamemodify(di_break.name, ':p')
          \ )
    " TODO: make kind to jump of function
    let di_line.kind = di_break.is_file ? 'jump_list' : 'common'
    let di_line.action__path = di_break.name
    let di_line.action__line = di_break.line_no
    call add(li_candidates, di_line)
  endfor

  let li_candidates = unite#util#sort_by(li_candidates
        \ , 'v:val.action__path . printf("%0' . nu_line_no_len . 'd", v:val.action__line)')

  return li_candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

