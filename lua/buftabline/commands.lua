local b = require("buftabline.buffers")
local o = require("buftabline.options")

local M = {}

local bufcmd = function(cmd, n)
    vim.cmd(string.format("%s %d", cmd, n))
end
M.bufcmd = bufcmd

local buftarget = function(n, cmd)
    if o.get().buffer_id_index then
        bufcmd(cmd, n)
        return
    end

    n = n == 0 and 10 or n
    local numbers = b.get_numbers()
    if not numbers[n] then
        return
    end

    bufcmd(cmd, numbers[n])
end
M.buftarget = buftarget

M.next_buffer = function()
    if o.get().buffer_id_index then
        vim.cmd("bnext")
        return
    end

    local next = b.get_current_index() + 1
    buftarget(b.get_numbers()[next] and next or 1, "buffer")
end

M.prev_buffer = function()
    if o.get().buffer_id_index then
        vim.cmd("bprev")
        return
    end

    local prev = b.get_current_index() - 1
    local numbers = b.get_numbers()
    buftarget(numbers[prev] and prev or #numbers, "buffer")
end

M.toggle_tabline = function()
    vim.o.showtabline = vim.o.showtabline > 0 and 0 or 2
end

M.auto_hide = function()
    vim.schedule(function()
        vim.o.showtabline = #b.getbufinfo() <= 1 and 0 or 2
    end)
end

return M
