local o = require("buftabline.options")
local h = require("buftabline.highlights")

local api = vim.api
local dir_separator = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):sub(-1)
local flags, hlgroups = o.get().flags, o.get().hlgroups

local get_hl = function(tab)
    local name = tab.current and "current" or vim.fn.bufwinnr(tab.buf.bufnr) > 0 and "active" or "normal"

    -- backwards compatibility with old hlgroup_current and hlgroup_normal config keys
    if o.get()["hlgroup_" .. name] then
        return o.get()["hlgroup_" .. name]
    end

    return tab.buf.changed > 0 and hlgroups["modified_" .. name] or hlgroups[name] or hlgroups.normal or ""
end

local get_flags = function(tab)
    local buffer_flags = {}
    if tab.buf.changed > 0 and type(flags.modified) == "string" and flags.modified ~= "" then
        table.insert(buffer_flags, flags.modified)
    end
    if
        not api.nvim_buf_get_option(tab.buf.bufnr, "modifiable")
        and type(flags.not_modifiable) == "string"
        and flags.not_modifiable ~= ""
    then
        table.insert(buffer_flags, flags.not_modifiable)
    end
    if
        api.nvim_buf_get_option(tab.buf.bufnr, "readonly")
        and type(flags.readonly) == "string"
        and flags.readonly ~= ""
    then
        table.insert(buffer_flags, flags.readonly)
    end
    if vim.tbl_count(buffer_flags) > 0 then
        table.insert(buffer_flags, 1, " ")
    end
    return table.concat(buffer_flags)
end

local Tab = {}

function Tab:__index(k)
    if k == "current" then
        return self.buf.bufnr == self.current_bufnr
    end
    if k == "label" then
        return rawget(self, k) or o.get().tab_format
    end
    if k == "name" then
        return rawget(self, k) or vim.fn.fnamemodify(self.buf.name, ":t")
    end
    if k == "flags" then
        return get_flags(self)
    end
    if k == "hl" then
        return get_hl(self)
    end
    if k == "width" then
        return vim.fn.strchars(self.label)
    end
    if k == "icon" or k == "icon_hl" or k == "icon_pos" then
        self:generate_icon()
    end

    return Tab[k] or rawget(self, k)
end

function Tab:new(t)
    setmetatable(t, self)
    return t
end

function Tab:can_insert(budget)
    return self.buf.bufnr <= self.current_bufnr or budget > 0
end

function Tab:has_icon_colors()
    local icon_colors = o.get().icon_colors
    if icon_colors == true then
        return true
    end
    if icon_colors == "current" then
        return self.current
    end
    if icon_colors == "normal" then
        return not self.current
    end
    return false
end

function Tab:generate_icon()
    if self._has_icon then
        return
    end
    local icon_pos = self.label:find("#{i}")
    if not icon_pos then
        return
    end

    local icon, icon_hl = require("nvim-web-devicons").get_icon(
        vim.fn.fnamemodify(self.buf.name, ":t"),
        vim.fn.fnamemodify(self.buf.name, ":e"),
        { default = true }
    )
    self.icon = icon
    self.icon_pos = icon_pos
    self.icon_hl = self:has_icon_colors() and h.merge_hl(icon_hl, self.hl) or self.hl
    self._has_icon = true
end

function Tab:truncate(budget)
    self.label = vim.fn.strcharpart(self.label, 0, self.width + budget - 1) .. ">"
    self.truncated = true
end

function Tab:highlight()
    if not self.icon then
        self.label = h.add_hl(self.label, self.hl)
        return
    end

    -- assume first space after icon represents icon end
    local icon_end = self.label:find("%s", self.icon_pos)
    if not icon_end then
        self.label = h.add_hl(self.label, self.hl)
        return
    end

    -- split tab to correctly apply highlights
    local before_icon_part = self.label:sub(1, self.icon_pos - 1)
    local icon_part = self.label:sub(self.icon_pos, icon_end)
    local after_icon_part = self.label:sub(icon_end + 1)

    self.label = h.add_hl(before_icon_part, self.hl)
        .. h.add_hl(icon_part, self.icon_hl)
        .. h.add_hl(after_icon_part, self.hl)
end

function Tab:generate(tabs, budget)
    if self:is_ambiguous(tabs) then
        local split_path = vim.split(self.buf.name, dir_separator)
        self.name = split_path[#split_path - 1] .. dir_separator .. self.name
    end

    self.label = self.label:gsub("#{n}", self.index)
    self.label = self.label:gsub("#{b}", self.name)
    self.label = self.label:gsub("#{f}", self.flags)
    self.label = self.label:gsub("#{i}", self.icon or "")

    budget = budget - self.width
    if not self:can_insert(budget) then
        self:truncate(budget)
    end

    self:highlight()
    return budget
end

function Tab:is_ambiguous(tabs)
    for _, existing in ipairs(tabs) do
        if existing.name == self.name and existing.buf.name ~= self.buf.name then
            return true
        end
    end
end

return Tab
