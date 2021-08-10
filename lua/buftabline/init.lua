local o = require("buftabline.options")
local u = require("buftabline.utils")

local M = {}

M.map = u.map

M.__load = function()
    local opts = o.get()

    u.clear_augroup()

    if not opts.disable_commands then
        u.define_command("ToggleBuftabline", "toggle_tabline()")
        u.define_command("BufNext", "next_buffer()")
        u.define_command("BufPrev", "prev_buffer()")
    end
    if opts.go_to_maps then
        u.map({ prefix = "<Leader>", cmd = "buffer" })
    end

    u.define_autocmd("BufAdd", "on_buffer_add()")
    u.define_autocmd("BufDelete", "on_buffer_delete()")
    u.define_autocmd("TabClosed", "on_tab_closed()")
    u.define_autocmd("SessionLoadPost", "on_vim_enter()")
    u.define_autocmd("BufEnter,BufUnload,TabNew,TabClosed", "check_auto_hide()")

    if opts.icon_colors then
        u.define_autocmd("ColorScheme", "reset_icon_colors()")
        u.define_autocmd("OptionSet", "reset_icon_colors()", "background")
    end

    vim.o.tabline = [[%!luaeval('require("buftabline.build")()')]]
    vim.o.showtabline = (opts.start_hidden or opts.auto_hide) and 0 or 2
end

M.setup = function(opts)
    opts = opts or {}
    o.set(opts)

    if vim.v.vim_did_enter == 1 then
        M.__load()
    else
        vim.cmd [[
            augroup BuftablineLoad
                autocmd VimEnter * ++once lua require('buftabline').__load()
            augroup END
        ]]
    end
end

return M
