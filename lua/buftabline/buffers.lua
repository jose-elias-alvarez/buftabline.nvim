local o = require("buftabline.options")
local Buftab = require("buftabline.buftab")

local api = vim.api

local state = {}

local is_visible = function(bufnr, current_tabpage)
    if not o.get().tabpage_buffers then
        return state[bufnr]
    end
    return state[bufnr] and state[bufnr].tabpages[current_tabpage]
end

local should_handle = function(bufnr)
    return api.nvim_buf_get_option(bufnr, "buflisted") and api.nvim_buf_get_name(bufnr) ~= ""
end

local getbufinfo = function()
    local current_bufnr, current_tabpage = api.nvim_get_current_buf(), api.nvim_tabpage_get_number(0)
    local processed = {}
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if is_visible(bufnr, current_tabpage) then
            table.insert(processed, {
                bufnr = bufnr,
                name = state[bufnr].name,
                tabpages = state[bufnr].tabpages,
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

-- autocommands
M.on_buffer_add = function()
    local bufnr = tonumber(vim.fn.expand("<abuf>"))
    if not should_handle(bufnr) then
        return
    end

    state[bufnr] = state[bufnr] or { name = api.nvim_buf_get_name(bufnr), tabpages = {} }
    if o.get().tabpage_buffers then
        state[bufnr].tabpages[api.nvim_tabpage_get_number(0)] = true
    end
end

M.on_buffer_delete = function()
    local bufnr = tonumber(vim.fn.expand("<abuf>"))
    state[bufnr] = nil
end

M.on_tab_closed = function()
    if not o.get().tabpage_buffers then
        return
    end

    local closed = tonumber(vim.fn.expand("<afile>"))
    for bufnr, info in pairs(state) do
        if info.tabpages[closed] then
            info.tabpages[closed] = nil
            -- try to delete buffer if it's not visible in any other tabpages
            if vim.tbl_count(info.tabpages) == 0 then
                if not api.nvim_buf_get_option(bufnr, "modified") then
                    vim.cmd("bdelete " .. bufnr)
                else
                    -- kick modified buffer back to previous tabpage so it doesn't become invisible
                    info.tabpages[closed - 1] = true
                end
            end
        end
    end
end

return M
