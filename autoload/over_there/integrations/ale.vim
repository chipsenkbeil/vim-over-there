"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - INTEGRATIONS/ALE
"
" About: Represents integration point into the ALE plugin.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! over_there#integrations#ale#apply()
  " TODO: Find and inject into ALE buffer variables, wrapping the binaries
  "       with a call to `over-there client exec ...`
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
