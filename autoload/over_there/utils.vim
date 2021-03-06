"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - UTILS
"
" About: Represents utility functions for use throughout the plugin API.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Checks whether or not the `over-there` binary is available
function! over_there#utils#has_binary() abort
    return executable('over-there')
endfunction

" Produces a 32-bit unique id
function! over_there#utils#gen_unique_id() abort
    " Use maximum value of an unsigned 32-bit integer, which is what our
    " external program uses as the message ID
    return over_there#utils#random(4294967295)
endfunction

" From https://github.com/mhinz/vim-randomtag
"
" Generates a random number up to max integer specified using current time
" in microseconds to provide some form of randomness. This isn't necessarily
" a quality random function nor is it secure, but it's useful to get a number
" that is unique enough for callback IDs
function! over_there#utils#random(max) abort
  return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:]) % a:max
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
