<h1>
  deferred-clipboard.nvim
  <a href="https://github.com/EtiamNullam/deferred-clipboard.nvim/tags" alt="Latest SemVer tag">
    <img src="https://img.shields.io/github/v/tag/EtiamNullam/deferred-clipboard.nvim" />
  </a>
</h1>

## Overview

This plugin synchronizes the clipboard of your operating system with [`Neovim`](https://neovim.io)'s unnamed register (`"`), while avoiding the [performance issue of `clipboard=unnamed` and `clipboard=unnamedplus`](https://github.com/neovim/neovim/issues/11804).

It works both ways so you can `y`ank something in `Neovim` to be available in your OS, but also copy something in your OS and `p`ut in `Neovim`.


The content of system clipboard will also be written to the unnamed register (`"`) on `.setup()` if its empty, and read from unnamed register (`"`) just before `Neovim` exits, so your latest yank won't be lost even if your client doesn't support focus change events.

### [Vim](https://www.vim.org)

Apparently the performance issue is specific to `Neovim` and does not apply to `Vim`.

## Requirements

- `Neovim >= 0.7.0`
- `Neovim` client which supports both focus change events - `FocusGained` and `FocusLost`

## Installation

Use your favorite package manager. For example [`vim-plug`](https://github.com/junegunn/vim-plug):

```vimscript
Plug 'EtiamNullam/deferred-clipboard.nvim'
```

## Usage

### Fallback (Recommended)

```lua
vim.o.clipboard = 'unnamedplus' -- or your preferred setting for clipboard

require('deferred-clipboard').setup()
```

The continuous clipboard sync (`clipboard=unnamed*`) will be automatically disabled when support for focus change events is detected in your terminal or `Neovim` client, but will be left untouched otherwise.

### Lazy

You can use `lazy` option, off by default, to improve startup time by delaying access of system clipboard. Make sure to disable it if you run into any trouble, for example if you load `shada` on launch but still want the clipboard to be loaded into unnamed register (`"`).

```lua
require('deferred-clipboard').setup {
  lazy = true,
}
```

### Basic

```lua
require('deferred-clipboard').setup()
```

It is required to call `setup()` to start the plugin, which will load the system clipboard to the unnamed register (`"`), hook up focus change events and disable continuous clipboard sync if it's enabled.

Calling it with no arguments will use default settings.

## Known issues

- Won't trigger when `cmdline` is open/busy
