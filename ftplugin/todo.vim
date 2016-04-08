setlocal shiftwidth=2
setlocal tabstop=2

hi link Category StatusLine
hi TodoCompleted guifg=#666666
hi TodoPostponed guifg=#663300
hi TodoDiscarded guifg=#993333
hi link TodoNext Todo
hi TodoSoon term=standout ctermfg=229 ctermbg=16 guifg=#FFFABC guibg=#1F1E16
" TODO: Fix the ctermfg for the TodoTag
hi TodoAdded guifg=#5EB1FF
hi TodoRemoved guifg=#FF5E71
hi TodoExpandedBelow guifg=#A1FF9E
hi TodoTag term=standout ctermfg=229 ctermbg=16 guifg=#A1FF9E guibg=#151F14

let g:sectionBegin = '^\ze>>'
let g:sectionEnd = '\n\ze>>\|\%$'

" see http://learnvimscriptthehardway.stevelosh.com/chapters/51.html
" see http://learnvimscriptthehardway.stevelosh.com/chapters/50.html
function! s:NextSection(type, backwards, visual)
    if a:visual
        normal! gv
    endif

    if a:type == 1
        let pattern = g:sectionBegin
        let flags = 'e'
    elseif a:type == 2
        let pattern = g:sectionEnd
        let flags = ''
    endif

    if a:backwards
        let dir = '?'
    else
        let dir = '/'
    endif

    execute 'silent normal! ' . dir . pattern . dir . flags . "\r"
endfunction
noremap <script> <buffer> <silent> ]] :call <SID>NextSection(1, 0, 0)<cr>
noremap <script> <buffer> <silent> [[ :call <SID>NextSection(1, 1, 0)<cr>
noremap <script> <buffer> <silent> ][ :call <SID>NextSection(2, 0, 0)<cr>
noremap <script> <buffer> <silent> [] :call <SID>NextSection(2, 1, 0)<cr>
vnoremap <script> <buffer> <silent> ]] :<c-u>call <SID>NextSection(1, 0, 1)<cr>
vnoremap <script> <buffer> <silent> [[ :<c-u>call <SID>NextSection(1, 1, 1)<cr>
vnoremap <script> <buffer> <silent> ][ :<c-u>call <SID>NextSection(2, 0, 1)<cr>
vnoremap <script> <buffer> <silent> [] :<c-u>call <SID>NextSection(2, 1, 1)<cr>

" move entire section
function! s:MoveSection(dir)
    let l:winview = winsaveview()
    if a:dir < 0
        " Move current section before the previous section, or the the end of file
        let [ l:startlnum, l:devnull ] = searchpos(g:sectionBegin, 'cbW')
        let [ l:endlnum, l:devnull ] = searchpos(g:sectionEnd, 'n')
        let [ l:newlnum, l:devnull ] = searchpos(g:sectionBegin, 'bw')
        let l:newlnum = l:newlnum - 1
    else
        " Move current section after the next section, or at the beginning of file
        let [ l:startlnum, l:devnull ] = searchpos(g:sectionBegin, 'cbW')
        let [ l:endlnum, l:devnull ] = searchpos(g:sectionEnd, '')
        let [ l:newlnum, l:devnull ] = searchpos(g:sectionEnd, 'w')
    endif
    call winrestview(l:winview)

    let l:cursor = getpos(".")
    let l:cursor[1] = l:cursor[1] - l:startlnum + l:newlnum + 1
    if (l:newlnum > l:startlnum)
        let l:cursor[1] = l:cursor[1] - (l:endlnum - l:startlnum + 1)
    endif

    execute l:startlnum . ',' . l:endlnum . 'm' . l:newlnum
    call setpos(".", l:cursor)
endfunction
nnoremap <script> <buffer> <silent> <A-S-Up> :call <SID>MoveSection(-1)<cr>
nnoremap <script> <buffer> <silent> <A-S-Down> :call <SID>MoveSection(1)<cr>

" TODO: see http://blog.carbonfive.com/2011/10/17/vim-text-objects-the-definitive-guide/
" TODO: syn region CategoryGroup start=/^>>/ end=/\n\ze>>/

setlocal nonumber
hi clear SignColumn
hi link SignColumn Normal
sign define Category linehl=StatusLine texthl=StatusLine text=>>

let g:high_ind = 0
fun! IncHighlightInd()
    let g:high_ind = g:high_ind + 1
    return g:high_ind
endf
nmap <buffer> <silent> <F1> :silent sign place <C-R>=IncHighlightInd()<CR> name=Category line=<C-R>=line(".")<CR> file=<C-R>=expand("%:p")<CR><CR>
nmap <buffer> <silent> <C-F1> :silent sign unplace<CR>

fu! ToggleMark(mark, otherPossibleMarks)
    let line = getline(".")
    if match(line, '\v^(  )+') == 0
        let whitespaceMatcher = '\v^((  )+)[' . a:otherPossibleMarks . '] '
        let whitespaceNormal = '\v^((  )+)\* '
        if match(line, whitespaceMatcher) == 0
            call setline(".", substitute(line, whitespaceMatcher, '\1* ', ''))
            " normal ^dl
        elseif match(line, whitespaceNormal) == 0
            call setline(".", substitute(line, whitespaceNormal, '\1' . a:mark . ' ', ''))
            " setreg('.', a:mark)
            " normal ^cl<c-r>.<esc>
        endif
        return
    end

    if match(line, '^[' . a:otherPossibleMarks . ']') == 0
        call setline(".", line[3:])
    else
        call setline(".", a:mark . line)
    endif
endf

nmap <buffer> <silent> <CR> :call ToggleMark('✓', '✓✗~→⇨')<CR>
nmap <buffer> <silent> <C-CR> :call ToggleMark('✗', '✓✗~→⇨')<CR>
nmap <buffer> <silent> <C-X> :call ToggleMark('⇨', '✓✗~→⇨')<CR>
nmap <buffer> <silent> <C-N> :call ToggleMark('→', '✓✗~→⇨')<CR>

" TODO: Move categories

" Find next tasks

fu! LineCompare(i1, i2)
    " trim strings
    let c1 = substitute(a:i1, '\v^\s+', '', '')
    let c2 = substitute(a:i2, '\v^\s+', '', '')

    " pick the sortables
    let c1 = c1[0:byteidx(c1, 1)-1] . printf("%6s", matchlist(c1, '|\(.\+\)|')[1])
    let c2 = c2[0:byteidx(c2, 1)-1] . printf("%6s", matchlist(c2, '|\(.\+\)|')[1])
    echo c1 . " || " . c2
    return c1 < c2 ? -1 : (c1 > c2 ? 1 : 0)
endf

fu! NextTasks()
    let b:nextTasks = []
    g/\v^(  )*[⇨→].+$/echo add(b:nextTasks, getline(".") . "|" . line(".") . "|" . bufname("%"))
    echo sort(b:nextTasks, "LineCompare")
    noh
    set efm=%m\|%l\|%f
    lexpr! join(b:nextTasks, "\n")
    lopen
    setlocal nowrap
endf

nmap <buffer> <silent> <F5> :silent call NextTasks()<CR>
nmap <buffer> <silent> <C-Up> :silent lp<CR>
nmap <buffer> <silent> <C-Down> :silent lne<CR>

" Make the regions folding; everything below a Category should fold together;
" the fold message should be the next task for that Category, as follows: the
" first task marked with an arrow (considering arrow priorities), or the first
" task that's not completed

fu! FoldExpr()
    let line = getline(v:lnum)
    " Categories and empty lines aren't folding
    if match(line, '\v^\>\>') == 0 || match(line, '\v^$') == 0
        return 0
    endif
    " Completed tasks fold deeper than non-completed tasks
    if match(line, '\v^✓') == 0
        return 2
    end
    " to make the previous line work, indented lines (subtasks and notes)
    " follow the folding of their oldest ancestor
    if match(line, '\v^\s') == 0
        return '='
    end
    " everything else folds
    return 1
endf
fu! FoldText()
    " TODO: When all tasks in a fold are completed, create a summary of
    " completed tasks (eg. "5 tasks completed")
    let nextAction = ""
    let nextActionPriority = -1
    let resolved = [ '✓', '✗' ]
    let priority = [ '*', '⇨', '→' ]
    let completedDepth = -1
    for i in range(v:foldstart, v:foldend)
        let depth = strlen(matchstr(getline(i), '\v^\s+'))/2

        " skip sub-tasks if the parent is completed
        if completedDepth > -1 && depth > completedDepth
            continue
        else
            let completedDepth = -1
        end

        let task = substitute(getline(i), '\v^\s+', '', '')
        let firstByte = task[0:byteidx(task, 1)-1]
        if index(resolved, firstByte) < 0
            let taskPriority = index(priority, firstByte)
            if taskPriority < 0
                let taskPriority = 0
            endif
        else
            let taskPriority = -1
            let completedDepth = depth
        endif
        if taskPriority > nextActionPriority
            " some formatting
            if taskPriority == 0
            else
                let task = firstByte . ' ' . substitute(task[byteidx(task, 1):], '\v^\s+', '', '')
            endif

            let nextAction = task
            let nextActionPriority = taskPriority
        endif
    endfor
    return nextAction
endf

setlocal foldmethod=expr
setlocal foldexpr=FoldExpr()
setlocal foldtext=FoldText()

setlocal wrap linebreak showbreak=\ \ \ \ 

" re-place all signs
silent execute ":sign unplace * file=" . expand("%:p")
silent g/^>>/execute "normal \<F1>" | noh | normal gg

