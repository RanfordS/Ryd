--  All test are structured as follows:
--  1.  Some functionality is invoked and a string is returned.
--  2.  The resulting string is written to a file in [m|test_output/].
--  3.  It is also compared with the corresponding file in [m|test_baseline/].
--  4.  If the files match then the test passes, otherwise it fails.
--  When a test fails, you can investigate the result by performing a diff
--  between output and the baseline.
--  If the new output file is correct, replace the baseline.

local test_results = {}

local pass = "\27[1;32mPass\27[0m"
local fail = "\27[1;31mFail\27[0m"

---@param test_name string Unique name for the test.
---@param actual string Resulting output of the tested code.
function Test_Result (test_name, actual)
    assert(test_results[test_name] == nil,
        ("Multiple test have the name `%s`"):format(test_name))

    local output_path   = ("./test_output/%s")  :format(test_name)
    local baseline_path = ("./test_baseline/%s"):format(test_name)
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

---@param test_name string Unique name for the test.
---@param f fun(...: any): any Function to be tested.
---@param ... any Optional arguments to pass to the function.
function Expect_Error (test_name, f, ...)
    assert(test_results[test_name] == nil,
        ("Multiple test have the name `%s`"):format(test_name))
    local success, _ = pcall(f, ...)
    local result = not success
    test_results[test_name] = result

    print((result and pass or fail) .." - ".. test_name)
end

function Test_Summary ()
    local passed, failed = 0, 0
    ---@type string[]
    local failed_tests = {}

    for test, result in pairs(test_results) do
        if result then
            passed = passed + 1
        else
            failed_tests[#failed_tests+1] = test
            failed = failed + 1
        end
    end

    print(("\27[1;32mPassed:\27[0m %i"):format(passed))
    if failed == 0 then
        print("\27[1;32mAll passed\27[0m")
    else
        print(("\27[1;31mFailed:\27[0m %i"):format(failed))

        print("")
        print("\27[1mFailed tests:\27[0m")
        table.sort(failed_tests)
        for _, test in ipairs(failed_tests) do
            print("- ".. test)
        end
    end

end

