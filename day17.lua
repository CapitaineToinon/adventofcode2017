local utils = require("utils")

local function part_one(steps)
	local state = { 0 }
	local i = 1

	for _ = 1, 2017 do
		i = utils.mod(i + steps, #state)
		table.insert(state, i + 1, #state)
		i = utils.mod(i + 1, #state)
	end

	return state[i + 1]
end

local function part_two(steps)
	local i = 0
	local solution = 1
	local size = 1

	while size <= 50000000 do
		i = (i + steps) % size

		if i == 0 then
			solution = size
		end

		size = size + 1
		i = i + 1
	end

	return solution
end

local input = utils.tonumber(utils.readline("./input/day17"))

print(part_one(input))
print(part_two(input))
