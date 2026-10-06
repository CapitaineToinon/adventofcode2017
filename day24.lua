local utils = require("utils")

---@class component
---@field key string
---@field left number
---@field right number
---@field weight number

---@type component
local root = {
	key = "0/0",
	left = 0,
	right = 0,
	weight = 0,
}

---@param input string
---@return component
local function parse_component(input)
	---@type number[]
	local words = {}

	for word in utils.split(input, "/") do
		table.insert(words, utils.tonumber(word))
	end

	assert(#words == 2, "invalid component")

	---@type component
	return {
		key = input,
		left = words[1],
		right = words[2],
		weight = words[1] + words[2],
	}
end

---@return component[]
local function get_components()
	---@type component[]
	local components = { root }

	for line in io.lines("./input/day24", "l") do
		table.insert(components, parse_component(line))
	end

	return components
end

---@param components component[]
---@return table<string, component[]>
local function build_graph(components)
	---@type table<string, component[]>
	local edges = {}

	for i = 1, #components do
		for j = i + 1, #components do
			local a, b = components[i], components[j]

			if a.left == b.left or a.left == b.right or a.right == b.left or a.right == b.right then
				if edges[a.key] == nil then
					edges[a.key] = {}
				end

				if edges[b.key] == nil then
					edges[b.key] = {}
				end

				table.insert(edges[a.key], b)
				table.insert(edges[b.key], a)
			end
		end
	end

	return edges
end

---@param edges table<string, component[]>
---@return number
local function find_best(edges)
	---@type { node: component, score: number, visited: table<string, boolean> }[]
	local queue = { { node = root, score = 0, visited = {} } }

	while true do
		local cur = table.remove(queue, 1)

		if cur == nil then
			break
		end

		for _, n in ipairs(edges[cur.node.key]) do
			if not cur.visisted[n.key] then
			end
		end
	end
end

local components = get_components()
local edges = build_graph(components)

print(find_best(edges))
