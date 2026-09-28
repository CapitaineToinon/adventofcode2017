local utils = require("utils")

local MERSENNE = 0x7FFFFFFF
local MASK = 0xFFFF

---@alias generator { seed: number, factor: number, multiple: number }

---@param line string
---@param generator string
---@return number
local function get_seed(line, generator)
	local match = assert(line:match("Generator " .. generator .. " starts with (%d+)"), "invalid line")
	return utils.tonumber(match)
end

---@return number, number
local function get_input()
	local f = assert(io.open("./input/day15", "r"), "failed to open input")
	local a = get_seed(f:read("l"), "A")
	local b = get_seed(f:read("l"), "B")
	f:close()
	return a, b
end

---@param generator generator
---@param initial_state number
---@param use_multiple? boolean
---@return number
local function next(generator, initial_state, use_multiple)
	local state = initial_state

	while true do
		state = (state * generator.factor) % MERSENNE

		if not use_multiple then
			return state
		end

		if state % generator.multiple == 0 then
			return state
		end
	end
end

---@param a generator
---@param b generator
---@param options { loops: number, use_multiple?: boolean }
---@return number
local function solve(a, b, options)
	local count = 0
	local state_a = a.seed
	local state_b = b.seed

	for _ = 1, options.loops do
		state_a = next(a, state_a, options.use_multiple)
		state_b = next(b, state_b, options.use_multiple)

		if state_a & MASK == state_b & MASK then
			count = count + 1
		end
	end

	return count
end

local seed_a, seed_b = get_input()

---@type generator
local a = { seed = seed_a, factor = 16807, multiple = 4 }

---@type generator
local b = { seed = seed_b, factor = 48271, multiple = 8 }

local part_one = solve(a, b, { loops = 40000000 })
print(part_one)

local part_two = solve(a, b, { loops = 5000000, use_multiple = true })
print(part_two)
