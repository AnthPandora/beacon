-- This file register beams nodes and particles
local colors = beacon.colors

-- Register per color beam and base nodes
for _,color in ipairs(colors) do

	-- Base node
	minetest.register_node("beacon:"..color.."base", {
		visual_scale = 1.0,
		drawtype = "plantlike",
		tiles = {color.."base.png"},
		paramtype = "light",
		walkable = false,
		diggable = false,
		light_source = 13,
		groups = {not_in_creative_inventory=1}
	})

	-- Beam node
	minetest.register_node("beacon:"..color.."beam", {
		visual_scale = 1.0,
		drawtype = "plantlike",
		tiles = {color.."beam.png"},
		paramtype = "light",
		walkable = false,
		diggable = false,
		light_source = 50,
		groups = {not_in_creative_inventory=1}
	})

	-- Spawn Particles
	minetest.register_abm({
		nodenames = {"beacon:"..color.."base"}, --makes small particles emanate from the beginning of a beam
		interval = 1,
		chance = 2,
		action = function(pos, node)
			minetest.add_particlespawner(
				32, --amount
				4, --time
				{x=pos.x-0.25, y=pos.y-0.25, z=pos.z-0.25}, --minpos
				{x=pos.x+0.25, y=pos.y+0.25, z=pos.z+0.25}, --maxpos
				{x=-0.8, y=-0.8, z=-0.8}, --minvel
				{x=0.8, y=0.8, z=0.8}, --maxvel
				{x=0,y=0,z=0}, --minacc
				{x=0,y=0,z=0}, --maxacc
				0.5, --minexptime
				1, --maxexptime
				1, --minsize
				2, --maxsize
				false, --collisiondetection
				color.."particle.png" --texture
			)
		end,
	})
end 
