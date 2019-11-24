-- This file contains fonctions used to generate and remove beams

local colors = beacon.colors
local beam_break_nodes = beacon.config.beam_break_nodes
local msg_prefix = beacon.config.msg_prefix
local effects_radius = beacon.config.effects_radius
local timer_timeout = beacon.config.timer_timeout
local beacon_distance_check = beacon.config.beacon_distance_check

-- Check for other nearby beacons
beacon.is_near = function(pos)
	local beacon_nodes = {"beacon:blue","beacon:purple","beacon:red","beacon:green"}
	local other_beacon = minetest.find_node_near(pos, effects_radius, beacon_nodes)
	if other_beacon ~= nil then
		-- minetest.set_node(pos, {name='air'})
		return true
	end
	return false
end


-- on_construct table for per node functions
beacon.on_construct = {}
-- Register per color on_construct function
for _,color in ipairs(colors) do
	beacon.on_construct[color] = function(pos)
	
			-- Return if placing inside the radius of another beacon
		if beacon_distance_check and beacon.is_near(pos) then 
			local meta = minetest.get_meta(pos)
			meta:set_string('infotext', "Another beacon nearby prevented this beacon from being activated.")
			return
		end

		
		--
		-- Start timer if action on timer defined
		--
		if color == 'green' or color == 'red' then
			-- Start timer
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then timer:start(timer_timeout)	end
		end
		
		
		--
		-- Place base
		--
		pos.y = pos.y + 1
		local beambase_node = minetest.get_node(pos)
		if not beambase_node.name or beambase_node.name ~= "air" then
			return
		end

		minetest.add_node(pos, {name="beacon:"..color.."base"})
		
		--
		-- Place beam
		--
		for i=1,179 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			-- Get far node (from http://dev.minetest.net/minetest.get_node)
			local node = minetest.get_node(p)
			if node.name == "ignore" then
				minetest.get_voxel_manip():read_from_map(p, p)
				node = minetest.get_node(p)
			end
			-- Stop when hitting something else than air and config option is so
			if not beam_break_nodes and node.name ~= "air" then break
			-- Place node
			else	minetest.add_node(p, {name="beacon:"..color.."beam"})
			end
		end

		
	end	
end

-- on_destruct : Called when beacon node is removed
beacon.on_destruct = function(pos) --remove the beam above a source when source is removed
		-- Remove base node
		pos.y = pos.y + 1        
	        local node_name_base = minetest.get_node(pos).name
		if node_name_base == "ignore" then
			minetest.get_voxel_manip():read_from_map(pos, pos)
			node_name_base = minetest.get_node(pos).name
		end
		if node_name_base:match('^beacon:.*base') then    
        		minetest.set_node(pos, {name='air'})
        	end

		-- Remove beam nodes
		for i=1,179 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			local node_name = minetest.get_node(p).name
			if node_name == "ignore" then
				minetest.get_voxel_manip():read_from_map(p, p)
				node_name = minetest.get_node(p).name
			end
			if node_name:match('^beacon:.*beam') then
				minetest.set_node(p, {name='air'})
			end
		end
 end
 
