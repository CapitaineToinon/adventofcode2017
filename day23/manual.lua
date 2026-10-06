local utils = require("utils")

---@param input string
---@return string
---@return string
---@return string
local function parse_instruction(input)
	local segments = {}

	for word in utils.split_spaces(input) do
		table.insert(segments, word)
	end

	assert(#segments == 3, "invalid instruction")

	return segments[1], segments[2], segments[3]
end

local M = {}

---Solves part one manually, by executing the source code.
---This code is too slow for part two.
---@param registers table<string, number>
---@return table<string, number>
function M.part_one(registers)
	local lines = utils.readlines("./input/day23")
	local p = 1

	---@type table<string, number>
	local calls = {}

	---@type table<number, number>
	local p_counts = {}

	---@param register string
	---@return number
	local function get(register)
		local number = tonumber(register)

		if number ~= nil then
			return number
		end

		return registers[register] or 0
	end

	---@param register string
	---@param value number
	local function set(register, value)
		registers[register] = value
	end

	while true do
		local i = lines[p]

		if i == nil then
			break
		end

		p_counts[p] = (p_counts[p] or 0) + 1

		local a, x, y = parse_instruction(i)

		calls[a] = (calls[a] or 0) + 1

		if a == "set" then
			set(x, get(y))
			p = p + 1
		end

		if a == "sub" then
			set(x, get(x) - get(y))
			p = p + 1
		end

		if a == "mul" then
			set(x, get(x) * get(y))
			p = p + 1
		end

		if a == "jnz" then
			if get(x) ~= 0 then
				p = p + get(y)
			else
				p = p + 1
			end
		end
	end

	return calls
end

return M
