local Buftab = require("buftabline.buftab")

local api = vim.api

local M = {}

local has_name = function(b)
    return vim.fn.fnamemodify(b.name, ":t") ~= ""
end

local getbufinfo = function()
    local current_bufnr = api.nvim_get_current_buf()
    local processed = {}
    for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if has_name(b) then
            table.insert(processed, {
                name = b.name,
                bufnr = b.bufnr,
                changed = b.changed > 0,
                current = b.bufnr == current_bufnr,
                safe = b.bufnr <= current_bufnr,
                modifiable = api.nvim_buf_get_option(b.bufnr, "modifiable"),
                readonly = api.nvim_buf_get_option(b.bufnr, "readonly"),
                active = vim.fn.bufwinnr(b.bufnr) > 0,
            })
        end
    end
    return processed
end
M.getbufinfo = getbufinfo

M.get_numbers = function()
    local numbers = {}
    for _, buf in ipairs(getbufinfo()) do
        table.insert(numbers, buf.bufnr)
    end
    return numbers
end

M.get_current_index = function()
    local current = api.nvim_get_current_buf()
    for i, buf in ipairs(getbufinfo()) do
        if buf.bufnr == current then
            return i
        end
    end
end

M.make_buftabs = function()
    local bufinfo = getbufinfo()
    local buftabs = {}
    for i, buf in ipairs(bufinfo) do
        table.insert(buftabs, Buftab:new(buf, i, i == #bufinfo))
    end
    return buftabs
end

return M
