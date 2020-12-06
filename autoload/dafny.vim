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
  -1
  const stopline = search(a:stoppat, 'bnW')
  const result = search(a:pat, 'bnWc', stopline)
  +1
  return result
endfunction

function s:find_prev_decl() abort
  return s:find_prev_pat(s:decl_pat, s:first_line_pat)
endfunction

function s:find_prev_while() abort
  return s:find_prev_pat('^\s*while', s:decl_pat)
endfunction

function s:find_prev_bullet(bullet) abort
  return s:find_prev_pat(a:bullet,
        \ printf('\(%s\)\|\(%s\)', s:contract_pattern, s:block_stopping_pattern))
endfunction

function s:find_prev_contract() abort
  return s:find_prev_pat(s:contract_pattern,
        \ printf('\(%s\)\|\(%s\)', s:decl_pat, s:block_stopping_pattern))
endfunction

function s:find_correct_nested_open_brace() abort
  return searchpair('{', '', '}', 'bnW')
endfunction

function s:handle_bullet(bullet) abort
  let prev_brace = s:find_correct_nested_open_brace()
  let prev_bullet = s:find_prev_bullet(a:bullet)
  if prev_bullet isnot# 0
    return s:indent(prev_bullet, 0)
  elseif prev_brace isnot# 0
    return s:indent(prev_brace, shiftwidth())
  else
    return s:indent(s:find_prev_contract(), shiftwidth())
  endif
endfunction

function s:in_calc() abort
  return getline(s:find_correct_nested_open_brace()) =~# '^\s*calc'
endfunction

function s:find_prev_calc() abort
  call assert_true(s:in_calc())
  return s:find_correct_nested_open_brace()
endfunction

function dafny#indentexpr(lnum) abort
  if a:lnum is# 0 || a:lnum is# 1
    return 0
  endif
  const line = getline(a:lnum)
  if line =~# s:decl_pat
    let prev_brace = s:find_correct_nested_open_brace()
    if prev_brace isnot# 0
      return s:indent(prev_brace, shiftwidth())
    else
      return 0
    endif
  elseif line =~# s:full_contract_pattern
    return s:indent(s:find_prev_decl(), shiftwidth())
  elseif line =~# '^\s*invariant'
    return s:indent(s:find_prev_while(), shiftwidth())
  elseif line =~# '^\s*decreases'
    let prev_indent = s:find_prev_while()
    if prev_indent is# 0
      let prev_indent = s:find_prev_decl()
    endif
    return s:indent(prev_indent, shiftwidth())
  elseif line =~# '^\s*||'
    return s:handle_bullet('||')
  elseif line =~# '^\s*&&'
    return s:handle_bullet('&&')
  elseif line =~# '^\s*\(==\|<\|>\|!=\|<=\|>=\|<==>\|<==\|==>\)' && s:in_calc()
    return s:indent(s:find_prev_calc(), 0)
  elseif line =~# '^\s*}'
    call cursor('.', 1)
    return s:indent(s:find_correct_nested_open_brace(), 0)
  elseif line =~# '^\s*{'
    -1
    return s:indent(s:find_correct_nested_open_brace(), shiftwidth())
  else
    return s:indent(s:find_correct_nested_open_brace(), shiftwidth())
  endif
endfunction
