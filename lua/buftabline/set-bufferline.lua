local o = require("buftabline.options")

local set_bufferline = function()
    vim.o.showtabline = o.get().start_hidden and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build_bufferline()')]]
end

return set_bufferline
