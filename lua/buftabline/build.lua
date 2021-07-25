local o = require("buftabline.options")
local b = require("buftabline.buffers")
local Tab = require("buftabline.tab")
local Tabpage = require("buftabline.tabpage")

local api = vim.api

return function()
    local budget = vim.o.columns
    local current_bufnr, current_tabnr = api.nvim_get_current_buf(), vim.fn.tabpagenr()
    local show_tabpages, tabpage_position = o.get().show_tabpages, o.get().tabpage_position

    local tabs, skipped = {}, 0
    local tabpages = show_tabpages and vim.fn.gettabinfo()
    local should_show_tabpages = function()
        return show_tabpages and (#tabpages > 1 or show_tabpages == "always")
    end
    local should_insert_separator = function()
        return should_show_tabpages() and tabpage_position == "right" and budget > 0
    end

    local buf_to_tab = function(buf, i)
        return Tab:new({
            buf = buf,
            index = o.get().buffer_id_index and buf.bufnr or i - skipped,
            current_bufnr = current_bufnr,
            generator = function(tab)
                budget = tab:generate(tabs, budget)
                return tab.label, tab.truncated
            end,
        })
    end
    local tabpage_to_tab = function(tabinfo, i)
        return Tabpage:new({
            index = i,
            tabinfo = tabinfo,
            current_tabnr = current_tabnr,
            generator = function(tabpage)
                budget = tabpage:generate(budget)
                return tabpage.label
            end,
        })
    end

    for i, buf in ipairs(b.getbufinfo()) do
        if b.has_name(buf) then
            table.insert(tabs, buf_to_tab(buf, i))
        else
            skipped = skipped + 1
        end
    end

    local labels = {}
    if should_show_tabpages() then
        for i, tabinfo in ipairs(tabpages) do
            table.insert(labels, tabpage_to_tab(tabinfo, i):generator())
        end
    end
    for i, tab in ipairs(tabs) do
        local label, done = tab:generator()
        if should_insert_separator() then
            table.insert(labels, i, label)
        else
            table.insert(labels, label)
        end
        if done then
            break
        end
    end
    if should_insert_separator() then
        local spacing = {}
        for _ = 1, budget do
            table.insert(spacing, " ")
        end
        table.insert(labels, #tabs + 1, table.concat(spacing))
    end
    return table.concat(labels)
end
