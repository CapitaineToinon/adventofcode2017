local N = 256

---@return string
local function get_input()
	local f = assert(io.open("./input/day10", "r"), "failed to open input")
	local content = tostring(f:read("l"))
	f:close()
	local trimmed, _ = content:gsub(" ", "")
	return trimmed
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

---@param n number
---@return number[]
local function create_list(n)
	---@type number[]
	local list = {}

	for i = 0, n - 1 do
		table.insert(list, i)
	end

	return list
end

---@param input string
---@return number[]
local function to_ascii(input)
	---@type number[]
	local ascii = { input:byte(1, -1) }

	for _, value in ipairs({ 17, 31, 73, 47, 23 }) do
		table.insert(ascii, value)
	end

	return ascii
end

---@param list number[]
---@return number[]
local function clone(list)
	return { table.unpack(list) }
end

---@param n number
---@param m number
local function mod(n, m)
	return ((n - 1) % m) + 1
end

---@param input number[]
---@param source number[]
---@param position number
---@param skip number
---@return number[], number, number
local function knot_hash(input, source, position, skip)
	local list = clone(source)
	local p = position
	local s = skip

	for _, len in ipairs(input) do
		local dest = clone(list)

		for i = 0, len - 1 do
			local from = mod(p + len - i - 1, N)
			local to = mod(p + i, N)
			dest[to] = list[from]
		end

		list = dest
		p = p + len + s
		s = s + 1
	end

	return list, p, s
end

---@param input string
---@return number
local function part_one(input)
	local numbers = parse_input(input)
	local list, _, _ = knot_hash(numbers, create_list(N), 1, 0)
	return list[1] * list[2]
end

---@param hash number[]
---@return number[]
local function densify(hash)
	---@type number[]
	local dense = {}

	for i = 0, 15 do
		local from = (16 * i) + 1
		local to = (from + 16 - 1)

		table.insert(dense, 0)

		for j = from, to do
			dense[#dense] = dense[#dense] ~ hash[j]
		end
	end

	return dense
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
---@param rounds number
local function part_two(input, rounds)
	local ascii = to_ascii(input)
	local list = create_list(N)
	local skip = 0
	local position = 1

	for _ = 1, rounds do
		list, position, skip = knot_hash(ascii, list, position, skip)
	end

	return to_hex(densify(list))
end

local input = get_input()

print(input)
print(part_one(input))
print(part_two(input, 64))
