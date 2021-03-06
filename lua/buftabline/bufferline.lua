local set_bufferline = function()
    vim.o.showtabline = 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build_bufferline()')]]
end

return set_bufferline
