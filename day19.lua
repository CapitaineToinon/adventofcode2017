---@enum dir
local directions = {
	up = "up",
	down = "down",
	left = "left",
	right = "right",
}

---@type table<dir, { dx: number, dy: number }>
local deltas = {
	[directions.up] = { dx = 0, dy = -1 },
	[directions.down] = { dx = 0, dy = 1 },
	[directions.left] = { dx = -1, dy = 0 },
	[directions.right] = { dx = 1, dy = 0 },
}

---@type table<dir, dir[]>
local turn_directions = {
	[directions.up] = { directions.left, directions.right },
	[directions.down] = { directions.left, directions.right },
	[directions.left] = { directions.up, directions.down },
	[directions.right] = { directions.up, directions.down },
}

---@return string[]
local function get_map()
	---@type string[]
	local lines = {}

	for line in io.lines("./input/day19", "l") do
		table.insert(lines, line)
	end

	return lines
end

---@param map string[]
---@param x number
---@param y number
---@return string|nil
local function get_c(map, x, y)
	local line = map[y]

	if line == nil then
		return nil
	end

	local c = line:sub(x, x)

	if c == " " then
		return nil
	end

	return c
end

---@param map string[]
local function walk(map)
	local x = assert(map[1]:find("|"), "failed to find start of the map")
	local y = 1
	local output = ""
	local steps = 0

	---@type dir
	local dir = directions.down

	while true do
		local c = get_c(map, x, y)

		if c == nil then
			break
		end

		if c ~= "+" and c ~= "|" and c ~= "-" then
			output = output .. c
		end

		if c == "+" then
			for _, next_d in ipairs(turn_directions[dir]) do
				local next_x = x + deltas[next_d].dx
				local next_y = y + deltas[next_d].dy
				local next_c = get_c(map, next_x, next_y)

				if next_c ~= nil then
					dir = next_d
					break
				end
			end
		end

		x = x + deltas[dir].dx
		y = y + deltas[dir].dy
		steps = steps + 1
	end

	return output, steps
end

local map = get_map()
local letters, steps = walk(map)

print(letters)
print(steps)
