local o = require("buftabline.options")
local Tabpage = require("buftabline.tabpage-tab")

local M = {}

M.make_tabpage_tabs = function()
    local tabpage_tabs = {}
    if not o.get().show_tabpages then
        return tabpage_tabs
    end

    local tabpages = vim.fn.gettabinfo()
    if #tabpages <= 1 and o.get().show_tabpages ~= "always" then
        return tabpage_tabs
    end

    local current_tabnr = vim.fn.tabpagenr()
    for i, tabinfo in ipairs(tabpages) do
        table.insert(
            tabpage_tabs,
            Tabpage:new({
                index = i,
                current = tabinfo.tabnr == current_tabnr,
            })
        )
    end
    return tabpage_tabs
end

return M
