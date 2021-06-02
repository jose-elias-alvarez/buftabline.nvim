local o = require("buftabline.options")
local b = require("buftabline.buffers")

local M = {}
M.watch = function()
    -- schedule to make sure we get accurate buffer count
    vim.schedule(function()
        vim.o.showtabline = vim.tbl_count(b.get_buf_numbers()) <= 1 and 0 or 2
    end)
end

M.setup = function()
    if not o.get().auto_hide or o.get().start_hidden then
        return
    end

    vim.api.nvim_exec(
        [[
    augroup WatchBuffers
        autocmd!
        autocmd BufAdd,BufDelete * lua require'buftabline.auto-hide'.watch()
    augroup END
    ]],
        false
    )
end

return M
