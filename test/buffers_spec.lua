local stub = require("luassert.stub")

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
            for i = 1, 5 do
                vim.cmd("e" .. i)
                if i % 2 == 0 then
                    vim.cmd("bw")
                end
            end

            local buf_numbers = b.get_buf_numbers()

            assert.equals(vim.tbl_count(buf_numbers), 3)
            for i = 1, 3 do
                assert.is.truthy(buf_numbers[i])
            end
        end)

        it("should get a table of non-ordinal buffer numbers when buffer_id_index is true", function()
            o.set({ buffer_id_index = true })
            for i = 1, 5 do
                vim.cmd("e" .. i)
                if i % 2 == 0 then
                    vim.cmd("bw")
                end
            end

            local buf_numbers = b.get_buf_numbers()

            assert.equals(vim.tbl_count(buf_numbers), 3)
            for i = 2, 3 do
                assert.not_equals(i, buf_numbers[i])
            end
        end)
    end)

    describe("get_current_buf_number", function()
        it("should return current buffer's ordinal number", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end
            local buf_numbers = b.get_buf_numbers()

            vim.cmd("buffer " .. buf_numbers[3])
            local current_buf_number = b.get_current_buf_number()

            assert.equals(current_buf_number, 3)
        end)
    end)

    describe("get_buffers", function()
        after_each(function()
            o.set({ icons = false })
        end)

        it("should get table of open buffers and set current buffer", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

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

        it("should set buffer icon info if icons option is set", function()
            o.set({ icons = true })
            local get_icon = stub.new().returns("icon", "icon_hl")
            package.loaded["nvim-web-devicons"] = { get_icon = get_icon }

            vim.cmd("e testdir/testfile")
            local buffers = b.get_buffers()

            assert.stub(get_icon).was_called()
            assert.equals(buffers[1].icon, "icon")
            assert.equals(buffers[1].icon_hl, "icon_hl")
        end)
    end)
end)
