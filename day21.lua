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

---@param number number
---@return integer
local function get_root(number)
	return math.floor(math.sqrt(number))
end

---@param size number
---@return number
local function get_split_size(size)
	if size % 2 == 0 then
		return 2
	end

	if size % 3 == 0 then
		return 3
	end

	error("impossible to divide grid in sub grids")
end

---@param grid string
---@return string[]
local function split(grid)
	local size = get_root(#grid)
	local chunk_size = get_split_size(size)
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
local function expand_rules_with_transformations(rules)
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

---@return table<string, string>
local function get_rules()
	---@type table<string, string>
	local rules = {}

	for line in io.lines("./input/day21", "l") do
		local i, j = string.find(line, " => ")
		local key = string.sub(line, 1, i - 1)
		local value = string.sub(line, j + 1, string.len(line))
		rules[strip(key)] = strip(value)
	end

	return expand_rules_with_transformations(rules)
end

---@param rules table<string, string>
---@return table<string, string[]>
local function create_graph(rules)
	---@type table<string, string[]>
	local edges = {}

	for from, to in pairs(rules) do
		if rules[to] == nil then
			-- we need to split and replace the next
			-- pattern to create the graph for rules
			local chunks = split(to)

			for i, c in ipairs(split(to)) do
				chunks[i] = rules[c] or error("failed to replace chunk")
			end

			local next = join(chunks)
			-- this counts as two itterations so update both
			-- next and next's next
			edges[from] = { next }
			edges[next] = {}

			for _, n in ipairs(split(next)) do
				table.insert(edges[next], n)
			end
		else
			-- There is a one to one replacement rule
			edges[from] = { to }
		end
	end

	return edges
end

---@param grid string
---@param edges table<string, string[]>
---@param steps number
---@return number
local function process(grid, edges, steps)
	---@type table<string, number>
	local counts = { [grid] = 1 }

	for _ = 1, steps do
		local next = {}

		for node, freq in pairs(counts) do
			for _, n in ipairs(edges[node]) do
				next[n] = (next[n] or 0) + freq
			end
		end

		counts = next
	end

	local total = 0

	for node, freq in pairs(counts) do
		total = total + count_on(node) * freq
	end

	return total
end

local rules = get_rules()
local edges = create_graph(rules)

print(process(STARTING_GRID, edges, 5))
print(process(STARTING_GRID, edges, 18))
