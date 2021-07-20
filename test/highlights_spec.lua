local highlights = require("buftabline.highlights")

describe("highlights", function()
    describe("merge_hl", function()
        before_each(function()
            vim.cmd("highlight TestFg guifg=black")
            vim.cmd("highlight TestBg guibg=white")
        end)
        after_each(function()
            vim.cmd("highlight clear")
        end)

        it("should define and return merged hl group", function()
            local merged = highlights.merge_hl("TestFg", "TestBg")

            assert.equals(merged, "TestFgTestBg")
            assert.equals(
                vim.api.nvim_exec("highlight " .. merged, true),
                "TestFgTestBg   xxx guifg=#000000 guibg=#ffffff"
            )
            assert.equals(vim.fn.hlexists(merged), 1)
        end)
    end)

    describe("add_hl", function()
        it("should format string with highlight group", function()
            local formatted = highlights.add_hl("text", "TestFg")

            assert.equals(formatted, "%#TestFg#text%*")
        end)
    end)
end)
