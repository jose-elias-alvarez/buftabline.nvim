local o = require("buftabline.options")

local add_commands = function()
    if o.get().disable_commands then
        return
    end

    vim.api.nvim_exec(
        [[
    command! ToggleBuftabline lua require("buftabline").toggle_tabline()
    command! BufNext lua require("buftabline").next_buffer()
    command! BufPrev lua require("buftabline").prev_buffer()
    ]],
        false
    )
end

return add_commands
