---@param day number
local function run_day(day)
	print("--- DAY " .. day .. " ---")
	local x = os.clock()
	require("day" .. string.format("%02d", day))
	print(string.format("elapsed time: %.2f", os.clock() - x))
end

local x = os.clock()

for i = 1, 24 do
	if not pcall(run_day, i) then
		print("not implemented yet")
	end
end

print(string.format("Total elapsed time: %.2f", os.clock() - x))
