local o = require("buftabline.options")
local h = require("buftabline.highlights")

local dir_separator = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):sub(-1)

local Buftab = {}
Buftab.__index = Buftab

-- new buftab methods
function Buftab:generate_hl()
    local hlgroups = o.get().hlgroups
    local name = self.buf.current and "current" or self.buf.active and "active" or "normal"

    -- backwards compatibility with old hlgroup_current and hlgroup_normal config keys
    if o.get()["hlgroup_" .. name] then
        self.hl = o.get()["hlgroup_" .. name]
        return
    end

    self.hl = self.buf.changed and hlgroups["modified_" .. name] or hlgroups[name] or hlgroups.normal or ""
end

function Buftab:generate_flags()
    local flags, buffer_flags = o.get().flags, {}
    if self.buf.changed and flags.modified ~= "" then
        table.insert(buffer_flags, flags.modified)
    end
    if not self.buf.modifiable and flags.not_modifiable ~= "" then
        table.insert(buffer_flags, flags.not_modifiable)
    end
    if self.buf.readonly and flags.readonly ~= "" then
        table.insert(buffer_flags, flags.readonly)
    end
    if vim.tbl_count(buffer_flags) > 0 then
        table.insert(buffer_flags, 1, "")
    end
    self.flags = table.concat(buffer_flags)
end

function Buftab:has_icon_colors()
    local icon_colors = o.get().icon_colors
    if icon_colors == true then
        return true
    end
    if icon_colors == "current" then
        return self.buf.current
    end
    if icon_colors == "normal" then
        return not self.buf.current
    end
    return false
end

function Buftab:generate_icon()
    local icon_pos = self.format:find("#{i}")
    if not icon_pos then
        return
    end

    local fname = vim.fn.fnamemodify(self.buf.name, ":t")
    local ext = vim.fn.fnamemodify(self.buf.name, ":e")
    if ext == "" then
        ext = vim.api.nvim_buf_get_option(self.buf.bufnr, "filetype")
    end

    local icon, icon_hl = require("nvim-web-devicons").get_icon(fname, ext, { default = true })
    self.icon = icon
    self.icon_pos = icon_pos
    self.icon_hl = self:has_icon_colors() and h.merge_hl(icon_hl, self.hl) or self.hl
end

function Buftab:new(buf, index, last)
    local t = {}
    t.index = o.get().buffer_id_index and buf.bufnr or index
    t.insert_at = index
    t.last = last

    t.buf = buf
    t.name = vim.fn.fnamemodify(buf.name, ":t")
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
    return self.buf.safe or adjusted > 0
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
        if existing.name == self.name and existing.buf.name ~= self.buf.name then
            return true
        end
    end
    return false
end

function Buftab:replace_template(option, val)
    local start_pos = self.label:find(option)
    if not start_pos then
        return
    end

    local len_before = #self.label
    self.label = self.label:gsub(option, val)
    if self.icon_pos and start_pos < self.icon_pos then
        self.icon_pos = self.icon_pos + #self.label - len_before
    end
end

function Buftab:generate(budget, tabs)
    local name = self.name
    if self:is_ambiguous(tabs) then
        local split_path = vim.split(self.buf.name, dir_separator)
        local disambiguated = { split_path[#split_path - 1], dir_separator, name }
        name = table.concat(disambiguated)
    end

    self.label = self.format
    self:replace_template("#{n}", self.index)
    self:replace_template("#{f}", self.flags)
    self:replace_template("#{i}", self.icon or "")
    self:replace_template("#{b}", name)

    local adjusted = budget - self:get_width()
    if not self:can_insert(adjusted) then
        self:truncate(adjusted)
    end

    self:highlight()
    return adjusted, self.label, self.last
end

return Buftab
