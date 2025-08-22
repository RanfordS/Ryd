require "utils"
require "definitions"

local Ryd = {}

---@alias Token Text | Command | Group | Separator

---@class Text
---@field _metaname "Token.Text"
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
local Text = {}
Text.__index = Text
Text._metaname = "Token.Text"

function Text.new (start_position, end_position)
    return setmetatable({
        start_pos = start_position,
        end_pos   = end_position,
    }, Text)
end

---@class Command
---@field _metaname "Token.Command"
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
---@field name string Identifier part of the command
---@field content Token[]
local Command = {}
Command.__index = Command
Command._metaname = "Token.Command"

function Command.new (position)
    return setmetatable({
        start_pos = position,
        end_pos = position,
        name = "",
        content = {},
    }, Command)
end

---@class Group
---@field _metaname "Token.Group"
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
---@field content Token[]
local Group = {}
Group.__index = Group
Group._metaname = "Token.Group"

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
---@field _metaname "Token.Separator"
---@field pos integer Byte offset of the token within the file.
local Separator = {}
Separator.__index = Separator
Separator._metaname = "Token.Separator"

---@param position integer
---@return Separator
function Separator.new (position)
    return setmetatable({
        pos = position,
    }, Separator)
end



---@enum Token_Type
local Token_Type = {
    ["Token.Command"]   = Command,
    ["Token.Group"]     = Group,
    ["Token.Text"]      = Text,
    ["Token.Separator"] = Separator,
}



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
        if top._metaname == "Token.Command" then
            return top.content
        elseif top._metaname == "Token.Group" then
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
            if #stack == 0 or stack[#stack]._metaname ~= "Token.Command" then
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
                if     top._metaname == "Token.Command" then
                    -- TODO: handle intermediate text
                    table.insert(top.content, sep)
                elseif top._metaname == "Token.Group"   then
                    -- TODO: handle intermediate text
                    table.insert(top.content, sep)
                else
                    pos_error("Separator not valid within ".. top._metaname)
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
                if #stack == 0 or stack[#stack]._metaname ~= "Token.Group" then
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

    assert(#stack == 0, "Reached end of input with groups/commands still open")

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
        local t = token._metaname
        if t == "Token.Text" then
            local text = source:sub(token.start_pos, token.end_pos)
            table.insert(result, prefix .. text:escape())
        elseif t == "Token.Separator" then
            table.insert(result, prefix .. "|")
        elseif t == "Token.Command" then
            local args = Ryd.token_list_to_string(source, token.content, indent + 1)
            table.insert(result, prefix .."[".. token.name .."]\n".. args)
        elseif t == "Token.Group" then
            local args = Ryd.token_list_to_string(source, token.content, indent + 1)
            table.insert(result, prefix .. "{}\n".. args)
        end
    end
    return table.concat(result, "\n")
end

return Ryd
