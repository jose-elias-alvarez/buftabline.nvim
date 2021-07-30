local stub = require("luassert.stub")

local o = require("buftabline.options")
local h = require("buftabline.highlights")

describe("Buftab", function()
    local Buftab = require("buftabline.buftab")

    local mock_buf
    before_each(function()
        mock_buf = {
            bufnr = 5,
            name = "/mock/path/mock-file.lua",
            changed = false,
            current = false,
            safe = true,
            last = false,
            modifiable = true,
            readonly = false,
        }
    end)
    after_each(function()
        o.reset()
    end)

    describe("new", function()
        it("should create new tab with methods from data", function()
            local tab = Buftab:new(mock_buf, 1, false)

            assert.equals(tab.index, 1)
            assert.equals(tab.insert_at, 1)
            assert.equals(tab.buf, mock_buf)
            assert.equals(tab.name, "mock-file.lua")
            assert.equals(tab.position, "left")
            assert.equals(tab.format, o.get().tab_format)

            assert.equals(type(tab.generate_hl), "function")
            assert.equals(type(tab.generate_flags), "function")
            assert.equals(type(tab.has_icon_colors), "function")
            assert.equals(type(tab.generate_icon), "function")
            assert.equals(type(tab.can_insert), "function")
            assert.equals(type(tab.get_width), "function")
            assert.equals(type(tab.truncate), "function")
            assert.equals(type(tab.highlight), "function")
            assert.equals(type(tab.is_ambiguous), "function")
            assert.equals(type(tab.generate), "function")
        end)

        it("should set index from bufnr if buffer_id_index option is set", function()
            o.set({ buffer_id_index = true })

            local tab = Buftab:new(mock_buf, 1, false)

            assert.equals(tab.index, mock_buf.bufnr)
        end)
    end)

    describe("new tab methods", function()
        describe("generate_flags", function()
            it("should insert flag + space", function()
                mock_buf.changed = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.flags, " " .. o.get().flags.modified)
            end)

            it("should insert flag + space", function()
                mock_buf.changed = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.flags, " " .. o.get().flags.modified)
            end)

            it("should contain modified flag if buffer is changed", function()
                mock_buf.changed = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.truthy(tab.flags:find(o.get().flags.modified, nil, true))
            end)

            it("should contain not modifiable flag if buffer is not modifiable", function()
                mock_buf.modifiable = false

                local tab = Buftab:new(mock_buf, 1, false)

                assert.truthy(tab.flags:find(o.get().flags.not_modifiable, nil, true))
            end)

            it("should contain readonly flag if buffer is read-only", function()
                mock_buf.readonly = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.truthy(tab.flags:find(o.get().flags.readonly, nil, true))
            end)

            it("should not insert modified flag if set to empty string", function()
                mock_buf.readonly = false
                mock_buf.modifiable = true
                mock_buf.changed = false
                o.set({ flags = { modified = "" } })

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.flags, "")
            end)

            it("should not insert not modifiable flag if set to empty string", function()
                o.set({ flags = { not_modifiable = "" } })
                mock_buf.modifiable = false

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.flags, "")
            end)

            it("should not insert readonly flag if set to empty string", function()
                o.set({ flags = { readonly = "" } })
                mock_buf.readonly = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.flags, "")
            end)
        end)

        describe("generate_hl", function()
            it("should set current hlgroup", function()
                mock_buf.current = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, o.get().hlgroups.current)
            end)

            it("should set old current hlgroup", function()
                o.set({ hlgroup_current = "TestHl" })
                mock_buf.current = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should set active hlgroup if set", function()
                o.set({ hlgroups = { active = "TestHl" } })
                mock_buf.active = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should set normal hlgroup if active hlgroup is not set", function()
                mock_buf.active = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, o.get().hlgroups.normal)
            end)

            it("should set normal hlgroup", function()
                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, o.get().hlgroups.normal)
            end)

            it("should set old normal hlgroup", function()
                o.set({ hlgroup_normal = "TestHl" })

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should set modified hlgroup if buffer if set", function()
                o.set({ hlgroups = { modified_current = "TestHl" } })
                mock_buf.changed = true
                mock_buf.current = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab.hl, "TestHl")
            end)
        end)

        describe("has_icon_colors", function()
            it("should return true if icon_colors is set to true", function()
                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:has_icon_colors(), true)
            end)

            it("should return true if icon_colors is set to current and tab is current", function()
                o.set({ icon_colors = "current" })
                mock_buf.current = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:has_icon_colors(), true)
            end)

            it("should return false if icon_colors is set to current and tab is not current", function()
                o.set({ icon_colors = "current" })

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:has_icon_colors(), false)
            end)

            it("should return true if icon_colors is set to normal and tab is normal", function()
                o.set({ icon_colors = "normal" })

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:has_icon_colors(), true)
            end)

            it("should return false if icon_colors is set to normal and tab is not normal", function()
                o.set({ icon_colors = "normal" })
                mock_buf.current = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:has_icon_colors(), false)
            end)

            it("should return false if icon_colors is set to false", function()
                o.set({ icon_colors = false })

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:has_icon_colors(), false)
            end)
        end)

        describe("generate_icon", function()
            local get_icon, merge_hl
            before_each(function()
                o.set({ tab_format = "#{i}" })

                merge_hl = stub(h, "merge_hl").returns("merged")
                get_icon = stub.new().returns("icon", "IconHl")
                package.loaded["nvim-web-devicons"] = { get_icon = get_icon }
            end)
            after_each(function()
                merge_hl:revert()
                package.loaded["nvim-web-devicons"] = nil
            end)

            it("should generate icon, icon_pos, and merged icon_hl", function()
                local tab = Buftab:new(mock_buf, 1, false)

                tab:generate_icon()

                assert.stub(get_icon).was_called_with("mock-file.lua", "lua", { default = true })
                assert.stub(merge_hl).was_called_with("IconHl", tab.hl)
                assert.equals(tab.icon, "icon")
                assert.equals(tab.icon_pos, 1)
                assert.equals(tab.icon_hl, "merged")
            end)

            it("should get own hlgroup when has_icon_colors returns false", function()
                o.set({ icon_colors = false })
                local tab = Buftab:new(mock_buf, 1, false)

                tab:generate_icon()

                assert.equals(tab.icon_hl, tab.hl)
                assert.stub(merge_hl).was_not_called()
            end)
        end)
    end)

    describe("generator methods", function()
        describe("can_insert", function()
            it("should return true if tab is on left side", function()
                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:can_insert(0), true)
            end)

            it("should return true if tab is current", function()
                mock_buf.current = true

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:can_insert(0), true)
            end)

            it("should return true if tab is safe", function()
                mock_buf.safe = false

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:can_insert(10), true)
            end)

            it("should return false if tab is not safe and no budget remains", function()
                mock_buf.safe = false

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:can_insert(0), false)
            end)
        end)

        describe("get_width", function()
            it("should return tab label width", function()
                local tab = Buftab:new(mock_buf, 1, false)

                tab.label = "test"

                assert.equals(tab:get_width(), 4)
            end)

            it("should handle multibyte character", function()
                local tab = Buftab:new(mock_buf, 1, false)

                tab.label = "" -- lua devicon

                assert.equals(tab:get_width(), 1)
            end)
        end)

        describe("truncate", function()
            it("should truncate tab to fit budget + separator", function()
                local tab = Buftab:new(mock_buf, 1, false)
                tab.label = "test"

                tab:truncate(-2)

                assert.equals(tab.label, "t>")
                assert.equals(tab.last, true)
            end)
        end)

        describe("is_ambiguous", function()
            it("should return true if existing tab name matches but buffer name does not", function()
                local tabs = { { name = "mock-file.lua", buf = { name = "other" } } }

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:is_ambiguous(tabs), true)
            end)

            it("should return false if existing tab name and buffer name match", function()
                local tabs = { { name = "mock-file.lua", buf = { name = mock_buf.name } } }

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:is_ambiguous(tabs), false)
            end)

            it("should return false if tab does not overlap with existing tabs", function()
                local tabs = { { name = "other-file.lua", buf = { name = "other" } } }

                local tab = Buftab:new(mock_buf, 1, false)

                assert.equals(tab:is_ambiguous(tabs), false)
            end)
        end)

        describe("replace_template", function()
            local tab
            before_each(function()
                tab = Buftab:new(mock_buf)
            end)

            it("should do nothing if label does not contain option", function()
                tab.label = "#{b}"

                tab:replace_template("#{i}", "icon")

                assert.equals(tab.label, "#{b}")
            end)

            it("should replace option with value", function()
                tab.label = "#{i}"

                tab:replace_template("#{i}", "icon")

                assert.equals(tab.label, "icon")
            end)

            it("should offset icon_pos by label difference if start_pos is before icon_pos", function()
                tab.label = "#{b}"
                tab.icon_pos = 5

                tab:replace_template("#{b}", "longname") -- 4 characters longer

                assert.equals(tab.icon_pos, 9)
            end)

            it("should not offset icon_pos if start_pos is after icon_pos", function()
                tab.label = "#{i} #{b}"
                tab.icon_pos = 4

                tab:replace_template("#{b}", "longname")

                assert.equals(tab.icon_pos, 4)
            end)
        end)

        describe("generate", function()
            local tab
            before_each(function()
                tab = Buftab:new(mock_buf, 1, false)
                tab.is_ambiguous = stub.new()
                tab.can_insert = stub.new()
                tab.truncate = stub.new()
                tab.highlight = stub.new()
                tab.replace_template = stub.new()
            end)

            it("should call tab:replace_template() with self args", function()
                tab:generate(100, {})

                assert.stub(tab.replace_template).was_called(4)
                assert.stub(tab.replace_template).was_called_with(tab, "#{n}", tab.index)
                assert.stub(tab.replace_template).was_called_with(tab, "#{f}", tab.flags)
                assert.stub(tab.replace_template).was_called_with(tab, "#{i}", "")
                assert.stub(tab.replace_template).was_called_with(tab, "#{b}", "mock-file.lua")
            end)

            it("should call tab:replace_template() with icon if set", function()
                tab.icon = "icon"

                tab:generate(100, {})

                assert.stub(tab.replace_template).was_called_with(tab, "#{i}", "icon")
            end)

            it("should call tab:highlight()", function()
                tab:generate(100, {})

                assert.stub(tab.highlight).was_called()
            end)

            it("should add containing directory to name if is_ambiguous returns true", function()
                tab.is_ambiguous.returns(true)

                tab:generate(100, {})

                assert.stub(tab.replace_template).was_called_with(tab, "#{b}", "path/mock-file.lua")
            end)

            it("should call truncate if can_insert returns false", function()
                tab.can_insert.returns(false)

                tab:generate(100, {})

                assert.stub(tab.truncate).was_called()
            end)

            it("should return adjusted budget, label, and last", function()
                local adjusted, label, last = tab:generate(100, {})

                assert.equals(adjusted, 100 - tab:get_width())
                assert.equals(label, tab.label)
                assert.equals(last, false)
            end)
        end)
    end)
end)
