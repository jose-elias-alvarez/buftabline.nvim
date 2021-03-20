local b = require("buftabline.buffers")
local u = require("test.utils")
local o = require("buftabline.options")

local reset = function() vim.cmd("bufdo! bwipeout!") end

describe("get_name", function()
    it("should return modifier + No Name when buffer name isn't set", function()
        reset()
        vim.cmd("enew")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1: [No Name]")
    end)

    it("should return modifier + buffer name", function()
        reset()
        vim.cmd("e testfile")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1: testfile")
    end)

    it("should return modifier + buffer name + flags", function()
        reset()
        vim.cmd("e testfile")
        vim.cmd("normal itestcontent")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1: testfile [+]")
    end)

    it("should format index according to index_format", function()
        reset()
        o.set({index_format = "%d. "})
        vim.cmd("e testfile")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1. testfile")
    end)
end)

describe("get_buf_numbers", function()
    it("should get table of ordinal buffer numbers", function()
        reset()
        for i = 1, 5 do vim.cmd("e" .. i) end

        local buf_numbers = b.get_buf_numbers()

        assert.equals(u.tablelength(buf_numbers), 5)
    end)
end)

describe("get_current_buf_number", function()
    it("should return current buffer's ordinal number", function()
        reset()
        for i = 1, 5 do vim.cmd("e" .. i) end
        local buf_numbers = b.get_buf_numbers()

        vim.cmd("buffer " .. buf_numbers[3])
        local current_buf_number = b.get_current_buf_number()

        assert.equals(current_buf_number, 3)
    end)
end)

describe("get_buffers", function()
    it("should get table of open buffers and set current buffer", function()
        reset()
        for i = 1, 5 do vim.cmd("e" .. i) end

        local buffers = b.get_buffers()

        assert.equals(u.tablelength(buffers), 5)
        assert.equals(buffers[4].current, false)
        assert.equals(buffers[5].current, true)
    end)
end)

describe("get_bufname_base", function()
    it("should remove padding around base when padding = 0", function()
        o.set({padding = 0})

        local base = b.get_bufname_base()

        assert.equals(base, "%s")
    end)

    it("should add one space around base for each digit of padding", function()
        o.set({padding = 2})

        local base = b.get_bufname_base()

        assert.equals(base, "  %s  ")
    end)
end)
