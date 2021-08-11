local o = require("buftabline.options")
local u = require("buftabline.utils")

local M = {}

M.map = u.map

M.setup = function(opts)
    opts = opts or {}
    o.set(opts)

    if not o.get().disable_commands then
        u.define_command("ToggleBuftabline", "toggle_tabline()")
        u.define_command("BufNext", "next_buffer()")
        u.define_command("BufPrev", "prev_buffer()")
    end
    if o.get().go_to_maps then
        u.map({ prefix = "<Leader>", cmd = "buffer" })
    end

    u.define_autocmd("BufAdd,BufEnter", "on_buffer_add()")
    u.define_autocmd("BufDelete", "on_buffer_delete()")
    u.define_autocmd("TabClosed", "on_tab_closed()")
    u.define_autocmd("VimEnter", "on_vim_enter()")
    u.define_autocmd("BufAdd,BufEnter,BufDelete,BufModifiedSet,TabEnter,TabClosed,WinEnter", "build()")

    if o.get().icon_colors then
        u.define_autocmd("ColorScheme", "reset_icon_colors()")
        u.define_autocmd("OptionSet", "reset_icon_colors()", "background")
    end

    vim.o.showtabline = (o.get().start_hidden or o.get().auto_hide) and 0 or 2
end

return M
