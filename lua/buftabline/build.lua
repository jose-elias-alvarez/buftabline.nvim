local o = require("buftabline.options")
local b = require("buftabline.buffers")
local u = require("buftabline.utils")
local Buftab = require("buftabline.buftab")
local Tabpage = require("buftabline.tabpage")

local api = vim.api

local make_separator = function(budget)
    local spacing = {}
    for _ = 1, budget do
        table.insert(spacing, " ")
    end
    return table.concat(spacing)
end

local make_buftabs = function(current)
    local buftabs = {}
    local buffers = b.getbufinfo()

    for i, bufinfo in ipairs(buffers) do
        table.insert(
            buftabs,
            Buftab:new({
                index = i,
                bufinfo = bufinfo,
                current = bufinfo.bufnr == current,
                safe = bufinfo.bufnr <= current,
                last = i == #buffers,
            })
        )
    end
    return buftabs
end
local make_tabpage_tabs = function(current)
    local tabpage_tabs = {}
    if not o.get().show_tabpages then
        return tabpage_tabs
    end

    local tabpages = vim.fn.gettabinfo()
    if #tabpages <= 1 and o.get().show_tabpages ~= "always" then
        return tabpage_tabs
    end

    for i, tabinfo in ipairs(tabpages) do
        table.insert(
            tabpage_tabs,
            Tabpage:new({
                index = i,
                current = tabinfo.tabnr == current,
            })
        )
    end
    return tabpage_tabs
end

local build = function()
    local budget = vim.o.columns
    local tabs = {}
    vim.list_extend(tabs, make_tabpage_tabs(vim.fn.tabpagenr()))
    vim.list_extend(tabs, make_buftabs(api.nvim_get_current_buf()))

    local labels = {}
    for _, tab in ipairs(tabs) do
        local remaining, label = tab:generate(budget, tabs)
        budget = remaining
        if tab.position == "right" or tabs[1].position == "left" then
            table.insert(labels, label)
        else
            table.insert(labels, tab.insert_at, label)
        end
        if tab.last then
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
