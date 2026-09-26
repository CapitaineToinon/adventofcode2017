---@param content string
---@param get_j fun (i: number, content: string): number
---@return number
local function solve(content, get_j)
	local total = 0

	for i = 1, #content do
		local j = get_j(i, content)

		if content:sub(j, j) == content:sub(i, i) then
			total = total + tonumber(content:sub(i, i))
		end
	end

	return total
end

---@param i number
---@param content string
---@return number
local function part_one(i, content)
	return (i + 1) % #content
end

---@param i number
---@param content string
---@return number
local function part_two(i, content)
	return (i + #content / 2) % #content
end

local f = assert(io.open("./input/day01", "r"), "failed to open input")
local content = f:read("l")
f:close()

print(solve(content, part_one))
print(solve(content, part_two))
