local utils = require("utils")

---@alias condition { register: string, cmp: string, value: number }
---@alias instruction { register: string, action: string, by: number, conditition: condition }
---@alias registers { [string]?: number }

---@param line string
---@return instruction
local function parse_instruction(line)
	---@type string[]
	local words = {}

	for word in utils.split_spaces(line) do
		table.insert(words, word)
	end

	---@type instruction
	local instruction = {
		register = words[1],
		action = words[2],
		by = utils.tonumber(words[3]),
		conditition = {
			register = words[5],
			cmp = words[6],
			value = utils.tonumber(words[7]),
		},
	}

	return instruction
end

---@return instruction[]
local function get_instructions()
	---@type instruction[]
	local instructions = {}

	for line in io.lines("./input/day08", "l") do
		table.insert(instructions, parse_instruction(line))
	end

	return instructions
end

---@param registers registers
---@return number
local function get_biggest_register(registers)
	---@type number
	local max = math.mininteger

	for _, value in pairs(registers) do
		max = math.max(max, value)
	end

	return max
end

---@param registers registers
---@param condition condition
---@return boolean
local function is_true(registers, condition)
	local actual = registers[condition.register] or 0

	if condition.cmp == ">" then
		return actual > condition.value
	end

	if condition.cmp == ">=" then
		return actual >= condition.value
	end

	if condition.cmp == "==" then
		return actual == condition.value
	end

	if condition.cmp == "!=" then
		return actual ~= condition.value
	end

	if condition.cmp == "<=" then
		return actual <= condition.value
	end

	if condition.cmp == "<" then
		return actual < condition.value
	end

	error("invalid condition")
end

---@param registers registers
---@param i instruction
local function run_instruction(registers, i)
	if is_true(registers, i.conditition) then
		local actual = registers[i.register] or 0

		if i.action == "inc" then
			registers[i.register] = actual + i.by
			return
		end

		if i.action == "dec" then
			registers[i.register] = actual - i.by
			return
		end

		error("invalid instruction")
	end
end

---@param instructions instruction[]
---@return number, number
local function run_instructions(instructions)
	local max = math.mininteger

	---@type registers
	local registers = {}

	for _, instruction in ipairs(instructions) do
		run_instruction(registers, instruction)
		max = math.max(max, get_biggest_register(registers))
	end

	return get_biggest_register(registers), max
end

local instructions = get_instructions()
local part_one, part_two = run_instructions(instructions)

print(part_one)
print(part_two)
