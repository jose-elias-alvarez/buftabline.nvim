local o = require("buftabline.options")
local u = require("buftabline.utils")

describe("buftabline", function()
    local buftabline = require("buftabline")

    after_each(function()
        o.reset()
        vim.o.showtabline = 0
        vim.cmd("comclear")
        u.clear_augroup()
        for i = 0, 9 do
            if vim.fn.maparg("<Leader>" .. i) ~= "" then
                vim.api.nvim_del_keymap("n", "<Leader>" .. i)
            end
        end
    end)

    describe("commands", function()
        it("should create commands on setup", function()
            buftabline.setup()

            assert.equals(vim.fn.exists(":ToggleBuftabline"), 2)
            assert.equals(vim.fn.exists(":BufNext"), 2)
            assert.equals(vim.fn.exists(":BufPrev"), 2)
        end)

        it("should not create commands when disable_commands is set", function()
            buftabline.setup({ disable_commands = true })

            assert.equals(vim.fn.exists(":ToggleBuftabline"), 0)
            assert.equals(vim.fn.exists(":BufNext"), 0)
            assert.equals(vim.fn.exists(":BufPrev"), 0)
        end)
    end)

    describe("autocommands", function()
        it("should define augroup and autocommands when auto_hide is set ", function()
            buftabline.setup({ auto_hide = true })

            assert.equals(vim.fn.exists("#Buftabline#BufAdd,BufDelete"), 1)
        end)

        it("should not define augroup and autocommands when auto_hide is not set", function()
            buftabline.setup()

            assert.equals(vim.fn.exists("#Buftabline#BufAdd,BufDelete"), 0)
        end)
    end)

    describe("maps", function()
        it("should set go to maps", function()
            buftabline.setup()

            for i = 0, 9 do
                assert.not_equals(vim.fn.mapcheck("<Leader>" .. i, "n"), "")
            end
        end)

        it("should not set go to maps when disabled", function()
            buftabline.setup({ go_to_maps = false })

            for i = 0, 9 do
                assert.equals(vim.fn.mapcheck("<Leader>" .. i, "n"), "")
            end
        end)
    end)

    describe("showtabline", function()
        it("should set showtabline to 2", function()
            buftabline.setup()

            assert.equals(vim.o.showtabline, 2)
        end)

        it("should set showtabline to 0 when start_hidden is set", function()
            buftabline.setup({ start_hidden = true })

            assert.equals(vim.o.showtabline, 0)
        end)
    end)

    describe("tabline", function()
        it("should set tabline to buftabline.build", function()
            buftabline.setup()

            assert.equals(vim.o.tabline, [[%!luaeval('require("buftabline").build()')]])
        end)
    end)
end)
