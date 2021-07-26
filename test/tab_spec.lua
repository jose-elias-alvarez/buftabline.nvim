local mock = require("luassert.mock")
local stub = require("luassert.stub")

local o = require("buftabline.options")
local h = require("buftabline.highlights")

describe("tab", function()
    local Tab = require("buftabline.tab")

    local mock_opts, api
    before_each(function()
        api = mock(vim.api, true)
        mock_opts = {
            buf = { bufnr = 5, name = "/mock/path/mock-file.lua", changed = 0 },
            current_bufnr = 10,
            index = 1,
            generator = stub.new(),
        }
    end)
    after_each(function()
        mock_opts = nil
        api = nil
        o.reset()
    end)

    describe("new", function()
        it("should create new tab with methods from data", function()
            local tab = Tab:new(mock_opts)

            assert.equals(tab.index, mock_opts.index)
            assert.equals(tab.generator, mock_opts.generator)
            assert.equals(tab.bufnr, mock_opts.buf.bufnr)
            assert.equals(tab.bufname, mock_opts.buf.name)
            assert.equals(tab.changed, false)
            assert.equals(tab.current, false)
            assert.equals(tab.position, "left")
            assert.equals(tab.name, "mock-file.lua")
            assert.equals(tab.label, o.get().tab_format)

            assert.equals(type(tab.generate_hl), "function")
            assert.equals(type(tab.generate_flags), "function")
            assert.equals(type(tab.generate_icon), "function")
            assert.equals(type(tab.has_icon_colors), "function")
            assert.equals(type(tab.can_insert), "function")
            assert.equals(type(tab.get_width), "function")
            assert.equals(type(tab.truncate), "function")
            assert.equals(type(tab.generate), "function")
            assert.equals(type(tab.is_ambiguous), "function")
            assert.equals(type(tab.highlight), "function")
        end)
    end)

    describe("new tab methods", function()
        describe("generate_flags", function()
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
                mock_opts.buf.changed = 1

                local tab = Tab:new(mock_opts)

                assert.equals(tab.flags, " " .. o.get().flags.modified)
            end)

            it("should contain modified flag if buf.changed", function()
                mock_opts.buf.changed = 1

                local tab = Tab:new(mock_opts)

                assert.truthy(tab.flags:find(o.get().flags.modified, nil, true))
            end)

            it("should contain not modifiable flag if buffer is not modifiable", function()
                modifiable = false

                local tab = Tab:new(mock_opts)

                assert.truthy(tab.flags:find(o.get().flags.not_modifiable, nil, true))
            end)

            it("should contain readonly flag if buffer is read-only", function()
                readonly = true

                local tab = Tab:new(mock_opts)

                assert.truthy(tab.flags:find(o.get().flags.readonly, nil, true))
            end)

            it("should not insert modified flag if set to empty string", function()
                modifiable = true
                readonly = false
                mock_opts.buf.changed = 1
                o.set({ flags = { modified = "" } })

                local tab = Tab:new(mock_opts)

                assert.equals(tab.flags, "")
            end)

            it("should not insert not modifiable flag if set to empty string", function()
                o.set({ flags = { not_modifiable = "" } })
                modifiable = false

                local tab = Tab:new(mock_opts)

                assert.equals(tab.flags, "")
            end)

            it("should not insert readonly flag if set to empty string", function()
                o.set({ flags = { readonly = "" } })
                readonly = true

                local tab = Tab:new(mock_opts)

                assert.equals(tab.flags, "")
            end)
        end)

        describe("generate_hl", function()
            before_each(function()
                vim.fn.bufwinnr = stub.new().returns(0)
            end)

            after_each(function()
                vim.fn.bufwinnr:revert()
            end)

            it("should set current hlgroup", function()
                mock_opts.current_bufnr = mock_opts.buf.bufnr

                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, o.get().hlgroups.current)
            end)

            it("should set old current hlgroup", function()
                o.set({ hlgroup_current = "TestHl" })
                mock_opts.current_bufnr = mock_opts.buf.bufnr

                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should set active hlgroup if set", function()
                o.set({ hlgroups = { active = "TestHl" } })
                vim.fn.bufwinnr.returns(1)

                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should set normal hlgroup if active hlgroup is not set", function()
                vim.fn.bufwinnr.returns(1)

                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, o.get().hlgroups.normal)
            end)

            it("should set normal hlgroup", function()
                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, o.get().hlgroups.normal)
            end)

            it("should set old normal hlgroup", function()
                o.set({ hlgroup_normal = "TestHl" })

                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, "TestHl")
            end)

            it("should set modified hlgroup if buffer if set", function()
                o.set({ hlgroups = { modified_current = "TestHl" } })
                mock_opts.buf.changed = 1
                mock_opts.current_bufnr = mock_opts.buf.bufnr

                local tab = Tab:new(mock_opts)

                assert.equals(tab.hl, "TestHl")
            end)
        end)

        describe("has_icon_colors", function()
            it("should return true if icon_colors is set to true", function()
                local tab = Tab:new(mock_opts)

                assert.equals(tab:has_icon_colors(), true)
            end)

            it("should return true if icon_colors is set to current and tab is current", function()
                o.set({ icon_colors = "current" })
                mock_opts.current_bufnr = mock_opts.buf.bufnr

                local tab = Tab:new(mock_opts)

                assert.equals(tab:has_icon_colors(), true)
            end)

            it("should return false if icon_colors is set to current and tab is not current", function()
                o.set({ icon_colors = "current" })

                local tab = Tab:new(mock_opts)

                assert.equals(tab:has_icon_colors(), false)
            end)

            it("should return true if icon_colors is set to normal and tab is normal", function()
                o.set({ icon_colors = "normal" })

                local tab = Tab:new(mock_opts)

                assert.equals(tab:has_icon_colors(), true)
            end)

            it("should return false if icon_colors is set to normal and tab is not normal", function()
                o.set({ icon_colors = "normal" })
                mock_opts.current_bufnr = mock_opts.buf.bufnr

                local tab = Tab:new(mock_opts)

                assert.equals(tab:has_icon_colors(), false)
            end)

            it("should return false if icon_colors is set to false", function()
                o.set({ icon_colors = false })

                local tab = Tab:new(mock_opts)

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
                local tab = Tab:new(mock_opts)

                tab:generate_icon()

                assert.stub(get_icon).was_called_with("mock-file.lua", "lua", { default = true })
                assert.stub(merge_hl).was_called_with("IconHl", tab.hl)
                assert.equals(tab.icon, "icon")
                assert.equals(tab.icon_pos, 1)
                assert.equals(tab.icon_hl, "merged")
            end)

            it("should get own hlgroup when has_icon_colors returns false", function()
                o.set({ icon_colors = false })
                local tab = Tab:new(mock_opts)

                tab:generate_icon()

                assert.equals(tab.icon_hl, tab.hl)
                assert.stub(merge_hl).was_not_called()
            end)
        end)
    end)

    describe("generator methods", function()
        describe("can_insert", function()
            it("should return true if tab is on left side", function()
                local tab = Tab:new(mock_opts)

                assert.equals(tab:can_insert(0), true)
            end)

            it("should return true if tab is current", function()
                mock_opts.current_bufnr = mock_opts.buf.bufnr

                local tab = Tab:new(mock_opts)

                assert.equals(tab:can_insert(0), true)
            end)

            it("should return true if tab is on right side and budget remains", function()
                mock_opts.current_bufnr = mock_opts.buf.bufnr - 1

                local tab = Tab:new(mock_opts)

                assert.equals(tab:can_insert(10), true)
            end)

            it("should return false if tab is on right side but no budget remains", function()
                mock_opts.current_bufnr = mock_opts.buf.bufnr - 1

                local tab = Tab:new(mock_opts)

                assert.equals(tab:can_insert(0), false)
            end)
        end)

        describe("get_width", function()
            it("should return tab label width", function()
                local tab = Tab:new(mock_opts)

                tab.label = "test"

                assert.equals(tab:get_width(), 4)
            end)

            it("should handle multibyte character", function()
                local tab = Tab:new(mock_opts)

                tab.label = "" -- lua devicon

                assert.equals(tab:get_width(), 1)
            end)
        end)

        describe("truncate", function()
            it("should truncate tab to fit budget + separator", function()
                local tab = Tab:new(mock_opts)
                tab.label = "test"

                tab:truncate(-2)

                assert.equals(tab.label, "t>")
                assert.equals(tab.truncated, true)
            end)
        end)

        describe("is_ambiguous", function()
            it("should return true if existing tab name matches but buffer name does not", function()
                local tabs = { { name = "mock-file.lua", bufname = "other" } }
                local tab = Tab:new(mock_opts)

                assert.equals(tab:is_ambiguous(tabs), true)
            end)

            it("should return false if existing tab name and buffer name match", function()
                local tabs = { { name = "mock-file.lua", bufname = mock_opts.buf.name } }
                local tab = Tab:new(mock_opts)

                assert.equals(tab:is_ambiguous(tabs), false)
            end)

            it("should return false if tab does not overlap with existing tabs", function()
                local tabs = { { name = "other-file.lua", bufname = "other" } }
                local tab = Tab:new(mock_opts)

                assert.equals(tab:is_ambiguous(tabs), false)
            end)
        end)

        describe("generate", function()
            local tab
            before_each(function()
                api.nvim_buf_get_option.invokes(function(_, opt)
                    return opt == "modifiable" and true or opt == "readonly" and false
                end)

                tab = Tab:new(mock_opts)
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

                assert.equals(remaining, 100 - tab:get_width())
            end)

            it("should call truncate if can_insert returns false", function()
                tab.can_insert.returns(false)

                tab:generate({}, 100)

                assert.stub(tab.truncate).was_called()
            end)
        end)
    end)
end)
