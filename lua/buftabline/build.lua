local b = require("buftabline.buffers")
local h = require("buftabline.highlights")
local o = require("buftabline.options")

local make_separator = function(budget)
    local spacing = {}
    for _ = 1, budget do
        table.insert(spacing, " ")
    end

    local to_string = table.concat(spacing)
    local hl = o.get().hlgroups.spacing
    return hl and h.add_hl(to_string, hl) or to_string
end

return function()
    local budget = vim.o.columns
    local tabs = b.make_buftabs()
    local labels = {}
    for _, tab in ipairs(tabs) do
        local remaining, label, last = tab:generate(budget, tabs)
        budget = remaining

        table.insert(labels, tab.insert_at, label)
        if last then
            break
        end
    end

    table.insert(labels, make_separator(budget))

    return table.concat(labels)
end
