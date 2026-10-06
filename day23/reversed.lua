local M = {}

--- Mapping of the original assembly code to lua, line by line
--- This is a sanity check to confirm the code behaves the same
--- as the original assembly.
---@param initial_a number|nil
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function M.assembly(initial_a)
	local a = initial_a or 0
	local b = 0
	local c = 0
	local d = 0
	local e = 0
	local f = 0
	local g = 0
	local h = 0
	local mul = 0

	b = 57 -- 						set b 57
	c = b -- 						set c b

	if a ~= 0 then --				jnz a 2 & jnz 1 5
		b = b * 100 --	 			mul b 100
		mul = mul + 1
		b = b + 100000 -- 			sub b -100000
		c = b -- 					set c b
		c = c + 17000 --			sub c -17000
	end

	while true do
		f = 1 --					set f 1
		d = 2 --					set d 2

		while true do
			e = 2 --				set e 2

			while true do
				g = d --			set g d
				g = g * e --		mul g e
				mul = mul + 1
				g = g - b --		sub g b

				if g == 0 then -- 	jnz g 2
					f = 0 -- 		set f 0
				end

				e = e + 1 --		sub e -1
				g = e -- 			set g e
				g = g - b --		sub g b

				if g == 0 then -- 	jnz g -8
					break
				end
			end

			d = d + 1 --			set d -1
			g = d --				set g d
			g = g - b --			sub g b

			if g == 0 then -- 		jnz g -13
				break
			end
		end

		if f == 0 then -- 			jnz f 2
			h = h + 1 --			sub h -1
		end

		g = b -- 					set g b
		g = g - c --				sub g c

		if g == 0 then
			break
		end

		b = b + 17 --				sub b -17
	end

	return a, b, c, d, e, f, g, h, mul
end

---Simplified version of the code, doing the same thing but
---removing some assembly for its logical, shorter equivalent
---@param big_start boolean|nil
---@return boolean
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
---@return number
function M.simplified(big_start)
	local b = 0
	local c = 0
	local d = 0
	local e = 0
	local f = 0
	local g = 0
	local h = 0
	local mul = 0

	b = 57
	c = b

	if big_start then
		mul = mul + 1
		b = (b * 100) + 100000
		c = b + 17000
	end

	while true do
		f = 1
		d = 2

		repeat
			e = 2

			repeat
				g = d * e
				mul = mul + 1

				if g == b then
					f = 0
				end

				e = e + 1
			until e == b

			d = d + 1
		until d == b

		if f == 0 then
			h = h + 1
		end

		g = b - c

		if g == 0 then
			break
		end

		b = b + 17
	end

	return big_start or false, b, c, d, e, f, g, h, mul
end

---Explicit version, doing the same thing still very slow
---but with easy to read code and variable names
---@param big_start boolean|nil
---@return number
---@return number
function M.explicit(big_start)
	local b = 0
	local c = 0

	b = 57
	c = b

	if big_start then
		b = (b * 100) + 100000
		c = b + 17000
	end

	local mul = 0
	local non_prime_count = 0

	while b <= c do
		local is_prime = true

		for d = 2, b - 1 do
			for e = 2, b - 1 do
				if d * e == b then
					is_prime = false
				end
			end
		end

		if not is_prime then
			non_prime_count = non_prime_count + 1
		end

		mul = mul + ((b - 2) * (c - 2))
		b = b + 17
	end

	return non_prime_count, mul
end

return M
