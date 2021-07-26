local stub = require("luassert.stub")

local o = require("buftabline.options")
local h = require("buftabline.highlights")

describe("tabpage", function()
    local Tabpage = require("buftabline.tabpage")

    local mock_opts
    before_each(function()
        mock_opts = {
            tabinfo = { tabnr = 1 },
            current_tabnr = 10,
            index = 1,
        }
    end)
    after_each(function()
        mock_opts = nil
        o.reset()
    end)

    describe("new", function()
        it("should create new tabpage with methods from data", function()
            local tabpage = Tabpage:new(mock_opts)

            assert.equals(tabpage.index, mock_opts.index)
            assert.equals(tabpage.generator, mock_opts.generator)
            assert.equals(tabpage.current, false)
            assert.equals(tabpage.label, o.get().tabpage_format)
            assert.equals(type(tabpage.generate_hl), "function")
            assert.equals(type(tabpage.generate), "function")
            assert.equals(type(tabpage.highlight), "function")
        end)
    end)

    describe("new tabpage methods", function()
        describe("generate_hl", function()
            it("should return tabpage_current hlgroup when tab is current and option is set", function()
                o.set({ hlgroups = { tabpage_current = "MockHl" } })
                mock_opts.current_tabnr = mock_opts.tabinfo.tabnr

                local tabpage = Tabpage:new(mock_opts)

                assert.equals(tabpage.hl, "MockHl")
            end)

            it("should return current hlgroup when tab is current and option is not set", function()
                mock_opts.current_tabnr = mock_opts.tabinfo.tabnr

                local tabpage = Tabpage:new(mock_opts)

                assert.equals(tabpage.hl, o.get().hlgroups.current)
            end)

            it("should return tabpage_normal hlgroup when tab is normal and option is set", function()
                o.set({ hlgroups = { tabpage_normal = "MockHl" } })

                local tabpage = Tabpage:new(mock_opts)

                assert.equals(tabpage.hl, "MockHl")
            end)

            it("should return normal hlgroup when tab is current and option is not set", function()
                local tabpage = Tabpage:new(mock_opts)

                assert.equals(tabpage.hl, o.get().hlgroups.normal)
            end)
        end)
    end)

    describe("generator methods", function()
        describe("get_width", function()
            it("should return tabpage label width", function()
                local tabpage = Tabpage:new(mock_opts)

                tabpage.label = "test"

                assert.equals(tabpage:get_width(), 4)
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
                local tabpage = Tabpage:new(mock_opts)
                tabpage.label = "mock label"

                tabpage:highlight()

                assert.stub(add_hl).was_called_with("mock label", tabpage.hl)
            end)

            it("should replace tabpage label with highlighted string", function()
                local tabpage = Tabpage:new(mock_opts)

                tabpage:highlight()

                assert.equals(tabpage.label, "hl")
            end)
        end)

        describe("generate", function()
            local tabpage
            before_each(function()
                tabpage = Tabpage:new(mock_opts)
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
end)
