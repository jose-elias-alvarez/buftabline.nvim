local mock = require("luassert.mock")
local stub = require("luassert.stub")

local o = require("buftabline.options")
local h = require("buftabline.highlights")

describe("tab", function()
    local Tab = require("buftabline.tab")

    local mock_data, api
    before_each(function()
        api = mock(vim.api, true)
        mock_data = {
            buf = { bufnr = 5, name = "/mock/path/mock-file.lua", changed = 0 },
            current_bufnr = 10,
            index = 1,
        }
    end)
    after_each(function()
        o.reset()
    end)

    describe("new", function()
        it("should create new tab with methods from data", function()
            local tab = Tab:new(mock_data)

            assert.equals(tab.buf, mock_data.buf)
            assert.equals(type(tab.can_insert), "function")
            assert.equals(type(tab.generate), "function")
            assert.equals(type(tab.generate_icon), "function")
            assert.equals(type(tab.has_icon_colors), "function")
            assert.equals(type(tab.highlight), "function")
            assert.equals(type(tab.is_ambiguous), "function")
            assert.equals(type(tab.truncate), "function")
        end)
    end)

    describe("getters", function()
        describe("current", function()
            it("should return true if buf.bufnr equals current bufnr", function()
                mock_data.current_bufnr = mock_data.buf.bufnr

                local tab = Tab:new(mock_data)

                assert.equals(tab.current, true)
            end)

            it("should return false if buf.bufnr does not equal current bufnr", function()
                local tab = Tab:new(mock_data)

                assert.equals(tab.current, false)
            end)
        end)

        describe("label", function()
            it("should return tab_format option if not set", function()
                local tab = Tab:new(mock_data)

                assert.equals(tab.label, o.get().tab_format)
            end)

            it("should return label if set", function()
                local tab = Tab:new(mock_data)

                tab.label = "mock label"

                assert.equals(tab.label, "mock label")
            end)
        end)

        describe("name", function()
            it("should return filename if not set", function()
                local tab = Tab:new(mock_data)

                assert.equals(tab.name, "mock-file.lua")
            end)

            it("should return name if set", function()
                local tab = Tab:new(mock_data)

                tab.name = "mock name"

                assert.equals(tab.name, "mock name")
            end)
        end)

        describe("flags", function()
            local modifiable, readonly
            before_each(function()
                modifiable = true
                readonly = false
                api.nvim_buf_get_option.invokes(function(_, opt)
                    return opt == "modifiable" and modifiable or opt == "readonly" and readonly
                end)
            end)

            after_each(function()
                api.nvim_buf_get_option:clear()
            end)

            it("should insert flag + space", function()
                mock_data.buf.changed = 1

                local tab = Tab:new(mock_data)

                assert.equals(tab.flags, " " .. o.get().flags.modified)
            end)

            it("should contain modified flag if buf.changed", function()
                mock_data.buf.changed = 1

                local tab = Tab:new(mock_data)

                assert.truthy(tab.flags:find(o.get().flags.modified, nil, true))
            end)

            it("should contain not modifiable flag if buffer is not modifiable", function()
                modifiable = false

                local tab = Tab:new(mock_data)

                assert.truthy(tab.flags:find(o.get().flags.not_modifiable, nil, true))
            end)

            it("should contain readonly flag if buffer is read-only", function()
                readonly = true

                local tab = Tab:new(mock_data)

                assert.truthy(tab.flags:find(o.get().flags.readonly, nil, true))
            end)

            it("should not insert modified flag if set to empty string", function()
                modifiable = true
                readonly = false
                mock_data.buf.changed = 1
                o.set({ flags = { modified = "" } })

                local tab = Tab:new(mock_data)

                assert.equals(tab.flags, "")
            end)

            it("should not insert not modifiable flag if set to empty string", function()
                o.set({ flags = { not_modifiable = "" } })
                modifiable = false

                local tab = Tab:new(mock_data)

                assert.equals(tab.flags, "")
            end)

            it("should not insert readonly flag if set to empty string", function()
                o.set({ flags = { readonly = "" } })
                readonly = true

                local tab = Tab:new(mock_data)

                assert.equals(tab.flags, "")
            end)
        end)

        describe("hl", function()
            before_each(function()
                vim.fn.bufwinnr = stub.new().returns(0)
            end)

            after_each(function()
                vim.fn.bufwinnr:revert()
            end)

            it("should return current hlgroup", function()
                mock_data.current = true

                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, o.get().hlgroups.current)
            end)

            it("should return old current hlgroup", function()
                o.set({ hlgroup_current = "TestHl" })
                mock_data.current = true

                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should return active hlgroup if set", function()
                o.set({ hlgroups = { active = "TestHl" } })
                vim.fn.bufwinnr.returns(1)

                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should return normal hlgroup if active hlgroup is not set", function()
                vim.fn.bufwinnr.returns(1)

                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, o.get().hlgroups.normal)
            end)

            it("should return normal hlgroup", function()
                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, o.get().hlgroups.normal)
            end)

            it("should return old normal hlgroup", function()
                o.set({ hlgroup_normal = "TestHl" })

                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should return modified hlgroup if buffer if set", function()
                o.set({ hlgroups = { modified_current = "TestHl" } })
                mock_data.buf.changed = 1
                mock_data.current = true

                local tab = Tab:new(mock_data)

                assert.equals(tab.hl, "TestHl")
            end)
        end)

        describe("width", function()
            it("should return tab label width", function()
                local tab = Tab:new(mock_data)

                tab.label = "test"

                assert.equals(tab.width, 4)
            end)

            it("should handle multibyte character", function()
                local tab = Tab:new(mock_data)

                tab.label = "" -- lua devicon

                assert.equals(tab.width, 1)
            end)
        end)

        describe("icon", function()
            local generate_icon_stub
            before_each(function()
                generate_icon_stub = stub.new()
            end)

            it("should call generate icon if key == icon", function()
                local tab = Tab:new(mock_data)
                tab.generate_icon = generate_icon_stub

                local _ = tab.icon

                assert.stub(generate_icon_stub).was_called()
            end)

            it("should call generate icon if key == icon_hl", function()
                local tab = Tab:new(mock_data)
                tab.generate_icon = generate_icon_stub

                local _ = tab.icon_hl

                assert.stub(generate_icon_stub).was_called()
            end)

            it("should call generate icon if key == icon_pos", function()
                local tab = Tab:new(mock_data)
                tab.generate_icon = generate_icon_stub

                local _ = tab.icon_pos

                assert.stub(generate_icon_stub).was_called()
            end)
        end)
    end)

    describe("can_insert", function()
        it("should return true if tab is on left side", function()
            local tab = Tab:new(mock_data)

            assert.equals(tab:can_insert(0), true)
        end)

        it("should return true if tab is current", function()
            mock_data.current_bufnr = mock_data.buf.bufnr

            local tab = Tab:new(mock_data)

            assert.equals(tab:can_insert(0), true)
        end)

        it("should return true if tab is on right side and budget remains", function()
            mock_data.current_bufnr = mock_data.buf.bufnr - 1

            local tab = Tab:new(mock_data)

            assert.equals(tab:can_insert(10), true)
        end)

        it("should return false if tab is on right side but no budget remains", function()
            mock_data.current_bufnr = mock_data.buf.bufnr - 1

            local tab = Tab:new(mock_data)

            assert.equals(tab:can_insert(0), false)
        end)
    end)

    describe("has_icon_colors", function()
        it("should return true if icon_colors is set to true", function()
            local tab = Tab:new(mock_data)

            assert.equals(tab:has_icon_colors(), true)
        end)

        it("should return true if icon_colors is set to current and tab is current", function()
            o.set({ icon_colors = "current" })
            mock_data.current = true

            local tab = Tab:new(mock_data)

            assert.equals(tab:has_icon_colors(), true)
        end)

        it("should return false if icon_colors is set to current and tab is not current", function()
            o.set({ icon_colors = "current" })
            mock_data.current = false

            local tab = Tab:new(mock_data)

            assert.equals(tab:has_icon_colors(), false)
        end)

        it("should return true if icon_colors is set to normal and tab is normal", function()
            o.set({ icon_colors = "normal" })
            mock_data.current = false

            local tab = Tab:new(mock_data)

            assert.equals(tab:has_icon_colors(), true)
        end)

        it("should return false if icon_colors is set to normal and tab is not normal", function()
            o.set({ icon_colors = "normal" })
            mock_data.current = true

            local tab = Tab:new(mock_data)

            assert.equals(tab:has_icon_colors(), false)
        end)

        it("should return false if icon_colors is set to false", function()
            o.set({ icon_colors = false })

            local tab = Tab:new(mock_data)

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

        it("should return if tab already has icon", function()
            local tab = Tab:new(mock_data)
            tab._has_icon = true

            tab:generate_icon()

            assert.stub(get_icon).was_not_called()
        end)

        it("should generate icon, icon_pos, and merged icon_hl", function()
            local tab = Tab:new(mock_data)

            tab:generate_icon()

            assert.stub(get_icon).was_called_with("mock-file.lua", "lua", { default = true })
            assert.stub(merge_hl).was_called_with("IconHl", tab.hl)
            assert.equals(tab.icon, "icon")
            assert.equals(tab.icon_pos, 1)
            assert.equals(tab.icon_hl, "merged")
            assert.equals(tab._has_icon, true)
        end)

        it("should get own hlgroup when has_icon_colors returns false", function()
            local tab = Tab:new(mock_data)
            tab.has_icon_colors = stub.new().returns(false)

            tab:generate_icon()

            assert.equals(tab.icon_hl, tab.hl)
            assert.stub(merge_hl).was_not_called()
        end)
    end)

    describe("truncate", function()
        it("should truncate tab to fit budget + separator", function()
            local tab = Tab:new(mock_data)
            tab.label = "test"

            tab:truncate(-2)

            assert.equals(tab.label, "t>")
            assert.equals(tab.truncated, true)
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

        it("should format label directly if tab does not have icon", function()
            local tab = Tab:new(mock_data)
            tab.label = "1. test"
            local original_label = tab.label

            tab:highlight()

            assert.stub(add_hl).was_called(1)
            assert.stub(add_hl).was_called_with(original_label, tab.hl)
            assert.equals(tab.label, "hl")
        end)

        it("should split label if tab has icon", function()
            local tab = Tab:new(mock_data)
            tab.label = " 1. test"
            tab.icon = ""
            tab.icon_pos = 1
            tab.icon_hl = "IconHl"

            tab:highlight()

            assert.stub(add_hl).was_called(3)
            assert.stub(add_hl).was_called_with("", tab.hl)
            assert.stub(add_hl).was_called_with(tab.icon .. " ", "IconHl")
            assert.stub(add_hl).was_called_with("1. test", tab.hl)
            assert.equals(tab.label, "hlhlhl")
        end)
    end)

    describe("is_ambiguous", function()
        it("should return true if existing tab name matches but buffer name does not", function()
            local tabs = { { name = "mock-file.lua", buf = { name = "other" } } }
            local tab = Tab:new(mock_data)

            assert.equals(tab:is_ambiguous(tabs), true)
        end)

        it("should return false if existing tab name and buffer name match", function()
            local tabs = { { name = "mock-file.lua", buf = { name = mock_data.buf.name } } }
            local tab = Tab:new(mock_data)

            assert.equals(tab:is_ambiguous(tabs), false)
        end)

        it("should return false if tab does not overlap with existing tabs", function()
            local tabs = { { name = "other-file.lua", buf = { name = "other" } } }
            local tab = Tab:new(mock_data)

            assert.equals(tab:is_ambiguous(tabs), false)
        end)
    end)

    describe("generate", function()
        local tab
        before_each(function()
            api.nvim_buf_get_option.invokes(function(_, opt)
                return opt == "modifiable" and true or opt == "readonly" and false
            end)

            tab = Tab:new(mock_data)
            tab.name = "test"
            tab.is_ambiguous = stub.new()
            tab.can_insert = stub.new()
            tab.truncate = stub.new()
            tab.highlight = stub.new()
        end)

        it("should replace placeholders with data", function()
            tab:generate({}, 100)

            assert.equals(tab.label, " 1: test ")
        end)

        it("should call tab:highlight()", function()
            tab:generate({}, 100)

            assert.stub(tab.highlight).was_called()
        end)

        it("should add containing directory if is_ambiguous returns true", function()
            tab.is_ambiguous.returns(true)

            tab:generate({}, 100)

            assert.equals(tab.label, " 1: path/test ")
        end)

        it("should replace icon placeholder with icon", function()
            tab.icon = "icon"
            tab.label = "#{i}"

            tab:generate({}, 100)

            assert.equals(tab.label, "icon")
        end)

        it("should return budget minus tab width", function()
            local remaining = tab:generate({}, 100)

            assert.equals(remaining, 100 - tab.width)
        end)

        it("should call truncate if can_insert returns false", function()
            tab.can_insert.returns(false)

            tab:generate({}, 100)

            assert.stub(tab.truncate).was_called()
        end)
    end)
end)
