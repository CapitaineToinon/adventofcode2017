local utils = require("utils")

---@class vector3
---@field x number
---@field y number
---@field z number

---@class particule
---@field p vector3
---@field v vector3
---@field a vector3

---@return particule[]
local function parse_particules()
	---@type particule[]
	local particules = {}
	for line in io.lines("./input/day20", "l") do
		---@type number[]
		local numbers = {}

		for word in line:gmatch("%-?%d+") do
			table.insert(numbers, utils.tonumber(word))
		end

		assert(#numbers == 9, "invalid line")

		---@type particule
		local p = {
			p = { x = numbers[1], y = numbers[2], z = numbers[3] },
			v = { x = numbers[4], y = numbers[5], z = numbers[6] },
			a = { x = numbers[7], y = numbers[8], z = numbers[9] },
		}

		table.insert(particules, p)
	end

	return particules
end

---@param a vector3
---@param b vector3
---@return boolean
local function are_same(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

---@param a vector3
---@param b vector3
---@return vector3
local function add(a, b)
	return {
		x = a.x + b.x,
		y = a.y + b.y,
		z = a.z + b.z,
	}
end

---@param a vector3
---@return vector3
local function clone_vector3(a)
	return {
		x = a.x,
		y = a.y,
		z = a.z,
	}
end

---@param p particule
---@return particule
local function clone_particule(p)
	return {
		p = clone_vector3(p.p),
		v = clone_vector3(p.v),
		a = clone_vector3(p.a),
	}
end

---@param particules particule[]
---@return particule[]
local function clone_particules(particules)
	local cloned = {}

	for _, p in ipairs(particules) do
		table.insert(cloned, clone_particule(p))
	end

	return cloned
end

---@param particules particule[]
---@param destroyed table<number, boolean>
---@return boolean
local function remove_collisions(particules, destroyed)
	local changed = false

	for i = 1, #particules do
		for j = i + 1, #particules do
			if not destroyed[i] and not destroyed[j] and are_same(particules[i].p, particules[j].p) then
				destroyed[i] = true
				destroyed[j] = true
				changed = true
			end
		end
	end

	return changed
end

---@param particule particule
---@return number
local function distance(particule)
	return math.abs(particule.p.x) + math.abs(particule.p.y) + math.abs(particule.p.z)
end

---@param particules particule[]
---@param destoyed table<number, boolean>
local function tick(particules, destoyed)
	for i, part in ipairs(particules) do
		if not destoyed[i] then
			particules[i].v = add(part.v, part.a)
			particules[i].p = add(part.p, particules[i].v)
		end
	end
end

---@param particules particule[]
---@return number, number
local function get_closest(particules)
	local closest = nil
	local best = math.maxinteger

	for i, particule in ipairs(particules) do
		local dist_i = distance(particule)

		if dist_i < best then
			closest = i
			best = dist_i
		end
	end

	if closest == nil then
		error("empty list of particules")
	end

	return closest, best
end

---@param particules particule[]
---@return number, number
local function part_one(particules)
	local confidance = 1000
	local i = 0
	local closest, best = get_closest(particules)
	local destroyed = {}

	while i < confidance do
		tick(particules, destroyed)

		local closest_j, best_j = get_closest(particules)

		if closest_j == closest then
			i = i + 1
		else
			i = 0
			closest = closest_j
			best = best_j
		end
	end

	return closest - 1, best
end

---@param particules particule[]
---@return number
local function part_two(particules)
	local destroyed = {}
	local confidance = 1000
	local i = 0

	while i < confidance do
		tick(particules, destroyed)

		local changed = remove_collisions(particules, destroyed)

		if not changed then
			i = i + 1
		else
			i = 0
		end

		print(i)
	end

	local total = 0

	for j = 1, #particules do
		if not destroyed[j] then
			total = total + 1
		end
	end

	return total
end

local a = parse_particules()
local b = clone_particules(a)

print(#a)

print(part_one(a))
print(part_two(b))
