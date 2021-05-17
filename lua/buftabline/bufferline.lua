local b = require("buftabline.buffers")
local u = require("buftabline.utils")
local o = require("buftabline.options")
local set_hlgroup = require("buftabline.set-hlgroup")

local next_indicator = o.get().next_indicator

local strchars = vim.fn.strchars

local M = {}

local get_flags = function(buffer)
    local flags = {}
    if buffer.readonly then table.insert(flags, "[RO]") end
    if not buffer.modifiable then table.insert(flags, "[-]") end
    if buffer.modified then table.insert(flags, "[+]") end
    return table.concat(flags)
end

local get_name = function(buffer)
    local name = "[No Name]"
    local index = buffer.index
    local modifier = o.get().modifier
    if buffer.name ~= "" then
        name = vim.fn.fnamemodify(buffer.name, modifier)
        if buffer.ambiguous then
            local split = vim.split(buffer.name, "/")
            name = split[vim.tbl_count(split) - 1] .. "/" .. name
        end
    end

    local index_format = o.get().index_format
    local flags = get_flags(buffer)
    if flags ~= "" then
        name = string.format(index_format .. "%s %s", index, name, flags)
    else
        name = string.format(index_format .. "%s", index, name)
    end

    if buffer.icon then name = name .. " " .. buffer.icon end
    return name
end
M.get_name = get_name

local generate_label = function(buffer)
    return string.format(u.pad("%s"), get_name(buffer))
end

local format_tab = function(tab) return set_hlgroup(tab) end

local generate_tabs = function(buffers)
    local tabs = {}
    local current_pos, width = 0, 0
    for _, buffer in ipairs(buffers) do
        local label = generate_label(buffer)
        -- use strchars to account for icons
        local tab_width = strchars(label)
        table.insert(tabs, {
            label = label,
            width = tab_width,
            current = buffer.current,
            icon_hl = buffer.icon_hl
        })

        if buffer.current then current_pos = width end
        if current_pos == 0 then width = width + tab_width end
    end
    return tabs, current_pos
end

local tab_is_visible = function(tab, pos, current_pos, columns)
    local side = pos - tab.width < current_pos and "left" or "right"
    -- vim handles shrinking left-side tabs automatically
    if side == "left" then return true end

    -- always insert current tab and fully visible tabs to the right of the current tab
    if tab.current or pos <= columns then return true end

    -- determine if right tab can shrink to fit remaining space
    local budget = columns - pos + tab.width
    if budget > 0 then
        -- shrink and make room for indicator
        tab.label = string.sub(tab.label, 1, budget - strchars(next_indicator))
        tab.shrank = true
        return true
    end

    return false
end

local generate_bufferline = function(tabs, current_pos)
    local columns = vim.o.columns

    local bufferline = {}
    local pos, hidden = 0, false
    for _, tab in ipairs(tabs) do
        pos = pos + tab.width

        local is_visible = tab_is_visible(tab, pos, current_pos, columns)
        if is_visible then table.insert(bufferline, format_tab(tab)) end
        if not is_visible or tab.shrank then hidden = true end
    end
    if hidden then
        table.insert(bufferline, format_tab({label = next_indicator}))
    end
    return table.concat(bufferline)
end

M.set = function()
    vim.o.showtabline = o.get().start_hidden and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build_bufferline()')]]
end

M.build = function()
    local tabs, current_pos = generate_tabs(b.get_buffers())
    return generate_bufferline(tabs, current_pos)
end

return M
