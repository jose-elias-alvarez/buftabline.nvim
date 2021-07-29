local o = require("buftabline.options")
local u = require("buftabline.utils")
local build = require("buftabline.build")

local M = {}

M.build = function()
    local ok, result = xpcall(build, debug.traceback)
    if ok then
        return result
    end

    u.echo_warning("Something went wrong!: " .. result)
    vim.o.tabline = ""
    u.clear_augroup()
end

M.map = u.map

M.setup = function(opts)
    opts = opts or {}
    o.set(opts)

    if not o.get().disable_commands then
        u.define_command("ToggleBuftabline", "toggle_tabline()")
        u.define_command("BufNext", "next_buffer()")
        u.define_command("BufPrev", "prev_buffer()")
    end
    if o.get().auto_hide then
        u.define_autocmd("BufAdd,BufDelete", "auto_hide()")
    end
    if o.get().go_to_maps then
        u.map({ prefix = "<Leader>", cmd = "buffer" })
    end

    vim.o.showtabline = (o.get().start_hidden or o.get().auto_hide) and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build()')]]
end

return M
