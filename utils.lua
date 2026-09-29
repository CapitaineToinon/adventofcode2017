local M = {}

---tonumber wrapped with an assert
---@param input string
---@return number
function M.tonumber(input)
	return assert(tonumber(input), "failed to parse number " .. input)
end

---Does 1 to base modulo instead of 0 to base - 1
---@param i number
---@param base number
---@return number
function M.mod(i, base)
	return ((i - 1) % base) + 1
end

---Reads the first line skipping the end of line
---@param filename string
---@return string
function M.readline(filename)
	local f = assert(io.open(filename, "r"), "failed to open input")
	local content = tostring(f:read("l"))
	f:close()
	return content
end

---Split on sparator
---@param input string
---@param separator string
---@return fun(): string, ...
function M.split(input, separator)
	return input:gmatch("([^" .. separator .. "]+)")
end

---Split on spaces
---@param input string
---@return fun(): string, ...
function M.split_spaces(input)
	return input:gmatch("%S+")
end

---Split on commas
---@param input string
---@return fun(): string, ...
function M.split_commas(input)
	return M.split(input, ",")
end

return M
