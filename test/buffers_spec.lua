local b = require("buftabline.buffers")

describe("buffers", function()
    after_each(function()
        vim.cmd("bufdo! bwipeout!")
    end)

    describe("getbufinfo", function()
        it("should return getbufinfo results", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            assert.same(b.getbufinfo(), vim.fn.getbufinfo({ buflisted = 1 }))
        end)
    end)

    describe("get_numbers", function()
        it("should get buffer numbers", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            local numbers = b.get_numbers()

            for i = 1, 5 do
                assert.equals(numbers[i], b.getbufinfo()[i].bufnr)
            end
        end)
    end)

    describe("get_current_index", function()
        it("should get current buffer's index", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            vim.cmd("e 3")

            assert.equals(b.get_current_index(), 3)
        end)
    end)
end)
