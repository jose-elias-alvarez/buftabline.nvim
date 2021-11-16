local o = require("buftabline.options")
local h = require("buftabline.highlights")

local Tabpage = {}
Tabpage.__index = Tabpage

-- new tabpage methods
function Tabpage:generate_hl()
    local hlgroups = o.get().hlgroups
    local name = self.current and "current" or "normal"
    self.hl = hlgroups["tabpage_" .. name] or hlgroups[name] or hlgroups.normal or ""
end

function Tabpage:new(opts)
    local index, current = opts.index, opts.current

    local t = {}
    t.index = index
    t.insert_at = index
    t.current = current
    t.format = o.get().tabpage_format
    t.position = o.get().tabpage_position

    setmetatable(t, self)

    t:generate_hl()
    return t
end

-- generator methods
function Tabpage:get_width()
    return vim.fn.strchars(self.label)
end

function Tabpage:highlight()
    self.label = h.add_hl(self.label, self.hl)
end

function Tabpage:generate(budget)
    self.label = self.format
    self.label = self.label:gsub("#{n}", self.index)
    local adjusted = budget - self:get_width()

    self:highlight()
    return adjusted, self.label
end

return Tabpage
