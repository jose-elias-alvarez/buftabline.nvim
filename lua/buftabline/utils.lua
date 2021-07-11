local api = vim.api
local format = string.format

local M = {}

M.define_command = function(name, fn)
    vim.cmd(format("command! %s lua require'buftabline.commands'.%s", name, fn))
end

M.define_autocmd = function(event, fn)
    api.nvim_exec(
        format(
            [[
        augroup Buftabline
            autocmd %s * lua require'buftabline.commands'.%s
        augroup END
            ]],
            event,
            fn
        ),
        false
    )
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
