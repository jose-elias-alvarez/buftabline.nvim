local o = require("buftabline.options")
local u = require("buftabline.utils")

local M = {}

M.build = require("buftabline.build")

M.map = u.map

M.setup = function(opts)
    o.set(opts)

    if not o.get().disable_commands then
        u.define_command("ToggleBuftabline", "toggle_tabline()")
        u.define_command("BufNext", "next_buffer()")
        u.define_command("BufPrev", "prev_buffer()")
    end
    if o.get().auto_hide then
        u.define_autocmd("BufEnter", "auto_hide()")
    end
    if o.get().go_to_maps then
        u.map({ prefix = "<Leader>", cmd = "buffer" })
    end

    vim.o.showtabline = o.get().start_hidden and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build()')]]
end

return M
