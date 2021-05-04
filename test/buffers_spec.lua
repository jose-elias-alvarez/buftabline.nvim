local b = require("buftabline.buffers")
local o = require("buftabline.options")

local defaults = vim.deepcopy(o.get())

describe("buffers", function()
    after_each(function()
        vim.cmd("bufdo! bwipeout!")
        o.set(defaults)
    end)

    describe("get_buf_numbers", function()
        it("should get table of ordinal buffer numbers", function()
            for i = 1, 5 do vim.cmd("e" .. i) end

            local buf_numbers = b.get_buf_numbers()

            assert.equals(vim.tbl_count(buf_numbers), 5)
        end)
    end)

    describe("get_current_buf_number", function()
        it("should return current buffer's ordinal number", function()
            for i = 1, 5 do vim.cmd("e" .. i) end
            local buf_numbers = b.get_buf_numbers()

            vim.cmd("buffer " .. buf_numbers[3])
            local current_buf_number = b.get_current_buf_number()

            assert.equals(current_buf_number, 3)
        end)
    end)

    describe("get_buffers", function()
        it("should get table of open buffers and set current buffer", function()
            for i = 1, 5 do vim.cmd("e" .. i) end

            local buffers = b.get_buffers()

            assert.equals(vim.tbl_count(buffers), 5)
            assert.equals(buffers[4].current, false)
            assert.equals(buffers[5].current, true)
        end)

        it("should mark buffers as ambiguous", function()
            vim.cmd("e testdir/testfile")
            vim.cmd("e testdir/other-file")
            vim.cmd("e testdir2/testfile")

            local buffers = b.get_buffers()

            assert.equals(buffers[1].ambiguous, true)
            assert.equals(buffers[2].ambiguous, nil)
            assert.equals(buffers[3].ambiguous, true)
        end)
    end)
end)
