local b = require("buftabline.buffers")
local o = require("buftabline.options")
local set_hlgroup = require("buftabline.set-hlgroup")

local M = {}

local get_flags = function(buffer)
    local flags = {}
    if buffer.readonly then table.insert(flags, "[RO]") end
    if not buffer.modifiable then table.insert(flags, "[-]") end
    if buffer.modified then table.insert(flags, "[+]") end
    return table.concat(flags)
end

local get_name = function(buffer)
    local name = "[No Name]"
    local index = buffer.index
    local modifier = o.get().modifier
    if buffer.name ~= "" then
        name = vim.fn.fnamemodify(buffer.name, modifier)
        if buffer.ambiguous then
            local split = vim.split(buffer.name, "/")
            name = split[vim.tbl_count(split) - 1] .. "/" .. name
        end
    end

    local index_format = o.get().index_format
    local flags = get_flags(buffer)
    if flags ~= "" then
        name = string.format(index_format .. "%s %s", index, name, flags)
    else
        name = string.format(index_format .. "%s", index, name)
    end
    return name
end
M.get_name = get_name

local get_padded_base = function()
    local base = {"%s"}
    local padding = o.get().padding
    if padding and padding > 0 then
        for _ = 1, padding do
            table.insert(base, " ")
            table.insert(base, 1, " ")
        end
    end
    return table.concat(base)
end
M.get_padded_base = get_padded_base

local get_icon = function(buffer)
    return require("nvim-web-devicons").get_icon(buffer.fname, buffer.extension,
                                                 {default = true})
end
M.get_icon = get_icon

local generate_tab = function(buffer)
    local tab = {}
    local bufname = string.format(get_padded_base(), get_name(buffer))
    table.insert(tab, set_hlgroup(bufname, buffer.current))

    if o.get().icons then
        table.insert(tab, set_hlgroup(get_icon(buffer) .. " ", buffer.current))
    end
    return table.concat(tab)
end

M.set = function()
    vim.o.showtabline = o.get().start_hidden and 0 or 2
    vim.o.tabline = [[%!luaeval('require("buftabline").build_bufferline()')]]
end

M.build = function()
    local bufferline = {}
    for _, buffer in ipairs(b.get_buffers()) do
        table.insert(bufferline, generate_tab(buffer))
    end
    return table.concat(bufferline)
end

return M
