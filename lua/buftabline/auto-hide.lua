local o = require("buftabline.options")
local b = require("buftabline.buffers")

local M = {}
M.watch = function()
    vim.o.showtabline = vim.tbl_count(b.get_buffers()) <= 1 and 0 or 2
end

M.setup = function()
    if not o.get().auto_hide or o.get().start_hidden then
        return
    end

    -- BufCreate is for compatibility w/ plugins that open multiple files at once (e.g. nnn.vim)
    vim.api.nvim_exec(
        [[
    augroup WatchBuffers
        autocmd!
        autocmd BufEnter,BufCreate * lua require'buftabline.auto-hide'.watch()
    augroup END
    ]],
        false
    )
end

return M
