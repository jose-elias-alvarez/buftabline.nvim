local o = require("buftabline.options")
local set_hlgroup = require("buftabline.set-hlgroup")

local exclude_buffer = function(bufnr)
    return vim.fn.getbufvar(bufnr, "&filetype") == "qf"
end

local get_flags = function(buffer)
    local flags = {}
    if buffer.readonly then table.insert(flags, "[RO]") end
    if not buffer.modifiable then table.insert(flags, "[-]") end
    if buffer.modified then table.insert(flags, "[+]") end
    return table.concat(flags)
end

local M = {}
local get_name = function(buffer)
    local name = "[No Name]"
    local index = buffer.index
    local modifier = o.get().modifier
    if vim.fn.bufname(buffer.bufnr) ~= "" then
        name = vim.fn.fnamemodify(vim.fn.bufname(buffer.bufnr), modifier)
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

local get_bufname_base = function()
    local bufname_base = {"%s"}
    local padding = o.get().padding
    if padding then
        for _ = 1, padding do
            table.insert(bufname_base, " ")
            table.insert(bufname_base, 1, " ")
        end
    end
    return table.concat(bufname_base)
end
M.get_bufname_base = get_bufname_base

local get_buf_numbers = function()
    local numbers = {}
    for i, bufinfo in ipairs(vim.fn.getbufinfo({buflisted = 1})) do
        numbers[i] = bufinfo.bufnr
    end
    return numbers
end
M.get_buf_numbers = get_buf_numbers

M.get_current_buf_number = function()
    local current_bufnr = vim.fn.bufnr()
    for i, v in ipairs(get_buf_numbers()) do
        if v == current_bufnr then return i end
    end
end

M.get_buffers = function()
    local buffers = {}
    local current_bufnr = vim.fn.bufnr()
    local last_timestamp, last_buffer
    for i, bufinfo in ipairs(vim.fn.getbufinfo({buflisted = 1})) do
        if not exclude_buffer(bufinfo.bufnr) then
            local buffer = {
                index = i,
                bufnr = bufinfo.bufnr,
                current = bufinfo.bufnr == current_bufnr,
                modifiable = vim.fn.getbufvar(bufinfo.bufnr, "&modifiable") == 1,
                modified = vim.fn.getbufvar(bufinfo.bufnr, "&modified") == 1,
                readonly = vim.fn.getbufvar(bufinfo.bufnr, "&readonly") == 1,
                extension = vim.fn.expand("#" .. bufinfo.bufnr .. ":e")
            }
            if not last_timestamp or bufinfo.lastused > last_timestamp then
                last_timestamp, last_buffer = bufinfo.lastused, buffer
            end
            table.insert(buffers, buffer)
        end
    end
    if last_buffer and exclude_buffer(current_bufnr) then
        last_buffer.current = true
    end
    return buffers
end

local get_icon = function(buffer)
    return require("nvim-web-devicons").get_icon(buffer.fname, buffer.extension,
                                                 {default = true})
end
M.get_icon = get_icon

M.generate_tab = function(buffer)
    local tab = {}
    local bufname = string.format(get_bufname_base(), get_name(buffer))
    table.insert(tab, set_hlgroup(bufname, buffer.current))

    if o.get().icons then
        table.insert(tab, set_hlgroup(get_icon(buffer) .. " ", buffer.current))
    end
    return table.concat(tab)
end

return M
