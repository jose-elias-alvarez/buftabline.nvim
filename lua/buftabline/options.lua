local options = {
    modifier = ":t",
    icons = false,
    start_hidden = false,
    go_to_maps = true,
    kill_maps = false,
    custom_command = nil,
    custom_map_prefix = nil,
    hlgroup_current = "BufTabLineCurrent",
    hlgroup_normal = "BufTabLineFill",
    no_link_hlgroups = false
}

local M = {}
M.set_options = function(user_options)
    options = vim.tbl_extend("force", options, user_options)
end

M.get_options = function() return options end

return M

