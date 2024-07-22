<h1>
  deferred-clipboard.nvim
  <a href="https://github.com/EtiamNullam/deferred-clipboard.nvim/tags" alt="Latest SemVer tag">
    <img src="https://img.shields.io/github/v/tag/EtiamNullam/deferred-clipboard.nvim" />
  </a>
</h1>

## Overview

This plugin synchronizes the clipboard of your operating system with [`Neovim`](https://neovim.io)'s unnamed register (`"`), while avoiding [the performance issue of `clipboard=unnamed` and `clipboard=unnamedplus`](https://github.com/neovim/neovim/issues/11804).

It works both ways so you can `y`ank something in `Neovim` to be available in your OS, but also copy something in your OS and `p`ut in `Neovim`.

The content of system clipboard will also be written to the unnamed register (`"`) on `.setup()` if its empty, and read from unnamed register (`"`) just before `Neovim` exits, so your latest yank won't be lost even if your client doesn't support focus change events.

### [Vim](https://www.vim.org)

Apparently the performance issue is specific to `Neovim` and does not apply to `Vim`.

## Requirements

- `Neovim >= 0.7.0`
- (optional, recommended) `Neovim` client which supports both focus change events - `FocusGained` and `FocusLost`

## Installation

Use your favorite package manager. For example [`vim-plug`](https://github.com/junegunn/vim-plug):

```vimscript
Plug 'EtiamNullam/deferred-clipboard.nvim'
```

## Usage

### Setup

#### Best compatibility

```lua
require('deferred-clipboard').setup {
  fallback = 'unnamedplus', -- or your preferred setting for clipboard
}
```

If `fallback` is specified it will be applied as your `clipboard` setting until support for focus change events is detected in your terminal or `Neovim` client. This way you will get a consistent behavior, no matter if focus change events are supported or not.

#### Best performance

You can use `lazy` option (off by default) to improve startup time by delaying access of system clipboard. Make sure to disable it if you run into any trouble, for example if you load `shada` on launch but still want the clipboard to be loaded into unnamed register (`"`).

```lua
require('deferred-clipboard').setup {
  lazy = true,
}
```

#### Basic

```lua
require('deferred-clipboard').setup()
```

It is required to call `setup()` to start the plugin, which will load the system clipboard to the unnamed register (`"`), hook up focus change events and disable continuous clipboard sync if it's enabled.

Calling it with no arguments will use default settings.

#### `force_init_unnamed`

By default clipboard will be copied to your unnamed register (`"`) on `setup` only when it's empty. If your unnamed register might not be empty and you want to make sure its loaded from your clipboard on `setup` you can use `force_init_unnamed` option:

```lua
require('deferred-clipboard').setup {
  force_init_unnamed = true
}
```

### API

Other than `setup()` described before, this plugin exposes a simple API. There is no need to call `setup()` prior to using the API.

#### `read() -> string | nil`

It will load content of your system clipboard and place it in your `unnamed` register (`"`). It will also return the content of system clipboard unless it's invalid - in that case it will return `nil`.

##### Example:

```lua
local clipboard = require('deferred-clipboard')

local clipboard_content = clipboard.read()

local is_clipboard_content_invalid = clipboard_content == nil
```

#### `write(content?: string)`

If called with no argument it will simply write your `unnamed` register (`"`) to system clipboard.

If called with argument it will write the specified `content` to your system clipboard. 

##### Example:

```lua
vim.keymap.set('n', 'x', function()
  require('deferred-clipboard').write()
end)

vim.keymap.set('n', 'X', function()
  require('deferred-clipboard').write('example')
end)
```

## Known issues

- Clipboard will not be synchronized if `Neovim` is busy or when `hit-enter-prompt` is open
