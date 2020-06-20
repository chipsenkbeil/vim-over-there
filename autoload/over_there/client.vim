"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OVER THERE - CLIENT
"
" About: Represents an OOP-based client API to spawn and talk to an instance
"        of the `over-there` binary running as a client.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ensure that all VimL uses standard option set to maintain consistency
let s:save_cpo = &cpoptions
set cpoptions&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CONSTRUCTOR

" Creates a new instance of the client inside vim without attempting to connect
function! over_there#client#new() abort
  return copy(s:self)
endfunction

let s:self = {}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PUBLIC METHODS

" Attempt to connect by spawning a client instance of the `over-there` binary,
" returning connected client
function! s:self.connect() dict abort
  " Fail to connect if already running
  if self.is_running()
    throw 'Client is already running and cannot connect again!'
  endif

  " If the binary isn't available, fail early
  if !over_there#utils#has_binary()
    throw 'Binary unavailable!'
  endif

  " Clear out the previous internal information
  call self._clear()

  " Launch the client, running interactively (to send/receive multiple msgs)
  " and in meta mode so we can attach additional information such as callback
  " IDs for responses
  let l:job_id = jobstart([
  \     'over-there', 'client', self.host().':'.self.port(),
  \     'raw', '-i', '-m',
  \ ], self)

  if l:job_id > 0
    let self._running = 1
    let self._job_id = l:job_id
    let self._callbacks = {}
  else
    throw 'Failed to launch job: '.l:job_id
  endif

  return self
endfunction

" Sends the provided content, invoking a different callback based on receiving
" a positive reply or negative reply
function! s:self.send(type, payload, on_ok, on_err) dict abort
  " Fail early if client is not running
  if !self.is_running()
    throw 'Unable to send as client is not running!'
  endif

  let l:callback_id = over_there#utils#gen_unique_id()

  " Register our callbacks that will process replies
  let self._callbacks[l:callback_id] = {
  \ 'on_ok': a:on_ok,
  \ 'on_err': a:on_err,
  \ }

  let l:msg = {
  \ 'metadata': {
  \     'callback_id': l:callback_id,
  \ },
  \ 'content': {
  \     'type': a:type,
  \     'payload': a:payload,
  \ },
  \ }

  call chansend(self.job_id(), json_encode(l:msg))
endfunction

" Kills the client's job and resets state
function! s:self.shutdown() dict abort
  let l:job_id = self.job_id()
  if l:job_id > 0
    call jobstop(l:job_id)
  endif
endfunction

" Returns whether or not the client is currently running
function! s:self.is_running() dict abort
  return get(self, '_running')
endfunction

" Returns the ID of the job associated with a running client
function! s:self.job_id() dict abort
  return self._job_id
endfunction

" Returns the host associated with this client instance
function! s:self.host() dict abort
  return self._host
endfunction

" Sets the host for this client instance and returns updated client instance
function! s:self.set_host(host) dict abort
  " Only update the host if the client is not running
  if self.is_running()
    throw 'Cannot update host while client is running!'
  endif

  let self._host = a:host
  return self
endfunction

" Returns the port associated with this client instance
function! s:self.port() dict abort
  return self._port
endfunction

" Sets the port for this client instance and returns updated client instance
function! s:self.set_port(port) dict abort
  " Only update the port if the client is not running
  if self.is_running()
    throw 'Cannot update port while client is running!'
  endif

  let self._port = a:port
  return self
endfunction

" Sets a custom callback to use when this client exits
"
" exit_callback takes two arguments: client, exit_code
function! s:self.set_exit_callback(callback) dict abort
  " Only update the callback if the client is not running
  if self.is_running()
    throw 'Cannot update exit callback while client is running!'
  endif

  let self._exit_callback = a:callback
  return self
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INTERNAL METHODS

" [Internal] Processes a line of output from the client as a msg and invokes
" associated callbacks
function! s:self._process_line(line) dict abort
  " Assume that binary is good and gives us JSON back all the time
  let l:msg = json_decode(a:line)

  " Determine the ID associated with callbacks
  let l:callback_id = get(get(l:msg, 'metadata', {}), 'callback_id', -1)

  " If we have a callback ID and matching callback, process msg
  if l:callback_id > -1 && has_key(self._callbacks, l:callback_id)
    let l:callback = self._callbacks[l:callback_id]

    " If the msg is an error, invoke the error callback
    if l:msg.type ==# 'error_reply' && has_key(l:callback, 'on_err')
      call callback.on_err(l:msg.payload)

    " Otherwise, invoke the success callback
    elseif has_key(l:callback, 'on_ok')
      call callback.on_ok(l:msg.payload)
    endif
  endif
endfunction

" [Internal] Clears internal state of client
function! s:self._clear() dict abort
  let self._job_id = 0
  let self._callbacks = {}
  let self._running = 0
  let self._stdout_lines = []
  let self._stderr_lines = []
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EVENT HANDLERS

" Event handler for stdout received from client
function! s:self.on_stdout(job_id, data, event) dict abort
  let l:eof = (a:data == [''])

  " Complete previous line (first item does not reflect a newline
  let self._stdout_lines[-1] .= a:data[0]

  " Append to internal state, where last item may be a partial line until EOF
  " NOTE: All remaining items (except last) have a newline following
  call extend(self._stdout_lines, a:data[1:])

  " Process all but the last line
  if len(self._stdout_lines) > 1
    " Remove all but last line
    let l:complete_lines = remove(self._stdout_lines, 0, -2)

    " For each line, treat it as a new msg
    for l:line in l:complete_lines
      try
        call self._process_line(l:line)
      catch
        echom 'Process line failed: '.v:exception
      endtry
    endfor
  endif

  " Unless we're EOF, then process the last line
  if l:eof && len(self._stdout_lines) > 0
    try
      call self._process_line(self._stdout_lines[0])
    catch
      echom 'Process line failed: '.v:exception
    endtry
  endif
endfunction

" Event handler for stderr received from client
function! s:self.on_stderr(job_id, data, event) dict abort
  let l:eof = (a:data == [''])

  " Complete previous line
  let self._stderr_lines[-1] .= a:data[0]

  " Append to internal state, where last item may be a partial line until EOF
  " NOTE: All remaining items (except last) have a newline following
  call extend(self._stderr_lines, a:data[1:])

  " Process all but the last line
  if len(self._stderr_lines) > 1
    " Remove all but last line
    let l:complete_lines = remove(self._stderr_lines, 0, -2)

    " For each line, treat it as a new msg
    for l:line in l:complete_lines
      echoerr l:line
    endfor
  endif

  " Unless we're EOF, then process the last line
  if l:eof && len(self._stderr_lines) > 0
    echoerr self._stderr_lines[0]
  endif
endfunction

" Event handler for job exiting
function! s:self.on_exit(job_id, data, event) dict abort
  " TODO: Handle any remaining information in stdout/stderr?
  "
  " TODO: Check if we want to auto-restart on error? Would need to check the
  "       exit code (in a:data) to determine if natural shutdown.
  "
  " If standard exit code, normal number
  " If signal, 128+SIGNUM such as 128+15=143 for SIGTERM (15)
  let l:exit_code = a:data

  " If callback provided, will invoke
  if has_key(self, '_exit_callback')
    call self._exit_callback(self, l:exit_code)
  endif

  call self._clear()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Restore VI-compatible behavior configured by user
let &cpoptions = s:save_cpo
unlet s:save_cpo
