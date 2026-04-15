# vim-lsp Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps using checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace 28 bloated plugins (YCM, syntastic, UltiSnips, etc.) with vim-lsp + vim-lsp-settings + vim-vsnip, reducing plugin count from 31 to 4.

**Architecture:** vim-pathogen manages plugins from `bundle/` directory. vim-lsp provides LSP client, vim-lsp-settings auto-manages LSP servers (clangd for C/C++/CUDA, pylsp for Python), vim-vsnip provides snippet engine with LSP integration. vimrc is rewritten to remove old plugin configs and add LSP registration.

**Tech Stack:** Vim 9.1, vim-pathogen, vim-lsp, vim-lsp-settings, vim-vsnip

---

### Task 1: Remove old plugin submodules from .gitmodules and bundle/

**Files:**
- Modify: `.gitmodules`
- Delete: 28 plugin directories under `bundle/`

- [ ] **Step 1: Remove all submodule entries except vim-pathogen from .gitmodules**

Rewrite `.gitmodules` to contain only the vim-pathogen submodule entry:

```gitmodules
[submodule "bundle/vim-pathogen"]
	path = bundle/vim-pathogen
	url = https://github.com/tpope/vim-pathogen.git
```

Command:
```bash
cd /home/lighthouse/.vim
# Remove all submodule entries except vim-pathogen
git config -f .gitmodules --remove-section submodule.bundle/nerdtree
git config -f .gitmodules --remove-section submodule.bundle/vim-latex
git config -f .gitmodules --remove-section submodule.bundle/c
git config -f .gitmodules --remove-section submodule.bundle/a
git config -f .gitmodules --remove-section submodule.bundle/FencView
git config -f .gitmodules --remove-section submodule.bundle/DoxygenToolkit
git config -f .gitmodules --remove-section submodule.bundle/fcitx
git config -f .gitmodules --remove-section submodule.bundle.omlet
git config -f .gitmodules --remove-section submodule.bundle/OmniCppComplete
git config -f .gitmodules --remove-section submodule.bundle/ultisnips
git config -f .gitmodules --remove-section submodule.bundle/taglist
git config -f .gitmodules --remove-section submodule.bundle/checksyntax
git config -f .gitmodules --remove-section submodule.bundle/CmdlineComplete
git config -f .gitmodules --remove-section submodule.bundle/SearchComplete
git config -f .gitmodules --remove-section submodule.bundle/vim-bufexplorer
git config -f .gitmodules --remove-section submodule.bundle/Trinity
git config -f .gitmodules --remove-section submodule.bundle/snipMate
git config -f .gitmodules --remove-section submodule.bundle/octopress
git config -f .gitmodules --remove-section submodule.bundle/clang_complete
git config -f .gitmodules --remove-section submodule.bundle/VimWiki
git config -f .gitmodules --remove-section submodule.bundle/phpvim
git config -f .gitmodules --remove-section submodule.bundle/vim-jsbeautify
git config -f .gitmodules --remove-section submodule.bundle/python-mode
git config -f .gitmodules --remove-section submodule.bundle/vim-lua-ftplugin
git config -f .gitmodules --remove-section submodule.bundle/vim-misc
git config -f .gitmodules --remove-section submodule.bundle/YouCompleteMe
git config -f .gitmodules --remove-section submodule.bundle/molokai
git config -f .gitmodules --remove-section submodule.bundle/syntastic
git config -f .gitmodules --remove-section submodule.bundle/ag
git config -f .gitmodules --remove-section submodule.bundle/ack
```

- [ ] **Step 2: Deinit and remove all old submodules from git**

```bash
cd /home/lighthouse/.vim
for sub in nerdtree vim-latex c a FencView DoxygenToolkit fcitx omlet OmniCppComplete ultisnips taglist checksyntax CmdlineComplete SearchComplete vim-bufexplorer Trinity snipMate octopress clang_complete VimWiki phpvim vim-jsbeautify python-mode vim-lua-ftplugin vim-misc YouCompleteMe molokai syntastic ag ack; do
    git submodule deinit -f "bundle/$sub" 2>/dev/null
    git rm -f "bundle/$sub" 2>/dev/null || rm -rf "bundle/$sub"
done
```

- [ ] **Step 3: Remove any remaining bundle directories**

```bash
cd /home/lighthouse/.vim
rm -rf bundle/nerdtree bundle/vim-latex bundle/c bundle/a bundle/FencView bundle/DoxygenToolkit bundle/fcitx bundle/omlet bundle/OmniCppComplete bundle/ultisnips bundle/taglist bundle/checksyntax bundle/CmdlineComplete bundle/SearchComplete bundle/vim-bufexplorer bundle/Trinity bundle/snipMate bundle/octopress bundle/clang_complete bundle/VimWiki bundle/phpvim bundle/vim-jsbeautify bundle/python-mode bundle/vim-lua-ftplugin bundle/vim-misc bundle/YouCompleteMe bundle/molokai bundle/syntastic bundle/ag bundle/ack
# Verify only vim-pathogen remains
ls bundle/
# Expected output: vim-pathogen
```

- [ ] **Step 4: Verify .gitmodules contains only vim-pathogen**

```bash
cd /home/lighthouse/.vim
cat .gitmodules
# Should contain only:
# [submodule "bundle/vim-pathogen"]
#     path = bundle/vim-pathogen
#     url = https://github.com/tpope/vim-pathogen.git
```

- [ ] **Step 5: Commit**

```bash
cd /home/lighthouse/.vim
git add .gitmodules bundle/
git commit -m "chore: remove 28 unused plugin submodules"
```

Expected: Clean commit removing all old plugin entries.

---

### Task 2: Add vim-lsp, vim-lsp-settings, vim-vsnip as submodules

**Files:**
- Modify: `.gitmodules` (new entries added by git submodule add)
- Create: `bundle/vim-lsp/`
- Create: `bundle/vim-lsp-settings/`
- Create: `bundle/vim-vsnip/`

- [ ] **Step 1: Add vim-lsp submodule**

```bash
cd /home/lighthouse/.vim
git submodule add https://github.com/prabirshrestha/vim-lsp.git bundle/vim-lsp
```

- [ ] **Step 2: Add vim-lsp-settings submodule**

```bash
cd /home/lighthouse/.vim
git submodule add https://github.com/mattn/vim-lsp-settings.git bundle/vim-lsp-settings
```

- [ ] **Step 3: Add vim-vsnip submodule**

```bash
cd /home/lighthouse/.vim
git submodule add https://github.com/hrsh7th/vim-vsnip.git bundle/vim-vsnip
```

- [ ] **Step 4: Verify all three submodules exist and have content**

```bash
cd /home/lighthouse/.vim
ls bundle/
# Expected: vim-pathogen vim-lsp vim-lsp-settings vim-vsnip
ls bundle/vim-lsp/plugin/lsp.vim bundle/vim-lsp-settings/plugin/lsp_settings.vim bundle/vim-vsnip/plugin/vsnip.vim
# All should exist
```

- [ ] **Step 5: Commit**

```bash
cd /home/lighthouse/.vim
git add .gitmodules bundle/vim-lsp bundle/vim-lsp-settings bundle/vim-vsnip
git commit -m "feat: add vim-lsp, vim-lsp-settings, vim-vsnip plugins"
```

Expected: Clean commit adding new LSP plugin submodules.

---

### Task 3: Rewrite vimrc - remove old plugin configs

**Files:**
- Modify: `vimrc`

- [ ] **Step 1: Remove all plugin-specific config blocks**

Remove these sections from `vimrc` (keep only core vim settings):

1. **Lines 149-159** (Taglist config): `map <F3> :silent! Tlist<CR>`, all `Tlist_*` settings
2. **Lines 161-182** (Encoding + FencView): Keep `set fileencodings=utf-8,gbk` and `let termencoding = &encoding`, remove FencView `g:fencview_autodetect` and `map <F2>`
3. **Lines 184-249** (cscope tag functions): Remove `map <F11>`, all `nmap <C-@>` cscope mappings, and `function! Do_CsTag() ... endfunction`
4. **Lines 252-264** (DoxygenToolkit): Remove `map fg`, all `g:DoxygenToolkit_*` settings
5. **Lines 266-284** (vim-latex): Remove `filetype plugin on`, `set shellslash`, `set grepprg=`, `filetype indent on`, `let g:tex_flavor='latex'`
6. **Lines 289-298** (Header guards): Remove `function! s:insert_gates()`, `autocmd BufNewFile`, `let g:C_SourceCodeExtensions`
7. **Lines 300-302** (VimWiki): Remove `g:vimwiki_use_mouse`, `g:vimwiki_list`
8. **Lines 307-317** (jsbeautify): Remove all `g:jsbeautify_engine` lines
9. **Lines 319-360** (InsertHeadDef): Remove `function InsertHeadDef`, `function InsertHeadDefN`, `nmap ,ha`
10. **Lines 362-373** (YCM config): Remove all `g:ycm_*`, `g:clang_*` lines

After removal, the remaining vimrc should contain:
- Header comment (lines 1-11)
- `set nocompatible` (line 13-15)
- pathogen setup (lines 17-19)
- Windows detection (lines 21-30)
- `autocmd BufEnter * lcd %:p:h` (line 30)
- evim check (lines 32-35)
- backspace settings (lines 37-39)
- backup settings (lines 41-45)
- history, ruler, showcmd, incsearch (lines 46-49)
- tab settings (lines 51-62)
- guioptions comment (line 64-65)
- `map Q gq` (line 68)
- `inoremap <C-U>` (line 72)
- mouse settings (lines 74-87)
- syntax on + hlsearch (lines 89-94)
- autocmd group vimrcEx (lines 96-128)
- DiffOrig command (lines 130-136)
- mapleader + reload mappings (lines 138-147)
- `set nu` (line 287, keep this)
- `colorscheme elflord` (line 305, keep this)
- Encoding basics: `let termencoding = &encoding`, `set fileencodings=utf-8,gbk`

- [ ] **Step 2: Test vim starts without errors**

```bash
cd /home/lighthouse/.vim
vim -u vimrc -es -c 'redir! > /tmp/vim_test.txt' -c 'messages' -c 'redir END' -c 'q!' 2>&1
cat /tmp/vim_test.txt
# Expected: No errors, exit code 0
```

- [ ] **Step 3: Commit**

```bash
cd /home/lighthouse/.vim
git add vimrc
git commit -m "chore: remove old plugin configs from vimrc"
```

Expected: Clean commit. Vim should start without any E117 errors.

---

### Task 4: Add vim-lsp configuration to vimrc

**Files:**
- Modify: `vimrc`

- [ ] **Step 1: Add vim-lsp server registration after pathogen setup**

Add this block after `call pathogen#infect()` (line 19) in `vimrc`:

```vim
" vim-lsp configuration
if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp', 'cuda', 'opencl'],
        \ })
endif

if executable('pylsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
        \ })
endif

" Enable LSP diagnostics (replaces syntastic)
let g:lsp_diagnostics_enabled = 1

" Enable text edits from LSP server
let g:lsp_text_edit_enabled = 1

" vim-vsnip integration with LSP
let g:vsnip_filetypes = {}

" Autocomplete: accept completion with Enter
if exists('*complete_info')
    inoremap <expr> <cr> complete_info().selected != -1 ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" LSP key mappings
nnoremap <silent> <leader>ld <cmd>call lsp#show_line_diagnostics()<CR>
nnoremap <silent> <leader>lf <cmd>call lsp#show_float_diagnostics()<CR>
nnoremap <silent> <leader>la <cmd>call lsp#show_code_action()<CR>
nnoremap <silent> <leader>lr <cmd>call lsp#rename()<CR>
nnoremap <silent> <leader>lh <cmd>call lsp#peek_definition()<CR>
nnoremap <silent> <leader>gd <cmd>call lsp#definition()<CR>
nnoremap <silent> <leader>gr <cmd>call lsp#references()<CR>
nnoremap <silent> <leader>gi <cmd>call lsp#implementation()<CR>
nnoremap <silent> <leader>gt <cmd>call lsp#type_definition()<CR>
```

- [ ] **Step 2: Test vim starts without errors**

```bash
cd /home/lighthouse/.vim
vim -u vimrc -es -c 'redir! > /tmp/vim_test.txt' -c 'messages' -c 'redir END' -c 'q!' 2>&1
cat /tmp/vim_test.txt
# Expected: No errors, exit code 0
```

- [ ] **Step 3: Commit**

```bash
cd /home/lighthouse/.vim
git add vimrc
git commit -m "feat: add vim-lsp server registration and key mappings"
```

Expected: Clean commit. Vim should start without errors (clangd/pylsp may not be installed yet, but the `executable()` checks prevent errors).

---

### Task 5: Install LSP servers and verify

**Files:**
- System: clangd (via apt)
- System: pylsp (via pip)

- [ ] **Step 1: Install clangd**

```bash
apt list --installed 2>/dev/null | grep clangd
# If not installed:
sudo apt-get install -y clangd 2>&1 || echo "clangd installation attempted (may need sudo)"
```

- [ ] **Step 2: Install pylsp**

```bash
pip3 list 2>/dev/null | grep python-lsp-server
# If not installed:
pip3 install python-lsp-server 2>&1
```

- [ ] **Step 3: Verify servers are executable**

```bash
which clangd && clangd --version
which pylsp && pylsp --version
```

- [ ] **Step 4: Test vim loads LSP servers**

```bash
cd /home/lighthouse/.vim
vim -u vimrc -es -c 'redir! > /tmp/vim_lsp_test.txt' -c 'messages' -c 'redir END' -c 'q!' 2>&1
cat /tmp/vim_lsp_test.txt
# Expected: No errors
```

---

### Task 6: Final cleanup and push

**Files:**
- All modified files

- [ ] **Step 1: Verify final state**

```bash
cd /home/lighthouse/.vim
echo "=== Bundle contents ==="
ls bundle/
echo "=== Git status ==="
git status
echo "=== vimrc line count ==="
wc -l vimrc
```

Expected:
- Bundle: `vim-pathogen vim-lsp vim-lsp-settings vim-vsnip`
- Only uncommitted changes should be from this session's work
- vimrc should be significantly shorter (was 374 lines)

- [ ] **Step 2: Verify vim startup one final time**

```bash
cd /home/lighthouse/.vim
vim -u vimrc -es -c 'redir! > /tmp/vim_final.txt' -c 'messages' -c 'redir END' -c 'q!' 2>&1
echo "Exit code: $?"
cat /tmp/vim_final.txt
# Expected: Exit 0, no error messages
```

- [ ] **Step 3: Push to remote**

```bash
cd /home/lighthouse/.vim
git push origin master
```

Expected: All commits pushed to origin/master.
