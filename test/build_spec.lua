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

    after_each(function()
        close_all()
        o.reset()
    end)

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
