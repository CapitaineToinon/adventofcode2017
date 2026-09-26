---Parse a line of numbers
---@param line string
---@return number[]
local function split_line(line)
	local numbers = {}

	for w in line:gmatch("%S+") do
		table.insert(numbers, tonumber(w))
	end

	table.sort(numbers)

	return numbers
end

---@return number[][]
local function get_input()
	local rows = {}

	for line in io.lines("./input/day02", "l") do
		table.insert(rows, split_line(line))
	end

	return rows
end

---@param rows number[][]
---@return number
local function part_one(rows)
	local total = 0

	for _, row in ipairs(rows) do
		total = total + (row[#row] - row[1])
	end

	return total
end

---@param rows number[][]
---@return number
local function part_two(rows)
	local total = 0

	for _, row in ipairs(rows) do
		for i = 1, #row do
			for j = i + 1, #row do
				if row[j] % row[i] == 0 then
					total = total + (row[j] // row[i])
					goto continue
				end
			end
		end

		error("failed to find numbers that evenly divide")

		::continue::
	end

	return total
end

local input = get_input()

print(part_one(input))
print(part_two(input))
