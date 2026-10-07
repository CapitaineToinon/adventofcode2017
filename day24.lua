local utils = require("utils")

---@class component
---@field id number
---@field key string
---@field left number
---@field right number
---@field weight number

---@type component
local root = {
	id = 1,
	key = "0/0",
	left = 0,
	right = 0,
	weight = 0,
}

---@param id number
---@param input string
---@return component
local function parse_component(id, input)
	---@type number[]
	local words = {}

	for word in utils.split(input, "/") do
		table.insert(words, utils.tonumber(word))
	end

	assert(#words == 2, "invalid component")

	---@type component
	return {
		id = id,
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
		table.insert(components, parse_component(#components + 1, line))
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
---@return number
local function find_best(edges)
	---@class item
	---@field node component
	---@field score number
	---@field visited number
	---@field right number
	---@field length number

	---@type item
	local start = {
		node = root,
		score = 0,
		visited = root.id,
		right = root.right,
		length = 0,
	}

	---@type item[]
	local queue = { start }

	---@type item|nil
	local best = nil

	---@type item|nil
	local best_longest = nil

	while true do
		local cur = table.remove(queue)

		if cur == nil then
			break
		end

		local stuck = true

		for _, n in ipairs(edges[cur.node.key]) do
			local visited = (cur.visited >> n.id) & 1 == 1

			if not visited and (n.left == cur.right or n.right == cur.right) then
				local right = n.right

				if right == cur.right then
					right = n.left
				end

				local next = {
					node = n,
					score = cur.score + n.weight,
					visited = cur.visited | (1 << n.id),
					right = right,
					length = cur.length + 1,
				}

				table.insert(queue, next)
				stuck = false
			end
		end

		if stuck then
			if best == nil or cur.score > best.score then
				best = cur
			end

			if best_longest == nil or cur.score > best_longest.score or cur.length > best_longest.length then
				best_longest = cur
			end
		end
	end

	return best.score, best_longest.score
end

local components = get_components()
local edges = build_graph(components)

print(find_best(edges))
