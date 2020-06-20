"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - PLUGIN
"
" About: Represents the plugin to integrate with `over-there`.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:private_loaded_over_there')
    finish
endif
let g:private_loaded_over_there = 1

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" NOTE: Imported from https://github.com/dense-analysis/ale/blob/master/plugin/ale.vim

" A flag for detecting if the required features are set.
if has('nvim')
    let s:has_features = has('timers') && has('nvim-0.2.0')
else
    " Check if Job and Channel functions are available, instead of the
    " features. This works better on old MacVim versions.
    let s:has_features = has('timers') && exists('*job_start') && exists('*ch_close_in')
endif

if !s:has_features
    " Only output a warning if editing some special files.
    if index(['', 'gitcommit'], &filetype) == -1
        execute 'echoerr ''vim-over-there requires NeoVim >= 0.2.0 or Vim 8 with +timers +job +channel'''
        execute 'echoerr ''Please update your editor appropriately.'''
    endif

    " Stop here, as it won't work.
    finish
endif

" Enable other plugins to play well with this one
let g:loaded_over_there = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: Provide shortcuts to API through commands like
"
"   command! -bar OverThereSync :call over_there#Sync()
"   command! -bar -nargs=* OverThereConnect :call over_there#Connect(<f-args>)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: Provide plug mappings to API like
"
"   nnoremap <silent> <Plug>(over_there_sync) :OverThereSync<Return>
"   nnoremap <silent> <Plug>(over_there_connect) :OverThereConnect<Return>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
