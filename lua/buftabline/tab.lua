local o = require("buftabline.options")
local h = require("buftabline.highlights")

local api = vim.api
local dir_separator = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):sub(-1)

local Tab = {}
Tab.__index = Tab

-- new tab methods
function Tab:generate_hl()
    local hlgroups = o.get().hlgroups
    local name = self.current and "current" or vim.fn.bufwinnr(self.bufnr) > 0 and "active" or "normal"

    -- backwards compatibility with old hlgroup_current and hlgroup_normal config keys
    if o.get()["hlgroup_" .. name] then
        self.hl = o.get()["hlgroup_" .. name]
        return
    end

    self.hl = self.changed and hlgroups["modified_" .. name] or hlgroups[name] or hlgroups.normal or ""
end

function Tab:generate_flags()
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
    local icon_pos = self.label:find("#{i}")
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

function Tab:new(opts)
    local buf, index, current_bufnr, generator = opts.buf, opts.index, opts.current_bufnr, opts.generator

    local t = {}
    t.index = index
    t.generator = generator

    t.bufnr = buf.bufnr
    t.bufname = buf.name
    t.changed = buf.changed > 0
    t.current = buf.bufnr == current_bufnr
    t.position = buf.bufnr <= current_bufnr and "left" or "right"
    t.name = vim.fn.fnamemodify(buf.name, ":t")
    t.label = o.get().tab_format

    setmetatable(t, self)

    t:generate_hl()
    t:generate_flags()
    t:generate_icon()
    return t
end

-- generator methods
function Tab:can_insert(budget)
    return self.position == "left" or budget > 0
end

function Tab:get_width()
    return vim.fn.strchars(self.label)
end

function Tab:truncate(budget)
    self.label = vim.fn.strcharpart(self.label, 0, self:get_width() + budget - 1) .. ">"
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

function Tab:is_ambiguous(tabs)
    for _, existing in ipairs(tabs) do
        if existing.name == self.name and existing.bufname ~= self.bufname then
            return true
        end
    end
    return false
end

function Tab:generate(tabs, budget)
    local name = self.name
    if self:is_ambiguous(tabs) then
        local split_path = vim.split(self.bufname, dir_separator)
        name = split_path[#split_path - 1] .. dir_separator .. name
    end

    self.label = self.label:gsub("#{n}", self.index)
    self.label = self.label:gsub("#{f}", self.flags)
    self.label = self.label:gsub("#{i}", self.icon or "")
    self.label = self.label:gsub("#{b}", name)

    budget = budget - self:get_width()
    if not self:can_insert(budget) then
        self:truncate(budget)
    end

    self:highlight()
    return budget
end

return Tab
