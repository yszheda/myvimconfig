# Design: Replace Bloated Vim Plugins with vim-lsp

**Date:** 2026-04-15
**Author:** Claude Code
**Status:** Draft — awaiting user review

## Problem

The current vim configuration has 21 plugins in `bundle/`, many of which are old, unmaintained, or redundant. Completion is handled by a pile of overlapping plugins (clang_complete + OmniCppComplete + snipMate + UltiSnips) that slow startup and provide inferior features compared to modern LSP. Code navigation relies on ctags/cscope instead of true semantic analysis.

## Goals

1. **Modern IDE features** — go-to-definition, references, rename, hover docs, diagnostics via LSP
2. **Simplify maintenance** — replace 13 redundant/old plugins with a single LSP stack
3. **Fast startup** — vim-lsp + asyncomplete are lightweight vimscript plugins

## Approach

**Approach A** — vim-lsp + vim-lsp-settings + asyncomplete.vim, minimal plugin count.

- Plugin manager: vim-pathogen (existing)
- Version control: git in `C:\Users\shuyua01\.vim` (existing repo)

## Plugin Inventory

### Remove (13 plugins)

| Plugin | Reason |
|--------|--------|
| `clang_complete` | Replaced by clangd via vim-lsp |
| `OmniCppComplete` | Replaced by LSP completion |
| `snipMate` | Duplicate of UltiSnips |
| `taglist` | Replaced by LSP document symbols |
| `Trinity` | Wrapper for taglist + others being removed |
| `checksyntax` | Replaced by LSP diagnostics |
| `CmdlineComplete` | Vim built-in completion suffices |
| `SearchComplete` | Vim built-in completion suffices |
| `a` | Unknown utility, likely unused |
| `omlet` | Unknown utility, likely unused |
| `FencView` | UTF-8 defaults make this unnecessary |
| `DoxygenToolkit` | LSP doc comments + UltiSnips cover this |
| `fcitx` | No longer needed |

### Keep (5 plugins)

| Plugin | Reason |
|--------|--------|
| `vim-pathogen` | Plugin manager |
| `nerdtree` | File tree explorer |
| `ultisnips` | Snippet engine |
| `VimWiki` | Personal wiki |
| `c/c-support` | C/C++ templates and snippets |

### Add (4 plugins)

| Plugin | Purpose |
|--------|---------|
| `prabirshrestha/vim-lsp` | LSP client |
| `prabirshrestha/asyncomplete.vim` | Async completion framework |
| `prabirshrestha/asyncomplete-lsp.vim` | Bridge vim-lsp to asyncomplete |
| `mattn/vim-lsp-settings` | Auto-install & configure LSP servers |

## LSP Server Configuration

| Language | Filetypes | LSP Server | Notes |
|----------|-----------|------------|-------|
| C | `c` | clangd | Auto-installed by vim-lsp-settings |
| C++ | `cpp` | clangd | Auto-installed by vim-lsp-settings |
| CUDA | `cu`, `cuh` | clangd | Mapped to `cpp` filetype |
| OpenCL | `cl` | clangd | Mapped to `cpp` filetype |
| Python | `python` | pyright | Auto-installed by vim-lsp-settings |

## vimrc Changes

### Blocks to Add

1. **vim-lsp + asyncomplete registration** — register servers for each language
2. **Filetype mappings** — `.cu`/`.cuh`/`.cl` → `cpp` filetype
3. **Completion trigger** — asyncomplete on `.` and keyword
4. **LSP keymaps** — definition, references, rename, hover

### Blocks to Remove

- Taglist section (F3 mapping, all `Tlist_*` variables)
- DoxygenToolkit section (fg mapping, all `g:DoxygenToolkit_*` variables)
- Trinity references
- Any clang_complete / OmniCppComplete settings
- `ctags` / `cscope` `Do_CsTag()` function (F11 mapping)
- FencView section (F2 mapping, `g:fencview_autodetect`)

### Key Remapping

| Old | New |
|-----|-----|
| F3 → taglist | F3 → NERDTree (file explorer) |
| F11 → Do_CsTag() | Remove — use `:LspDefinition` / `:LspReferences` |
| F2 → FencView | Remove |
| fg → Dox | Remove |

## Implementation Order

1. Remove 13 plugin directories from `bundle/`
2. `git submodule add` to register 4 new plugins into `bundle/` (matching existing repo's submodule pattern)
3. Edit vimrc — remove old blocks, add LSP blocks
4. Test: open a C file, verify clangd starts, completion works, go-to-def works
5. Test: open a Python file, verify pyright starts
6. Commit all changes
