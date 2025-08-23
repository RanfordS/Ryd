require "test_framework"
local R = require "ryd"

Test_Result("ryd.tokenizer-empty.lua",
    "return ".. table.splat(R.tokenize("")))

Test_Result("ryd.tokenizer-just_text.lua",
    "return ".. table.splat(R.tokenize("Foo")))

Test_Result("ryd.tokenizer-one_command.lua",
    "return ".. table.splat(R.tokenize("Foo [alpha]")))

local complete_input = [=[
[section|Introduction]

The following text is an example of many [Ryd] features being used at once.
As a quick overview, these are:
[list|
|   Invariant commands, such as the [m|[l]list[r]] start and [m|[l]Ryd[r]] logo.
|   Argument commands, such as [m|[l]section[|]<name>[r]].
|   Free-floating separators.
|   Groups, such as the table alignment list for the table.
]

[section|Special Commands]

The following commands can be used to include the special characters literally.
[table|{cc|l}|
| Character | Command | Description |[nr]
[h-line]
| [l]       | [m|[l]l[r]] | Left square bracket. |[nr]
| [r]       | [m|[l]r[r]] | Right square bracket. |[nr]
| [|]       | [m|[l][|][r]] | Vertical bar/pipe. |[nr]
| [{]       | [m|[l][{][r]] | Left curly brace. |[nr]
| [}]       | [m|[l][}][r]] | Right curly brace. |[nr]
]
]=]
local tokenized = R.tokenize(complete_input)
local complete_result = table.splat(tokenized)
Test_Result("ryd.tokenizer-large_complete_sample.lua",
    "return ".. complete_result)



---@type {[string]: string}
local failure_cases = {
    incomplete_command = "[",
    incomplete_command_args = "[foo|bar",
    incomplete_group = "{",
    unmatched_command = "]",
    unmatched_group = "}",
    mismatched_1 = "[}",
    mismatched_2 = "[|}",
    mismatched_3 = "{]",
    mismatched_4 = "{[foo|}]",
}

for test, input in table.sorted_pairs(failure_cases) do
    Expect_Error("ryd.tokenizer-fail-".. test,
        R.tokenize, input)
end


