local o = require("buftabline.options")

local M = {}

M.string_replace = function(str, original, replacement)
    local found, found_end = string.find(str, original, nil, true)
    if not found then
        return
    end

    if str == original then
        return replacement
    end

    local first_half = string.sub(str, 0, found - 1)
    local second_half = string.sub(str, found_end + 1)

    return first_half .. replacement .. second_half
end

M.pad = function(text, right_only)
    local padding = o.get().padding
    if not padding or padding == 0 then
        return text
    end

    local padded = { text }
    for _ = 1, padding do
        table.insert(padded, " ")
        if not right_only then
            table.insert(padded, 1, " ")
        end
    end
    return table.concat(padded)
end

return M
