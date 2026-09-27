---@class Spin
---@field type 's'
---@field size number

---@class Exchange
---@field type 'x'
---@field a number
---@field b number

---@class Partner
---@field type 'p'
---@field a string
---@field b string

---@alias move Spin|Exchange|Partner

---@param input string
---@return number
local function parse_int(input)
	return assert(tonumber(input), "failed to parse int " .. input)
end

---@param i number
---@param base number
---@return number
local function mod(i, base)
	return ((i - 1) % base) + 1
end

---@return string
local function get_input()
	local f = assert(io.open("./input/day16", "r"), "failed to open input")
	local content = tostring(f:read("l"))
	f:close()
	return content
end

---@param word string
---@return move
local function parse_move(word)
	local type = word:sub(1, 1)
	local rest = word:sub(2, #word)

	if type == "s" then
		---@type Spin
		return {
			type = "s",
			size = parse_int(rest),
		}
	end

	local slash = assert(rest:find("/"), "invalid move")
	local a = rest:sub(1, slash - 1)
	local b = rest:sub(slash + 1, #rest)

	if type == "x" then
		---@type Exchange
		return {
			type = "x",
			a = parse_int(a) + 1,
			b = parse_int(b) + 1,
		}
	end

	if type == "p" then
		---@type Partner
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

	for word in input:gmatch("([^,]+)") do
		table.insert(moves, parse_move(word))
	end

	return moves
end

---@param pos_to_char table<number, string>
---@param offset number
---@param len number
---@return string
local function get_output(pos_to_char, offset, len)
	local output = ""

	for i = 1, len do
		local j = mod(i + offset, len)
		output = output .. pos_to_char[j]
	end

	return output
end

---@param program string
---@param moves move[]
---@param count? number
local function dance(program, moves, count)
	local len = #program

	---@type table<string, number>
	local char_to_pos = {}
	---@type table<number, string>
	local pos_to_char = {}

	for i = 1, #program do
		char_to_pos[program:sub(i, i)] = i
		pos_to_char[i] = program:sub(i, i)
	end

	local offset = 0

	---@param a number
	---@param b number
	local function swap(a, b)
		local char_a, char_b = pos_to_char[a], pos_to_char[b]
		pos_to_char[a] = char_b
		pos_to_char[b] = char_a
		char_to_pos[char_a] = b
		char_to_pos[char_b] = a
	end

	local loop = 1
	local loops = count or 1

	---@type table<string, number>
	local state_to_step = {}
	---@type table<number, string>
	local step_to_state = {}

	while loop <= loops do
		for _, move in ipairs(moves) do
			if move.type == "s" then
				offset = mod(offset - move.size, len)
			end

			if move.type == "x" then
				local a, b = mod(move.a + offset, len), mod(move.b + offset, len)
				swap(a, b)
			end

			if move.type == "p" then
				local a, b = char_to_pos[move.a], char_to_pos[move.b]
				swap(a, b)
			end
		end

		local output = get_output(pos_to_char, offset, len)
		local cache = state_to_step[output]

		if cache ~= nil and cache ~= loop then
			local loop_size = loop - cache
			return step_to_state[loops % loop_size]
		end

		state_to_step[output] = loop
		step_to_state[loop] = output
		loop = loop + 1
	end

	-- found no loop, just return the last computed value
	return step_to_state[loop - 1]
end

local input = get_input()
local moves = parse_moves(input)

local part_one = dance("abcdefghijklmnop", moves)
print(part_one)

local part_two = dance("abcdefghijklmnop", moves, 1000000000)
print(part_two)
