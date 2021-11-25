local defaults = {
    tab_format = " #{n}: #{b}#{f} ",
    buffer_id_index = false,
    icon_colors = true,
    start_hidden = false,
    auto_hide = false,
    disable_commands = false,
    go_to_maps = true,
    flags = {
        modified = " [+]",
        not_modifiable = " [-]",
        readonly = " [RO]",
    },
    hlgroups = {
        current = "TabLineSel",
        normal = "TabLineFill",
        spacing = nil,
        active = nil,
        modified_current = nil,
        modified_normal = nil,
        modified_active = nil,
        tabpage_current = nil,
        tabpage_normal = nil,
    },
    show_tabpages = true,
    tabpage_format = " #{n} ",
    tabpage_position = "right",
}

local options = vim.deepcopy(defaults)

local M = {}
M.set = function(user_options)
    options = vim.tbl_deep_extend("force", options, user_options)
end

M.get = function()
    return options
end

M.reset = function()
    options = vim.deepcopy(defaults)
end

return M
