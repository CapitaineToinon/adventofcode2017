---@alias Layer { depth: number, range: number }

---@param line string
---@return Layer
local function get_layer(line)
	---@type number[]
	local numbers = {}

	for word in string.gmatch(line, "%d+") do
		local number = assert(tonumber(word), "failed to parse int")
		table.insert(numbers, number)
	end

	---@type Layer
	local layer = {
		depth = numbers[1],
		range = numbers[2],
	}

	return layer
end

---@return Layer[]
local function get_layers()
	---@type Layer[]
	local layers = {}

	for line in io.lines("./input/day13", "l") do
		local layer = get_layer(line)
		table.insert(layers, layer)
	end

	table.sort(layers, function(a, b)
		return a.range < b.range
	end)

	return layers
end

---@param layers Layer[]
---@param options { delay?: number, minimize?: boolean } | nil
---@return number
local function move(layers, options)
	local delay = (options or {}).delay or 0
	local minimize = (options or {}).minimize or false
	local severity = 0

	for _, layer in ipairs(layers) do
		if (layer.depth + delay) % ((layer.range * 2) - 2) == 0 then
			if minimize then
				return math.maxinteger
			end

			severity = severity + layer.depth * layer.range
		end
	end

	return severity
end

---@param layers Layer[]
---@return number
local function try_delays(layers)
	local delay = 0

	while true do
		if move(layers, { delay = delay, minimize = true }) == 0 then
			return delay
		end

		delay = delay + 1
	end
end

local layers = get_layers()

local part_one = move(layers)
print(part_one)

local part_two = try_delays(layers)
print(part_two)
