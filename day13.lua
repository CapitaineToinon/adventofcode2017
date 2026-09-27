---@alias Layer { depth: number, range: number, period: number, forbidden: number }

---@param line string
---@return Layer
local function get_layer(line)
	---@type number[]
	local numbers = {}

	for word in string.gmatch(line, "%d+") do
		local number = assert(tonumber(word), "failed to parse int")
		table.insert(numbers, number)
	end

	local depth = numbers[1]
	local range = numbers[2]
	local period = ((range * 2) - 2)
	local forbidden = -depth % period

	---@type Layer
	local layer = {
		depth = depth,
		range = range,
		period = period,
		forbidden = forbidden,
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

	-- sort by periodicity, more frequent layers
	-- are more important to pass first
	table.sort(layers, function(a, b)
		return a.period < b.period
	end)

	return layers
end

---https://en.wikipedia.org/wiki/Greatest_common_divisor
---@param a number
---@param b number
---@return number
local function gcd(a, b)
	if a == b then
		return a
	elseif a > b then
		return gcd(a - b, b)
	else
		return gcd(a, b - a)
	end
end

---@param a number
---@param b number
---@return number
local function lcm(a, b)
	return a * b // gcd(a, b)
end

---Pre-computed the delay offsets that survives all the first N layers
---given a list of sorted layers by their periods
---@param layers Layer[]
---@param N number
---@return number[], number
local function get_survivors(layers, N)
	local M = 1

	for i = 1, N do
		M = lcm(M, layers[i].period)
	end

	---@type number[]
	local survivors = {}

	for delay = 0, M - 1 do
		for i = 1, N do
			if delay % layers[i].period == layers[i].forbidden then
				goto skip
			end
		end

		table.insert(survivors, delay)

		::skip::
	end

	return survivors, M
end

---Moves through the layers, either computing the severity or bailing early
---based on the bail parameter
---@param layers Layer[]
---@param options { delay?: number, bail?: boolean } | nil
---@return number
local function move(layers, options)
	local delay = (options or {}).delay or 0
	local minimize = (options or {}).bail or false
	local severity = 0

	for _, layer in ipairs(layers) do
		if delay % layer.period == layer.forbidden then
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
	-- find the delay offsets that survive at least the first
	-- half the layers
	local survivors, M = get_survivors(layers, #layers // 2)

	-- assume none of the survivors themselfs are possible answers
	local delay = M

	while true do
		-- the solution has to be a multiple of one of the survivor so pre-computing
		-- them allows us to only check theses instead of brute forcing everything
		for _, survivor in ipairs(survivors) do
			if move(layers, { delay = delay + survivor, bail = true }) == 0 then
				return delay + survivor
			end
		end

		delay = delay + M
	end
end

local layers = get_layers()

local part_one = move(layers)
print(part_one)

local part_two = try_delays(layers)
print(part_two)
