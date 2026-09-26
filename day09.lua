---@alias Group { score: number, length: number, garbage: number }
---@alias Garbage { length: number, count: number }

---@return string
local function get_input()
	local f = assert(io.open("./input/day09", "r"), "failed to open input")
	local content = f:read("l")
	f:close()
	return content
end

---@param input string
---@param start number
---@return Garbage
local function parse_garbage(input, start)
	local i = start + 1
	local count = 0

	while true do
		if input:sub(i, i) == ">" then
			return {
				length = i - start + 1,
				count = count,
			}
		elseif input:sub(i, i) == "!" then
			i = i + 2
		else
			i = i + 1
			count = count + 1
		end
	end
end

---@param input string
---@param start number
---@param depth number
---@return Group
local function parse_group(input, start, depth)
	local i = start + 1
	local score = depth
	local garbage = 0

	while true do
		if input:sub(i, i) == "}" then
			return {
				score = score,
				length = i - start + 1,
				garbage = garbage,
			}
		elseif input:sub(i, i) == "{" then
			local j = parse_group(input, i, depth + 1)
			score = score + j.score
			garbage = garbage + j.garbage
			i = i + j.length
		elseif input:sub(i, i) == "<" then
			local g = parse_garbage(input, i)
			garbage = garbage + g.count
			i = i + g.length
		elseif input:sub(i, i) == "!" then
			i = i + 2
		else
			i = i + 1
		end
	end
end

local input = get_input()
local group = parse_group(input, 1, 1)

print(group.score)
print(group.garbage)
