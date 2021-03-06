local o = require("buftabline.options").get_options
local fmt = string.format

local exclude_buffer = function(bufnr)
    return
        vim.fn.buflisted(bufnr) == 0 or vim.fn.getbufvar(bufnr, "&filetype") ==
            "qf"
end

local get_flags = function(buffer)
    local flags = {}
    if buffer.readonly then table.insert(flags, "[RO]") end
    if not buffer.modifiable then table.insert(flags, "[-]") end
    if buffer.modified then table.insert(flags, "[+]") end
    return table.concat(flags)
end

local M = {}

M.get_name = function(buffer)
    local name = "[No Name]"
    local index = buffer.index
    local modifier = o().modifier
    if vim.fn.bufname(buffer.bufnr) ~= "" then
        name = vim.fn.fnamemodify(vim.fn.bufname(buffer.bufnr), modifier)
    end

    local flags = get_flags(buffer)
    if flags ~= "" then
        name = fmt("%d: %s %s", index, name, flags)
    else
        name = fmt("%d: %s", index, name)
    end
    return name
end

M.get_buf_numbers = function()
    local numbers = {}
    for i, bufinfo in ipairs(vim.fn.getbufinfo({buflisted = 1})) do
        numbers[i] = bufinfo.bufnr
    end
    return numbers
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
                readonly = vim.fn.getbufvar(bufinfo.bufnr, "&readonly") == 1
            }
            if not last_timestamp or bufinfo.lastused > last_timestamp then
                last_timestamp, last_buffer = bufinfo.lastused, buffer
            end
            table.insert(buffers, buffer)
        end
    end
    if exclude_buffer(current_bufnr) then last_buffer.current = true end
    return buffers
end

return M

