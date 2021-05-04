local b = require("buftabline.buffers")
local o = require("buftabline.options")

local M = {}

M.set = function()
    vim.o.showtabline = o.get().start_hidden and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build_bufferline()')]]
end

M.build = function()
    local bufferline = {}
    for _, buffer in ipairs(b.get_buffers()) do
        table.insert(bufferline, b.generate_tab(buffer))
    end
    return table.concat(bufferline)
end

return M
