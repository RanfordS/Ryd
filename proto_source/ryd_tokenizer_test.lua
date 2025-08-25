local R = require "ryd"

T.file_compare("ryd.tokenizer-empty.lua",
    "return ".. table.splat(R.tokenize("")))

T.file_compare("ryd.tokenizer-just_text.lua",
    "return ".. table.splat(R.tokenize("Foo")))

T.file_compare("ryd.tokenizer-one_command.lua",
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
local complete_tokenized = R.tokenize(complete_input)
local complete_result = table.splat(complete_tokenized)
T.file_compare("ryd.tokenizer-large_complete_sample.lua",
    "return ".. complete_result)

local seeking_input = [=[
[section|Seeking Example]

[set|fib|10]

First [show|fib] Fibonacci numbers:
[enum|
    [lua|
        local fib = {0, 1}
        while #fib < Ryd.vars.fib do
            local i = #fib + 1
            fib[i] = fib[i-2] + fib[i-1]
        end

        for _, v in ipairs(fib) do
            Ryd.insert("| ".. tostring(v))
        end
    ]
]

How's that?
]=]
local seeking_tokenized = R.tokenize(seeking_input)
local seeking_result = table.splat(seeking_tokenized)
T.file_compare("ryd.tokenizer-seeking_command.lua",
    "return ".. seeking_result)



---@type {[string]: string}
local failure_cases = {
    incomplete_command = "[",
    incomplete_command_args_1 = "[foo|bar",
    incomplete_command_args_2 = "[foo|bar|",
    incomplete_group = "{",
    unmatched_command = "]",
    unmatched_group = "}",
    mismatched_1 = "[}",
    mismatched_2 = "[|}",
    mismatched_3 = "{]",
    mismatched_4 = "{[foo|}]",
}

for test, input in table.sorted_pairs(failure_cases) do
    T.expect_error("ryd.tokenizer-fail-".. test,
        R.tokenize, input)
end


