local o = require("buftabline.options")
local h = require("buftabline.highlights")

local api = vim.api
local dir_separator = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):sub(-1)

local Buftab = {}
Buftab.__index = Buftab

-- new buftab methods
function Buftab:generate_hl()
    local hlgroups = o.get().hlgroups
    local name = self.current and "current" or vim.fn.bufwinnr(self.bufnr) > 0 and "active" or "normal"

    -- backwards compatibility with old hlgroup_current and hlgroup_normal config keys
    if o.get()["hlgroup_" .. name] then
        self.hl = o.get()["hlgroup_" .. name]
        return
    end

    self.hl = self.changed and hlgroups["modified_" .. name] or hlgroups[name] or hlgroups.normal or ""
end

function Buftab:generate_flags()
    local flags, buffer_flags = o.get().flags, {}
    if self.changed and flags.modified ~= "" then
        table.insert(buffer_flags, flags.modified)
    end
    if not api.nvim_buf_get_option(self.bufnr, "modifiable") and flags.not_modifiable ~= "" then
        table.insert(buffer_flags, flags.not_modifiable)
    end
    if api.nvim_buf_get_option(self.bufnr, "readonly") and flags.readonly ~= "" then
        table.insert(buffer_flags, flags.readonly)
    end
    if vim.tbl_count(buffer_flags) > 0 then
        table.insert(buffer_flags, 1, " ")
    end
    self.flags = table.concat(buffer_flags)
end

function Buftab:has_icon_colors()
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

function Buftab:generate_icon()
    local icon_pos = self.format:find("#{i}")
    if not icon_pos then
        return
    end

    local icon, icon_hl = require("nvim-web-devicons").get_icon(
        vim.fn.fnamemodify(self.bufname, ":t"),
        vim.fn.fnamemodify(self.bufname, ":e"),
        { default = true }
    )
    self.icon = icon
    self.icon_pos = icon_pos
    self.icon_hl = self:has_icon_colors() and h.merge_hl(icon_hl, self.hl) or self.hl
end

function Buftab:new(opts)
    local bufinfo, index, current, safe, last = opts.bufinfo, opts.index, opts.current, opts.safe, opts.last

    local t = {}
    t.current = current
    t.safe = safe
    t.last = last

    t.index = o.get().buffer_id_index and bufinfo.bufnr or index
    t.insert_at = index
    t.bufnr = bufinfo.bufnr
    t.bufname = bufinfo.name
    t.changed = bufinfo.changed > 0
    t.name = vim.fn.fnamemodify(bufinfo.name, ":t")
    t.format = o.get().tab_format
    t.position = "left"

    setmetatable(t, self)

    t:generate_hl()
    t:generate_flags()
    t:generate_icon()
    return t
end

-- generator methods
function Buftab:can_insert(adjusted)
    return self.safe or adjusted > 0
end

function Buftab:get_width()
    return vim.fn.strchars(self.label)
end

function Buftab:truncate(adjusted)
    self.label = vim.fn.strcharpart(self.label, 0, self:get_width() + adjusted - 1) .. ">"
    self.last = true
end

function Buftab:highlight()
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

    local highlighted = {
        h.add_hl(before_icon_part, self.hl),
        h.add_hl(icon_part, self.icon_hl),
        h.add_hl(after_icon_part, self.hl),
    }
    self.label = table.concat(highlighted)
end

function Buftab:is_ambiguous(tabs)
    for _, existing in ipairs(tabs) do
        if existing.name == self.name and existing.bufname ~= self.bufname then
            return true
        end
    end
    return false
end

function Buftab:generate(budget, tabs)
    local name = self.name
    if self:is_ambiguous(tabs) then
        local split_path = vim.split(self.bufname, dir_separator)
        local disambiguated = { split_path[#split_path - 1], dir_separator, name }
        name = table.concat(disambiguated)
    end

    self.label = self.format
    self.label = self.label:gsub("#{n}", self.index)
    self.label = self.label:gsub("#{f}", self.flags)
    self.label = self.label:gsub("#{i}", self.icon or "")
    self.label = self.label:gsub("#{b}", name)

    local adjusted = budget - self:get_width()
    if not self:can_insert(adjusted) then
        self:truncate(adjusted)
    end

    self:highlight()
    return adjusted, self.label
end

return Buftab
