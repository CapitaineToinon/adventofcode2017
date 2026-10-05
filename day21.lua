local STARTING_GRID = ".#...####"

---@param grid string
---@return string
local function strip(grid)
	local stripped, _ = grid:gsub("/", "")
	return stripped
end

---@param grid string
---@return number
local function count_on(grid)
	local _, count = grid:gsub("#", "")
	return count
end

local function get_rules()
	---@type table<string, string>
	local rules = {}

	for line in io.lines("./input/day21", "l") do
		local i, j = string.find(line, " => ")
		local key = string.sub(line, 1, i - 1)
		local value = string.sub(line, j + 1, string.len(line))
		rules[strip(key)] = strip(value)
	end

	return rules
end

---@param number number
---@return integer
local function get_root(number)
	local root = math.floor(math.sqrt(number))
	assert(root * root == number, "number does not have a whole root: " .. number)
	assert(root > 1, "should not be possible to have a root of " .. root .. " caused by number " .. number)
	return root
end

local function get_split_size(size)
	assert(size >= 4, "should not be able to split a grid of size " .. size)

	if size % 2 == 0 then
		return 2
	end

	if size % 3 == 0 then
		return 3
	end

	error("impossible to divide grid in sub grids")
end

---@param grid string
local function p(grid)
	local size = get_root(#grid)

	for y = 0, size - 1 do
		print(grid:sub(size * y + 1, size * y + size))
	end
end

---@param grid string
---@return string[]
local function split(grid)
	local size = get_root(#grid)
	local chunk_size = get_split_size(size)

	print("trying to divide in chunks of size " .. chunk_size)

	local chunks = {}

	for j = 0, (size // chunk_size) - 1 do
		for i = 0, (size // chunk_size) - 1 do
			local chunk = ""
			local from = (size * chunk_size * j) + i * chunk_size + 1

			for k = 0, chunk_size - 1 do
				local line = grid:sub(from + (size * k), from + (size * k) + chunk_size - 1)
				chunk = chunk .. line
			end

			table.insert(chunks, chunk)
		end
	end

	assert(#chunks > 0, "created empty chunks, not possible")

	return chunks
end

---@param chunks string[]
---@return string
local function join(chunks)
	local output = ""
	local size = get_root(#chunks)

	-- assume chunks are all the same size
	local chunk_size = get_root(#chunks[1])

	for row = 0, size - 1 do
		for y = 0, chunk_size - 1 do
			for col = 0, size - 1 do
				local k = 1 + (row * size) + col
				output = output .. chunks[k]:sub((chunk_size * y) + 1, (chunk_size * y) + chunk_size)
			end
		end
	end

	return output
end

---@param grid string
---@param size number
---@param times number
---@return string
local function rotate(grid, size, times)
	local t = times % 4

	if t == 0 then
		return grid
	end

	local a = grid
	local b = ""

	for _ = 0, t - 1 do
		for i = 0, size - 1 do
			for j = 0, size - 1 do
				local at = size * (size - 1 - j) + i + 1
				b = b .. a:sub(at, at)
			end
		end

		a = b
		b = ""
	end

	return a
end

---@param grid string
---@param size number
---@param axis "horizontal" | "vertical"
---@return string
local function flip(grid, size, axis)
	if axis == "vertical" then
		grid = rotate(grid, size, 1)
	end

	local output = ""

	for j = 0, size - 1 do
		local at = size * (size - 1 - j) + 1
		output = output .. grid:sub(at, at + size - 1)
	end

	if axis == "vertical" then
		output = rotate(output, size, -1)
	end

	return output
end

---@param rules table<string, string>
---@return table<string, string>
local function expand_rules(rules)
	---@type table<string, string>
	local expanded = {}

	for grid, next in pairs(rules) do
		local size = get_root(#grid)

		for _, axis in ipairs({ false, "vertical", "horizontal" }) do
			for i = 0, 3 do
				local key = grid

				if axis ~= false then
					key = flip(key, size, axis)
				end

				if i ~= 0 then
					key = rotate(key, size, i)
				end

				if expanded[key] == nil then
					expanded[key] = next
				end
			end
		end
	end

	return expanded
end

---@type table<string, number>
local cache = {}

local function r(grid, rules, steps)
	if steps == 0 then
		return count_on(grid)
	end

	if rules[grid] ~= nil then
		return r(rules[grid], rules, steps - 1)
	end

	local total = 0
	local chunks = split(grid)

	for _, c in ipairs(chunks) do
		total = total + r(rules[c], rules, steps - 1)
	end

	return total
end

local function process(grid, rules, steps)
	local output = grid

	for step = 1, steps do
		print(step)
		local next = rules[output]

		if next == nil then
			local chunk = split(output)

			for i, q in ipairs(chunk) do
				chunk[i] = rules[q]

				if chunk[i] == nil then
					error("failed to replace pattern, no match for " .. q)
				end
			end

			next = join(chunk)
		end

		output = next
	end

	return output
end

local rules = get_rules()
local all_rules = expand_rules(rules)
print(r(STARTING_GRID, all_rules, 5))
-- local processed = process(STARTING_GRID, all_rules, 18)
--
-- p(processed)
-- print(count_on(processed))
