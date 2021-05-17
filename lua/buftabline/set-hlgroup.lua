local o = require("buftabline.options")
local u = require("buftabline.utils")

local hl_exists = function(hlgroup)
    return vim.fn.hlexists(hlgroup) > 0 and true or false
end

local add_hlgroup = function(hlgroup, text)
    return string.format("%%#%s#%s%%*", hlgroup, text)
end

-- thanks to barbar.nvim for the implementation of icon colors
local get_hl_attribute = function(hlgroup, attr)
    local rgb_val = vim.api.nvim_get_hl_by_name(hlgroup, true)[attr]
    return rgb_val and string.format("#%06x", rgb_val) or "NONE"
end

local create_hlgroup = function(name, fg, bg)
    vim.api.nvim_command("hi! " .. name .. " guifg=" .. fg .. " guibg=" .. bg)
end

local set_hlgroup = function(tab)
    local label, current, icon_hl = tab.label, tab.current, tab.icon_hl
    local hlgroup = current and o.get().hlgroup_current or
                        o.get().hlgroup_normal
    if not hl_exists(hlgroup) then return label end

    if o.get().icon_colors and icon_hl then
        local split = vim.split(vim.trim(label), " ")
        -- assume icon is last element
        local icon = split[vim.tbl_count(split)]
        if not icon then return add_hlgroup(hlgroup, label) end

        -- create new hlgroup that uses devicons color for fg and tabline color for bg
        local merged_icon_hl = current and icon_hl .. "Current" or icon_hl ..
                                   "Normal"
        if not hl_exists(merged_icon_hl) then
            create_hlgroup(merged_icon_hl,
                           get_hl_attribute(icon_hl, "foreground"),
                           get_hl_attribute(hlgroup, "background"))
        end

        label = u.string_replace(label, icon,
                                 add_hlgroup(merged_icon_hl, u.pad(icon, true)))
    end

    return add_hlgroup(hlgroup, label)
end

return set_hlgroup
