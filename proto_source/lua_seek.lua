
---Seeks the end of a Lua block.
---@TODO: handle [[]] strings
---@TODO: handle comments
---@param str string String to search within.
---@param start_pos integer Byte to start from, the first character of Lua.
---@return integer? end_pos Resulting length of the Lua block, nil on error.
return function (str, start_pos)
    local end_pos = #str
    local bracket_depth = 0
    local in_string = false
    local string_type = ""
    local escaped = false
    for i = start_pos, end_pos do
        local c = str:sub(i,i)

        if escaped then
            escaped = false
        elseif in_string then
            if c == "\\" then
                escaped = true
            elseif c == string_type then
                in_string = false
            end
        elseif c == "[" then
            bracket_depth = bracket_depth + 1
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
    return nil
end

