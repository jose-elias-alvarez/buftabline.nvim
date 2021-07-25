local o = require("buftabline.options")

local edit_mock_files = function(count)
    for i = 1, count do
        vim.cmd("e test" .. i .. ".lua")
    end
end

local close_all = function()
    vim.cmd("bufdo! bwipeout!")
end

describe("build", function()
    local build = require("buftabline.build")

    local original_columns = vim.o.columns
    after_each(function()
        vim.o.columns = original_columns
        close_all()
        o.reset()
    end)

    describe("tabs", function()
        it("should build tabline from open buffers", function()
            edit_mock_files(3)

            assert.equals(
                build(),
                "%#TabLineFill# 1: test1.lua %*%#TabLineFill# 2: test2.lua %*%#TabLineSel# 3: test3.lua %*"
            )
        end)

        -- test is order dependent, since buffer numbers won't be cleared until neovim is closed
        it("should use buffer id index", function()
            o.set({ buffer_id_index = true })

            edit_mock_files(3)

            assert.equals(
                build(),
                "%#TabLineFill# 4: test1.lua %*%#TabLineFill# 5: test2.lua %*%#TabLineSel# 6: test3.lua %*"
            )
        end)

        it("should skip no name buffer", function()
            vim.cmd("enew")

            edit_mock_files(3)

            assert.equals(
                build(),
                "%#TabLineFill# 1: test1.lua %*%#TabLineFill# 2: test2.lua %*%#TabLineSel# 3: test3.lua %*"
            )
        end)

        it("should truncate to fit budget", function()
            vim.opt.columns = 32

            edit_mock_files(3)
            -- go to previous buffer to truncate last
            vim.cmd("b#")

            assert.equals(build(), "%#TabLineFill# 1: test1.lua %*%#TabLineSel# 2: test2.lua %*%#TabLineFill# 3:>%*")
        end)
    end)

    describe("tabpages", function()
        before_each(function()
            vim.opt.columns = 24
            edit_mock_files(1)
        end)

        it("should not show tabpages if only one tab is open and show_tabpages is set to true", function()
            assert.equals(build(), "%#TabLineSel# 1: test1.lua %*")
        end)

        it("should not show tabpages regardless of number if show_tabpages is set to false", function()
            o.set({ show_tabpages = false })

            vim.cmd("tabnew")

            assert.equals(build(), "%#TabLineFill# 1: test1.lua %*")
        end)

        it("should show tabpages if more than one tab is open and show_tabpages is set to true", function()
            vim.cmd("tabnew")

            assert.equals(build(), "%#TabLineFill# 1: test1.lua %*    %#TabLineFill# 1 %*%#TabLineSel# 2 %*")
        end)

        it("should show tabpages if only one tab is open and show_tabpages is set to 'always'", function()
            o.set({ show_tabpages = "always" })

            assert.equals(build(), "%#TabLineSel# 1: test1.lua %*       %#TabLineSel# 1 %*")
        end)

        it("should show tabpages on left if tabpage_position is set to 'left'", function()
            o.set({ tabpage_position = "left" })

            vim.cmd("tabnew")

            assert.equals(build(), "%#TabLineFill# 1 %*%#TabLineSel# 2 %*%#TabLineFill# 1: test1.lua %*")
        end)
    end)
end)
