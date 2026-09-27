local kh = require("knot_hash")

---@return string
local function get_input()
	local f = assert(io.open("./input/day10", "r"), "failed to open input")
	local content = tostring(f:read("l"))
	f:close()
	return content
end

---@param input string
---@return number[]
local function parse_input(input)
	---@type number[]
	local numbers = {}

	for word in input:gmatch("([^,]+)") do
		local value = assert(tonumber(word), "failed to parse int")
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

local input = get_input()

print(part_one(input))
print(part_two(input))
