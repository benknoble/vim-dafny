setlocal expandtab
setlocal shiftwidth=2 softtabstop=2

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
if !empty(b:undo_ftplugin)
  let b:undo_ftplugin .= '|'
endif
let b:undo_ftplugin .= 'setlocal expandtab< shiftwidth< softtabstop<'
