---@param line string
---@return number[]
local function get_nodes(line)
	---@type number[]
	local numbers = {}

	for word in string.gmatch(line, "%d+") do
		local number = assert(tonumber(word), "failed to parse int")
		table.insert(numbers, number)
	end

	return numbers
end

---@generic T
---@param list T[]
---@param e T
---@return boolean
local function in_list(list, e)
	for _, value in ipairs(list) do
		if value == e then
			return true
		end
	end

	return false
end

---@param edges table<number, number[]|nil>
---@param a number
---@param b number
local function add_edge(edges, a, b)
	if edges[a] == nil then
		edges[a] = {}
	end

	if edges[b] == nil then
		edges[b] = {}
	end

	table.insert(edges[a], b)
	table.insert(edges[b], a)
end

local function parse_input()
	---@type table<number, number[]>
	local edges = {}

	---@type number[]
	local nodes = {}

	for line in io.lines("./input/day12", "l") do
		local list = get_nodes(line)

		if not in_list(nodes, list[1]) then
			table.insert(nodes, list[1])
		end

		for i = 2, #list do
			add_edge(edges, list[1], list[i])
		end
	end

	return nodes, edges
end

---@param nodes number[]
---@param edges table<number, number[]>
---@return number, number
local function get_groups(nodes, edges)
	---@type number[]
	local candidates = { table.unpack(nodes) }
	---@type table<number, number>
	local node_to_group = {}
	---@type table<number, number>
	local sizes = {}
	local count = 0

	while true do
		local candidate = table.remove(candidates)

		if candidate == nil then
			break
		end

		if node_to_group[candidate] == nil then
			---@type number[]
			local queue = { candidate }
			local gid = 1 + count

			while #queue ~= 0 do
				local head = table.remove(queue)

				if node_to_group[head] == nil then
					node_to_group[head] = gid
					sizes[gid] = (sizes[gid] or 0) + 1

					for _, neighbor in ipairs(edges[head]) do
						table.insert(queue, neighbor)
					end
				end
			end

			count = count + 1
		end
	end

	local root_gid = assert(node_to_group[0], "root is not in a group")
	local root_size = assert(sizes[root_gid], "group has no size")

	return root_size, count
end

local nodes, edges = parse_input()
local part_one, part_two = get_groups(nodes, edges)

print(part_one)
print(part_two)
