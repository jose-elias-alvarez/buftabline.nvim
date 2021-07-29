local b = require("buftabline.buffers")
local t = require("buftabline.tabpages")
local u = require("buftabline.utils")

local make_separator = function(budget)
    local spacing = {}
    for _ = 1, budget do
        table.insert(spacing, " ")
    end
    return table.concat(spacing)
end

local build = function()
    local budget = vim.o.columns
    local tabs = {}
    vim.list_extend(tabs, t.make_tabpage_tabs())
    vim.list_extend(tabs, b.make_buftabs())

    local labels = {}
    for _, tab in ipairs(tabs) do
        local remaining, label, last = tab:generate(budget, tabs)
        budget = remaining
        if tab.position == "right" or tabs[1].position == "left" then
            table.insert(labels, label)
        else
            table.insert(labels, tab.insert_at, label)
        end
        if last then
            if tabs[1].position == "right" then
                table.insert(labels, tab.insert_at + 1, make_separator(budget))
            end

            break
        end
    end
    return table.concat(labels)
end

return function()
    local ok, result = xpcall(build, debug.traceback)
    if ok then
        return result
    end

    u.echo_warning("Something went wrong while building the bufferline!")
    u.echo_warning("Please report the error and include the following trace: " .. result)
    vim.o.tabline = ""
end
