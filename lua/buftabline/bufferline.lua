local get_options = require("buftabline.options").get_options

local set_bufferline = function()
    vim.o.showtabline = get_options().start_hidden and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build_bufferline()')]]
end

return set_bufferline
