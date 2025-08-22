require "utils"
require "definitions"

local Ryd = {}

---@alias Token Text | Command | Group | Separator

---@class Text
---@field token_type "text"
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
local Text = {}
Text.token_type = "text"

function Text.new (start_position, end_position)
    return setmetatable({
        start_pos = start_position,
        end_pos   = end_position,
    }, Text)
end

---@class Command
---@field token_type "command"
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
---@field name string Identifier part of the command
---@field content Token[]
local Command = {}
Command.__index = Command
Command.token_type = "command"

function Command.new (position)
    return setmetatable({
        start_pos = position,
        end_pos = position,
        name = "",
        content = {},
    }, Command)
end

---@class Group
---@field token_type "group"
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
---@field content Token[]
local Group = {}
Group.__index = Group
Group.token_type = "group"

---@param position integer
---@return Group
function Group.new (position)
    return setmetatable({
        start_pos = position,
        end_pos = position,
        content = {},
    }, Group)
end

---@class Separator
---@field token_type "separator"
---@field pos integer Byte offset of the token within the file.
local Separator = {}
Separator.__index = Separator
Separator.token_type = "separator"

---@param position integer
---@return Separator
function Separator.new (position)
    return setmetatable({
        pos = position,
    }, Separator)
end



---@enum Token_Type
local Token_Type = {
    command   = Command,
    group     = Group,
    text      = Text,
    separator = Separator,
}



---@param source string
---@return Token[]
function Ryd.parse_by_char (source)
    ---@type Token[]
    local result = {}

    for char in source:gmatch(".") do
    end

    return result
end



---@param source string
---@return Token[]
function Ryd.tokenize (source)
    local result = {}

    ---@type Token[]
    local stack = {}
    local in_command_name = false

    local function context ()
        if #stack == 0 then
            return result
        end
        local top = stack[#stack]
        if top.token_type == "command" then
            return top.content
        elseif top.token_type == "group" then
            return top.content
        end
        error("idk")
    end

    local last = 0
    while true do
        local pos, _ = source:find(POI_Pattern, last + 1)
        if pos == nil then
            break
        end
        ---@type Special_Char
        local char = source:sub(pos, pos)

        ---@param message string
        local function pos_error (message)
            local prefix = ("(Byte %i, Char `%s`)"):format(pos, char)
            error(prefix .. message)
        end

        if not in_command_name then
            if last+1 <= pos-1 then
                table.insert(context(), Text.new(last+1, pos-1))
            end
        end

        local top = stack[#stack]

        if not table.contains(Special_Chars, char) then
            pos_error("POI_Pattern matched an unexpected character")

        elseif char == Special_Chars.open_command then
            if in_command_name then
                pos_error(
                    "Open command character not allowed in a command name")
            end
            in_command_name = true
            local cmd = Command.new(pos)
            table.insert(context(), cmd)
            stack[#stack+1] = cmd

        elseif char == Special_Chars.close_command then
            if #stack == 0 or stack[#stack].token_type ~= "command" then
                pos_error(
                    "Close command unmatched")
            end
            if in_command_name then
                in_command_name = false
                top.name = source:sub(top.start_pos+1, pos-1)
            end
            top.end_pos = pos
            stack[#stack] = nil

        elseif char == Special_Chars.separator then
            local sep = Separator.new(pos)
            if #stack == 0 then
                result[#result+1] = sep
            else
                if     top.token_type == "command" then
                    -- TODO: handle intermediate text
                    table.insert(top.content, sep)
                elseif top.token_type == "group"   then
                    -- TODO: handle intermediate text
                    table.insert(top.content, sep)
                else
                    pos_error("Separator not valid within ".. top.token_type)
                end
            end
            if in_command_name then
                in_command_name = false
                top.name = source:sub(top.start_pos+1, pos-1)
            end

        elseif char == Special_Chars.open_group then
            if not in_command_name then
                stack[#stack+1] = Group.new(pos)
                --TODO: create token
            end

        elseif char == Special_Chars.close_group then
            if not in_command_name then
                if #stack == 0 or stack[#stack].token_type ~= "group" then
                    pos_error(
                        "Close group unmatched")
                end
                stack[#stack].end_pos = pos
                stack[#stack] = nil
            end

        else
            pos_error("Unhandled special character")
        end

        last = pos
    end

    return result
end

---@param source string
---@param tokens Token[]
---@param indent integer
---@return string
function Ryd.token_list_to_string (source, tokens, indent)
    local result = {}
    local prefix = ("  "):rep(indent)
    for _, token in ipairs(tokens) do
        local t = token.token_type
        if t == "text" then
            local text = source:sub(token.start_pos, token.end_pos)
            table.insert(result, prefix .. text:escape())
        elseif t == "separator" then
            table.insert(result, prefix .. "|")
        elseif t == "command" then
            local args = Ryd.token_list_to_string(source, token.content, indent + 1)
            table.insert(result, prefix .. token.name .."\n".. args)
        end
    end
    return table.concat(result, "\n")
end

return Ryd
