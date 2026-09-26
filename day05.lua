---@return number[]
local function get_input()
	local offsets = {}

	for line in io.lines("./input/day05", "l") do
		table.insert(offsets, tonumber(line))
	end

	return offsets
end

---@param offsets number[]
---@return number[]
local function clone(offsets)
	return { table.unpack(offsets) }
end

---@param offsets number[]
---@param get_next fun (offset: number): number
---@return number
local function solve(offsets, get_next)
	local i = 1
	local steps = 0
	local cloned = clone(offsets)

	while i >= 1 and i <= #cloned do
		local offset = cloned[i]
		cloned[i] = get_next(offset)
		i = i + offset
		steps = steps + 1
	end

	return steps
end

---@param offset number
---@return number
local function part_one(offset)
	return offset + 1
end

---@param offset number
---@return number
local function part_two(offset)
	if offset >= 3 then
		return offset - 1
	end

	return offset + 1
end

local offsets = get_input()

print(solve(offsets, part_one))
print(solve(offsets, part_two))
