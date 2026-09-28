--- Should out to this fucking amazing article
--- https://www.redblobgames.com/grids/hexagons/

local utils = require("utils")

---@alias direction "n" | "ne" | "nw" | "s" | "se" | "sw"

---@return direction[]
local function get_input()
	local content = utils.readline("./input/day11")

	---@type direction[]
	local dirs = {}

	for d in utils.split_commas(content) do
		table.insert(dirs, d)
	end

	return dirs
end

---@param q number
---@param r number
---@param s number
---@return number
local function distance(q, r, s)
	return (math.abs(q) + math.abs(r) + math.abs(s)) // 2
end

---@param directions direction[]
---@return number, number
local function walk(directions)
	local q = 0
	local r = 0
	local s = 0
	local max = 0

	for _, d in ipairs(directions) do
		if d == "n" then
			q = q
			s = s + 1
			r = r - 1
		end

		if d == "s" then
			q = q
			s = s - 1
			r = r + 1
		end

		if d == "ne" then
			q = q + 1
			s = s
			r = r - 1
		end

		if d == "sw" then
			q = q - 1
			s = s
			r = r + 1
		end

		if d == "nw" then
			q = q - 1
			s = s + 1
			r = r
		end

		if d == "se" then
			q = q + 1
			s = s - 1
			r = r
		end

		max = math.max(max, distance(q, r, s))
	end

	local dist = distance(q, r, s)

	return dist, max
end

local directions = get_input()
local part_one, part_two = walk(directions)

print(part_one)
print(part_two)
