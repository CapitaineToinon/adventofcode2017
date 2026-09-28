local utils = require("utils")

---@return string[][]
local function get_input()
	local passphrases = {}

	for line in io.lines("./input/day04", "l") do
		local passphrase = {}

		for word in utils.split_spaces(line) do
			table.insert(passphrase, word)
		end

		table.insert(passphrases, passphrase)
	end

	return passphrases
end

---@param input string
---@return string
local function sort(input)
	---@type string[]
	local chars = {}

	for i = 1, #input do
		table.insert(chars, input:sub(i, i))
	end

	table.sort(chars, function(a, b)
		return a:lower() < b:lower()
	end)

	return table.concat(chars)
end

---@param passphrase string[]
---@return boolean
local function part_one(passphrase)
	for i = 1, #passphrase do
		for j = i + 1, #passphrase do
			if passphrase[i] == passphrase[j] then
				return false
			end
		end
	end

	return true
end

---@param passphrase string[]
---@return boolean
local function part_two(passphrase)
	for i = 1, #passphrase do
		for j = i + 1, #passphrase do
			if sort(passphrase[i]) == sort(passphrase[j]) then
				return false
			end
		end
	end

	return true
end

---@param passphrases string[][]
---@param is_valid fun (passphrase: string[]): boolean
---@return number
local function solve(passphrases, is_valid)
	local total = 0

	for _, p in ipairs(passphrases) do
		if is_valid(p) then
			total = total + 1
		end
	end

	return total
end

local passphrases = get_input()

print(solve(passphrases, part_one))
print(solve(passphrases, part_two))
