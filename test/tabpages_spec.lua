local o = require("buftabline.options")

describe("tabpages", function()
    local t = require("buftabline.tabpages")

    after_each(function()
        vim.cmd("silent tabonly")

        o.reset()
    end)

    describe("make_tabpage_tabs", function()
        it("should return empty table if show_tabpages option is false", function()
            o.set({ show_tabpages = false })

            local tabpage_tabs = t.make_tabpage_tabs()

            assert.equals(#tabpage_tabs, 0)
        end)

        it("should return empty table if only one tabpage", function()
            local tabpage_tabs = t.make_tabpage_tabs()

            assert.equals(#tabpage_tabs, 0)
        end)

        it("should return tabpage tab if only one tabpage but option is set to 'always'", function()
            o.set({ show_tabpages = "always" })

            local tabpage_tabs = t.make_tabpage_tabs()

            assert.equals(#tabpage_tabs, 1)
        end)

        it("should return tabpage tabs if more than one tabpage", function()
            vim.cmd("tabnew")

            local tabpage_tabs = t.make_tabpage_tabs()

            assert.equals(#tabpage_tabs, 2)
        end)

        it("should set tabpage tab index and current", function()
            vim.cmd("tabnew")

            local tabpage_tabs = t.make_tabpage_tabs()

            assert.equals(tabpage_tabs[1].index, 1)
            assert.equals(tabpage_tabs[1].current, false)
            assert.equals(tabpage_tabs[2].index, 2)
            assert.equals(tabpage_tabs[2].current, true)
        end)
    end)
end)
