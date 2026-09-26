---@return number[]
local function get_input()
	local f = assert(io.open("./input/day06", "r"), "failed to open input")
	local content = f:read("l")
	f:close()

	local banks = {}

	for word in content:gmatch("%S+") do
		table.insert(banks, tonumber(word))
	end

	return banks
end

---@param banks number[]
---@return string
local function hash(banks)
	return table.concat(banks, "-")
end

---@param banks number[]
---@return number, number
local function find_largest(banks)
	local i = 1
	local max = banks[i]

	for j = 2, #banks do
		if banks[j] > max then
			max = banks[j]
			i = j
		end
	end

	return i, max
end

---@param banks number[]
local function redistribute(banks)
	local i, bank = find_largest(banks)
	local j = i + 1

	banks[i] = 0

	while bank > 0 do
		local jj = ((j - 1) % #banks) + 1
		banks[jj] = banks[jj] + 1
		bank = bank - 1
		j = j + 1
	end
end

---@param banks number[]
---@return number, number
local function solve(banks)
	---@type {[string]?: number}
	local seen = {}
	local step = 0

	while true do
		local key = hash(banks)

		if seen[key] ~= nil then
			local size = step - seen[key]
			return step, size
		end

		seen[key] = step
		redistribute(banks)
		step = step + 1
	end
end

local banks = get_input()
local part_one, part_two = solve(banks)

print(part_one)
print(part_two)
