<!-- markdownlint-configure-file
{
  "line-length": false
}
-->

# buftabline.nvim

A low-config, minimalistic buffer tabline Neovim plugin written in Lua,
shamelessly inspired by [vim-buftabline](https://github.com/ap/vim-buftabline).

![Screen Shot 2021-08-25 at 3 30 42 PM](https://user-images.githubusercontent.com/54108223/130738428-4823dc74-5310-4688-9302-c747978aeae2.png)

## Setup

Install using your favorite plugin manager and call the following Lua code
somewhere in your configuration:

```lua
require("buftabline").setup {}
```

If you're using [packer.nvim](https://github.com/wbthomason/packer.nvim), you
can install and set up buftabline simultaneously:

```lua
use {
    "jose-elias-alvarez/buftabline.nvim",
    requires = {"kyazdani42/nvim-web-devicons"}, -- optional!
    config = function() require("buftabline").setup {} end
}
```

## Features

Buftabline shows your open buffers in your tabline with (optional) filetype
icons and applies highlighting to each tab based its buffer's state. If you
want, it'll also show your tabpages (`:help tabpages`). That's pretty much it.

For convenience, the plugin exposes a function, `buftarget(number, command)`
which will target a buffer in the tabline with a command:

```lua
require("buftabline").buftarget(1, "rightbelow sb")
```

By default, the plugin maps `<Leader>0-9` to go to the corresponding buffer (`0`
gets converted to `10`), but you can disable this by setting `go_to_maps` to
`false` (see [Options](#options)).

To simplify the creation of more custom commands, buftabline also exposes a
`map` method. The following example will map `<Leader>c1` through `Leader<c9>`
to the corresponding `bdelete` command:

```lua
require("buftabline").map({ prefix = "<Leader>c", cmd = "bdelete" })
```

Lastly, the plugin adds the following Vim commands:

- `:ToggleBuftabline` (useful for smaller screens / focus sessions)

- `:BufNext` and `:BufPrev` (like `:bnext` and `:bprev`, but they correspond to
  bufferline indexes.

## Options

For most users, everything should work out-of-the-box, but the plugin exposes
the following options (defaults shown):

```lua
local options = {
    tab_format = " #{n}: #{b}#{f} ",
    buffer_id_index = false,
    icon_colors = true,
    start_hidden = false,
    auto_hide = false,
    disable_commands = false,
    go_to_maps = true,
    flags = {
        modified = " [+]",
        not_modifiable = " [-]",
        readonly = " [RO]",
    },
    hlgroups = {
        current = "TabLineSel",
        normal = "TabLine",
        active = nil,
        spacing = nil,
        modified_current = nil,
        modified_normal = nil,
        modified_active = nil,
        tabpage_current = nil,
        tabpage_normal = nil,
    },
    show_tabpages = true,
    tabpage_format = " #{n} ",
    tabpage_position = "right",
}
```

| Option             | Description                                                                                                                                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tab_format`       | Defines how the plugin formats buffer tabs (see [Format](#format) below for details).                                                                                                                       |
| `buffer_id_index`  | Uses buffer numbers (the ones shown in `:ls`) instead of sequential indexes.                                                                                                                                |
| `icon_colors`      | Shows icon colors in your tabline. Can be `true` (always show), `current` (show for current tab), and `normal` (show for background tabs).                                                                  |
| `start_hidden`     | Hides the tabline when Neovim starts.                                                                                                                                                                       |
| `auto_hide`        | Shows the tabline when you have more than one buffer open and hides it when you don't. Not compatible with `start_hidden`.                                                                                  |
| `disable_commands` | Stops the plugin from defining commands.                                                                                                                                                                    |
| `go_to_maps`       | Maps `<Leader>0-9` to go to the corresponding buffer.                                                                                                                                                       |
| `flags`            | Sets the flags used to mark a buffer's status.                                                                                                                                                              |
| `hlgroups`         | Sets highlight groups (see [Colors](#colors) below for details).                                                                                                                                            |
| `show_tabpages`    | Shows tabpages (`:h tabpages`) in your bufferline. Can be `true` (show if more than one tabpage), `always` (always show), and `false` (disable). If you don't use tabpages, there's no need to change this. |
| `tabpage_format`   | Defines how the plugin formats tabpages (see [Format](#format) below for details).                                                                                                                          |
| `tabpage_position` | Determines where the plugin shows tabpages. Can be `right` or `left`. Does nothing if you've set `show_tabpages` to `false`.                                                                                |

## Format

The `tab_format` string accepts the following special options and replaces them
with the corresponding buffer information. The plugin won't do anything to other
characters, including spaces and separators.

| Option | Information                                                                                                              |
| ------ | ------------------------------------------------------------------------------------------------------------------------ |
| `#{n}` | The buffer's index. Modified by `buffer_id_index`.                                                                       |
| `#{b}` | The buffer's filename. If two or more buffers share a filename, it'll add the name of each buffer's enclosing directory. |
| `#{f}` | The buffer's flags (modified, modifiable, and read-only).                                                                |
| `#{i}` | The buffer's filetype icon.                                                                                              |

The `tabpage_format` string accepts the following option:

| Option | Information          |
| ------ | -------------------- |
| `#{n}` | The tabpage's index. |

## Colors

The `hlgroups` option is a table that accepts the following keys to allow
setting highlight groups based on buffer state. Leaving a value empty will
cause the plugin to fall back to the next available group.

| Key                | Condition                                                                                               |
| ------------------ | ------------------------------------------------------------------------------------------------------- |
| `current`          | The current buffer.                                                                                     |
| `normal`           | The buffer is not current visible in any window.                                                        |
| `active`           | The buffer is visible in another window.                                                                |
| `spacing`          | Applied to the empty space between buffer tabs and any right-aligned tabs (or the end of the viewport). |
| `modified_current` | Same as `current`, but the buffer is modified.                                                          |
| `modified_normal`  | Same as `normal`, but the buffer is modified.                                                           |
| `modified_active`  | Same as `active`, but the buffer is modified.                                                           |
| `tabpage_current`  | The current tabpage. Falls back to `current` if not defined.                                            |
| `tabpage_normal`   | Tabpages other than the current. Falls back to `normal` if not defined.                                 |

## FAQ

### How do I enable icons?

Add `#{i}` to `tab_format`. For example, to keep the default format but show
icons after the buffer's filename:

```lua
tab_format = " #{n}: #{b}#{f} #{i} "
```

## Non-goals

- Vim support. Use [vim-buftabline](https://github.com/ap/vim-buftabline)!
- Mouse support.
- Visual customization beyond what's available now.

Aside from these, I'm open to PRs.

## Tests

Run `make test` from the plugin's root directory. Depends on
[plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

## Inspiration

- [vim-buftabline](https://github.com/ap/vim-buftabline), the direct inspiration
  for this plugin and still a solid plugin.

- [nvim-bufbar](https://github.com/ojroques/nvim-bufbar) by
  [@ojroques](https://github.com/ojroques), who directed me to his plugin and
  encouraged me to use it as a starting point.

- [lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline),
  which gave me the idea to "target" buffers in the tabline with commands.

- [nvim-bufferline](https://github.com/akinsho/nvim-bufferline.lua) and
  [barbar.nvim](https://github.com/romgrk/barbar.nvim), two tabline plugins that
  are far and away better than this one but are a little too much for my simple
  needs. (Thanks to barbar.nvim for its implementation of colored icons, which
  provided the basis for the implementation in this plugin.)
