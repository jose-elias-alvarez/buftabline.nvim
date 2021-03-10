local o = require("buftabline.options")
local set_maps = require("buftabline.set-maps")

local reset = function()
    for i = 0, 9 do
        if vim.fn.maparg("<Leader>" .. i) ~= "" then
            vim.api.nvim_del_keymap("n", "<Leader>" .. i)
        end
    end
end

describe("set_maps", function()
    it("should set go to buffer maps when go_to_maps == true", function()
        reset()
        o.set({go_to_maps = true})

        set_maps()

        for i = 0, 9 do
            assert.equals(vim.fn.maparg("<Leader>" .. i),
                          ":lua require'buftabline'.go_to_buffer(" .. i ..
                              ")<CR>")
        end
    end)

    it("should not set go to buffer maps when go_to_maps == false", function()
        reset()
        o.set({go_to_maps = false})

        set_maps()

        for i = 0, 9 do assert.equals(vim.fn.maparg("<Leader>" .. i), "") end
    end)

    it("should set kill buffer maps when kill_maps == true", function()
        reset()
        o.set({kill_maps = true})

        set_maps()

        for i = 0, 9 do
            assert.equals(vim.fn.maparg("<Leader>c" .. i),
                          ":lua require'buftabline'.kill_buffer(" .. i ..
                              ")<CR>")
        end
    end)

    it(
        "should set custom command maps when custom_command and custom_map_prefix have been set",
        function()
            reset()
            o.set({custom_command = "vsplit", custom_map_prefix = "v"})

            set_maps()

            for i = 0, 9 do
                assert.equals(vim.fn.maparg("<Leader>v" .. i),
                              ":lua require'buftabline'.custom_command(" .. i ..
                                  ")<CR>")
            end
        end)
end)
