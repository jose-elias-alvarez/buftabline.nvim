local o = require("buftabline.options")
local b = require("buftabline.buffers")
local Tab = require("buftabline.tab")

local api = vim.api

return function()
    local budget = vim.o.columns
    local current_bufnr = api.nvim_get_current_buf()
    local tabs, skipped = {}, 0
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

    for i, buf in ipairs(b.getbufinfo()) do
        if b.has_name(buf) then
            table.insert(tabs, buf_to_tab(buf, i))
        else
            skipped = skipped + 1
        end
    end

    local labels = {}
    for _, tab in ipairs(tabs) do
        local label, done = tab:generator()
        table.insert(labels, label)
        if done then
            break
        end
    end
    return table.concat(labels)
end
