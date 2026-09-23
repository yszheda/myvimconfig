" Keep :LspDefinition reliable while lsp-settings and language servers initialize.
if exists('g:loaded_compass_lsp_definition')
  finish
endif
let g:loaded_compass_lsp_definition = 1

function! CompassLspProjectRoot() abort
  let l:gitdir = finddir('.git', expand('%:p:h') . ';')
  if !empty(l:gitdir)
    return fnamemodify(l:gitdir, ':h')
  endif
  let l:gitfile = findfile('.git', expand('%:p:h') . ';')
  return !empty(l:gitfile) ? fnamemodify(l:gitfile, ':h') : getcwd()
endfunction

function! CompassLspProjectRootUri(server_info) abort
  return exists('*lsp#utils#path_to_uri')
        \ ? lsp#utils#path_to_uri(CompassLspProjectRoot())
        \ : ''
endfunction

function! CompassLspActivate(...) abort
  if exists('*lsp#enable')
    silent! call lsp#enable()
  endif
  if exists('*lsp#activate')
    silent! call lsp#activate()
  endif
endfunction

augroup compass_lsp_autostart
  autocmd!
  autocmd User lsp_register_server call timer_start(0, function('CompassLspActivate'))
  autocmd FileType c,cpp,cuda,python call timer_start(0, function('CompassLspActivate'))
augroup END

function! CompassLspEnsurePythonServer() abort
  if &filetype !=# 'python' || !exists('*lsp#register_server')
    return
  endif

  let l:candidates = ['basedpyright-langserver', 'pyright-langserver', 'jedi-language-server', 'pylsp']
  if exists('*lsp#get_server_names')
    for l:server in l:candidates
      if index(lsp#get_server_names(), l:server) >= 0
        return
      endif
    endfor
  endif

  let l:server_name = ''
  let l:cmd = []
  if exists('*lsp_settings#filetype_servers')
    let l:configured = lsp_settings#filetype_servers('python')
    if !empty(l:configured)
      let l:server_name = l:configured[0]
      if exists('*lsp_settings#server_command')
        let l:cmd = lsp_settings#server_command(l:server_name)
      endif
    endif
  endif

  if empty(l:cmd)
    for l:server in l:candidates
      if !exists('*lsp_settings#executable') || !lsp_settings#executable(l:server)
        continue
      endif
      let l:server_name = l:server
      if exists('*lsp_settings#server_command')
        let l:cmd = lsp_settings#server_command(l:server)
      endif
      if empty(l:cmd) && exists('*lsp_settings#exec_path')
        let l:executable = lsp_settings#exec_path(l:server)
        if !empty(l:executable)
          let l:cmd = [l:executable, '--stdio']
        endif
      endif
      if !empty(l:cmd)
        break
      endif
    endfor
  endif

  if empty(l:server_name) || empty(l:cmd)
    return
  endif

  call lsp#register_server({
        \ 'name': l:server_name,
        \ 'cmd': l:cmd,
        \ 'root_uri': function('CompassLspProjectRootUri'),
        \ 'initialization_options': v:null,
        \ 'allowlist': ['python'],
        \ 'blocklist': [],
        \ 'config': exists('*lsp_settings#server_config') ? lsp_settings#server_config(l:server_name) : {},
        \ 'workspace_config': {'python': {'analysis': {'useLibraryCodeForTypes': v:true}}},
        \ 'semantic_highlight': {},
        \ })
endfunction

function! CompassLspDefinitionFallback() abort
  if index(['python', 'asm'], &filetype) < 0
    return 0
  endif

  let l:word = expand('<cword>')
  if empty(l:word)
    return 0
  endif

  let l:root = CompassLspProjectRoot()
  let l:files = [fnamemodify(expand('%:p'), ':p')]
  if &filetype ==# 'python'
    call extend(l:files, globpath(l:root, '**/*.py', 0, 1))
    let l:patterns = [
          \ '^\s*\%(def\|class\)\s\+' . escape(l:word, '\') . '\>',
          \ '^\s*' . escape(l:word, '\') . '\s*=',
          \ ]
  else
    call extend(l:files, globpath(l:root, '**/*.s', 0, 1))
    call extend(l:files, globpath(l:root, '**/*.asm', 0, 1))
    let l:patterns = [
          \ '^\s*' . escape(l:word, '\') . '\s*:',
          \ '^\s*\.globl\s\+' . escape(l:word, '\') . '\>',
          \ ]
  endif

  let l:seen = []
  for l:file in l:files
    let l:file = fnamemodify(l:file, ':p')
    if index(l:seen, l:file) >= 0 || !filereadable(l:file)
      continue
    endif
    call add(l:seen, l:file)
    let l:lines = readfile(l:file)
    for l:index in range(0, len(l:lines) - 1)
      if !empty(filter(copy(l:patterns), 'l:lines[l:index] =~# v:val'))
        execute 'edit ' . fnameescape(l:file)
        let l:column = match(l:lines[l:index], '\V' . escape(l:word, '\')) + 1
        call cursor(l:index + 1, max([1, l:column]))
        echo 'Retrieved project fallback definition'
        return 1
      endif
    endfor
  endfor
  return 0
endfunction

function! CompassLspDefinitionServers(bufnr) abort
  if !exists('*lsp#get_allowed_servers')
    return []
  endif
  return lsp#get_allowed_servers(a:bufnr)
endfunction

function! CompassLspDefinitionReady(bufnr) abort
  if !exists('*lsp#capabilities#has_definition_provider') || !exists('*lsp#get_server_status')
    return []
  endif
  let l:ready = []
  for l:server in CompassLspDefinitionServers(a:bufnr)
    if lsp#get_server_status(l:server) ==# 'running'
          \ && lsp#capabilities#has_definition_provider(l:server)
      call add(l:ready, l:server)
    endif
  endfor
  return l:ready
endfunction

function! CompassLspDefinitionPump(state, timer) abort
  if !bufexists(a:state.bufnr) || bufnr('%') != a:state.bufnr
    return
  endif

  if exists('*lsp#enable')
    silent! call lsp#enable()
  endif
  if exists('*CompassLspEnsurePythonServer')
    silent! call CompassLspEnsurePythonServer()
  endif

  let l:servers = CompassLspDefinitionServers(a:state.bufnr)
  if empty(l:servers) && CompassLspDefinitionFallback()
    return
  endif

  " The project loader may register a server after the initial FileType event.
  " Activate again whenever the current buffer has no running server.
  let l:activate = empty(l:servers)
  if !l:activate && exists('*lsp#get_server_status')
    for l:server in l:servers
      if index(['not running', 'exited', 'failed'], lsp#get_server_status(l:server)) >= 0
        let l:activate = 1
        break
      endif
    endfor
  endif
  if l:activate && exists('*lsp#activate')
    silent! call lsp#activate()
  endif

  if !empty(CompassLspDefinitionReady(a:state.bufnr))
    call setpos('.', a:state.position)
    call lsp#ui#vim#definition(0)
    return
  endif

  if a:state.retry >= 300
    let l:status = exists('*lsp#get_server_status') ? lsp#get_server_status() : 'unknown'
    echohl WarningMsg
    echomsg 'LSP definition server is not ready (' . l:status . '). Run :LspStatus and retry :LspDefinition.'
    echohl None
    return
  endif

  let l:next = copy(a:state)
  let l:next.retry += 1
  call timer_start(100, function('CompassLspDefinitionPump', [l:next]))
endfunction

function! CompassLspDefinition() abort
  let l:state = {'bufnr': bufnr('%'), 'position': getpos('.'), 'retry': 0}
  call timer_start(0, function('CompassLspDefinitionPump', [l:state]))
endfunction

command! -bar LspDefinition call CompassLspDefinition()
