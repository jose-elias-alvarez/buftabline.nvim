local o = require("buftabline.options")
local b = require("buftabline.buffers")

describe("commands", function()
    local commands = require("buftabline.commands")

    after_each(function()
        vim.cmd("bufdo! bwipeout!")
        vim.o.showtabline = 2
        o.reset()
    end)

    describe("buftarget", function()
        it("should call specified command on specified buffer", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(1, "buffer")

            assert.equals(b.get_current_index(), 1)
        end)

        it("should target 10th buffer when number == 0", function()
            for i = 1, 10 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(1, "buffer")
            commands.buftarget(0, "buffer")

            assert.equals(b.get_current_index(), 10)
        end)

        it("should target by bufnr when buffer_id_index option is set", function()
            o.set({ buffer_id_index = true })
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(vim.fn.getbufinfo()[1].bufnr, "buffer")

            assert.equals(b.get_current_index(), 1)
        end)
    end)

    describe("next_buffer", function()
        it("should switch to next buffer", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(3, "buffer")
            commands.next_buffer()

            assert.equals(b.get_current_index(), 4)
        end)

        it("should wrap and target first buffer when current buffer is last buffer", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.next_buffer()

            assert.equals(b.get_current_index(), 1)
        end)

        it("should call bnext when buffer_id_index option is set", function()
            o.set({ buffer_id_index = true })
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(vim.fn.getbufinfo()[3].bufnr, "buffer")
            commands.next_buffer()

            assert.equals(b.get_current_index(), 4)
        end)
    end)

    describe("prev_buffer", function()
        it("should switch to previous buffer", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(3, "buffer")
            commands.prev_buffer()

            assert.equals(b.get_current_index(), 2)
        end)

        it("should wrap and target last buffer when current buffer is first buffer", function()
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(1, "buffer")
            commands.prev_buffer()

            assert.equals(b.get_current_index(), 5)
        end)

        it("should call bprev when buffer_id_index option is set", function()
            o.set({ buffer_id_index = true })
            for i = 1, 5 do
                vim.cmd("e" .. i)
            end

            commands.buftarget(vim.fn.getbufinfo()[3].bufnr, "buffer")
            commands.prev_buffer()

            assert.equals(b.get_current_index(), 2)
        end)
    end)

    describe("toggle_tabline", function()
        it("should hide tabline when visible", function()
            vim.o.showtabline = 2

            commands.toggle_tabline()

            assert.equals(vim.o.showtabline, 0)
        end)

        it("should show tabline when hidden", function()
            vim.o.showtabline = 0

            commands.toggle_tabline()

            assert.equals(vim.o.showtabline, 2)
        end)
    end)

    describe("auto_hide", function()
        it("should set showtabline to 0 when only 1 buffer is open", function()
            vim.cmd("e file1.txt")

            commands.auto_hide()
            vim.wait(0)

            assert.equals(vim.o.showtabline, 0)
        end)

        it("should set showtabline to 2 when more than one buffer is open", function()
            vim.cmd("e file1.txt")
            vim.cmd("e file2.txt")

            commands.auto_hide()
            vim.wait(0)

            assert.equals(vim.o.showtabline, 2)
        end)
    end)
end)
