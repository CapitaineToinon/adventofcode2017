local utils = require("utils")

---@class instruction
---@field type string
---@field X string
---@field Y? string|number

---@class state
---@field id number
---@field registers table<string, number>
---@field pointer number
---@field locked boolean

---@class global
---@field bus table<number, number[]>
---@field snd_count table<number, number>

---@param input string|nil
---@return string|number|nil
local function try_tonumber(input)
	if input == nil then
		return nil
	end

	local number = tonumber(input)

	if number ~= nil then
		return number
	end

	return input
end

---@return instruction[]
local function get_instructions()
	---@type instruction[]
	local instructions = {}

	for line in io.lines("./input/day18", "l") do
		---@type string[]
		local words = {}

		for word in utils.split_spaces(line) do
			table.insert(words, word)
		end

		table.insert(instructions, {
			type = words[1],
			X = try_tonumber(words[2]),
			Y = try_tonumber(words[3]),
		})
	end

	return instructions
end

---@param state state
---@param i string|number
---@return number
local function get(state, i)
	if type(i) == "number" then
		return i
	end

	return state.registers[i] or 0
end

---@param state state
---@param i string|number
---@param j number
local function set(state, i, j)
	if type(i) == "number" then
		error("invalid register destination")
	end

	state.registers[i] = j
end

---Runs the next instruction for a given program
---Returns true if the program is stuck
---@param state state
---@param rcv_from number|nil
---@param global global
---@param instructions instruction[]
---@return boolean
local function step(state, rcv_from, global, instructions)
	local i = instructions[state.pointer]

	if i == nil then
		return true
	end

	if i.type == "snd" then
		table.insert(global.bus[state.id], get(state, i.X))
		global.snd_count[state.id] = global.snd_count[state.id] + 1
		state.pointer = state.pointer + 1

		return false
	end

	if i.type == "set" then
		local y = get(state, i.Y)
		set(state, i.X, y)
		state.pointer = state.pointer + 1

		return false
	end

	if i.type == "add" then
		local x = get(state, i.X)
		local y = get(state, i.Y)
		set(state, i.X, x + y)
		state.pointer = state.pointer + 1

		return false
	end

	if i.type == "mul" then
		local x = get(state, i.X)
		local y = get(state, i.Y)
		set(state, i.X, x * y)
		state.pointer = state.pointer + 1

		return false
	end

	if i.type == "mod" then
		local x = get(state, i.X)
		local y = get(state, i.Y)
		set(state, i.X, x % y)
		state.pointer = state.pointer + 1

		return false
	end

	if i.type == "jgz" then
		local x = get(state, i.X)
		local y = get(state, i.Y)

		if x > 0 then
			state.pointer = state.pointer + y
		else
			state.pointer = state.pointer + 1
		end

		return false
	end

	if i.type == "rcv" then
		-- [NOTE] Part 1 says:
		--
		-- rcv X recovers the frequency of the last sound played, but only when the
		-- value of X is not zero. (If it is zero, the command does nothing.)
		--
		-- but not checking the value of X not only works just fine for part one
		-- but is also required for part two to work, at least with my input.
		--
		-- Leaving the logic as is.

		if rcv_from == nil then
			return true
		end

		local y = table.remove(global.bus[rcv_from], 1)

		if y == nil then
			return true
		end

		set(state, i.X, y)
		state.pointer = state.pointer + 1

		return false
	end

	error("invalid instruction")
end

---@param instructions instruction[]
---@return number|nil
local function run_one(instructions)
	---@type state
	local state = {
		id = 1,
		pointer = 1,
		registers = {},
		locked = false,
	}

	---@type global
	local global = {
		bus = {
			[state.id] = {},
		},
		snd_count = {
			[state.id] = 0,
		},
	}

	while true do
		local locked = step(state, nil, global, instructions)

		if locked then
			return table.remove(global.bus[state.id])
		end
	end
end

---@param instructions instruction[]
---@return number
local function run_two(instructions)
	---@type state
	local a = {
		id = 1,
		pointer = 1,
		registers = { p = 0 },
		locked = false,
	}

	---@type state
	local b = {
		id = 2,
		pointer = 1,
		registers = { p = 1 },
		locked = false,
	}

	---@type global
	local global = {
		bus = {
			[a.id] = {},
			[b.id] = {},
		},
		snd_count = {
			[a.id] = 0,
			[b.id] = 0,
		},
	}

	while true do
		local locked_a = step(a, b.id, global, instructions)
		local locked_b = step(b, a.id, global, instructions)

		if locked_a and locked_b then
			return global.snd_count[b.id]
		end
	end
end

local instructions = get_instructions()

print(run_one(instructions))
print(run_two(instructions))
