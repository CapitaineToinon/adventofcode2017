local utils = require("utils")

---@alias group { score: number, length: number, garbage: number }
---@alias garbage { length: number, count: number }

---@param input string
---@param start number
---@return garbage
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
---@return group
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

local input = utils.readline("./input/day09")
local group = parse_group(input, 1, 1)

print(group.score)
print(group.garbage)
