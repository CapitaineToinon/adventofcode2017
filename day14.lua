local kh = require("knot_hash")
local utils = require("utils")

---@alias position { x: number, y: number }

---@param position position
---@return number
local function hash_position(position)
	return ((position.x << 8) + position.y)
end

---@param input string
---@return table<number, position>, number
local function create_grid(input)
	---@type table<number, position>
	local positions = {}
	local size = 0

	for x = 1, 128 do
		local hash = kh.hash(input .. "-" .. (x - 1))

		for i, value in ipairs(hash) do
			for j = 0, 8 do
				if value >> (8 - j) & 1 == 1 then
					local y = 1 + ((8 * i) + j)
					local pos = { x = x, y = y }
					positions[hash_position(pos)] = pos
					size = size + 1
				end
			end
		end
	end

	return positions, size
end

---@param positions table<number, position>
---@return number
local function count_groups(positions)
	local groups = 0

	---@type table<number, boolean>
	local seen = {}

	for key, _ in pairs(positions) do
		if seen[key] == nil then
			groups = groups + 1

			---@type number[]
			local queue = { key }

			while #queue > 0 do
				local cur_key = table.remove(queue)
				local cur_pos = positions[cur_key]

				if cur_pos ~= nil and seen[cur_key] == nil then
					seen[cur_key] = true

					for _, offsets in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do
						local dx = offsets[1]
						local dy = offsets[2]
						table.insert(queue, hash_position({ x = cur_pos.x + dx, y = cur_pos.y + dy }))
					end
				end
			end
		end
	end

	return groups
end

local input = utils.readline("./input/day14")
local positions, size = create_grid(input)

print(size)
print(count_groups(positions))
