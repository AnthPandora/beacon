-- This file contains fonctions used for beacons special effects

local timer_timeout = beacon.config.timer_timeout
local effects_radius = beacon.config.effects_radius
local msg_prefix = beacon.config.msg_prefix


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

--
-- Special effects
--

--
-- Red Beacon : Regenerates health
--
beacon.effects.red = {}
beacon.effects.red.on_timer = function(pos, elapsed)
	local players = get_players_inside_radius(pos, effects_radius)
	for _,player in ipairs(players) do
		local hp = player:get_hp()
		local hp_max = 20 -- FIXME : get hp_max from player properties
		if hp < hp_max then player:set_hp(hp+(0.5*2)) end
	end
	-- Restart timer
	local timer = minetest.get_node_timer(pos)
	timer:start(timer_timeout)
end
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
	
	-- Protect the area 
	if minetest.get_modpath('areas') then
		local area_name = "Blue beacon at "..pos.x.." "..pos.y.." "..pos.z
		local p1 = { x = xr.max, y = yr.max, z = zr.max	}
		local p2 = { x = xr.min, y = yr.min, z = zr.min	}

		local canAdd, errMsg = areas:canPlayerAddArea(pos1, pos2, name)
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
	
	--[[ TODO : Draw a blue field around
	for xi = xr.min,xr.max do
		for yi = yr.min,yr.max do
			for zi = zr.min,zr.max do
				if xi == xr.min or xi == xr.max
				 or zi == zr.min or zi == zr.max
				 or yi == yr.min or yi == yr.max
				 then
					local p = {x=xi,y=yi,z=zi}
					local node = minetest.get_node(p)
					if node.name == "ignore" then
						minetest.get_voxel_manip():read_from_map(p, p)
						node = minetest.get_node(p)
					end
					if node.name == "air" then
						minetest.place_node(p,  {name="default:glass"})
					end	
				end	
			end
		end
	end --]]
	
end

beacon.effects.blue.on_destruct = function(pos)
	if minetest.get_modpath('areas') then
		local meta = minetest.get_meta(pos)
		-- local name = meta:get_string('placer')
		local id = meta:get_int("area_id")
		areas:remove(id)
		areas:save()
		minetest.chat_send_all(msg_prefix.."Removed area "..id)
	end
	-- Remove the beam
	for i=1,180 do
		minetest.remove_node({x=pos.x, y=pos.y+i, z=pos.z})
	end
end

beacon.effects.blue.on_timer = function(pos, elapsed)
	--[[
	-- Players in the area
	local players = get_players_inside_radius(pos, effects_radius)
	
	-- Grant privs to players in the area
	for _,player in ipairs(players) do
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		local player_has_privs = minetest.check_player_privs(name, {interact = true})
		if player_has_privs then 
			privs.interact = nil
			minetest.set_player_privs(name, privs)
			minetest.chat_send_player(name, msg_prefix.."Proximity of a blue beacon prevents you from interacting with the world.")
		end
		
		-- Restore privs after timeout if player disconnected or out of the area
		local after_timeout = timer_timeout+1
		minetest.after(after_timeout, function(player, pos, name, privs)
			-- Get player pos
			local p = player:getpos()
			-- Safety in case player died or was disconnected.
			if not p then  	
				privs.interact = true
				minetest.set_player_privs(name, privs)
			else
				-- Is player out of radius ?	
				local out_x = (p.x < ( pos.x - effects_radius )) or (p.x > ( pos.x + effects_radius ))
				local out_y = (p.y < ( pos.y - effects_radius )) or (p.y > ( pos.y + effects_radius ))
				local out_z = (p.z < ( pos.z - effects_radius )) or (p.z > ( pos.z + effects_radius ))
				if out_x or out_y or out_z then
					privs.interact = true			-- restore priv
					minetest.set_player_privs(name, privs)
					minetest.chat_send_player(name, msg_prefix.."Far from the blue beacon, you regain the ability to interact.")
				end	
			end	
		end, player, pos, name, privs)
	end
	--]]
end

--
-- Green Beacon : Allow flying in the area
--
beacon.effects.green = {}
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
