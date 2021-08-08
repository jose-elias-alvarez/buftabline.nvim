local api = vim.api
local format = string.format

local M = {}

M.echo_warning = function(message)
    api.nvim_echo({ { "buftabline.nvim: " .. message, "WarningMsg" } }, true, {})
end

M.define_command = function(name, fn)
    vim.cmd(format("command! %s lua require'buftabline.commands'.%s", name, fn))
end

M.define_autocmd = function(event, fn, cond)
    api.nvim_exec(
        format(
            [[
        augroup Buftabline
            autocmd %s %s lua require'buftabline.commands'.%s
        augroup END
            ]],
            event,
            cond or "*",
            fn
        ),
        false
    )
end

M.clear_augroup = function()
    api.nvim_exec(
        format([[
        augroup Buftabline
            autocmd!
        augroup END
            ]]),
        false
    )
    vim.cmd("autocmd! Buftabline")
end

M.map = function(opts)
    local prefix, cmd, max = opts.prefix, opts.cmd, opts.max
    max = max or 9

    for i = 0, max do
        api.nvim_set_keymap(
            "n",
            prefix .. i,
            format(":lua require'buftabline.commands'.buftarget(%d, '%s')<CR>", i, cmd),
            { silent = true, nowait = true, noremap = true }
        )
    end
end

return M
