require "test_framework"
local R = require "ryd"

Test_Result("ryd.tokenizer-empty.lua",
    "return ".. table.splat(R.tokenize("")))

Test_Result("ryd.tokenizer-just_text.lua",
    "return ".. table.splat(R.tokenize("Foo")))

Test_Result("ryd.tokenizer-one_command.lua",
    "return ".. table.splat(R.tokenize("Foo [alpha]")))

