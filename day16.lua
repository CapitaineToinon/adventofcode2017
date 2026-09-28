local utils = require("utils")

---@class spin
---@field type 's'
---@field size number

---@class exchange
---@field type 'x'
---@field a number
---@field b number

---@class partner
---@field type 'p'
---@field a string
---@field b string

---@alias move spin|exchange|partner

---@class program
---@field offset number
---@field length number
---@field c_to_p table<string, number>
---@field p_to_c table<number, string>

---@param word string
---@return move
local function parse_move(word)
	local type = word:sub(1, 1)
	local rest = word:sub(2, #word)

	if type == "s" then
		---@type spin
		return {
			type = "s",
			size = utils.tonumber(rest),
		}
	end

	local slash = assert(rest:find("/"), "invalid move")
	local a = rest:sub(1, slash - 1)
	local b = rest:sub(slash + 1, #rest)

	if type == "x" then
		---@type exchange
		return {
			type = "x",
			a = utils.tonumber(a) + 1,
			b = utils.tonumber(b) + 1,
		}
	end

	if type == "p" then
		---@type partner
		return {
			type = "p",
			a = a,
			b = b,
		}
	end

	error("unknown move " .. word)
end

---@param input string
---@return move[]
local function parse_moves(input)
	---@type move[]
	local moves = {}

	for word in utils.split_commas(input) do
		table.insert(moves, parse_move(word))
	end

	return moves
end

---@param program program
---@return string
local function get_output(program)
	local output = ""

	for i = 1, program.length do
		local j = utils.mod(i + program.offset, program.length)
		output = output .. program.p_to_c[j]
	end

	return output
end

---@param input string
---@return program
local function get_program(input)
	---@type program
	local program = {
		offset = 0,
		length = #input,
		c_to_p = {},
		p_to_c = {},
	}

	for i = 1, #input do
		program.c_to_p[input:sub(i, i)] = i
		program.p_to_c[i] = input:sub(i, i)
	end

	return program
end

---@param program program
---@param a number
---@param b number
local function swap(program, a, b)
	local char_a, char_b = program.p_to_c[a], program.p_to_c[b]
	program.p_to_c[a] = char_b
	program.p_to_c[b] = char_a
	program.c_to_p[char_a] = b
	program.c_to_p[char_b] = a
end

---@param program program
---@param moves move[]
---@return program
local function dance(program, moves)
	for _, move in ipairs(moves) do
		if move.type == "s" then
			program.offset = utils.mod(program.offset - move.size, program.length)
		end

		if move.type == "x" then
			local a = utils.mod(move.a + program.offset, program.length)
			local b = utils.mod(move.b + program.offset, program.length)

			swap(program, a, b)
		end

		if move.type == "p" then
			local a = program.c_to_p[move.a]
			local b = program.c_to_p[move.b]
			swap(program, a, b)
		end
	end

	return program
end

---@param input string
---@param moves move[]
---@param count? number
local function dance_loop(input, moves, count)
	local program = get_program(input)
	local loop = 1
	local loops = count or 1

	---@type table<string, number>
	local state_to_step = {}
	---@type table<number, string>
	local step_to_state = {}

	while loop <= loops do
		program = dance(program, moves)
		local output = get_output(program)

		if state_to_step[output] ~= nil then
			-- found a loop, meaning the last element
			-- has already been computed
			local loop_size = loop - state_to_step[output]
			return step_to_state[loops % loop_size]
		end

		state_to_step[output] = loop
		step_to_state[loop] = output
		loop = loop + 1
	end

	-- found no loop, just return the last computed value
	return step_to_state[loop - 1]
end

---@param input string
---@param moves move[]
---@return string
local function dance_once(input, moves)
	local program = get_program(input)
	return get_output(dance(program, moves))
end

local input = utils.readline("./input/day16")
local moves = parse_moves(input)

local part_one = dance_once("abcdefghijklmnop", moves)
print(part_one)

local part_two = dance_loop("abcdefghijklmnop", moves, 1000000000)
print(part_two)
