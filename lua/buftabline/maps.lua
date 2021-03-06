local o = require("buftabline.options").get_options

local map = function(mode, key, command)
    local options = {silent = true, nowait = true, noremap = true}
    vim.api.nvim_set_keymap(mode, key, command, options)
end

local replace_idx = function(raw, idx)
    -- assign to discard 2nd result
    local replaced = string.gsub(raw, "<idx>", tostring(idx), 1)
    return replaced
end

local iterate_maps = function(max, key, command)
    for i = 0, max do map("n", replace_idx(key, i), replace_idx(command, i)) end
end

local set_maps = function()
    if o().go_to_maps then
        iterate_maps(9, "<Leader><idx>",
                     ":lua require'buftabline'.go_to_buffer(<idx>)<CR>")
    end
    if o().bd_maps then
        iterate_maps(9, "<Leader>c<idx>",
                     ":lua require'buftabline'.kill_buffer(<idx>)<CR>")
    end
    if o().custom_command and o().custom_map_prefix then
        iterate_maps(9, "<Leader>" .. o().custom_map_prefix .. "<idx>",
                     ":lua require'buftabline'.custom_command(<idx>)<CR>")
    end
end

return set_maps
