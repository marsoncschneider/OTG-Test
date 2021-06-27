local positions = {
	{x = 32056, y = 31889, z = 5},
	{x = 32056, y = 31892, z = 5},
	{x = 32063, y = 31900, z = 5},
	{x = 32066, y = 31900, z = 5},
	{x = 32074, y = 31892, z = 5},
	{x = 32074, y = 31889, z = 5},
	{x = 32063, y = 31881, z = 5},
	{x = 32066, y = 31881, z = 5}
}
local spoofRevs = GlobalEvent("spoofRevs")

function spoofRevs.onThink(interval)
	for i = 1, #positions do
		Position(positions[i]):sendMagicEffect(CONST_ME_THUNDER)
	end
	return true
end

spoofRevs:interval(5000)
spoofRevs:register()
