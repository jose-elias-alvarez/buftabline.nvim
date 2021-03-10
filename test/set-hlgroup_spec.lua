local set_hlgroup = require("buftabline.set-hlgroup")
local o = require("buftabline.options")

describe("set_hlgroup", function()
    it("should set current hlgroup when current == true", function()
        local result = set_hlgroup("some text", true)

        assert.equals(result, "%#" .. o.get().hlgroup_current .. "#" ..
                          "some text" .. "%*")
    end)

    it("should set normal hlgroup when current == false", function()
        local result = set_hlgroup("some text", false)

        assert.equals(result, "%#" .. o.get().hlgroup_normal .. "#" ..
                          "some text" .. "%*")
    end)

    it("should return unmodified text when hlgroup doesn't exist", function()
        o.set({hlgroup_current = "NONEXISTENT"})

        local result = set_hlgroup("some text", true)

        assert.equals(result, "some text")
    end)
end)
