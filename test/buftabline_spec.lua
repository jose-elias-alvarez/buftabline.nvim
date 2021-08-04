local buftabline = require("buftabline")
local o = require("buftabline.options")

local input = function(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", true)
end

local edit_mock_files = function(count)
    for i = 1, count do
        vim.cmd("e test" .. i .. ".lua")
    end
end

local close_all = function()
    vim.cmd("silent tabonly")
    vim.cmd("bufdo! bwipeout!")
end

local wait_for_scheduler = function()
    vim.wait(0)
end

local assert_tabline = function(expected)
    wait_for_scheduler()

    assert.equals(vim.trim(vim.o.tabline), expected)
end

local assert_current = function(name)
    assert.truthy(vim.api.nvim_buf_get_name(0):find(name, nil, true))
end

describe("buftabline", function()
    after_each(function()
        vim.o.columns = 80
        vim.o.showtabline = 2
        close_all()
        o.reset()
    end)

    buftabline.setup()

    describe("buftabs", function()
        it("should show open buffers and highlight current", function()
            edit_mock_files(3)

            assert_tabline("%#TabLineFill# 1: test1.lua %*%#TabLineFill# 2: test2.lua %*%#TabLineSel# 3: test3.lua %*")
        end)

        -- test is order dependent, since buffer numbers won't reset until neovim is closed
        it("should index buffers according to bufnr", function()
            o.set({ buffer_id_index = true })
            edit_mock_files(3)

            assert_tabline("%#TabLineFill# 4: test1.lua %*%#TabLineFill# 5: test2.lua %*%#TabLineSel# 6: test3.lua %*")
        end)

        it("should skip no name buffer", function()
            edit_mock_files(3)
            vim.cmd("enew")

            assert_tabline("%#TabLineFill# 1: test1.lua %*%#TabLineFill# 2: test2.lua %*%#TabLineFill# 3: test3.lua %*")
        end)

        it("should truncate last tab to fit budget", function()
            vim.opt.columns = 32
            edit_mock_files(3)
            -- go to previous buffer to truncate last
            vim.cmd("b#")

            assert_tabline("%#TabLineFill# 1: test1.lua %*%#TabLineSel# 2: test2.lua %*%#TabLineFill# 3:>%*")
        end)

        it("should disambiguate same name tabs", function()
            edit_mock_files(1)
            vim.cmd("e " .. vim.fn.getcwd() .. "/test/test1.lua")

            assert_tabline("%#TabLineFill# 1: buftabline.nvim/test1.lua %*%#TabLineSel# 2: test/test1.lua %*")
        end)
    end)

    describe("events", function()
        before_each(function()
            vim.o.columns = 32
            edit_mock_files(1)
        end)

        it("should update on BufAdd", function()
            vim.cmd("e newfile")

            assert_tabline("%#TabLineFill# 1: test1.lua %*%#TabLineSel# 2: newfile %*")
        end)

        it("should update on BufEnter", function()
            vim.cmd("e newfile")

            vim.cmd("bprev")

            assert_tabline("%#TabLineSel# 1: test1.lua %*%#TabLineFill# 2: newfile %*")
        end)

        it("should update on BufDelete", function()
            vim.cmd("bdelete")

            assert_tabline("")
        end)

        it("should update on BufModifiedSet", function()
            vim.cmd("normal Atest")

            assert_tabline("%#TabLineSel# 1: test1.lua [+] %*")
        end)

        it("should update on TabEnter (new)", function()
            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1: test1.lua %*            %#TabLineFill# 1 %*%#TabLineSel# 2 %*")
        end)

        it("should update on TabEnter (change)", function()
            vim.cmd("tabnew")

            vim.cmd("tabprev")

            assert_tabline("%#TabLineSel# 1: test1.lua %*            %#TabLineSel# 1 %*%#TabLineFill# 2 %*")
        end)

        it("should update on TabClose", function()
            vim.cmd("tabnew")

            vim.cmd("tabclose")

            assert_tabline("%#TabLineSel# 1: test1.lua %*")
        end)

        it("should update on WinEnter (new)", function()
            vim.cmd("split")
            vim.cmd("e newfile")

            assert_tabline("%#TabLineFill# 1: test1.lua %*%#TabLineSel# 2: newfile %*")
        end)

        it("should update on WinEnter (change)", function()
            vim.cmd("split")
            vim.cmd("e newfile")

            vim.cmd("wincmd p")

            assert_tabline("%#TabLineSel# 1: test1.lua %*%#TabLineFill# 2: newfile %*")
        end)
    end)

    describe("highlights", function()
        before_each(function()
            vim.o.columns = 24
        end)

        it("should apply active highlight", function()
            o.set({ hlgroups = { active = "MockHl" } })
            edit_mock_files(1)

            vim.cmd("split")
            vim.cmd("e newfile")

            assert_tabline("%#MockHl# 1: test1.lua %*%#TabLineSel# 2: newfile %*")
        end)

        it("should apply modified_current highlight", function()
            o.set({ hlgroups = { modified_current = "MockHl" } })
            edit_mock_files(1)

            vim.cmd("normal Atest")

            assert_tabline("%#MockHl# 1: test1.lua [+] %*")
        end)

        it("should apply modified_normal highlight", function()
            o.set({ hlgroups = { modified_normal = "MockHl" } })
            edit_mock_files(1)

            vim.cmd("normal Atest")
            vim.cmd("e otherfile")

            assert_tabline("%#MockHl# 1: test1.lua [+] %*%#TabLineSel# 2: otherfile %*")
        end)

        it("should apply modified_active highlight", function()
            o.set({ hlgroups = { modified_active = "MockHl" } })
            edit_mock_files(1)
            vim.cmd("normal Atest")

            vim.cmd("split")
            vim.cmd("e newfile")

            assert_tabline("%#MockHl# 1: test1.lua [+] %*%#TabLineSel# 2: newfile %*")
        end)

        it("should apply tabpage_current highlight", function()
            o.set({ hlgroups = { tabpage_current = "MockHl" } })
            edit_mock_files(1)

            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1: test1.lua %*    %#TabLineFill# 1 %*%#MockHl# 2 %*")
        end)

        it("should apply tabpage_normal highlight", function()
            o.set({ hlgroups = { tabpage_normal = "MockHl" } })
            edit_mock_files(1)

            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1: test1.lua %*    %#MockHl# 1 %*%#TabLineSel# 2 %*")
        end)

        it("should apply space highlight", function()
            o.set({ hlgroups = { spacing = "MockHl" } })
            edit_mock_files(1)

            assert_tabline("%#TabLineSel# 1: test1.lua %*%#MockHl#          %*")
        end)

        it("should apply space highlight between buftabs and tabpage tabs", function()
            o.set({ hlgroups = { spacing = "MockHl" }, show_tabpages = "always" })
            edit_mock_files(1)

            assert_tabline("%#TabLineSel# 1: test1.lua %*%#MockHl#       %*%#TabLineSel# 1 %*")
        end)
    end)

    describe("auto_hide", function()
        before_each(function()
            o.set({ auto_hide = true })
        end)

        it("should hide tabline if only one tab is open", function()
            edit_mock_files(1)

            wait_for_scheduler()

            assert.equals(vim.o.showtabline, 0)
        end)

        it("should show tabline if more than one tab is open", function()
            edit_mock_files(2)

            wait_for_scheduler()

            assert.equals(vim.o.showtabline, 2)
        end)

        it("should hide on buffer close if only one tab is left", function()
            edit_mock_files(2)

            vim.cmd("bdelete")
            wait_for_scheduler()

            assert.equals(vim.o.showtabline, 0)
        end)
    end)

    if pcall(require, "nvim-web-devicons") then
        describe("icons", function()
            it("should show and highlight icons at tab beginning", function()
                o.set({ tab_format = " #{i} #{n}: #{b}#{f} " })
                edit_mock_files(2)

                assert_tabline(
                    "%#TabLineSel# %*%#DevIconLuaTabLineSel# %*%#TabLineSel#1: test2.lua %*%#TabLineFill# %*%#DevIconLuaTabLineFill# %*%#TabLineFill#2: test1.lua %*"
                )
            end)

            it("should correctly highlight icons in middle of tab", function()
                o.set({ tab_format = " #{n} #{i}: #{b}#{f} " })
                edit_mock_files(2)

                assert_tabline(
                    "%#TabLineFill# 1 %*%#DevIconLuaTabLineFill#: %*%#TabLineFill#test1.lua %*%#TabLineSel# 2 %*%#DevIconLuaTabLineSel#: %*%#TabLineSel#test2.lua %*"
                )
            end)

            it("should correctly highlight icons at tab end", function()
                o.set({ tab_format = " #{n}: #{b}#{f} #{i} " })
                edit_mock_files(2)

                assert_tabline(
                    "%#TabLineFill# 1: test1.lua %*%#DevIconLuaTabLineFill# %*%#TabLineFill#%*%#TabLineSel# 2: test2.lua %*%#DevIconLuaTabLineSel# %*%#TabLineSel#%*"
                )
            end)

            it("should not highlight icons if icon_colors is false", function()
                o.set({ tab_format = " #{i} #{n}: #{b}#{f} ", icon_colors = false })
                edit_mock_files(2)

                assert_tabline(
                    "%#TabLineFill# %*%#TabLineFill# %*%#TabLineFill#1: test1.lua %*%#TabLineSel# %*%#TabLineSel# %*%#TabLineSel#2: test2.lua %*"
                )
            end)

            it("should highlight only current tab icon if icon_colors is 'current'", function()
                o.set({ tab_format = " #{i} #{n}: #{b}#{f} ", icon_colors = "current" })
                edit_mock_files(2)

                assert_tabline(
                    "%#TabLineFill# %*%#TabLineFill# %*%#TabLineFill#1: test1.lua %*%#TabLineSel# %*%#DevIconLuaTabLineSel# %*%#TabLineSel#2: test2.lua %*"
                )
            end)

            it("should highlight only normal tab icon if icon_colors is 'normal'", function()
                o.set({ tab_format = " #{i} #{n}: #{b}#{f} ", icon_colors = "normal" })
                edit_mock_files(2)

                assert_tabline(
                    "%#TabLineFill# %*%#DevIconLuaTabLineFill# %*%#TabLineFill#1: test1.lua %*%#TabLineSel# %*%#TabLineSel# %*%#TabLineSel#2: test2.lua %*"
                )
            end)
        end)
    end

    describe("tabpages", function()
        before_each(function()
            vim.opt.columns = 24
            edit_mock_files(1)
        end)

        it("should not show tabpages if only one tab is open and show_tabpages is set to true", function()
            assert_tabline("%#TabLineSel# 1: test1.lua %*")
        end)

        it("should not show tabpages regardless of number if show_tabpages is set to false", function()
            o.set({ show_tabpages = false })
            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1: test1.lua %*")
        end)

        it("should show tabpages if more than one tab is open and show_tabpages is set to true", function()
            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1: test1.lua %*    %#TabLineFill# 1 %*%#TabLineSel# 2 %*")
        end)

        it("should show tabpages if only one tab is open and show_tabpages is set to 'always'", function()
            o.set({ show_tabpages = "always" })

            assert_tabline("%#TabLineSel# 1: test1.lua %*       %#TabLineSel# 1 %*")
        end)

        it("should show tabpages on left if tabpage_position is set to 'left'", function()
            o.set({ tabpage_position = "left" })
            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1 %*%#TabLineSel# 2 %*%#TabLineFill# 1: test1.lua %*")
        end)
    end)

    describe("commands", function()
        it("should define commands", function()
            assert.equals(vim.fn.exists(":ToggleBuftabline") > 1, true)
            assert.equals(vim.fn.exists(":BufNext") > 1, true)
            assert.equals(vim.fn.exists(":BufPrev") > 1, true)
        end)

        describe(":ToggleBuftabline", function()
            it("should hide tabline if visible", function()
                vim.cmd("ToggleBuftabline")

                assert.equals(vim.o.showtabline, 0)
            end)
            it("should show tabline if hidden", function()
                vim.cmd("ToggleBuftabline")

                vim.cmd("ToggleBuftabline")

                assert.equals(vim.o.showtabline, 2)
            end)
        end)

        describe(":BufNext", function()
            before_each(function()
                edit_mock_files(5)
            end)

            it("should go to next buffer", function()
                vim.cmd("e test3.lua")

                vim.cmd("BufNext")

                assert_current("test4.lua")
            end)

            it("should wrap to first buffer", function()
                vim.cmd("BufNext")

                assert_current("test1.lua")
            end)
        end)

        describe(":BufPrev", function()
            before_each(function()
                edit_mock_files(5)
            end)

            it("should go to previous buffer", function()
                vim.cmd("e test3.lua")

                vim.cmd("BufPrev")

                assert_current("test2.lua")
            end)

            it("should wrap to last buffer", function()
                vim.cmd("e test1.lua")

                vim.cmd("BufPrev")

                assert_current("test5.lua")
            end)
        end)

        describe("buftarget", function()
            local buftarget = require("buftabline.commands").buftarget

            it("should call specified command on specified buffer", function()
                edit_mock_files(5)

                buftarget(1, "buffer")

                assert_current("test1.lua")
            end)

            it("should target 10th buffer when number == 0", function()
                edit_mock_files(10)

                buftarget(1, "buffer")
                buftarget(0, "buffer")

                assert_current("test10.lua")
            end)

            it("should target by bufnr when buffer_id_index option is set", function()
                o.set({ buffer_id_index = true })
                edit_mock_files(5)

                buftarget(vim.fn.getbufinfo()[1].bufnr, "buffer")

                assert_current("test1.lua")
            end)
        end)

        describe("maps", function()
            before_each(function()
                edit_mock_files(5)
            end)

            it("should map key to buftarget command", function()
                input("<Leader>1")

                assert_current("test1.lua")
            end)
        end)
    end)

    describe("tabpage_buffers", function()
        before_each(function()
            o.set({ tabpage_buffers = true })
            vim.opt.columns = 24
        end)

        it("should not show file that belongs to other tab", function()
            edit_mock_files(1)

            vim.cmd("tabnew")

            assert_tabline("%#TabLineFill# 1 %*%#TabLineSel# 2 %*")
        end)

        it("should add file to current tab", function()
            edit_mock_files(1)

            vim.cmd("tabnew")
            vim.cmd("e new-tab-file.lua")

            assert_tabline("%#TabLineSel# 1: new-tab-file.lua %*%#TabLineFill# 1 %*%#TabLineSel# 2 %*")
        end)

        it("should delete buffer on tab close if only open in one tab", function()
            vim.cmd("tabnew")
            edit_mock_files(1)

            vim.cmd("tabclose")

            assert_tabline("")
        end)

        it("should not delete buffer on tab close if open in more than one tab", function()
            edit_mock_files(1)
            vim.cmd("tabnew")
            edit_mock_files(1)

            vim.cmd("tabclose")

            assert_tabline("%#TabLineSel# 1: test1.lua %*")
        end)

        it("should move modified buffer to previous tab", function()
            vim.cmd("tabnew")
            edit_mock_files(1)

            vim.cmd("normal Atest")
            vim.cmd("tabclose")

            assert_tabline("%#TabLineFill# 1: test1.lua [+] %*")
        end)
    end)
end)
