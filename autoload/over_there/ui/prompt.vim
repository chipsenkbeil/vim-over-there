"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - UI/PROMPT
"
" About: Represents API to display a prompt with choices, select a choice, and
"        return the selection.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: Implement prompt so it can be used to select an existing connection
"       when opening a new file

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
