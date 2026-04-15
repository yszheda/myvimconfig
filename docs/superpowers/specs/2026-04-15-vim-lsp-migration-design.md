# vim-lsp Migration Design

**Date:** 2026-04-15
**Topic:** Replace YCM and bloated plugins with vim-lsp ecosystem

## Problem

Current vim plugin setup is bloated (~12M, ~10,000 commits across 31 plugins). Key issues:
- YouCompleteMe requires compilation, is heavy (2.0M, 3259 commits)
- Multiple overlapping plugins (YCM + clang_complete + OmniCppComplete all do completion)
- syntastic (2.2M) is outdated; LSP provides better diagnostics
- UltiSnips (5.7M) is the largest plugin; vim-vsnip is lighter
- Many plugins are unused (phpvim, octopress, Trinity, etc.)

## Goal

Replace YCM and overlapping plugins with vim-lsp ecosystem. Reduce plugin count from 31 to ~4 (vim-pathogen + vim-lsp + vim-lsp-settings + vim-vsnip). Target ~350K total plugin size.

## Removed Plugins (28 total)

| Plugin | Size | Reason |
|--------|------|--------|
| YouCompleteMe | 2.0M | Replaced by vim-lsp |
| syntastic | 2.2M | Replaced by vim-lsp diagnostics |
| clang_complete | 272K | Replaced by clangd via vim-lsp |
| OmniCppComplete | 216K | Replaced by clangd via vim-lsp |
| python-mode | 764K | Replaced by pylsp via vim-lsp |
| UltiSnips | 5.7M | Replaced by vim-vsnip |
| snipMate | 196K | Replaced by vim-vsnip |
| checksyntax | 436K | Replaced by vim-lsp diagnostics |
| Trinity | 152K | Unused cscope tag browser |
| taglist | 236K | Unused, replaced by vim-lsp navigation |
| DoxygenToolkit | 60K | Unused |
| FencView | 12K | Unused |
| vim-latex | 1.4M | Unused |
| ack | 76K | Redundant with ag |
| ag | 52K | Unused |
| c | 636K | Unused |
| a | 48K | Unused |
| vim-jsbeautify | 48K | Unused |
| phpvim | 112K | Unused (no PHP) |
| octopress | 52K | Unused blog plugin |
| vim-bufexplorer | 80K | Unused |
| CmdlineComplete | 28K | Unused |
| SearchComplete | 20K | Unused |
| omlet | 120K | Unused |
| vim-lua-ftplugin | 156K | Unused |
| vim-misc | 296K | Unused |
| molokai | 32K | Unused colorscheme (using elflord) |
| NERDTree | 552K | Unused |
| VimWiki | 376K | Unused |

**Total removed:** ~16M

## Added Plugins (3 total)

| Plugin | Size | Purpose |
|--------|------|---------|
| vim-lsp | ~200K | LSP client |
| vim-lsp-settings | ~100K | Auto-manage LSP servers |
| vim-vsnip | ~50K | Snippet engine + LSP integration |

**Total added:** ~350K

## Kept

- **vim-pathogen** (52K) — plugin manager

## vimrc Changes

### Removed sections
1. **YCM config** (old lines 362-367): `g:ycm_key_list_select_completion`, `g:clang_*`
2. **DoxygenToolkit** (old lines 256-264)
3. **Taglist** (old lines 152-159)
4. **FencView** (old lines 181-182)
5. **vim-latex** (old lines 266-284): `g:tex_flavor`, `shellslash`, etc.
6. **cscope tag functions** (old lines 187-249): `Do_CsTag()`, cscope mappings
7. **Header guard functions** (old lines 289-360): `InsertHeadDef*`, `insert_gates()`
8. **Header insertion function** (old lines 196-249)
9. **YCM config** (old lines 362-374)

### Added sections
```vim
" vim-lsp configuration
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'allowlist': ['c', 'cpp', 'cuda', 'opencl'],
        \ })
endif

if executable('pylsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
        \ })
endif

" Enable diagnostics (replaces syntastic)
let g:lsp_diagnostics_enabled = 1

" Completion settings
let g:lsp_text_edit_enabled = 1

" vim-vsnip settings
let g:vsnip_filetypes = {}

" Autocomplete setup
if exists('*complete_info')
    inoremap <expr> <cr> complete_info().selected != -1 ? "\<C-y>" : "\<C-g>u\<CR>"
endif
```

## Language Support

| Language | LSP Server | Features |
|----------|-----------|----------|
| C/C++ | clangd | completion, go-to-def, hover, diagnostics, rename |
| CUDA | clangd | partial (syntax + completion) |
| OpenCL | vim-lsp basic | diagnostics via linter fallback |
| Python | pylsp | completion, go-to-def, hover, diagnostics, formatting |

## LSP Server Installation

vim-lsp-settings will auto-install servers when first opened for a filetype:
- `:LspInstallServer` for clangd
- `:LspInstallServer` for pylsp

Alternatively, manual install:
- `apt install clangd` for clangd
- `pip install python-lsp-server` for pylsp

## Migration Steps

1. Remove all plugin submodules from `.gitmodules` and `bundle/`
2. Add vim-lsp, vim-lsp-settings, vim-vsnip as submodules
3. Rewrite vimrc: remove old plugin configs, add vim-lsp config
4. Initialize submodules
5. Test vim startup (no errors)
6. Commit and push

## Risk Mitigation

- Keep a backup of the old vimrc before rewriting
- Test with `vim -u vimrc -es -c 'q'` to verify no startup errors
- If vim-lsp fails, the old config is in git history for recovery
