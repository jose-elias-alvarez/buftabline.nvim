local Buftab = require("buftabline.buftab")

local api = vim.api

local should_handle = function(bufnr)
    return api.nvim_buf_get_option(bufnr, "buflisted") and api.nvim_buf_get_name(bufnr) ~= ""
end

local getbufinfo = function()
    local current_bufnr = api.nvim_get_current_buf()
    local processed = {}
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if should_handle(bufnr) then
            table.insert(processed, {
                bufnr = bufnr,
                name = api.nvim_buf_get_name(bufnr),
                current = bufnr == current_bufnr,
                safe = bufnr <= current_bufnr,
                changed = api.nvim_buf_get_option(bufnr, "modified"),
                modifiable = api.nvim_buf_get_option(bufnr, "modifiable"),
                readonly = api.nvim_buf_get_option(bufnr, "readonly"),
                active = vim.fn.bufwinnr(bufnr) > 0,
            })
        end
    end
    return processed
end

local M = {}

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
