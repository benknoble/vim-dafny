setlocal expandtab
setlocal shiftwidth=2 softtabstop=2

setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//%s

setlocal suffixesadd=.dfy
setlocal include=^\\s*include
setlocal includeexpr=dafny#includeexpr(v:fname)
let &l:define = printf('^\s*\(%s\)',
      \ join([
      \   'var',
      \   'function',
      \   'method',
      \   'predicate',
      \   'lemma',
      \   'type',
      \   'datatype',
      \   'newtype',
      \ ], '\|'))

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
if !empty(b:undo_ftplugin)
  let b:undo_ftplugin .= '|'
endif
let b:undo_ftplugin .= 'setlocal expandtab< shiftwidth< softtabstop<'
let b:undo_ftplugin .= ' | setlocal comments< commentstring<'
let b:undo_ftplugin .= ' | setlocal suffixesadd< include< includeexpr< define<'
