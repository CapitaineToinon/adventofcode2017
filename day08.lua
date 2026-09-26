---@alias Condition { register: string, cmp: string, value: number }
---@alias Instruction { register: string, action: string, by: number, conditition: Condition }
---@alias Registers { [string]?: number }

---@param line string
---@return Instruction
local function parse_instruction(line)
	---@type string[]
	local words = {}

	for word in line:gmatch("%S+") do
		table.insert(words, word)
	end

	---@type Instruction
	local instruction = {
		register = words[1],
		action = words[2],
		by = assert(tonumber(words[3]), "failed to parse int"),
		conditition = {
			register = words[5],
			cmp = words[6],
			value = assert(tonumber(words[7]), "failed to parse int"),
		},
	}

	return instruction
end

---@return Instruction[]
local function get_instructions()
	---@type Instruction[]
	local instructions = {}

	for line in io.lines("./input/day08", "l") do
		table.insert(instructions, parse_instruction(line))
	end

	return instructions
end

---@param registers Registers
---@return number
local function get_biggest_register(registers)
	---@type number
	local max = math.mininteger

	for _, value in pairs(registers) do
		max = math.max(max, value)
	end

	return max
end

---@param registers Registers
---@param condition Condition
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

---@param registers Registers
---@param instruction Instruction
local function run_instruction(registers, instruction)
	if is_true(registers, instruction.conditition) then
		local actual = registers[instruction.register] or 0

		if instruction.action == "inc" then
			registers[instruction.register] = actual + instruction.by
			return
		end

		if instruction.action == "dec" then
			registers[instruction.register] = actual - instruction.by
			return
		end

		error("invalid instruction")
	end
end

---@param instructions Instruction[]
---@return number, number
local function run_instructions(instructions)
	local max = math.mininteger

	---@type Registers
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
