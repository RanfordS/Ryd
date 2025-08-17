--  All test are structured as follows:
--  1.  Some functionality is invoked and a string is returned.
--  2.  The resulting string is written to a file in [m|test_output/].
--  3.  It is also compared with the corresponding file in [m|test_baseline/].
--  4.  If the files match then the test passes, otherwise it fails.
--  5.  When a test fails, investigate the result by performing a diff.
--  6.  If the new output file is correct, use it to replace the baseline.

local test_results = {}

local pass = "\27[1;32mPass\27[0m"
local fail = "\27[1;31mFail\27[0m"

function Test_Result (test_name, actual)
    assert(test_results[test_name] == nil,
        ("Multiple test have the name `%s`"):format(test_name))

    local output_path   = ("./test_output/%s.txt")  :format(test_name)
    local baseline_path = ("./test_baseline/%s.txt"):format(test_name)
    local result = false

    local output_file = io.open(output_path, "wb")
    if output_file then
        output_file:write(actual)
        output_file:close()
    else
        print(test_name ..": Could not open file for writing test result")
    end

    local baseline_file = io.open(baseline_path, "rb")
    if baseline_file then
        local expected = baseline_file:read("*all")
        result = actual == expected
    else
        print(test_name ..": Could not open file for reading baseline")
    end
    test_results[test_name] = result

    print((result and pass or fail) .." - ".. test_name)
end

