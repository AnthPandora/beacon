--please view and edit with Notepad++
--Beacons v1.1 for minetest

beacon = {}

--load other scripts
dofile(minetest.get_modpath("beacon").."/effects.lua")
dofile(minetest.get_modpath("beacon").."/beaminit.lua")
dofile(minetest.get_modpath("beacon").."/beamgen.lua")
dofile(minetest.get_modpath("beacon").."/crafts.lua")

--code for "unactivated beacon"
minetest.register_node("beacon:empty", {
	description = "Unactivated Beacon",
	tiles = {"emptybeacon.png"},
	light_source = 3,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beacon:empty",
})

--code for "Main blue source cube"
minetest.register_node("beacon:blue", {
	description = "Blue Beacon",
	tiles = {"bluebeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beacon:blue",
	-- on_construct = beacon.effects.on_construct,
	on_destruct = beacon.effects.blue.on_destruct,
	after_place_node = beacon.effects.blue.after_place_node,
	-- on_timer = beacon.effects.blue.on_timer,

})

--code for "Main red source cube"
minetest.register_node("beacon:red", {
	description = "Red Beacon",
	tiles = {"redbeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beacon:red",
	on_construct = beacon.effects.on_construct,
	on_destruct = beacon.effects.on_destruct,
	on_timer = beacon.effects.red.on_timer,
})

--code for "Main green source cube"
minetest.register_node("beacon:green", {
	description = "Green Beacon",
	tiles = {"greenbeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beacon:green",
	on_construct = beacon.effects.on_construct,
	on_destruct = beacon.effects.on_destruct,
	after_place_node = beacon.effects.green.after_place_node,
	on_timer = beacon.effects.green.on_timer,
})

--code for "Main purple source cube"
minetest.register_node("beacon:purple", {
	description = "Violet Beacon",
	tiles = {"purplebeacon.png"},
	light_source = 13,
	groups = {cracky=3,oddly_breakable_by_hand=3},
	drop = "beacon:purple",
	on_construct = beacon.effects.on_construct,
	on_destruct = beacon.effects.on_destruct,

})

print("[OK] Beacons")
