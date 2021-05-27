local set_hlgroup = require("buftabline.set-hlgroup")
local o = require("buftabline.options")

describe("set_hlgroup", function()
    after_each(function()
        o.set({
            hlgroup_current = "TabLineSel",
            icons = false,
            icon_colors = false
        })
    end)

    it("should set current hlgroup when current == true", function()
        local result = set_hlgroup({label = "some text", current = true})

        assert.equals(result, "%#" .. o.get().hlgroup_current .. "#" ..
                          "some text" .. "%*")
    end)

    it("should set normal hlgroup when current == false", function()
        local result = set_hlgroup({label = "some text", current = false})

        assert.equals(result, "%#" .. o.get().hlgroup_normal .. "#" ..
                          "some text" .. "%*")
    end)

    it("should return unmodified label when hlgroup doesn't exist", function()
        o.set({hlgroup_current = "NONEXISTENT"})

        local result = set_hlgroup({label = "some text", current = true})

        assert.equals(result, "some text")
    end)

    describe("icon colors", function()
        before_each(function()
            o.set({icon_colors = true, padding = 1})
            vim.cmd("hi DevIconLua guifg=black")
        end)

        after_each(function() vim.cmd("hi clear DevIconLua") end)

        it("should format icon with normal hlgroup", function()
            local result = set_hlgroup({
                label = " 1: options.lua  ",
                icon_hl = "DevIconLua"
            })

            assert.truthy(string.find(result, "%#DevIconLuaNormal#", nil,
                                      true))
        end)

        it("should format icon with current hlgroup", function()
            local result = set_hlgroup({
                label = " 1: options.lua  ",
                icon_hl = "DevIconLua",
                current = true
            })

            assert.truthy(string.find(result, "%#DevIconLuaCurrent#", nil,
                                      true))
        end)

        it("should not format icon when icon_hl is not set", function()
            local result = set_hlgroup({
                label = " 1: options.lua  ",
                current = true
            })

            assert.falsy(string.find(result, "%#DevIconLuaCurrent#", nil,
                                     true))
        end)

        it("should not format icon when tab shrank", function()
            local result = set_hlgroup({
                label = " 1: options.lua  ",
                shrank = true
            })

            assert.falsy(string.find(result, "%#DevIconLuaCurrent#", nil,
                                     true))
        end)

        it("should format icon when tab is current and icon_colors == current",
           function()
            o.set({icon_colors = "current"})

            local result = set_hlgroup({
                label = " 1: options.lua  ",
                icon_hl = "DevIconLua",
                current = true
            })

            assert.truthy(string.find(result, "%#DevIconLuaCurrent#", nil,
                                      true))
        end)

        it(
            "should not format icon when tab is current and icon_colors ~= current",
            function()
                o.set({icon_colors = "normal"})

                local result = set_hlgroup(
                                   {
                        label = " 1: options.lua  ",
                        icon_hl = "DevIconLua",
                        current = true
                    })

                assert.falsy(string.find(result, "%#DevIconLuaCurrent#", nil,
                                         true))
            end)

        it("should format icon when tab is normal and icon_colors == normal",
           function()
            o.set({icon_colors = "normal"})

            local result = set_hlgroup({
                label = " 1: options.lua  ",
                icon_hl = "DevIconLua"
            })

            assert.truthy(string.find(result, "%#DevIconLuaNormal#", nil,
                                      true))
        end)

        it(
            "should not format icon when tab is normal and icon_colors ~= normal",
            function()
                o.set({icon_colors = "current"})

                local result = set_hlgroup(
                                   {
                        label = " 1: options.lua  ",
                        icon_hl = "DevIconLua"
                    })

                assert.falsy(string.find(result, "%#DevIconLuaNormal#", nil,
                                         true))
            end)
    end)
end)
