local o = require("buftabline.options")
local set_bufferline = require("buftabline.set-bufferline")

describe("set_bufferline", function()
    it("should set showtabline to 0 when start_hidden == true", function()
        o.set({start_hidden = true})

        set_bufferline()

        assert.equals(vim.o.showtabline, 0)
    end)

    it("should set showtabline to 2 when start_hidden == false", function()
        o.set({start_hidden = false})

        set_bufferline()

        assert.equals(vim.o.showtabline, 2)
    end)

    it("should set tabline correctly", function()
        vim.o.tabline = ""

        set_bufferline()

        assert.equals(vim.o.tabline,
                      [[%!luaeval('require("buftabline").build_bufferline()')]])
    end)
end)
