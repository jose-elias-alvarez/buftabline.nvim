local options = {
    modifier = ":t",
    icons = false,
    start_hidden = false,
    go_to_maps = true,
    kill_maps = false,
    custom_command = nil,
    custom_map_prefix = nil,
    hlgroup_current = "TabLineSel",
    hlgroup_normal = "TabLineFill"
}

local M = {}
M.set = function(user_options)
    options = vim.tbl_extend("force", options, user_options)
end

M.get = function() return options end

return M

