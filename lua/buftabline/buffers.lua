local api = vim.api

local M = {}

local has_name = function(b)
    return vim.fn.fnamemodify(b.name, ":t") ~= ""
end
M.has_name = has_name

local getbufinfo = function()
    return vim.fn.getbufinfo({ buflisted = 1 })
end
M.getbufinfo = getbufinfo

M.get_numbers = function()
    local numbers = {}
    for _, buf in ipairs(getbufinfo()) do
        if has_name(buf) then
            table.insert(numbers, buf.bufnr)
        end
    end
    return numbers
end

M.get_count = function()
    local count = 0
    for _, buf in ipairs(getbufinfo()) do
        count = has_name(buf) and count + 1 or count
    end
    return count
end

M.get_current_index = function()
    local current = api.nvim_get_current_buf()
    for i, buf in ipairs(getbufinfo()) do
        if buf.bufnr == current then
            return i
        end
    end
end

return M
