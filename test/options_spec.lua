local o = require("buftabline.options")

describe("options", function()
    local defaults = vim.deepcopy(o.get())

    after_each(function()
        o.reset()
    end)

    describe("set", function()
        it("should set default options when user options is empty", function()
            o.set({})

            local options = o.get()

            assert.same(defaults, options)
        end)

        it("should specify user option", function()
            o.set({ start_hidden = true })

            local options = o.get()

            assert.is_not.same(defaults, options)
            assert.equals(options.start_hidden, true)
        end)
    end)

    describe("get", function()
        it("should return options object", function()
            assert.equals(o.get().tab_format, defaults.tab_format)
        end)
    end)

    describe("reset", function()
        it("should reset options to defaults", function()
            o.set({ start_hidden = true })

            o.reset()

            assert.same(o.get(), defaults)
        end)
    end)
end)
