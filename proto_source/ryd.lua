require "utils"
require "definitions"

local Ryd = {}

---@class Token
---@field token_type Token_Type Type of the token, either one of the command
---     characters or a block of text.
---@field start_pos integer Byte offset of the token within the file.
---@field end_pos integer Byte offset of the token within the file.
local Token = {}
Token.__index = Token

---@param t Token_Type Type of the token.
---@param start_pos integer Byte offset of the token start within the file.
---@param end_pos integer Byte offset of the token end within the file.
function Token.new (t, start_pos, end_pos)
    local new = {
        token_type = t,
        start_pos = start_pos,
        end_pos   = end_pos,
    }
    return setmetatable(new, Token)
end

---@param source string
---@return Token[]
function Ryd.tokenize (source)
    local result = {}

    local last = 0
    while true do
        local pos, _ = source:find(POI_Pattern, last + 1)
        if pos == nil then
            break
        end

        local char = source:sub(pos, pos)
        result[#result+1] = Token.new(Token_Type.text, last+1, pos-1)
        result[#result+1] = Token.new(char, pos, pos)

        last = pos
    end

    result[#result+1] = Token.new(Token_Type.text, last+1, #source)

    return result
end

return Ryd
