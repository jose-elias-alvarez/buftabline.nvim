local o = require("buftabline.options")
local u = require("buftabline.utils")

describe("pad", function()
    after_each(function()
        o.set({ padding = 1 })
    end)

    local text = "text"
    it("should return unmodified text if padding = 0", function()
        o.set({ padding = 0 })

        local padded = u.pad(text)

        assert.equals(padded, text)
    end)

    it("should add one space around text for each digit of padding", function()
        o.set({ padding = 2 })

        local padded = u.pad(text)

        assert.equals(padded, "  text  ")
    end)
end)
