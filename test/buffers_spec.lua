local b = require("buftabline.buffers")

describe("buffers", function()
    after_each(function()
        vim.cmd("bufdo! bwipeout!")
    end)

    describe("getbufinfo", function()
        it("should return processed buffer info results", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            local bufinfo = b.getbufinfo()

            assert.equals(#bufinfo, 5)
            assert.equals(bufinfo[1].name, vim.fn.getcwd() .. "/1")
            assert.equals(bufinfo[1].bufnr, 1)
            assert.equals(bufinfo[1].changed, false)
            assert.equals(bufinfo[1].current, false)
            assert.equals(bufinfo[1].safe, true)
            assert.equals(bufinfo[1].modifiable, true)
            assert.equals(bufinfo[1].readonly, false)
            assert.equals(bufinfo[1].active, false)
        end)

        it("should set changed", function()
            vim.cmd("e" .. 1)
            vim.cmd("normal ahello")

            local bufinfo = b.getbufinfo()

            assert.equals(bufinfo[1].changed, true)
        end)

        it("should set current and active", function()
            vim.cmd("e" .. 1)

            local bufinfo = b.getbufinfo()

            assert.equals(bufinfo[1].current, true)
            assert.equals(bufinfo[1].active, true)
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

    describe("make_buftabs", function()
        it("should make buftabs from open buffers", function()
            for i = 1, 3 do
                vim.cmd("e" .. i)
            end

            local buftabs = b.make_buftabs()

            assert.equals(#buftabs, 3)
            assert.equals(buftabs[3].index, 3)
            assert.equals(buftabs[3].last, true)
        end)
    end)
end)
