"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - INTEGRATIONS/LIGHTLINE
"
" About: Represents integration point into the lightline plugin.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! over_there#integrations#lightline#apply()
  " TODO: Figure out how to tap into lightline events to update bar similar
  "       to how ALE does it
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
