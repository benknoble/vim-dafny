if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

setlocal smartindent
setlocal indentexpr=dafny#indentexpr(v:lnum)
setlocal indentkeys-=:
setlocal indentkeys-=0#
setlocal indentkeys+==function,=method,=predicate,=lemma
setlocal indentkeys+==requires,=ensures
setlocal indentkeys+=0===,0=<,0=>,0=!=,0=<=,0=>=
setlocal indentkeys+=0=<==>,0=<==,0===>

let b:undo_indent = get(b:, 'undo_indent', '')
if !empty(b:undo_indent)
  let b:undo_indent .= '|'
endif
let b:undo_indent .= 'setlocal smartindent< indentexpr< indentkeys<'
