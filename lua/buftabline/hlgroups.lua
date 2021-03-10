local o = require("buftabline.options")

local M = {}
M.set_hlgroup = function(text, current)
    local hlgroup
    if (current) then
        hlgroup = o.get().hlgroup_current
    else
        hlgroup = o.get().hlgroup_normal
    end
    if vim.fn.hlexists(hlgroup) == 0 then return text end
    return string.format("%%#%s#%s%%*", hlgroup, text)
end

M.link_hlgroups = function()
    if o.get().hlgroup_current == "BufTabLineCurrent" then
        vim.cmd("hi default link BufTabLineCurrent TabLineSel")
    end
    if o.get().hlgroup_normal == "BufTabLineFill" then
        vim.cmd("hi default link BufTabLineFill TabLineFill")
    end
end

return M
