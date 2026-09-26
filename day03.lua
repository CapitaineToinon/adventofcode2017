---@alias Coord { x: number, y: number }
---@alias Direction "up" | "right" | "left" | "down"
---@alias Delta { dx: number, dy: number }

---@type { [Direction]: Delta }
local detlas = {
	["up"] = { dx = 0, dy = -1 },
	["left"] = { dx = -1, dy = 0 },
	["down"] = { dx = 0, dy = 1 },
	["right"] = { dx = 1, dy = 0 },
}

---@type { [Direction]?: Direction }
local next_dir = {
	["up"] = "left",
	["left"] = "down",
	["down"] = "right",
	["right"] = nil,
}

---@param coordinates Coord
local function distance(coordinates)
	return math.abs(coordinates.x) + math.abs(coordinates.y)
end

---@param position number
---@return Coord
local function position_to_coordinate(position)
	if position == 1 then
		return { x = 0, y = 0 }
	end

	-- find which kth square we're on the edge of
	local k = math.ceil((math.sqrt(position) - 1) / 2)
	-- steps we already walked as part k-1 square
	local done = (2 * k - 1) * (2 * k - 1)
	-- remaining steps we need to walk
	local steps = position - done
	-- how many steps we can take before changing direction
	local side = 2 * k
	-- starting coordinate
	local coord = { x = k, y = k }

	for _, dir in ipairs({ "up", "left", "down", "right" }) do
		local d = detlas[dir]
		local by = math.min(steps, side)

		coord.x = coord.x + by * d.dx
		coord.y = coord.y + by * d.dy
		steps = steps - by

		if steps == 0 then
			break
		end
	end

	assert(steps == 0, "Failed to walk all the steps")

	return coord
end

---@param a Coord
---@param b Coord
---@return boolean
local function are_same(a, b)
	return a.x == b.x and a.y == b.y
end

---@param coordinate Coord
---@return Coord[]
local function get_neighbors(coordinate)
	local neighbors = {}
	for _, dx in ipairs({ -1, 0, 1 }) do
		for _, dy in ipairs({ -1, 0, 1 }) do
			if dx ~= 0 or dy ~= 0 then
				table.insert(neighbors, { x = coordinate.x + dx, y = coordinate.y + dy })
			end
		end
	end

	return neighbors
end

---@param coordinate Coord
---@return number
local function coordinate_to_position(coordinate)
	if are_same({ x = 0, y = 0 }, coordinate) then
		return 1
	end

	-- find the kth square this coordinate is a part of
	local k = math.max(math.abs(coordinate.x), math.abs(coordinate.y))
	-- minimum position
	local position = (2 * k - 1) * (2 * k - 1)
	-- remaining steps we need to walk
	local steps = 0
	-- how many steps we can take before changing direction
	local side = 2 * k
	-- starting coordinate
	local coord = { x = k, y = k }

	---@type Direction
	local dir = "up"

	while true do
		local d = detlas[dir]

		coord.x = coord.x + d.dx
		coord.y = coord.y + d.dy
		steps = steps + 1

		if steps % side == 0 then
			dir = next_dir[dir]
		end

		if are_same(coord, coordinate) then
			break
		end
	end

	return position + steps
end

---@type { [number]?: number }
local cache = {}

---@param position number
---@return number
local function compute_position(position)
	if position == 1 then
		return 1
	end

	if cache[position] == nil then
		local total = 0
		local coordinate = position_to_coordinate(position)

		for _, n in ipairs(get_neighbors(coordinate)) do
			local n_position = coordinate_to_position(n)

			if n_position < position then
				total = total + compute_position(n_position)
			end
		end

		cache[position] = total
	end

	return cache[position]
end

---@param position number
local function part_one(position)
	return distance(position_to_coordinate(position))
end

---@param position number
local function part_two(position)
	local i = 1

	while true do
		local value = compute_position(i)

		if value > position then
			return value
		end

		i = i + 1
	end
end

local f = assert(io.open("./input/day03", "r"), "failed to open input")
local input = assert(tonumber(f:read()), "input must be a number")
f:close()

print(part_one(input))
print(part_two(input))
