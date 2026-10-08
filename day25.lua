local tape = {}
local ones = 0
local i = math.maxinteger // 2
local steps = 12317297
local state = "A"

local function left()
	i = i - 1
end

local function right()
	i = i + 1
end

for _ = 1, steps do
	local value = tape[i] or 0

	local function write(v)
		if value == 0 and v == 1 then
			ones = ones + 1
		end

		if value == 1 and v == 0 then
			ones = ones - 1
		end

		tape[i] = v
	end

	if state == "A" then
		if value == 0 then
			write(1)
			right()
			state = "B"
		else
			write(0)
			left()
			state = "D"
		end
	elseif state == "B" then
		if value == 0 then
			write(1)
			right()
			state = "C"
		else
			write(0)
			right()
			state = "F"
		end
	elseif state == "C" then
		if value == 0 then
			write(1)
			left()
			state = "C"
		else
			write(1)
			left()
			state = "A"
		end
	elseif state == "D" then
		if value == 0 then
			write(0)
			left()
			state = "E"
		else
			write(1)
			right()
			state = "A"
		end
	elseif state == "E" then
		if value == 0 then
			write(1)
			left()
			state = "A"
		else
			write(0)
			right()
			state = "B"
		end
	elseif state == "F" then
		if value == 0 then
			write(0)
			right()
			state = "C"
		else
			write(0)
			right()
			state = "E"
		end
	else
		error("invalid state")
	end
end

print(ones)
