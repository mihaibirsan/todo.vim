if exists("b:current_syntax")
  finish
endif

syn match Category /\v^\>\>.*/
syn match TodoCompleted /\v^((  )*)✓.*(\n\1  .*)*/
syn match TodoPostponed /\v^((  )*)\~.*(\n\1  .*)*/
syn match TodoDiscarded /\v^((  )*)✗.*(\n\1  .*)*/
syn match TodoNext /\v^((  )*)→.*/
syn match TodoSoon /\v^((  )*)⇨.*/
syn match TodoAdded /\v^((  )*)[⇨→✓✗~]?\+.*(\n\1  .*)*/
syn match TodoRemoved /\v^((  )*)[⇨→✓✗~]?\-.*(\n\1  .*)*/
syn match TodoExpandedBelow /\v^((  )*)[⇨→✓✗~]?\@.*(\n\1  .*)*/
syn match TodoTag /\v(^|\s)@<=\@[a-z0-9-]+>/

if !exists('main_syntax')
  let main_syntax = 'todo'
endif
syn include @MD syntax/markdown.vim
unlet b:current_syntax
syn region markdownSnip matchgroup=Category start=/\v^\>\>\s*##.*/ end=/\v\n\ze\>\>/ contains=@MD keepend

syn sync fromstart
let b:current_syntax = "todo"

