local o = require("buftabline.options")

local exclude_buffer = function(bufnr)
    return vim.fn.getbufvar(bufnr, "&filetype") == "qf"
end

local get_icon = function(buffer)
    return require("nvim-web-devicons").get_icon(buffer.fname, buffer.extension, { default = true })
end

local M = {}

local get_buf_numbers = function()
    local numbers = {}
    for _, bufinfo in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if bufinfo.name ~= "" or o.get().show_no_name_buffers then
            table.insert(numbers, bufinfo.bufnr)
        end
    end
    return numbers
end
M.get_buf_numbers = get_buf_numbers

M.get_current_buf_number = function()
    local current_bufnr = vim.fn.bufnr()
    for i, v in ipairs(get_buf_numbers()) do
        if v == current_bufnr then
            return i
        end
    end
end

M.get_buffers = function()
    local buffers = {}
    local skipped, last_timestamp, last_buffer = 0, nil, nil
    local current_bufnr = vim.api.nvim_get_current_buf()
    for i, bufinfo in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
        if not exclude_buffer(bufinfo.bufnr) then
            local buffer = {
                index = i - skipped,
                bufnr = bufinfo.bufnr,
                name = bufinfo.name,
                current = bufinfo.bufnr == current_bufnr,
                modifiable = vim.fn.getbufvar(bufinfo.bufnr, "&modifiable") == 1,
                modified = vim.fn.getbufvar(bufinfo.bufnr, "&modified") == 1,
                readonly = vim.fn.getbufvar(bufinfo.bufnr, "&readonly") == 1,
                extension = vim.fn.fnamemodify(bufinfo.name, ":e"),
                fname = vim.fn.fnamemodify(bufinfo.name, ":t"),
            }
            if o.get().icons then
                buffer.icon, buffer.icon_hl = get_icon(buffer)
            end
            if o.get().buffer_id_index then
                buffer.index = buffer.bufnr
            end

            if not last_timestamp or bufinfo.lastused > last_timestamp then
                last_timestamp, last_buffer = bufinfo.lastused, buffer
            end

            for _, existing_buffer in ipairs(buffers) do
                if existing_buffer.fname == buffer.fname then
                    buffer.ambiguous = true
                    existing_buffer.ambiguous = true
                end
            end

            if buffer.name == "" and not o.get().show_no_name_buffers then
                skipped = skipped + 1
            else
                table.insert(buffers, buffer)
            end
        end
    end

    if last_buffer and exclude_buffer(current_bufnr) then
        last_buffer.current = true
    end
    return buffers
end

return M
