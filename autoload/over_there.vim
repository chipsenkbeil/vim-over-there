"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - AUTOLOAD ENTRYPOINT
"
" About: Represents the entrypoint for the autoloaded portion of the over
"        there plugin for vim. Will import plugin APIs to interact with
"        the `over-there` binary.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:autoloaded_over_there')
    finish
endif
let g:autoloaded_over_there = 1

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GLOBAL CONFIG

" Contains all active clients by job id
let g:over_there_clients = {}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TOP-LEVEL API

" Launches a new instance of server on remote host,  and connects to it,
" returning the id associated with the client
function! over_there#launch(host, port, opts) abort
    return 0
endfunction

" Connects to a running instance of `over-there` using a locally-spawned
" client instance, returning the id associated with the client
function! over_there#connect(host, port, opts) abort
    let l:client = over_there#client#new()
    \ .set_host(a:host)
    \ .set_port(a:port)
    \ .set_exit_callback(function('s:over_there#exit_callback'))
    \ .connect()

    let l:id = l:client.job_id()
    g:over_there_clients[l:id] = l:client

    return l:id
endfunction

" Disconnects client with associated id
function! over_there#disconnect(client_id) abort
    if has_key(g:over_there_clients, a:client_id)
        let l:client = remove(g:over_there_clients, a:client_id)
        call l:client.shutdown()
    endif
endfunction

" Opens a file specified by filename (path to file) using client specified by
" id, creating a new buffer configured for remote editing
function! over_there#open_file(args) abort
    let l:client = get(g:over_there_clients, a:args.client_id)

endfunction

" Writes the contents of a buffer to the specified remote file
function! over_there#write_buffer_into_file(args) abort
    let l:client = get(g:over_there_clients, a:args.client_id)

endfunction

" Reads the contents of a remote file to the specified buffer
function! over_there#read_file_into_buffer(args) abort
    let l:client = get(g:over_there_clients, a:args.client_id)

endfunction

" Closes a file specified by filename (path to file) using client specified by
" id
function! over_there#close_file(args) abort
    let l:client = get(g:over_there_clients, a:args.client_id)

endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" [Internal] General logging callback when a client exits
function! s:over_there#exit_callback(client, exit_code) abort
    if a:exit_code > 0
        echoerr 'Client '.a:client.job_id().' exited with code '.a:exit_code
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
