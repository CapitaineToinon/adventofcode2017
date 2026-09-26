---@alias Properties { weight: number, children: string[] }
---@alias Network { [string]: Properties }

---@param input string
---@return string[]
local function split(input)
	local chunks = {}

	for s in input:gmatch("%S+") do
		table.insert(chunks, s)
	end

	return chunks
end

---@param line string
---@return string, Properties
local function parse_node(line)
	local words = split(line)
	local name = words[1]
	local weight = assert(tonumber(words[2]:sub(2, #words[2] - 1)), "impossible to parse number")

	---@type Properties
	local properties = {
		weight = weight,
		children = {},
	}

	for i = 4, #words do
		local fixed, _ = string.gsub(words[i], ",", "")
		table.insert(properties.children, fixed)
	end

	return name, properties
end

---@return Network[], number
local function get_network()
	---@type Network
	local network = {}
	local size = 0

	for line in io.lines("./input/day07", "l") do
		local name, properties = parse_node(line)
		network[name] = properties
		size = size + 1
	end

	return network, size
end

---@param name string
---@param network Network
---@return number
local function get_depth(name, network)
	local depth = 1

	for _, n in ipairs(network[name].children) do
		depth = depth + get_depth(n, network)
	end

	return depth
end

---@param name string
---@param network Network
---@return number
local function get_weight(name, network)
	---@type number
	local weight = network[name].weight

	for _, n in ipairs(network[name].children) do
		weight = weight + get_weight(n, network)
	end

	return weight
end

---Find the first item in the array that is different
---than every other items in the list
---@param list number[]
---@return number|nil
local function ifind_different(list)
	for i, a in ipairs(list) do
		local has_duplicate = false

		for j, b in ipairs(list) do
			if i ~= j and a == b then
				has_duplicate = true
				break
			end
		end

		if not has_duplicate then
			return i
		end
	end

	return nil
end

---@param network Network
---@param size number
---@param root string
---@param target number|nil
---@return number
local function find_unbalanced(network, size, root, target)
	local me = network[root]

	---@type number[]
	local weights = {}
	local total = 0

	-- gather my children's weights
	for _, n in ipairs(me.children) do
		local w = get_weight(n, network)
		total = total + w
		table.insert(weights, w)
	end

	local different_i = ifind_different(weights)

	-- if one of my children's weight is different from
	-- my other childrens, try to fix it
	if different_i ~= nil then
		local next_target = weights[(((different_i + 1) - 1) % #weights) + 1]
		return find_unbalanced(network, size, me.children[different_i], next_target)
	end

	-- otherwise maybe I'm the problem
	if target ~= nil then
		local effective = me.weight + total
		local min, max = math.min(target, effective), math.max(target, effective)
		local diff = max - min

		if effective > target then
			return me.weight - diff
		end

		return me.weight + diff
	end

	error("failed to find a node to fix")
end

---@param network Network
---@param size number
---@return string
local function find_root(network, size)
	for name, _ in pairs(network) do
		if get_depth(name, network) == size then
			return name
		end
	end

	error("failed to find a root")
end

local network, size = get_network()
local root = find_root(network, size)
local unbalanced = find_unbalanced(network, size, root, nil)

print(root)
print(unbalanced)
