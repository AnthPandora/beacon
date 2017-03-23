-- This file contains fonctions used to generate and remove beams

local colors = beacon.colors
local beam_break_nodes = beacon.config.beam_break_nodes
local timer_timeout = beacon.config.timer_timeout

-- Functions below will be called by the beacon node

-- on_construct : Called when beacon node is placed
beacon.on_construct = {}

-- Register per color on_construct function
for _,color in ipairs(colors) do
	beacon.on_construct[color] = function(pos)
		--
		-- Place base
		--
		pos.y = pos.y + 1
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
		
		--
		-- Start timer if action on timer defined
		--
		local effect = beacon.effects[color]
		if effect.on_timer then
			-- Start timer
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then timer:start(timer_timeout)	end
		end
		
	end	
end

-- on_destruct : Called when beacon node is removed
beacon.on_destruct = function(pos) --remove the beam above a source when source is removed
		-- Remove base node
		pos.y = pos.y + 1
		minetest.remove_node(pos)
		-- Remove beam nodes
		for i=1,179 do
			local p = {x=pos.x, y=pos.y+i, z=pos.z}
			node_name = minetest.get_node(p).name
			if node_name:match('^beacon:.*beam') then
				minetest.remove_node(p)
			end
		end
 end

--[[
for _,color in ipairs(colors) do
	
	minetest.register_abm({
		nodenames = {"beacon:"..color},
		interval = 5,
		chance = 1,
		action = function(pos)
			pos.y = pos.y + 1
			minetest.add_node(pos, {name="beacon:"..color.."base"})
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
		end,
	})
end
--]]


