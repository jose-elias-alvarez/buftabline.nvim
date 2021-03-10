local o = require("buftabline.options")
local b = require("buftabline.buffers")
local buftabline = require("buftabline")

local reset = function() vim.cmd("bufdo bwipeout!") end

describe("buftarget", function()
    it("should call specified command on specified buffer", function()
        reset()
        for i = 1, 5 do vim.cmd("e" .. i) end

        buftabline.buftarget(1, "buffer")
        local buffers = b.get_buffers()

        assert.equals(buffers[1].current, true)
    end)

    it("should target 10th buffer when number == 0", function()
        reset()
        for i = 1, 10 do vim.cmd("e" .. i) end

        buftabline.buftarget(1, "buffer")
        buftabline.buftarget(10, "buffer")
        local buffers = b.get_buffers()

        assert.equals(buffers[10].current, true)
    end)
end)

describe("toggle_tabline", function()
    it("should hide tabline when visible", function()
        vim.o.showtabline = 2

        buftabline.toggle_tabline()

        assert.equals(vim.o.showtabline, 0)
    end)

    it("should show tabline when hidden", function()
        vim.o.showtabline = 0

        buftabline.toggle_tabline()

        assert.equals(vim.o.showtabline, 2)
    end)
end)

describe("custom_command", function()
    it("should call custom command when set", function()
        o.set({custom_command = "buffer"})
        reset()
        for i = 1, 5 do vim.cmd("e" .. i) end

        buftabline.custom_command(1)
        local buffers = b.get_buffers()

        assert.equals(buffers[1].current, true)
    end)

    it("should throw an error when custom command is falsy", function()
        o.set({custom_command = false}) -- setting to nil doesn't work w/ tbl_extend

        assert.has_error(function() buftabline.custom_command(1) end)
    end)
end)

describe("build_bufferline", function()
    it("should build default bufferline from list of buffers", function()
        reset()
        for i = 1, 5 do vim.cmd("e" .. i) end

        local bufferline = buftabline.build_bufferline()

        assert.equals(bufferline,
                      "%#TabLineFill# 1: 1 %*%#TabLineFill# 2: 2 %*%#TabLineFill# 3: 3 %*%#TabLineFill# 4: 4 %*%#TabLineSel# 5: 5 %*")
    end)

    it(
        "should throw an error when icons == true but devicons are not available",
        function()
            o.set({icons = true})

            assert.has_error(function() buftabline.build_bufferline() end)
        end)
end)
