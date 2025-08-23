
---Seeks the end of a Lua block.
---@param str string String to search within.
---@param start_pos integer Byte to start from, the first character of Lua.
---@return integer end_pos Resulting length of the Lua block.
return function (str, start_pos)
    local end_pos = #str
    local bracket_depth = 0
    local in_string = false
    local string_type = ""
    local escaped = false
    local skip_to = 0

    local function block_jump (start_from, expected_pos)
        local open_s, open_e = str:find("%[=*%[", start_from)
        if not open_s or open_s ~= expected_pos then
            return false
        end
        local block_open = str:sub(open_s, open_e)
        local shut_pattern = block_open:gsub("%[", "%%]")
        local shut_s, shut_e = str:find(shut_pattern, open_e + 1)
        if not shut_s then
            error(("Encounter a block opening `%s` at %i without a matching closing with format `%s`"):format(block_open, expected_pos, shut_pattern))
        end
        skip_to = shut_e + 1
        return true
    end

    for i = start_pos, end_pos do
        local c = str:sub(i,i)

        if i < skip_to then
            -- nothing
        elseif escaped then
            escaped = false
        elseif in_string then
            if c == "\\" then
                escaped = true
            elseif c == string_type then
                in_string = false
            end
        elseif c == "-" and str:sub(i+1, i+1) == "-" then
            if not block_jump(i, i + 2) then
                local s, e = str:find("\n", i + 2)
                assert(s and e, "Encounter a line comment with no ending")
                skip_to = s + 1
            end
        elseif c == "[" then
            if not block_jump(i, i) then
                bracket_depth = bracket_depth + 1
            end
        elseif c == "]" and not in_string then
            bracket_depth = bracket_depth - 1
            if bracket_depth < 0 then
                return i
            end
        elseif c == '"' or c == "'" then
            string_type = c
            in_string = true
        end
    end
    error("Reached end of input without encountering the end of the Lua block")
end

