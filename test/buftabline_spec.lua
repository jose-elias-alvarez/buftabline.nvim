local o = require("buftabline.options")
local b = require("buftabline.buffers")
local buftabline = require("buftabline")

local breakdown = function() vim.cmd("bufdo bwipeout!") end

describe("buftarget", function()
    after_each(function() breakdown() end)

    it("should call specified command on specified buffer", function()
        for i = 1, 5 do vim.cmd("e" .. i) end

        buftabline.buftarget(1, "buffer")
        local buffers = b.get_buffers()

        assert.equals(buffers[1].current, true)
    end)

    it("should target 10th buffer when number == 0", function()
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
    after_each(function() breakdown() end)

    it("should call custom command when set", function()
        o.set({custom_command = "buffer"})
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
    after_each(function() breakdown() end)

    it("should build default bufferline from list of buffers", function()
        for i = 1, 5 do vim.cmd("e" .. i) end

        local bufferline = buftabline.build_bufferline()

        assert.equals(bufferline,
                      "%#TabLineFill# 1: 1 %*%#TabLineFill# 2: 2 %*%#TabLineFill# 3: 3 %*%#TabLineFill# 4: 4 %*%#TabLineSel# 5: 5 %*")
    end)
end)

describe("next_buffer", function()
    after_each(function() breakdown() end)

    it("should target next buffer", function()
        for i = 1, 5 do vim.cmd("e" .. i) end
        local buf_numbers = b.get_buf_numbers()
        vim.cmd("buffer " .. buf_numbers[3])

        buftabline.next_buffer()
        local current_buf_number = b.get_current_buf_number()

        assert.equals(current_buf_number, 4)
    end)

    it("should wrap and target 1st buffer when current buffer is last buffer",
       function()
        for i = 1, 5 do vim.cmd("e" .. i) end
        local buf_numbers = b.get_buf_numbers()
        vim.cmd("buffer " .. buf_numbers[5])

        buftabline.next_buffer()
        local current_buf_number = b.get_current_buf_number()

        assert.equals(current_buf_number, 1)
    end)
end)

describe("prev_buffer", function()
    after_each(function() breakdown() end)

    it("should target previous buffer", function()
        for i = 1, 5 do vim.cmd("e" .. i) end
        local buf_numbers = b.get_buf_numbers()
        vim.cmd("buffer " .. buf_numbers[3])

        buftabline.prev_buffer()
        local current_buf_number = b.get_current_buf_number()

        assert.equals(current_buf_number, 2)
    end)

    it("should wrap and target last buffer when current buffer is first buffer",
       function()
        for i = 1, 5 do vim.cmd("e" .. i) end
        local buf_numbers = b.get_buf_numbers()
        vim.cmd("buffer " .. buf_numbers[1])

        buftabline.prev_buffer()
        local current_buf_number = b.get_current_buf_number()

        assert.equals(current_buf_number, 5)
    end)
end)
