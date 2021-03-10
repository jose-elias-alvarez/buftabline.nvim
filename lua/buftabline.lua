local b = require("buftabline.buffers")
local o = require("buftabline.options")
local set_bufferline = require("buftabline.set-bufferline")
local set_maps = require("buftabline.set-maps")
local set_hlgroup = require("buftabline.set-hlgroup")
local status, devicons = pcall(require, "nvim-web-devicons")

local M = {}
M.build_bufferline = function()
    local buffers = b.get_buffers()
    local bufferline, buflist = {}, {}
    for _, buffer in ipairs(buffers) do
        local bufname = string.format(" %s ", b.get_name(buffer))
        table.insert(buflist, set_hlgroup(bufname, buffer.current))
        if o.get().icons then
            if status == false then
                error("nvim-web-devicons is not installed")
            end
            local icon = devicons.get_icon(vim.fn.bufname(buffer.bufnr),
                                           buffer.filetype)
            if (icon) then
                table.insert(buflist, set_hlgroup(icon .. " ", buffer.current))
            end
        end

    end
    table.insert(bufferline, table.concat(buflist))
    return table.concat(bufferline)
end

local buftarget = function(number, command)
    if number == 0 then number = 10 end

    local buf_numbers = b.get_buf_numbers()
    if number <= #buf_numbers then
        vim.cmd(command .. " " .. buf_numbers[number])
    end
end
M.buftarget = buftarget

M.go_to_buffer = function(num) buftarget(num, "buffer") end
M.kill_buffer = function(num) buftarget(num, "bd") end
M.custom_command = function(num)
    local cmd = o.get().custom_command
    if not cmd then error("custom command not set") end
    buftarget(num, cmd)
end

M.toggle_tabline = function()
    vim.o.showtabline = vim.o.showtabline > 0 and 0 or 2
end

M.setup = function(user_options)
    o.set(user_options)
    set_bufferline()
    set_maps()
end

return M
