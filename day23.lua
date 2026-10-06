---Adpated from https://www.geeksforgeeks.org/dsa/check-for-prime-number/
---@param n number
---@return boolean
local function is_prime(n)
	if n <= 1 then
		return false
	end

	if n == 2 or n == 3 then
		return true
	end

	if n % 2 == 0 or n % 3 == 0 then
		return false
	end

	local i = 5

	while (i * i) <= n do
		if n % i == 0 or n % (i + 2) == 0 then
			return false
		end

		i = i + 6
	end

	return true
end

---Reverse engineered version of the code. Goes from b to c
---jumping by 17, counting all non prime numbers
---@param big_start boolean
---@return number
---@return number
local function solve(big_start)
	local b = 57
	local c = b

	if big_start then
		b = (b * 100) + 100000
		c = b + 17000
	end

	local count = 0
	local mul = 0

	while b <= c do
		if not is_prime(b) then
			count = count + 1
		end

		mul = mul + ((b - 2) * (c - 2))
		b = b + 17
	end

	return count, mul
end

local function part_one()
	local _, mul = solve(false)
	return mul
end

local function part_two()
	local h, _ = solve(true)
	return h
end

print(part_one())
print(part_two())
