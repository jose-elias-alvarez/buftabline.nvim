local o = require("buftabline.options")
local auto_hide = require("buftabline.auto-hide")

local open_buffers = function(count)
    for i = 1, count do
        vim.cmd("e" .. i)
    end
end

describe("watch", function()
    after_each(function()
        vim.cmd("bufdo! bwipeout!")
    end)

    it("should set showtabline to 0 when only 1 buffer is open", function()
        open_buffers(1)

        auto_hide.watch()

        assert.equals(vim.o.showtabline, 0)
    end)

    it("should set showtabline to 2 when more than one buffer is open", function()
        open_buffers(2)

        auto_hide.watch()

        assert.equals(vim.o.showtabline, 2)
    end)
end)

describe("setup", function()
    before_each(function()
        o.set({})
        vim.api.nvim_exec([[
        augroup WatchBuffers
            autocmd!
        augroup END
        ]], false)
    end)

    it("should not set autocmd when auto_hide is false", function()
        o.set({ auto_hide = false })

        auto_hide.setup()

        assert.equals(vim.fn.exists("#WatchBuffers#BufEnter,BufCreate"), 0)
    end)

    it("should not set autocmd when auto_hide and start_hidden are both true", function()
        o.set({ auto_hide = true, start_hidden = true })

        auto_hide.setup()

        assert.equals(vim.fn.exists("#WatchBuffers#BufEnter,BufCreate"), 0)
    end)

    it("should set autocmd when auto_hide is true and start_hidden is false", function()
        o.set({ auto_hide = true, start_hidden = false })

        auto_hide.setup()

        assert.equals(vim.fn.exists("#WatchBuffers#BufEnter,BufCreate"), 1)
    end)
end)
