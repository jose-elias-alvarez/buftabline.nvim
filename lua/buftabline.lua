local b = require("buftabline.buffers")
local o = require("buftabline.options")
local set_bufferline = require("buftabline.set-bufferline")
local set_maps = require("buftabline.set-maps")
local add_commands = require("buftabline.add-commands")

local M = {}
M.build_bufferline = function()
    local bufferline = {}
    for _, buffer in ipairs(b.get_buffers()) do
        table.insert(bufferline, b.generate_tab(buffer))
    end
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

M.next_buffer = function()
    local next = b.get_current_buf_number() + 1
    buftarget(b.get_buf_numbers()[next] and next or 1, "buffer")
end
M.prev_buffer = function()
    local prev = b.get_current_buf_number() - 1
    buftarget(b.get_buf_numbers()[prev] and prev or (#b.get_buf_numbers()),
              "buffer")
end

M.toggle_tabline = function()
    vim.o.showtabline = vim.o.showtabline > 0 and 0 or 2
end

M.setup = function(user_options)
    o.set(user_options)
    set_bufferline()
    set_maps()
    add_commands()
end

return M
