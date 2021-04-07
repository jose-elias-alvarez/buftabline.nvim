local u = require("buftabline.utils")

describe("deepcopy", function()
    it("should return new copy of object", function()
        local test_object = {key = "val", other_key = "other_val"}

        local copy = u.deepcopy(test_object)

        assert.is_not.equals(test_object, copy)
        assert.same(test_object, copy)
    end)

    it("should return identical copy of non-object", function()
        local test_string = "hello"

        local copy = u.deepcopy(test_string)

        assert.equals(test_string, copy)
        assert.same(test_string, copy)
    end)
end)

describe("tablelength", function()
    it("should return length of table", function()
        local test_table = {"item1", "item2", "item3"}

        local length = u.tablelength(test_table)

        assert.equals(length, 3)
    end)
end)
