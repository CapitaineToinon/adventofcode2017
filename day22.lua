local utils = require("utils")

---@enum cellstate
local cellstate = {
	clean = 0,
	weakened = 1,
	infected = 2,
	flagged = 3,
}

---@param x number
---@param y number
---@return number
local function encode(x, y)
	return (x << 32) + y
end

---@param dx number
---@param dy number
---@return number
---@return number
local function turn_left(dx, dy)
	local tmp = dx
	dx = dy
	dy = -tmp
	return dx, dy
end

---@param dx number
---@param dy number
---@return number
---@return number
local function turn_right(dx, dy)
	local tmp = dx
	dx = -dy
	dy = tmp
	return dx, dy
end

---@param dx number
---@param dy number
---@return number
---@return number
local function turn_back(dx, dy)
	return -dx, -dy
end

---@return table<number, cellstate>
local function open_input()
	local lines = utils.readlines("./input/day22")
	local height = #lines
	local width = #lines[1]

	local y = 0

	---@type table<number, cellstate>
	local grid = {}

	for _, line in ipairs(lines) do
		for x = 0, #line - 1 do
			local infected = string.sub(line, x + 1, x + 1) == "#"
			grid[encode(x - (width // 2), y - (height // 2))] = infected and cellstate.infected or cellstate.clean
		end
		y = y + 1
	end

	return grid
end

---@param grid table<number, cellstate>
---@param steps number
local function part_one(grid, steps)
	local x = 0
	local y = 0
	local dx = 0
	local dy = -1
	local infections = 0

	for _ = 1, steps do
		local p = encode(x, y)

		if grid[p] == cellstate.infected then
			grid[p] = cellstate.clean
			dx, dy = turn_right(dx, dy)
		else
			grid[p] = cellstate.infected
			infections = infections + 1
			dx, dy = turn_left(dx, dy)
		end

		x = x + dx
		y = y + dy
	end

	return infections
end

---@param grid table<number, cellstate>
---@param steps number
local function part_two(grid, steps)
	local x = 0
	local y = 0
	local dx = 0
	local dy = -1
	local infections = 0

	for _ = 1, steps do
		local p = encode(x, y)

		if grid[p] == cellstate.weakened then
			infections = infections + 1
			grid[p] = cellstate.infected
		elseif grid[p] == cellstate.infected then
			dx, dy = turn_right(dx, dy)
			grid[p] = cellstate.flagged
		elseif grid[p] == cellstate.flagged then
			dx, dy = turn_back(dx, dy)
			grid[p] = cellstate.clean
		else -- clean
			dx, dy = turn_left(dx, dy)
			grid[p] = cellstate.weakened
		end

		x = x + dx
		y = y + dy
	end

	return infections
end

print(part_one(open_input(), 10000))
print(part_two(open_input(), 10000000))
