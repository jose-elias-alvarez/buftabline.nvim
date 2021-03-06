local o = require("buftabline.options").get_options
local fmt = string.format

local M = {}
M.set_hlgroup = function(text, current)
    local hlgroup
    if (current) then
        hlgroup = o().hlgroup_current
    else
        hlgroup = o().hlgroup_normal
    end
    if vim.fn.hlexists(hlgroup) == 0 then return text end
    return fmt("%%#%s#%s%%*", hlgroup, text)
end

M.link_hlgroups = function()
    vim.cmd("hi default link " .. o().hlgroup_current .. " TabLineSel")
    vim.cmd("hi default link " .. o().hlgroup_normal .. " TabLineFill")
end

return M
