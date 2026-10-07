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
---@return number
local function find_best(edges)
	---@param node component
	---@param right number
	---@param score number
	---@param length number
	---@param visited number
	---@param best_score number
	---@param best_length number
	---@param best_length_score number
	---@return number
	---@return number
	---@return number
	local function recurse(node, right, score, length, visited, best_score, best_length, best_length_score)
		local stuck = true

		for _, n in ipairs(edges[node.key]) do
			local can_visit = (visited >> n.id) & 1 == 1

			if not can_visit and (n.left == right or n.right == right) then
				stuck = false

				best_score, best_length, best_length_score = recurse(
					n,
					n.right == right and n.left or n.right,
					score + n.weight,
					length + 1,
					visited | (1 << n.id),
					best_score,
					best_length,
					best_length_score
				)
			end
		end

		if stuck then
			if score > best_score then
				best_score = score
			end

			if score > best_length_score or length > best_length then
				best_length = length
				best_length_score = score
			end
		end

		return best_score, best_length, best_length_score
	end

	return recurse(root, root.right, 0, root.id, 0, 0, 0, 0)
end

local components = get_components()
local edges = build_graph(components)
local part_one, _, part_two = find_best(edges)

print(part_one)
print(part_two)
