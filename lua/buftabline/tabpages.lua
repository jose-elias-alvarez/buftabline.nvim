local o = require("buftabline.options")
local Tabpage = require("buftabline.tabpage-tab")

local api = vim.api

local M = {}

M.tabinfo = function()
    if not o.get().show_tabpages then
        return {}
    end

    local tabnrs = api.nvim_list_tabpages()
    if #tabnrs <= 1 and o.get().show_tabpages ~= "always" then
        return {}
    end

    return tabnrs
end

M.make_tabpage_tabs = function()
    local current_tabnr = api.nvim_get_current_tabpage()
    local tabpage_tabs = {}
    for i, tabnr in ipairs(M.tabinfo()) do
        table.insert(
            tabpage_tabs,
            Tabpage:new({
                index = i,
                current = tabnr == current_tabnr,
            })
        )
    end
    return tabpage_tabs
end

return M
