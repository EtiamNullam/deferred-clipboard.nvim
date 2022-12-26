# deferred-clipboard.nvim

## Overview

Provides an alternative for sharing of the clipboard between your operating system and [`Neovim`](https://neovim.io) while avoiding the performance issue of `clipboard=unnamed` and `clipboard=unnamedplus`. It delays synchronization between the `unnamed` register and the operating system's clipboard until focus change or `Neovim` exit.

Apparently the problem is specific to `Neovim` and does not apply to `Vim`.

See more details and track the status of the issue: https://github.com/neovim/neovim/issues/11804

## Requirements

- `Neovim`
- Your `Neovim` client has to support focus change events (`FocusGained` and `FocusLost`)

## Installation

Use your favorite package manager. For example [`vim-plug`](https://github.com/junegunn/vim-plug):

```vimscript
Plug 'EtiamNullam/deferred-clipboard.nvim'
```

## Usage

```lua
vim.o.clipboard = nil

require('deferred-clipboard').setup()
```

## Known issues

- Won't trigger when `cmdline` is open/busy
