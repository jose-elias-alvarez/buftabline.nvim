local o = require("buftabline.options")

local set_hlgroup = function(text, current)
    local hlgroup = current and o.get().hlgroup_current or
                        o.get().hlgroup_normal
    if vim.fn.hlexists(hlgroup) == 0 then return text end
    return string.format("%%#%s#%s%%*", hlgroup, text)
end

return set_hlgroup
