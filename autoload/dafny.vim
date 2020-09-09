function dafny#includeexpr(fname) abort
  return trim(a:fname, '"')
endfunction

const s:decl_pat = '^\s*\(function\|method\|predicate\|lemma\)'
const s:first_line_pat = '\%1l'
const s:contract_pattern = '^\s*\(requires\|ensures\)'
const s:full_contract_pattern = '^\s*\(returns\|requires\|modifies\|ensures\)'
const s:block_stopping_pattern = '^\s*\({\|if\|while\)'

function s:indent(lnum, offset) abort
  return a:lnum <= 0
        \ ? indent('.')
        \ : indent(a:lnum) + a:offset
endfunction

function s:find_prev_pat(pat, stoppat) abort
  const stopline = search(a:stoppat, 'bnW')
  return search(a:pat, 'bnW', stopline)
endfunction

function s:find_prev_decl() abort
  return s:find_prev_pat(s:decl_pat, s:first_line_pat)
endfunction

function s:find_prev_while() abort
  return s:find_prev_pat('^\s*while', s:decl_pat)
endfunction

function s:find_prev_bullet(bullet) abort
  " dont search on the same line as the bullet
  -1
  let result = s:find_prev_pat(printf('^\s*%s', a:bullet),
        \ printf('\(%s\)\|\(%s\)', s:contract_pattern, s:block_stopping_pattern))
  +1
  return result
endfunction

function s:find_prev_contract() abort
  return s:find_prev_pat(s:contract_pattern,
        \ printf('\(%s\)\|\(%s\)', s:decl_pat, s:block_stopping_pattern))
endfunction

function s:find_prev_class() abort
  return s:find_prev_pat('^\s*class', s:first_line_pat)
endfunction

function s:find_correct_nested_open_brace() abort
  return searchpair('{', '', '}', 'bnW')
endfunction

function dafny#indentexpr(lnum) abort
  if a:lnum is# 0 || a:lnum is# 1
    return 0
  endif
  const line = getline(a:lnum)
  if line =~# s:decl_pat
    let prev_decl = s:find_prev_decl()
    if prev_decl isnot# 0
      return indent(prev_decl)
    else
      return s:indent(s:find_prev_class(), &l:shiftwidth)
    endif
  elseif line =~# s:full_contract_pattern
    return s:indent(s:find_prev_decl(), &l:shiftwidth)
  elseif line =~# '^\s*invariant'
    return s:indent(s:find_prev_while(), &l:shiftwidth)
  elseif line =~# '^\s*decreases'
    let prev_indent = s:find_prev_while()
    if prev_indent is# 0
      let prev_indent = s:find_prev_decl()
    endif
    return s:indent(prev_indent, &l:shiftwidth)
  elseif line =~# '^\s*||'
    let prev_indent = s:find_prev_bullet('||')
    if prev_indent isnot# 0
      return s:indent(prev_indent, 0)
    else
      return s:indent(s:find_prev_contract(), &l:shiftwidth)
    endif
  elseif line =~# '^\s*&&'
    let prev_indent = s:find_prev_bullet('&&')
    if prev_indent isnot# 0
      return s:indent(prev_indent, 0)
    else
      return s:indent(s:find_prev_contract(), &l:shiftwidth)
    endif
  elseif line =~# '^\s*}'
    call cursor('.', 1)
    return s:indent(s:find_correct_nested_open_brace(), 0)
  else
    return s:indent(s:find_correct_nested_open_brace(), &l:shiftwidth)
  endif
endfunction
