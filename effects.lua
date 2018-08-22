-- This file contains fonctions used for beacons special effects

local timer_timeout = beacon.config.timer_timeout
local effects_radius = beacon.config.effects_radius
local msg_prefix = beacon.config.msg_prefix
local blue_field = beacon.config.blue_field
local beacon_distance_check = beacon.config.beacon_distance_check

--
-- Blue Field node
--
local blue_field_walkable = beacon.config.blue_field_solid or false

minetest.register_node("beacon:bluefield", {
	drawtype = "glasslike",
	tiles = {"bluefield.png"},
	paramtype = "light",
	sunlight_propagates = true,
	walkable = blue_field_walkable,
	diggable = false,
	light_source = 5,
	groups = {not_in_creative_inventory=1}
})


--
-- Utility fonctions
--

-- Return table of players inside the beacons radius
function get_players_inside_radius(pos, radius)
	-- Function from dev.minetest.net/minetest.get_objects_inside_radius
	local all_objects = minetest.get_objects_inside_radius(pos, radius)
	local players = {}
	local _,obj
	for _,obj in ipairs(all_objects) do
		if obj:is_player() then
			table.insert(players, obj)
		end
	end
	return players
end

-- Place field nodes around a given area
function draw_force_field(r, field_node)
	for xi = r.x.min,r.x.max do
		for yi = r.y.min,r.y.max do
			for zi = r.z.min,r.z.max do
				--	
				-- Draws the force field	
				--
				if xi == r.x.min or xi == r.x.max
				 or zi == r.z.min or zi == r.z.max
				 or yi == r.y.min or yi == r.y.max
				 then
					local p = {x=xi,y=yi,z=zi}
					local node = minetest.get_node(p)
					if node.name == "ignore" then
						minetest.get_voxel_manip():read_from_map(p, p)
						node = minetest.get_node(p)
					end

					if node.name == "air" then
						minetest.place_node(p, {name=field_node})
					end	
				end	
			end
		end
	end --]]
end

-- Remove field nodes around a given area
function remove_force_field(r, field_node)
	for xi = r.x.min,r.x.max do
		for yi = r.y.min,r.y.max do
			for zi = r.z.min,r.z.max do
				--	
				-- Limits the force field	
				--
				if xi == r.x.min or xi == r.x.max
				 or zi == r.z.min or zi == r.z.max
				 or yi == r.y.min or yi == r.y.max
				 then
					local p = {x=xi,y=yi,z=zi}
					local node = minetest.get_node(p)
					if node.name == "ignore" then
						minetest.get_voxel_manip():read_from_map(p, p)
						node = minetest.get_node(p)
					end
					if node and node.name == field_node then
						minetest.set_node(p, {name='air'})
					end	
				end	
			end
		end
	end --]]
end

--
-- Special effects
--

--
-- Red Beacon : Regenerates health
--
beacon.effects.red = {}
--beacon.effects.red.on_timer = function(pos, elapsed)
--	local players = get_players_inside_radius(pos, effects_radius)
--	for _,player in ipairs(players) do
--		local hp = player:get_hp()
--		local hp_max = 20 -- FIXME : get hp_max from player properties
--		if hp < hp_max then player:set_hp(hp+(0.5*2)) end
--	end
--
--	-- Restart timer
--	local timer = minetest.get_node_timer(pos)
--	timer:start(timer_timeout)
--end

--
-- TODO Purple Beacon : Double tools strength and regen
--
beacon.effects.purple = {}
beacon.effects.purple.on_timer = function(pos, elapsed)
	return
end 

--
-- Blue Beacon : Protect the area and draw blue field around
--
beacon.effects.blue = {}
beacon.effects.blue.after_place_node = function(pos, placer, itemstack, pointed_thing)

	-- Return if placing inside the radius of another beacon
	if beacon_distance_check and beacon.is_near(pos) then return end
	
	-- Set placer as meta
	local meta = minetest.get_meta(pos)
	local name = placer:get_player_name()
	meta:set_string('placer', name)
	
	-- Limits of radius
	local xr = {}
	xr.min = pos.x - effects_radius
	xr.max = pos.x + effects_radius
	local yr = {}
	yr.min = pos.y - effects_radius
	yr.max = pos.y + effects_radius
	local zr = {}
	zr.min = pos.z - effects_radius
	zr.max = pos.z + effects_radius
	
	
	--
	-- Draw a blue field around 
	--
	local radius_table = {x=xr,y=yr,z=zr}
	if blue_field then 
		draw_force_field(radius_table, "beacon:bluefield")
	end
	
	--
	-- Protect the area 
	--
	if minetest.get_modpath('areas') then
		local area_name = "Blue beacon at "..pos.x.." "..pos.y.." "..pos.z
		local p1 = { x = xr.max, y = yr.max, z = zr.max	}
		local p2 = { x = xr.min, y = yr.min, z = zr.min	}

		local canAdd, errMsg = areas:canPlayerAddArea(p1, p2, name)
		if not canAdd then
			minetest.chat_send_player(name, msg_prefix.."You can't protect that area: "..errMsg)
		else
			p1, p2 = areas:sortPos( p1, p2 );
			local id = areas:add(name, area_name, p1, p2, nil)
			areas:save()
			minetest.chat_send_player(name, msg_prefix.."Your blue beacon is protecting the surrounding area.")
			meta:set_int("area_id", id)
		end	
	end
	
	-- TODO : Add formspec for area config
end

beacon.effects.blue.on_destruct = function(pos)
	--
	-- Unprotect the area
	--
	if minetest.get_modpath('areas') then
		local meta = minetest.get_meta(pos)
		-- local name = meta:get_string('placer')
		local id = meta:get_int("area_id")
		if id and id ~= 0 then
			areas:remove(id)
			areas:save()
			minetest.chat_send_all(msg_prefix.."Removed area "..id)
		end
	end
	
	--
	-- Remove the blue field
	--
	if blue_field then 
		-- Limits of radius
		local xr = {}
		xr.min = pos.x - effects_radius
		xr.max = pos.x + effects_radius
		local yr = {}
		yr.min = pos.y - effects_radius
		yr.max = pos.y + effects_radius
		local zr = {}
		zr.min = pos.z - effects_radius
		zr.max = pos.z + effects_radius
		
		local radius_table = {x=xr,y=yr,z=zr}

		-- Remove field	
		remove_force_field(radius_table, "beacon:bluefield")
	end
	
	--
	-- Rest of on_destruct function common with other beacons
	--
	beacon.on_destruct(pos)
end

--
-- Green Beacon : Allow flying in the area
--
beacon.effects.green = {}
--[[
beacon.effects.green.on_timer = function(pos, elapsed)
	-- Players in the area
	local players = get_players_inside_radius(pos, effects_radius)
	
	-- Grant privs to players in the area
	for _,player in ipairs(players) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		local player_has_privs = minetest.check_player_privs(name, {fly = true})
		if not player_has_privs then 
			privs.fly = true
			minetest.set_player_privs(name, privs)
			minetest.chat_send_player(name, msg_prefix.."Proximity of a green beacon grant you the ability you to fly.")
		end
		
		-- Revoke privs after timeout if player disconnected or out of the area
		local after_timeout = timer_timeout+1
		minetest.after(after_timeout, function(player, pos, name, privs)
			-- Get player pos
			local p = player:getpos()
			-- Safety in case player died or was disconnected.
			if not p then  	-- no pos, no priv
				privs.fly = nil
				minetest.set_player_privs(name, privs)
			else
				-- Is player out of radius ?	
				local out_x = (p.x < ( pos.x - effects_radius )) or (p.x > ( pos.x + effects_radius ))
				local out_y = (p.y < ( pos.y - effects_radius )) or (p.y > ( pos.y + effects_radius ))
				local out_z = (p.z < ( pos.z - effects_radius )) or (p.z > ( pos.z + effects_radius ))
				if out_x or out_y or out_z then
					privs.fly = nil			-- revoke priv
					minetest.set_player_privs(name, privs)
					minetest.chat_send_player(name, msg_prefix.."Far from the green beacon, you lost the ability to fly.")
				end	
			end	
		end, player, pos, name, privs)
	end
	
	-- Restart timer
	local timer = minetest.get_node_timer(pos)
	timer:start(timer_timeout)
end
--]]


-- Use globalstep instead of node timer for green beacon
-- beacause node can be in an unloaded area
--

local timer = 0
minetest.register_globalstep(function(dtime)
	-- Update timer
	timer = timer + dtime
	if (timer >= timer_timeout) then
		-- List all connected player
		local players = minetest.get_connected_players()
		for _,player in ipairs(players) do

			-- Get player infos
			local pos = player:getpos()
			local name = player:get_player_name()
			local privs = minetest.get_player_privs(name)
			local player_has_privs = minetest.check_player_privs(name, {fly = true})
			local player_is_admin = minetest.check_player_privs(name, {privs = true})
	
			-- Find beacons in radius
			green_beacon_near = minetest.find_node_near(pos, effects_radius, {"beacon:greenbase"})
			
			-- Revoke privs if not found
			if player_has_privs and not green_beacon_near and not player_is_admin and pos.y < 6000 then
				privs.fly = nil			-- revoke priv
				minetest.set_player_privs(name, privs)
				minetest.chat_send_player(name, msg_prefix.."Far from the green beacon, you lost the ability to fly.")
			end
			
			-- Grant privs if found
			if green_beacon_near and not player_has_privs and not player_is_admin then 
				privs.fly = true
				minetest.set_player_privs(name, privs)
				minetest.chat_send_player(name, msg_prefix.."Proximity of a green beacon grant you the ability you to fly.")
			end
		
		end
		-- Restart timer
		timer = 0
	end
end)

