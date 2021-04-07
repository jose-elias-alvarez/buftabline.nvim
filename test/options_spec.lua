local o = require("buftabline.options")
local u = require("buftabline.utils")

local defaults = u.deepcopy(o.get())

describe("set_options", function()
    it("should return default options when no user options given", function()
        o.set({})

        local options = o.get()

        assert.same(defaults, options)
    end)

    it("should update defaults when user options given", function()
        o.set({start_hidden = true})

        local options = o.get()

        assert.is_not.same(defaults, options)
        assert.equals(options.start_hidden, true)
    end)
end)
