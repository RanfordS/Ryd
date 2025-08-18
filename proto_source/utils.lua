U = {}

local universal_comp_weight = {
    ["nil"] = 0,
    number = 1,
    boolean = 2,
    string = 3,
    table = 4,
}

---Universal comparison function, intended for use in `table.sort`.
---Note, relies on `tostring` for most types, may be slow.
---@param lhs any Left hand side.
---@param rhs any Right hand side.
---@return boolean result Whether `lhs < rhs` is considered true.
function U.universal_comp (lhs, rhs)
    local t_lhs = type(lhs)
    local t_rhs = type(rhs)
    if t_lhs ~= t_rhs then
        return universal_comp_weight[t_lhs]
            <  universal_comp_weight[t_rhs]
    end

    local t = t_lhs
    if t ~= "number" and t ~= "string" then
        lhs = tostring(lhs)
        rhs = tostring(rhs)
    end
    return lhs < rhs
end

---Gets a list of all the keys in a given table.
---Note that the order maybe be inconsistent between runs.
---@param tab table
---@return table
function table.list_keys (tab)
    local keys = {}
    for key, _ in pairs (tab) do
        keys[#keys+1] = key
    end
    return keys
end

---Takes a table and returns another table where all of the input table values
---are keys with `true` as the value. Useful when checking for the presence of
---many table values.
---@param tab table Table to get values from.
---@return {[any]: true} map Resulting value map.
function table.value_map (tab)
    local map = {}
    for _, v in pairs(tab) do
        map[v] = true
    end
    return map
end

---Returns the key of an item within a given table.
---If the item occurs within the table multiple times then there is no guarantee
---which key will be returned.
---If the table does not contain the item, `nil` is returned.
---@param tab table Table to search within.
---@param item any Item to search for.
---@return any? key Matching key, or `nil` if the value is not found.
function table.key_of (tab, item)
    for k, v in pairs(tab) do
        if v == item then
            return k
        end
    end
    return nil
end

---Returns whether a particular item is in the given table.
---@param tab table Table to search within
---@param item any Item to search for.
---@return boolean present True when the table contains the item.
function table.contains (tab, item)
    return table.key_of(tab, item) ~= nil
end

---Escapes control characters and quotes.
---@param str string String to apply escapes to.
---@return string
function string.escape (str)
    local new = str
    :gsub("\\", "\\\\")
    :gsub("\n", "\\n")
    :gsub("\r", "\\r")
    :gsub("\t", "\\t")
    :gsub("\"", "\\\"")
    return '"'.. new ..'"'
end

local keywords = {
    ["and"]      = true,
    ["break"]    = true,
    ["do"]       = true,
    ["else"]     = true,
    ["elseif"]   = true,
    ["end"]      = true,
    ["for"]      = true,
    ["function"] = true,
    ["in"]       = true,
    ["local"]    = true,
    ["not"]      = true,
    ["or"]       = true,
    ["repeat"]   = true,
    ["return"]   = true,
    ["then"]     = true,
    ["until"]    = true,
    ["while"]    = true,

    ["true"]     = true,
    ["false"]    = true,
    ["nil"]      = true,
}

---Checks to see if a string could be used as a key without being escaped.
function string.valid_key (str)
    if keywords[str] then
        return false
    end
    return str:match("^[_%a][_%a%d]*$") ~= nil
end

local function indent (str, depth)
    return ("    "):rep(depth) .. str
end

local splat_supported_key_types = {
    number = true,
    string = true,
    boolean = true,
}

---Outputs a given table and it's children as a string.
---@param tab table Table to output.
---@param depth integer Indentation depth for displaying at.
---@return string
local function splat (tab, depth)
    local keys = table.list_keys(tab)
    if #keys == 0 then
        return "{}"
    end
    local lines = {"{"}
    table.sort(keys, U.universal_comp)
    local is_array_index = true
    for i, key in ipairs(keys) do
        local value = tab[key]
        local t_key = type(key)
        --TODO: this may be an unreasonable constraint, re-evaluate
        assert(splat_supported_key_types[t_key],
            ("`%s` is not a supported key type for `splat`"):format(t_key))

        local prefix
        if is_array_index and i == key then
            prefix = ""
        else
            is_array_index = false
            if type(key) == "string" then
                if key:valid_key() then
                    prefix = key .." = "
                else
                    prefix = ("[%s] = "):format(key:escape())
                end
            else
                prefix = ("[%s] = "):format(tostring(key))
            end
        end

        local t_value = type(value)
        local str_value
        if t_value == "table" then
            str_value = splat(value, depth + 1)
        elseif t_value == "string" then
            str_value = value:escape()
        else
            str_value = tostring(value)
        end
        local line = indent(prefix .. str_value ..",", depth + 1)
        lines[#lines+1] = line
    end
    lines[#lines+1] = indent("}", depth)
    return table.concat(lines, "\n")
end

---Outputs a given table and it's children as a string.
---@param tab table Table to output.
---@return string
function table.splat (tab)
    return splat(tab, 0)
end

