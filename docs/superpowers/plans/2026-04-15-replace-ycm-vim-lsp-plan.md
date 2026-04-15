# Replace Bloated Vim Plugins with vim-lsp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove 13 redundant/old vim plugins and replace with a modern vim-lsp + asyncomplete stack for LSP-based code intelligence.

**Architecture:** vim-lsp as the LSP client, asyncomplete.vim + asyncomplete-lsp.vim for async completion UI, vim-lsp-settings for automatic LSP server installation. All plugins managed by existing vim-pathogen via git submodules.

**Tech Stack:** Vim script, git submodules, vim-lsp, asyncomplete.vim, clangd (C/C++/CUDA/OpenCL), pyright (Python).

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `.gitmodules` | Modify | Remove 13 submodule entries, add 4 new ones |
| `bundle/` directories | Delete 13, Add 4 | Plugin directories (git submodule rm/add) |
| `vimrc` | Modify | Remove old config blocks (lines 146-266), add LSP config |
| `bundle/vim-lsp/` | Create | LSP client plugin (new submodule) |
| `bundle/asyncomplete.vim/` | Create | Completion framework (new submodule) |
| `bundle/asyncomplete-lsp.vim/` | Create | vim-lsp → asyncomplete bridge (new submodule) |
| `bundle/vim-lsp-settings/` | Create | Auto-install LSP servers (new submodule) |

---

### Task 1: Remove 13 plugin submodules

**Files:**
- Modify: `.gitmodules` — remove 13 submodule entries
- Delete: 13 directories under `bundle/`

Remove these plugins from git submodule tracking and delete their directories:

```bash
cd /c/Users/shuyua01/.vim

# Remove 13 plugins: clang_complete, OmniCppComplete, snipMate, taglist,
# Trinity, checksyntax, CmdlineComplete, SearchComplete, a, omlet,
# FencView, DoxygenToolkit, fcitx
for plugin in clang_complete OmniCppComplete snipMate taglist Trinity \
  checksyntax CmdlineComplete SearchComplete a omlet FencView \
  DoxygenToolkit fcitx; do
  git submodule deinit -f "bundle/$plugin" 2>/dev/null || true
  git rm -f "bundle/$plugin"
  rm -rf ".git/modules/bundle/$plugin" 2>/dev/null || true
done
```

After running the above, verify `.gitmodules` no longer contains these 13 entries and the directories are gone from `bundle/`:

```bash
ls bundle/
# Expected remaining: c, nerdtree, ultisnips, VimWiki, vim-bufexplorer, vim-pathogen, php.vim
```

- [ ] **Commit the removal**

```bash
git commit -m "chore: remove 13 redundant plugins replaced by vim-lsp

Removed: clang_complete, OmniCppComplete, snipMate, taglist, Trinity,
checksyntax, CmdlineComplete, SearchComplete, a, omlet, FencView,
DoxygenToolkit, fcitx"
```

---

### Task 2: Add 4 new plugin submodules

**Files:**
- Modify: `.gitmodules` — add 4 new submodule entries
- Create: `bundle/vim-lsp/`, `bundle/asyncomplete.vim/`, `bundle/asyncomplete-lsp.vim/`, `bundle/vim-lsp-settings/`

Add the new plugins as git submodules:

```bash
cd /c/Users/shuyua01/.vim

git submodule add https://github.com/prabirshrestha/vim-lsp bundle/vim-lsp
git submodule add https://github.com/prabirshrestha/asyncomplete.vim bundle/asyncomplete.vim
git submodule add https://github.com/prabirshrestha/asyncomplete-lsp.vim bundle/asyncomplete-lsp.vim
git submodule add https://github.com/mattn/vim-lsp-settings bundle/vim-lsp-settings
```

Verify all 4 submodules are registered and cloned:

```bash
git submodule status
# Should show 4 new entries + the remaining old ones
ls bundle/vim-lsp/autoload/lsp.vim          # Should exist
ls bundle/asyncomplete.vim/autoload/asyncomplete.vim  # Should exist
ls bundle/asyncomplete-lsp.vim/plugin/asyncomplete-lsp.vim  # Should exist
ls bundle/vim-lsp-settings/autoload/lsp_settings.vim  # Should exist
```

- [ ] **Commit the additions**

```bash
git commit -m "feat: add vim-lsp, asyncomplete, and vim-lsp-settings plugins

vim-lsp: LSP client
asyncomplete.vim: async completion framework
asyncomplete-lsp.vim: bridge vim-lsp to asyncomplete
vim-lsp-settings: auto-install and configure LSP servers"
```

---

### Task 3: Rewrite vimrc — remove old config blocks

**Files:**
- Modify: `vimrc` — remove lines 146-283 (Taglist, Encoding/FencView, Do_CsTag/cscope, DoxygenToolkit, LaTeX section, header guard autocmd, C_SourceCodeExtensions, Windows font/encoding, VimWiki)

The current vimrc has these sections to remove. Match by content/comments (line numbers are from the original file for reference):

**Remove block 1 — Taglist (original lines 146-160):**
```vim
" Tag list (ctags)
" added by ys
" 2011-7-21
map <F3> :silent! Tlist<CR>
if g:iswindows==1
  let Tlist_Ctags_Cmd = 'ctags'
else
  let Tlist_Ctags_Cmd = '/usr/bin/ctags'
endif
let Tlist_Show_One_File = 1
let Tlist_File_Fold_Auto_Close = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1
let Tlist_Process_File_Always = 0
let Tlist_Inc_Winwidth = 0
```

**Remove block 2 — FencView (original lines 182-183):**
```vim
let g:fencview_autodetect = 0
map <F2> :FencView<CR>
```

**Remove block 3 — Do_CsTag/cscope function (original lines 188-251):**
```vim
" added by ys
" 2011-8-4
" reference: Vimer's blogs
map <F11> :call Do_CsTag()<CR>
... (the entire Do_CsTag function through endfunction)
```

**Remove block 4 — DoxygenToolkit (original lines 254-266):**
```vim
" added by ys
" 2011-8-6
" reference: Vimer's blogs
" DoxygenToolkit
map fg : Dox<cr>
let g:DoxygenToolkit_authorName="Shuai Yuan"
let g:DoxygenToolkit_licenseTag="My own license\<enter>"
let g:DoxygenToolkit_undocTag="DOXIGEN_SKIP_BLOCK"
let g:DoxygenToolkit_briefTag_pre = "@brief\t"
let g:DoxygenToolkit_paramTag_pre = "@param\t"
let g:DoxygenToolkit_returnTag = "@return\t"
let g:DoxygenToolkit_briefTag_funcName = "no"
let g:DoxygenToolkit_maxFunctionProtoLines = 30
```

**Remove block 5 — LaTeX section (original lines 268-286):**
```vim
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
filetype plugin on

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" OPTIONAL: This enables automatic indentation as you type.
filetype indent on

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'
```

**Remove block 6 — Header guard autocmd + C extensions + Windows settings (original lines 290-317):**

Remove the `s:insert_gates()` function and autocmd (lines 290-297), the `C_SourceCodeExtensions` line (299), and the Windows-specific block (lines 301-317).

**Remove block 7 — Redundant `filetype plugin indent on` and `filetype plugin on`/`filetype indent on`:**
Line 100 already has `filetype plugin indent on`. The LaTeX section redundantly does `filetype plugin on` and `filetype indent on` again — already being removed as part of block 5.

After all removals, the vimrc should contain: basic settings (original lines 1-144) + VimWiki section (original lines 319-321) + the new LSP config from Task 4.

- [ ] **Commit the cleanup**

```bash
git commit -am "chore: remove old plugin config blocks from vimrc

Removed taglist, FencView, Do_CsTag/cscope, DoxygenToolkit,
LaTeX-specific settings, header guard autocmd"
```

---

### Task 4: Add LSP configuration to vimrc

**Files:**
- Modify: `vimrc` — append LSP config block at the end of the file (after the VimWiki section)

Append this block to the end of `vimrc`:

```vim
" ============================================================================
" LSP Configuration (vim-lsp + asyncomplete + vim-lsp-settings)
" ============================================================================

" LSP keymaps
nnoremap <silent> gd :<C-u>LspDefinition<CR>
nnoremap <silent> gD :<C-u>LspDeclaration<CR>
nnoremap <silent> gr :<C-u>LspReferences<CR>
nnoremap <silent> <leader>rn :<C-u>LspRename<CR>
nnoremap <silent> K :<C-u>LspHover<CR>
nnoremap <silent> <leader>ca :<C-u>LspCodeAction<CR>
nnoremap <silent> <F3> :NERDTreeToggle<CR>

" LSP diagnostics
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1

" asyncomplete completion settings
set completeopt=menuone,noinsert,noselect
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 1
let g:asyncomplete_popup_delay = 0

" Filetype mappings for CUDA and OpenCL -> cpp (so clangd handles them)
augroup lsp_filetype_mappings
  autocmd!
  autocmd BufNewFile,BufRead *.cu,*.cuh set filetype=cpp
  autocmd BufNewFile,BufRead *.cl set filetype=cpp
augroup END

" LSP server configuration via vim-lsp-settings
" clangd for C/C++/CUDA/OpenCL
let g:lsp_settings = {
\   'clangd': {
\     'cmdline': ['clangd', '--background-index', '--clang-tidy'],
\     'whitelist': ['c', 'cpp', 'cuda', 'opencl'],
\   },
\   'pyright': {
\     'whitelist': ['python'],
\   },
\}

" Allow vim-lsp-settings to auto-install servers
let g:lsp_settings_enable_suggestions = 1
```

Key explanations:
- `gd` → go to definition (replaces ctags jump)
- `gr` → find references (replaces cscope)
- `<leader>rn` → rename symbol (new LSP capability)
- `K` → hover documentation (replaces manual lookup)
- `<leader>ca` → code actions (new LSP capability)
- `<F3>` → NERDTreeToggle (was taglist, now file explorer)
- CUDA (`.cu`/`.cuh`) and OpenCL (`.cl`) mapped to `cpp` filetype so clangd provides completions

- [ ] **Verify vimrc syntax**

```bash
vim -es -u vimrc -c 'q' 2>&1
# Should exit without errors. If errors appear, fix them.
```

- [ ] **Commit the LSP config**

```bash
git commit -am "feat: add vim-lsp + asyncomplete configuration to vimrc

LSP keymaps: gd=definition, gr=references, K=hover, <leader>rn=rename,
<leader>ca=codeaction, F3=NERDTree
Filetype mappings: .cu/.cuh/.cl -> cpp for clangd support
LSP servers: clangd (C/C++/CUDA/OpenCL), pyright (Python)"
```

---

### Task 5: Remove vim-bufexplorer (unused) and update gitmodules

**Files:**
- Modify: `.gitmodules` — remove vim-bufexplorer entry
- Delete: `bundle/vim-bufexplorer/`

The spec keeps 5 plugins: vim-pathogen, nerdtree, ultisnips, VimWiki, c/c-support. vim-bufexplorer is not in the "keep" list. Also remove php.vim which is a stray submodule not in bundle/.

```bash
cd /c/Users/shuyua01/.vim

git submodule deinit -f "bundle/vim-bufexplorer" 2>/dev/null || true
git rm -f "bundle/vim-bufexplorer"
rm -rf ".git/modules/bundle/vim-bufexplorer" 2>/dev/null || true

git submodule deinit -f "php.vim" 2>/dev/null || true
git rm -f "php.vim"
rm -rf ".git/modules/php.vim" 2>/dev/null || true
```

- [ ] **Commit the removal**

```bash
git commit -m "chore: remove vim-bufexplorer and php.vim submodules"
```

---

### Task 6: Final state verification and squash review

**Files:**
- Read: `vimrc`, `.gitmodules`
- Check: `bundle/` directory listing

Verify the final state matches the design spec:

```bash
# 1. Verify bundle/ contains exactly these 9 entries:
#    c, nerdtree, ultisnips, VimWiki, vim-pathogen,
#    vim-lsp, asyncomplete.vim, asyncomplete-lsp.vim, vim-lsp-settings
ls bundle/

# 2. Verify .gitmodules has no references to removed plugins
grep -E "clang_complete|OmniCppComplete|snipMate|taglist|Trinity|checksyntax|CmdlineComplete|SearchComplete|fcitx|FencView|DoxygenToolkit|vim-bufexplorer|php\.vim" .gitmodules
# Should return nothing

# 3. Verify vimrc doesn't reference removed plugins
grep -iE "Tlist|DoxygenToolkit|fencview|Do_CsTag|cscope" vimrc
# Should return nothing

# 4. Verify vimrc has LSP config
grep -c "LspDefinition\|asyncomplete\|lsp_settings" vimrc
# Should be > 0

# 5. Check git log for clean history
git log --oneline -10
```

If everything checks out, the work is complete. The user should:
1. Open gvim
2. Run `:LspInstallServer` to install clangd and pyright LSP servers
3. Open a `.c`/`.cpp`/`.cu`/`.cl`/`.py` file and verify LSP features work
