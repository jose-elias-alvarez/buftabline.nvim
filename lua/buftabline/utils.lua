local M = {}
M.string_replace = function(str, original, replacement)
    local found, found_end = string.find(str, original, nil, true)
    if not found then return end

    if str == original then return replacement end

    local first_half = string.sub(str, 0, found - 1)
    local second_half = string.sub(str, found_end + 1)

    return first_half .. replacement .. second_half
end

return M
