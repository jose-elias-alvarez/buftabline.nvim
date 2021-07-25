local o = require("buftabline.options")
local h = require("buftabline.highlights")

local get_hl = function(tabpage)
    local hlgroups = o.get().hlgroups
    return tabpage.current and (hlgroups.tabpage_current or hlgroups.current)
        or hlgroups.tabpage_normal
        or hlgroups.normal
end

local Tabpage = {}

function Tabpage:new(t)
    setmetatable(t, self)
    return t
end

function Tabpage:__index(k)
    if k == "current" then
        return self.tabinfo.tabnr == self.current_tabnr
    end
    if k == "label" then
        return rawget(self, k) or o.get().tabpage_format
    end
    if k == "hl" then
        return get_hl(self)
    end
    if k == "width" then
        return vim.fn.strchars(self.label)
    end

    return Tabpage[k] or rawget(self, k)
end

function Tabpage:highlight()
    self.label = h.add_hl(self.label, self.hl)
end

function Tabpage:generate(budget)
    self.label = self.label:gsub("#{n}", self.index)
    budget = budget - self.width

    self:highlight()
    return budget
end

return Tabpage
