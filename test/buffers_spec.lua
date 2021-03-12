local b = require("buftabline.buffers")
local u = require("test.utils")
local o = require("buftabline.options")

local reset = function() vim.cmd("bufdo bwipeout!") end

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
        vim.cmd("e test")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1: test")
    end)

    it("should return modifier + buffer name + flags", function()
        reset()
        vim.cmd("e test")
        vim.cmd("normal itestcontent")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1: test [+]")
    end)

    it("should format index according to index_format", function()
        reset()
        o.set({index_format = "%d. "})
        vim.cmd("e test")
        local buffers = b.get_buffers()

        local name = b.get_name(buffers[1])

        assert.equals(name, "1. test")
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
