local kh = require("knot_hash")
local utils = require("utils")

---@param input string
---@return number[]
local function parse_input(input)
	---@type number[]
	local numbers = {}

	for word in utils.split_commas(input) do
		local value = utils.tonumber(word)
		table.insert(numbers, value)
	end

	return numbers
end

---@param list number[]
---@return string
local function to_hex(list)
	local hex = ""

	for _, value in ipairs(list) do
		hex = hex .. string.format("%02x", value)
	end

	return hex
end

---@param input string
---@return number
local function part_one(input)
	local data = kh.create_data()
	local lengths = parse_input(input)
	local result, _ = kh.round(data, lengths)
	return result[1] * result[2]
end

---@param input string
---@return string
local function part_two(input)
	return to_hex(kh.hash(input))
end

local input = utils.readline("./input/day10")

print(part_one(input))
print(part_two(input))
