
---@class Command_Variant
---@field variadic boolean
---Whether the command accepts additional arguments.
---@field seeker (fun(str: string, start_pos: integer): integer)?
---If not nil, alternate parsing rule for determining the end of the input.
---@field handler function
---Function to execute when the command is encountered.
local Command_Variant = {}
Command_Variant.__index = Command_Variant

---@class Command_Set
---@field name string Command name.
---@field variants_by_arity table<integer, Command_Variant>
---Map of command variants by (minimum) argument count.
---Particular command definition by the (minimum) number of arguments taken.
---If a variadic variant exists, it is stored in the max_fixed_arity.
---@field max_fixed_arity integer
---The maximum number of fixed arguments across all variants.
local Command_Set = {}

---Checks whether the command set contains a seeking command.
---@param self Command_Set
function Command_Set.has_seeking (self)
    local top = self.variants_by_arity[self.max_fixed_arity]
    if not top then -- no command with th
        return false
    end
end

---@param command Command_Variant
---@return boolean
local function is_fixed (command)
    return command.variadic == false
       and command.seeker == nil
end
Command_Variant.is_fixed = is_fixed

---@type table<string, Command_Set>
local all_commands = {}

---comment
---@param name string Command name.
---@param fixed_arity integer Fixed number of arguments required.
---@param variadic_or_seeker boolean|fun(str: string, start_pos: integer): integer
---@param handler function
---@param override boolean
local function new (name, fixed_arity, variadic_or_seeker, handler, override)
end
Command_Variant.new = new

