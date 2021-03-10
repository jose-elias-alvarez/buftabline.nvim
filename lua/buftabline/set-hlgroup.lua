local o = require("buftabline.options")

local set_hlgroup = function(text, current)
    local hlgroup
    if (current) then
        hlgroup = o.get().hlgroup_current
    else
        hlgroup = o.get().hlgroup_normal
    end
    if vim.fn.hlexists(hlgroup) == 0 then return text end
    return string.format("%%#%s#%s%%*", hlgroup, text)
end

return set_hlgroup
