T = require "test_framework"
require "utils_test"
require "ryd_tokenizer_test"

--[[
Expect_Error("check_for_error-pass", function() error("Some error") end)
Expect_Error("check_for_error-fail", function() return "Not error"  end)
--]]

print("")
T.show_summary()

