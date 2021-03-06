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
    if o().hlgroup_current == "BufTabLineCurrent" then
        vim.cmd("hi default link BufTabLineCurrent TabLineSel")
    end
    if o().hlgroup_normal == "BufTabLineFill" then
        vim.cmd("hi default link BufTabLineFill TabLineFill")
    end
end

return M
