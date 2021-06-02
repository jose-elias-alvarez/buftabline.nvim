local o = require("buftabline.options")
local add_commands = require("buftabline.add-commands")

local breakdown = function()
    vim.cmd("comclear")
end

describe("add_commands", function()
    after_each(function()
        breakdown()
    end)

    it("should create commands", function()
        add_commands()

        assert.equals(vim.fn.exists(":ToggleBuftabline"), 2)
        assert.equals(vim.fn.exists(":BufNext"), 2)
        assert.equals(vim.fn.exists(":BufPrev"), 2)
    end)

    it("should not create commands when disable_commands is true", function()
        o.set({ disable_commands = true })

        add_commands()

        assert.equals(vim.fn.exists(":ToggleBuftabline"), 0)
        assert.equals(vim.fn.exists(":BufNext"), 0)
        assert.equals(vim.fn.exists(":BufPrev"), 0)
    end)
end)
