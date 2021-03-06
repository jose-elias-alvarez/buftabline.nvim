<!-- markdownlint-configure-file
{
  "line-length": false
}
-->

# buftabline.nvim

A low-config, minimalistic buffer tabline Neovim plugin written in Lua,
shamelessly inspired by [vim-buftabline](https://github.com/ap/vim-buftabline).

![buftabline](./screenshots/buftabline.png)

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
    requires = {"kyazdani42/nvim-web-devicons"}, -- optional
    config = function() require("buftabline").setup {} end
}
```

## Functionality

buftabline shows your open buffers in your tabline with (optional) filetype
icons, sorts them by (ordinal) number, and highlights the current buffer. That's
pretty much it.

For convenience, the plugin exposes 3 functions to interact with buffers in the
tabline by using the buffer's ordinal number:

- `go_to_buffer(number)`

  Does what you'd imagine. By default, the plugin maps `<Leader>0-9` to the
  corresponding `go_to_buffer` command (`0` gets converted to `10`), but you can
  disable this by setting `go_to_maps` to `false` (see [Options](#options)).

- `kill_buffer(number)`

  Again, self-explanatory. Not mapped by default, but you can have the plugin
  map `<Leader>c0-9` by setting `kill_maps` to `true` (see [Options](#options)).

- `custom_command(number)`

  By setting `custom_command` in your config, you can run an arbitrary command
  on a specific buffer in your tabline (see [Options](#options) for an example).

You can call any of these functions directly from Vimscript:

```vim
:lua require("buftabline").kill_buffer(5)
```

Or set custom maps:

```vim
nnoremap 1 <cmd> lua require("buftabline").go_to_buffer(1)<CR>
```

The plugin exposes the underlying function `buftarget(number, command)` and
allows access to enable creating more custom commands:

```vim
:lua require("buftabline").buftarget(1, "rightbelow sb")
```

Lastly, the plugin adds the following Vim commands:

- `:ToggleBuftabline` (useful for smaller screens / focus sessions)

- `:BufNext` and `:BufPrev` (like `:bnext` and `:bprev`, but they skip over
  invisible buffers)

## Options

For most users, everything should work out-of-the-box, but the plugin exposes
the following options (defaults shown):

```lua
local options = {
    modifier = ":t",
    index_format = "%d: ",
    buffer_id_index = false,
    padding = 1,
    icons = false,
    icon_colors = false,
    start_hidden = false,
    auto_hide = false,
    disable_commands = false,
    go_to_maps = true,
    kill_maps = false,
    show_no_name_buffers = false,
    next_indicator = ">",
    custom_command = nil,
    custom_map_prefix = nil,
    hlgroup_current = "TabLineSel",
    hlgroup_normal = "TabLineFill",
}
```

| Option | Description |
| ------ | ----------- |
| `modifier` | Allows modifying the format of each buffer in the tabline. See `:help filename-modifiers`. |
| `index_format` | Allows modifying the format of the index shown before each file's name in the tabline. Lua's `string.format` function uses [C directives](http://www.cplusplus.com/reference/cstdio/printf/), and you can also change spacing and punctuation. <br>For example, setting `index_format = "(%d) "` will format your tabs like this: ![index_format](./screenshots/index_format.png) |
| `buffer_id_index` | Uses the buffer numeric ID as the buffer index (instead of a sequential index). |
| `padding` | Each digit of `padding` adds a space around each side of each tab. Set to `0` or `false` to disable padding entirely. |
| `icons` | Enables filetype icons via [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons). Even if you've installed nvim-web-devicons, you must explicitly enable icons by setting this option to `true`, in case you don't want them in your tabline.  ![devicons](./screenshots/devicons.png)||
| `icon_colors` | Shows nvim-web-devicon's built-in icon colors in your tabline. Defaults to `false`. Can be `true` (always show icon colors), `current` (show icon color for current tab), and `normal` (show icon colors for background tabs). Depending on your tabline, you may want to change the plugin's default highlight groups for better visibility. |
| `start_hidden` | Hides the tabline when Neovim starts by setting `showtabline` to `0`. Disabled by default, but potentially useful in combination with `ToggleBuftabline`. |
| `auto_hide` | Shows the tabline when you have more than one buffer open and hides it when you don't. Not compatible with `start_hidden`. |
| `disable_commands` | Stops the plugin from creating commands in case you want to define your own. |
| `go_to_maps` | Maps `<Leader>0-9` to the corresponding `go_to_buffer` command. |
| `kill_maps` | Maps `<Leader>c0-9` to the corresponding `kill_buffer` command. |
| `show_no_name_buffers` | Does precisely what you'd imagine. |
| `next_indicator` | Defines the indicator shown when the bufferline truncates the rightmost tab or when there are more tabs to show. Set to `>` by default to match the left side of the tabline, which Neovim will automatically truncate. |
| `custom_command` | Defines the command that runs when calling `custom_command(number)`. Note that calling the function without defining a command will throw an error.  A practical example: setting `custom_command` to `vertical sb` and calling `:lua require("buftabline").custom_command(2)` will open the 2nd buffer in your tabline in a vertical split. |
| `custom_map_prefix` | A simple way to map your `custom_command`. Setting `custom_map_prefix` to `v` and setting `custom_command` to `vertical sb` will map `<Leader>v0-9` to open the corresponding buffer in a vertical split.  Does nothing if you haven't set `custom_command`. |
| `hlgroup_current` | Sets the highlight group for the current buffer. |
| `hlgroup_normal` | Sets the highlight group for normal (non-current) buffers. |

## Non-goals

- Vim support. Use [vim-buftabline](https://github.com/ap/vim-buftabline)!
- Mouse support.
- Extensive visual customization.

Aside from these, I'm open to PRs and hope to continue to improve the plugin,
but I don't think it'll change too much one way or another.

## Tests

I've covered most of the code with tests written with
[plenary.nvim](https://github.com/nvim-lua/plenary.nvim)'s test harness. Running
`make test` from the plugin's root directory will run the test suite and exit
with a relevant exit code.

## Inspiration

- [nvim-bufbar](https://github.com/ojroques/nvim-bufbar) by
  [@ojroques](https://github.com/ojroques), who directed me to his plugin and
  encouraged me to use it as a starting point. A large percentage of the code in
  this plugin comes from his (any and all terrible Lua code is all my own).

- [vim-buftabline](https://github.com/ap/vim-buftabline), the direct inspiration
  for this plugin and still a solid plugin if you don't mind Vimscript.

- [lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline),
  which gave me the idea to "target" buffers in the tabline with commands.

- [nvim-bufferline](https://github.com/akinsho/nvim-bufferline.lua) and
  [barbar.nvim](https://github.com/romgrk/barbar.nvim), two tabline plugins that
  are far and away better than this one but are a little too much for my simple
  needs. (Thanks to barbar.nvim for its implementation of colored icons, which
  provided the basis for the implementation in this plugin.)
