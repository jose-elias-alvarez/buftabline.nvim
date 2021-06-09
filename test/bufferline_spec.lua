local b = require("buftabline.buffers")
local o = require("buftabline.options")
local bufferline = require("buftabline.bufferline")

describe("bufferline", function()
    after_each(function()
        vim.cmd("bufdo! bwipeout!")
        o.reset()
    end)

    describe("get_name", function()
        it("should return modifier + No Name when buffer name isn't set", function()
            o.set({ show_no_name_buffers = true })
            vim.cmd("enew")
            local buffers = b.get_buffers()

            local name = bufferline.get_name(buffers[1])

            assert.equals(name, "1: [No Name]")
        end)

        it("should return modifier + buffer name", function()
            vim.cmd("e testfile")
            local buffers = b.get_buffers()

            local name = bufferline.get_name(buffers[1])

            assert.equals(name, "1: testfile")
        end)

        it("should return modifier + buffer name + flags", function()
            vim.cmd("e testfile")
            vim.cmd("normal itestcontent")
            local buffers = b.get_buffers()

            local name = bufferline.get_name(buffers[1])

            assert.equals(name, "1: testfile [+]")
        end)

        it("should format index according to index_format", function()
            o.set({ index_format = "%d. " })
            vim.cmd("e testfile")
            local buffers = b.get_buffers()

            local name = bufferline.get_name(buffers[1])

            assert.equals(name, "1. testfile")
        end)

        it("should add directory name when ambiguous", function()
            vim.cmd("e testdir/testfile")
            local buffers = b.get_buffers()
            buffers[1].ambiguous = true

            local name = bufferline.get_name(buffers[1])

            assert.equals(name, "1: testdir/testfile")
        end)

        it("should add buffer icon to end", function()
            vim.cmd("e testdir/testfile")
            local buffers = b.get_buffers()
            buffers[1].icon = ""

            local name = bufferline.get_name(buffers[1])

            assert.equals(name, "1: testfile ")
        end)
    end)

    describe("set_bufferline", function()
        it("should set showtabline to 0 when start_hidden == true", function()
            o.set({ start_hidden = true })

            bufferline.set()

            assert.equals(vim.o.showtabline, 0)
        end)

        it("should set showtabline to 2 when start_hidden == false", function()
            o.set({ start_hidden = false })

            bufferline.set()

            assert.equals(vim.o.showtabline, 2)
        end)

        it("should set tabline correctly", function()
            vim.o.tabline = ""

            bufferline.set()

            assert.equals(vim.o.tabline, [[%!luaeval('require("buftabline").build_bufferline()')]])
        end)
    end)

    describe("build_bufferline", function()
        it("should build default bufferline from list of buffers", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            local line = bufferline.build()

            assert.equals(
                line,
                "%#TabLineFill# 1: 1 %*%#TabLineFill# 2: 2 %*%#TabLineFill# 3: 3 %*%#TabLineFill# 4: 4 %*%#TabLineSel# 5: 5 %*"
            )
        end)

        it("should shrink bufferline and show next indicator when size exceeds columns", function()
            vim.o.columns = 20
            for i = 1, 2 do
                vim.cmd("e abcde" .. i)
            end
            -- switch back to previous to shrink last buffer
            vim.cmd("b#")

            local line = bufferline.build()

            assert.equals(line, "%#TabLineSel# 1: abcde1 %*%#TabLineFill# 2: abcd%*%#TabLineFill#>%*")
        end)
    end)
end)
