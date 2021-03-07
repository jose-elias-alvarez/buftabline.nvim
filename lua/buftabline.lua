local b = require("buftabline.buffers")
local h = require("buftabline.hlgroups")
local o = require("buftabline.options")
local set_bufferline = require("buftabline.bufferline")
local set_maps = require("buftabline.maps")
local fmt = string.format
local status, devicons = pcall(require, "nvim-web-devicons")

local M = {}
M.build_bufferline = function()
    local buffers = b.get_buffers()
    local bufferline, buflist = {}, {}
    for _, buffer in ipairs(buffers) do
        local bufname = fmt(" %s ", b.get_name(buffer))
        table.insert(buflist, h.set_hlgroup(bufname, buffer.current))
        if o.get_options().icons then
            if status == false then
                error("nvim-web-devicons is not installed")
            end
            local icon = devicons.get_icon(vim.fn.bufname(buffer.bufnr),
                                           buffer.filetype)
            if (icon) then
                table.insert(buflist, h.set_hlgroup(icon .. " ", buffer.current))
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

function M.go_to_buffer(num) buftarget(num, "buffer") end
function M.kill_buffer(num) buftarget(num, "bd") end
function M.custom_command(num)
    local cmd = o.get_options().custom_command
    if cmd == nil then error("custom command not set") end
    buftarget(num, cmd)
end

M.toggle_tabline = function()
    if vim.o.showtabline > 0 then
        vim.o.showtabline = 0
    else
        vim.o.showtabline = 2
    end
end

function M.setup(user_options)
    o.set_options(user_options)
    set_bufferline()
    set_maps()
    if not o.get_options().no_link_hlgroups then h.link_hlgroups() end
end

return M
