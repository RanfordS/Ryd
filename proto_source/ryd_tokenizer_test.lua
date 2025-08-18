require "test_framework"
local R = require "ryd"

Test_Result("ryd.tokenizer-empty",
    table.splat(R.tokenize("")))

Test_Result("ryd.tokenizer-just_text",
    table.splat(R.tokenize("Foo")))

Test_Result("ryd.tokenizer-one_command",
    table.splat(R.tokenize("Foo [alpha]")))

