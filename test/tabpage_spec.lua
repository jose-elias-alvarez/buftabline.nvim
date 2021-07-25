local stub = require("luassert.stub")

local o = require("buftabline.options")
local h = require("buftabline.highlights")

describe("tabpage", function()
    local Tabpage = require("buftabline.tabpage")

    local mock_data
    before_each(function()
        mock_data = {
            tabinfo = { tabnr = 1 },
            current_tabnr = 10,
            index = 1,
        }
    end)
    after_each(function()
        mock_data = nil
        o.reset()
    end)

    describe("new", function()
        it("should create new tabpage with methods from data", function()
            local tabpage = Tabpage:new(mock_data)

            assert.equals(tabpage.tabinfo, mock_data.tabinfo)
            assert.equals(type(tabpage.generate), "function")
        end)
    end)

    describe("getters", function()
        describe("current", function()
            it("should return true if tabinfo.tabnr equals current_tabnr", function()
                mock_data.tabinfo.tabnr = mock_data.current_tabnr

                local tabpage = Tabpage:new(mock_data)

                assert.equals(tabpage.current, true)
            end)

            it("should return false if tabinfo.tabnr does not equal current_tabnr", function()
                local tabpage = Tabpage:new(mock_data)

                assert.equals(tabpage.current, false)
            end)
        end)
    end)

    describe("label", function()
        it("should return tabpage_format option if not set", function()
            local tabpage = Tabpage:new(mock_data)

            assert.equals(tabpage.label, o.get().tabpage_format)
        end)

        it("should return label if set", function()
            local tabpage = Tabpage:new(mock_data)

            tabpage.label = "mock label"

            assert.equals(tabpage.label, "mock label")
        end)
    end)

    describe("hl", function()
        it("should return tabpage_current hlgroup when tab is current and option is set", function()
            o.set({ hlgroups = { tabpage_current = "MockHl" } })
            mock_data.current = true

            local tabpage = Tabpage:new(mock_data)

            assert.equals(tabpage.hl, "MockHl")
        end)

        it("should return current hlgroup when tab is current and option is not set", function()
            mock_data.current = true

            local tabpage = Tabpage:new(mock_data)

            assert.equals(tabpage.hl, o.get().hlgroups.current)
        end)

        it("should return tabpage_normal hlgroup when tab is normal and option is set", function()
            o.set({ hlgroups = { tabpage_normal = "MockHl" } })

            local tabpage = Tabpage:new(mock_data)

            assert.equals(tabpage.hl, "MockHl")
        end)

        it("should return normal hlgroup when tab is current and option is not set", function()
            local tabpage = Tabpage:new(mock_data)

            assert.equals(tabpage.hl, o.get().hlgroups.normal)
        end)
    end)

    describe("width", function()
        it("should return tab label width", function()
            local tabpage = Tabpage:new(mock_data)

            tabpage.label = "test"

            assert.equals(tabpage.width, 4)
        end)
    end)

    describe("highlight", function()
        local add_hl
        before_each(function()
            add_hl = stub.new(h, "add_hl").returns("hl")
        end)
        after_each(function()
            add_hl:revert()
        end)

        it("should call add_hl with tabpage label and hlgroup", function()
            local tabpage = Tabpage:new(mock_data)
            tabpage.label = "mock label"

            tabpage:highlight()

            assert.stub(add_hl).was_called_with("mock label", tabpage.hl)
        end)

        it("should replace tabpage label with highlighted string", function()
            local tabpage = Tabpage:new(mock_data)

            tabpage:highlight()

            assert.equals(tabpage.label, "hl")
        end)
    end)

    describe("generate", function()
        local tabpage
        before_each(function()
            tabpage = Tabpage:new(mock_data)
            tabpage.highlight = stub.new()
        end)

        it("should replace placeholder with data", function()
            tabpage:generate(100)

            assert.equals(tabpage.label, " 1 ")
        end)

        it("should call highlight", function()
            tabpage:generate(100)

            assert.stub(tabpage.highlight).was_called()
        end)

        it("should subtract tab width from budget", function()
            local budget = tabpage:generate(100)

            assert.equals(budget, 97)
        end)
    end)
end)
