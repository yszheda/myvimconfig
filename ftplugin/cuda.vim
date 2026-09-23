" Shared buffer setup for CUDA and Compass CPS files.

" CPS uses CUDA as its Vim filetype, so C++ snippets remain available.
if exists(':UltiSnipsAddFiletypes') == 2
  silent! UltiSnipsAddFiletypes cuda.cpp
endif

" Keep the native vim-lsp omnifunc available for Ctrl-X Ctrl-O completion.
if exists(':LspDefinition') == 2
  setlocal omnifunc=lsp#complete
endif
