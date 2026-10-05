---@param grid string
---@return string
local function strip(grid)
	local stripped, _ = grid:gsub("/", "")
	return stripped
end

---@param size number
---@return string
local function create_grid(size)
	local output = ""

	for i = 1, (size * size) do
		output = output .. i
	end

	return output
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

local function get_size(grid)
	if #grid == 4 then
		return 2
	elseif #grid == 9 then
		return 3
	elseif #grid == 16 then
		return 4
	else
		error("invalid grid size of " .. #grid)
	end
end

---@param grid string
local function p(grid)
	local size = get_size(grid)

	for y = 0, size - 1 do
		print(grid:sub(size * y + 1, size * y + size))
	end
end

---@param grid string
---@return string[]
local function split(grid)
	local size = get_size(grid)

	assert(size == 4, "Can only split grids of 4 by 4")

	local quadrants = {}

	for j = 0, 1 do
		for i = 0, 1 do
			local quad = ""
			local from = (size * (size // 2) * j) + i * (size // 2) + 1

			for k = 0, 1 do
				local line = grid:sub((size * k) + from, (size * k) + from + (size // 2) - 1)
				quad = quad .. line
			end

			table.insert(quadrants, quad)
		end
	end

	return quadrants
end

---Joins quadrants, assuming order is top-left, top-right, bottom-left, bottom-right
---@param quad string[]
---@return string
local function join(quad)
	assert(#quad == 4, "there must be 4 quadrants")

	local output = ""

	-- assume quadrants are all the same size
	local size = get_size(quad[1])

	for j = 0, size * 2 - 1 do
		for col = 0, 1 do
			local k = ((j // size) * size) + col + 1
			local y = j % size
			output = output .. quad[k]:sub((size * y) + 1, (size * y) + size)
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
	local a = grid
	local b = ""

	for _ = 0, t - 1 do
		for i = 0, size - 1 do
			for j = 0, size - 1 do
				local at = size * (size - 1 - j) + i + 1
				print(a, b, at)
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
	local output = grid

	if axis == "vertical" then
		output = rotate(output, size, 1)
	end

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
		local size = get_size(grid)

		for _, axis in ipairs({ false, "vertical", "horizontal" }) do
			for i = 0, 3 do
				local key = grid

				if axis ~= false then
					key = flip(key, size, axis)
				end

				if i ~= 0 then
					key = rotate(key, size, i)
				end

				expanded[key] = next
			end
		end
	end

	return expanded
end

local function process(grid, rules, steps)
	local output = grid

	for _ = 1, steps do
		local next = rules[output]

		if next == nil then
			local quad = split(grid)

			for i, q in ipairs(quad) do
				quad[i] = rules[q]
			end

			next = rules[join(quad)]
		end

		output = next
	end

	return output
end

-- local rules = get_rules()
-- local all_rules = expand_rules(rules)
-- local processed = process(".#...####", all_rules, 2)

local grid = create_grid(4)

p(grid)

local quad = split(grid)

for _, q in ipairs(quad) do
	p(q)
end
