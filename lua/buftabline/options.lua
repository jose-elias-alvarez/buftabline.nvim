local defaults = {
    tab_format = " #{n}: #{b}#{f} ",
    buffer_id_index = false,
    icon_colors = true,
    start_hidden = false,
    auto_hide = false,
    disable_commands = false,
    go_to_maps = true,
    hlgroup_current = "TabLineSel",
    hlgroup_normal = "TabLineFill",
}

local options = vim.deepcopy(defaults)

local M = {}
M.set = function(user_options)
    options = vim.tbl_extend("force", options, user_options)
end

M.get = function()
    return options
end

M.reset = function()
    options = vim.deepcopy(defaults)
end

return M
