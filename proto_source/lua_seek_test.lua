local seek = require "lua_seek"

---@param case string Test case name suffix.
---@param input string
---@param open_pattern string Pattern for the script opening.
---End of pattern is taken as the start.
---@param close_pattern string Pattern for the script ending.
---This should always start with a close square bracket.
local function test (case, input, open_pattern, close_pattern)
    local test_name = "lua-seek-".. case

    local _, start_pos = input:find(open_pattern)
    assert(start_pos, test_name ..": starting pattern not found")
    local expected_end, _ = input:find(close_pattern)
    assert(expected_end, test_name ..": ending pattern not found")
    local actual_end = seek(input, start_pos)
    local result = expected_end == actual_end
    T.record_result(test_name, result)
end

test("empty_script",
    "[lua|]",
    "|", "]")

test("basic_script",
    "From Lua [lua|print('Hi')].",
    "|", "]")

test("complex_strings",
    "From Lua [lua|print('Hi \"friend\", care for some drink\\'n')].",
    "|", "]%.")

test("strings_with_brackets",
    '[lua|local a = "][]["] is fine',
    "|", "] is fine")

test("indexing", [=[
Preamble:
[lua|
    local fib = {0, 1, 1, 2, 3, 5, 8, 13}
    for i = 1, #fib do
        print(i, fib[i])
    end
].
Done.
]=], "|", "]%.\nDone")



