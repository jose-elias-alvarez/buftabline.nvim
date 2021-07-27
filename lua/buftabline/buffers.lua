local api = vim.api

local M = {}

local has_name = function(b)
    return vim.fn.fnamemodify(b.name, ":t") ~= ""
end

local getbufinfo = function()
    return vim.tbl_filter(has_name, vim.fn.getbufinfo({ buflisted = 1 }))
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

return M
