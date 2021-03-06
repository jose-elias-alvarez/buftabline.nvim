local defaults = {
    modifier = ":t",
    index_format = "%d: ",
    buffer_id_index = false,
    padding = 1,
    icons = false,
    icon_colors = false,
    start_hidden = false,
    auto_hide = false,
    disable_commands = false,
    go_to_maps = true,
    kill_maps = false,
    show_no_name_buffers = false,
    next_indicator = ">",
    custom_command = nil,
    custom_map_prefix = nil,
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
