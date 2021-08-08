local M = {}

local api = vim.api

local icon_hls = {}

-- thanks to barbar.nvim for this implementation
local get_hl_attribute = function(hl, attribute)
    local rgb_val = api.nvim_get_hl_by_name(hl, true)[attribute]
    return rgb_val and string.format("#%06x", rgb_val) or "NONE"
end

local define_hl = function(name, fg, bg)
    vim.cmd(string.format("hi! %s guifg=%s guibg=%s", name, fg, bg))
    icon_hls[name] = true
end

M.merge_hl = function(fg_hl, bg_hl)
    local merged = fg_hl .. bg_hl
    if not icon_hls[merged] then
        define_hl(merged, get_hl_attribute(fg_hl, "foreground"), get_hl_attribute(bg_hl, "background"))
    end
    return merged
end

M.add_hl = function(text, hl)
    return string.format("%%#%s#%s%%*", hl, text)
end

M.reset = function()
    icon_hls = {}
end

return M
