local N = 256
local ROUNDS = 64

local M = {}

---@param input string
---@return number[]
local function to_ascii(input)
	---@type number[]
	local ascii = { input:byte(1, -1) }

	for _, value in ipairs({ 17, 31, 73, 47, 23 }) do
		table.insert(ascii, value)
	end

	return ascii
end

---@param list number[]
---@return number[]
local function clone(list)
	return { table.unpack(list) }
end

---@param n number
---@param m number
local function mod(n, m)
	return ((n - 1) % m) + 1
end

---@param hash number[]
---@return number[]
function M.densify(hash)
	---@type number[]
	local dense = {}

	for i = 0, 15 do
		local from = (16 * i) + 1
		local to = (from + 16 - 1)

		table.insert(dense, 0)

		for j = from, to do
			dense[#dense] = dense[#dense] ~ hash[j]
		end
	end

	return dense
end

---@return number[]
function M.create_data()
	---@type number[]
	local data = {}

	for i = 0, N - 1 do
		table.insert(data, i)
	end

	return data
end

---Runs a sigle round of knot hash
---@param data number[]
---@param lengths number[]
---@param initial_state? { position: number, skip: number }
---@return number[], { position: number, skip: number }
function M.round(data, lengths, initial_state)
	local state = initial_state or { position = 1, skip = 0 }
	local list = clone(data)

	for _, len in ipairs(lengths) do
		local dest = clone(list)

		for i = 0, len - 1 do
			local from = mod(state.position + len - i - 1, N)
			local to = mod(state.position + i, N)
			dest[to] = list[from]
		end

		list = dest
		state.position = state.position + len + state.skip
		state.skip = state.skip + 1
	end

	return list, state
end

---Hash the input using knot hashes
---@param input string
---@return number[]
function M.hash(input)
	local lengths = to_ascii(input)
	local data = M.create_data()
	local state = { position = 1, skip = 0 }

	for _ = 1, ROUNDS do
		data, state = M.round(data, lengths, state)
	end

	return M.densify(data)
end

return M
