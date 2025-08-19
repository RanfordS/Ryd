require "test_framework"
require "utils"

Test_Result("utils-table.splat-empty.lua",
    "return ".. table.splat({}) .."\n")

Test_Result("utils-table.splat-just_string_keys.lua",
    "return ".. table.splat({
        foo = 1,
        bar = "Hello\tWorld",
        baz = true,
    }) .."\n"
)

Test_Result("utils-table.splat-nested.lua",
    "return ".. table.splat({
        fib = {0, 1, 1, 2, 3, 5, 8},
        nested = {
            first_name = "John",
            last_name = "Doe",
            age = 44,
            tags = {"user", "vip"},
        },
        mixed_array = {
            "alpha",
            "beta",
            "gamma",
            "delta",
            {"epsilon", "var epsilon"},
            "Whatever's next in the Greek alphabet",
        },
        [10] = "index 10",
        ["10"] = "string 10",
        [true] = false,
        [false] = true,
    }) .."\n"
)

