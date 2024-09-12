if exists("c3c")
  finish
endif
let current_compiler = "c3c"
CompilerSet makeprg=c3c

let s:cpo_save = &cpo
set cpo-=C

setlocal errorformat=(%f:%l:%c)\ %m

let &cpo = s:cpo_save
unlet s:cpo_save

"vim: ft=vim
