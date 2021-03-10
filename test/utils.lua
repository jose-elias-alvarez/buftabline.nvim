local M = {}

function deepcopy(original)
    local original_type = type(original)
    local copy
    if original_type == "table" then
        copy = {}
        for orig_key, orig_value in next, original, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end
M.deepcopy = deepcopy

function tablelength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end
M.tablelength = tablelength

return M
