--use attached fire particle spawner on player in stead of entity, in a global table, with a timer to show how much time a player has before the fire goes out naturally, then delete it, also delete if in water and set timer to 0
--damage player slowly whilst on fire
--override fire and lava to not damage you
--override the spread fire function
--create a minetest.after function so that fire doesn't consume multiple nodes instantly from one node
-- minetest/fire/init.lua

fire = {}
fire.chance = 0.3
fire.top    = {-0.5,0.48,-0.5,0.5,0.48,0.5}
fire.bottom = {-0.5,-0.48,-0.5,0.5,-0.48,0.5}
fire.left   = {0.48,-0.5,-0.5,0.48,0.5,0.5}
fire.right  = {-0.48,-0.5,-0.5,-0.48,0.5,0.5}
fire.front  = {-0.5,-0.5,0.48,0.5,0.5,0.48}
fire.back   = {-0.5,-0.5,-0.48,0.5,0.5,-0.48}

--[[
function fire.check_state(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.z
	local state = ""
	--check for everything
	local a = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name
	if a ~= "air" and minetest.get_node_group(a, "fire") == 0 and minetest.get_item_group(a, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	
	local b = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name
	if b ~= "air" and minetest.get_node_group(b, "fire") == 0 and minetest.get_item_group(b, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	
	
	
	local c = minetest.get_node({x=pos.x+1,y=pos.y,z=pos.z}).name
	if c ~= "air" and minetest.get_node_group(c, "fire") == 0 and minetest.get_item_group(c, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	
	local d = minetest.get_node({x=pos.x-1,y=pos.y,z=pos.z}).name
	if d ~= "air" and minetest.get_node_group(d, "fire") == 0 and minetest.get_item_group(d, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	
	local e = minetest.get_node({x=pos.x,y=pos.y,z=pos.z+1}).name
	if e ~= "air" and minetest.get_node_group(e, "fire") == 0 and minetest.get_item_group(e, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	
	local f = minetest.get_node({x=pos.x,y=pos.y,z=pos.z-1}).name
	if f ~= "air" and minetest.get_node_group(f, "fire") == 0 and minetest.get_item_group(f, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	return(state)
end
]]--


--this is rediculous, but gets the job done for every possible state, basically binary
--up down left right front back
for a = 0,1 do
	for b = 0,1 do
		for c = 0,1 do
			for d = 0,1 do
				for e = 0,1 do
					for f = 0,1 do
						--creat fire node box if there are other blocks around
						--else make plantlike
						fire.nodebox = {}
						if a == 1 then
							table.insert(fire.nodebox, fire.top)
						end
						if b == 1 then
							table.insert(fire.nodebox, fire.bottom)
						end
						if c == 1 then
							table.insert(fire.nodebox, fire.left)
						end
						if d == 1 then
							table.insert(fire.nodebox, fire.right)
						end
						if e == 1 then
							table.insert(fire.nodebox, fire.front)
						end
						if f == 1 then
							table.insert(fire.nodebox, fire.back)
						end					
						minetest.register_node("fire:fire_"..a..b..c..d..e..f, {
							description = "Fire",
							tiles = {{
								name="fire_basic_flame_animated.png",
								animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
							}},
							inventory_image = "fire_basic_flame_animated.png",
							light_source = 14,
							groups = {igniter=2,dig_immediate=3,hot=3,fire=1},
							drop = '',						
							walkable = false,
							buildable_to = true,
							-- Make the fire entity hurt the player instead
							drawtype = "nodebox",
							paramtype = "light",
							node_box = {
								type = "fixed",
								fixed = fire.nodebox,
							},
						})
					end
				end
			end
		end
	end	
end

--this is for the flame placement of the nodebox (so that it looks like it's burning everything flammable around it!
function fire.update_state(pos)
	local min = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
	local max = {x=pos.x+1,y=pos.y+1,z=pos.z+1}
	local vm = minetest.get_voxel_manip()	
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	--DO THIS IN ANOTHER FUNCTION

	--delete flames that aren't next to anything
	--if oldstate == "fire:fire_000000" then
	--	local p_pos = area:index(pos.x, pos.y, pos.z)
	--	data[p_pos] = minetest.get_content_id("air")
	--	vm:set_data(data)
	--	vm:calc_lighting()
	--	vm:write_to_map()
	--	vm:update_map()
	--	return
	--end

	local state = ""
	
	local a = vm:get_node_at({x=pos.x,y=pos.y+1,z=pos.z}).name
	if a ~= "air" and minetest.get_node_group(a, "fire") == 0 and minetest.get_item_group(a, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	local b = vm:get_node_at({x=pos.x,y=pos.y-1,z=pos.z}).name
	if b ~= "air" and minetest.get_node_group(b, "fire") == 0 and minetest.get_item_group(b, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	local c = vm:get_node_at({x=pos.x+1,y=pos.y,z=pos.z}).name
	if c ~= "air" and minetest.get_node_group(c, "fire") == 0 and minetest.get_item_group(c, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	local d = vm:get_node_at({x=pos.x-1,y=pos.y,z=pos.z}).name
	if d ~= "air" and minetest.get_node_group(d, "fire") == 0 and minetest.get_item_group(d, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	local e = vm:get_node_at({x=pos.x,y=pos.y,z=pos.z+1}).name
	if e ~= "air" and minetest.get_node_group(e, "fire") == 0 and minetest.get_item_group(e, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	local f = vm:get_node_at({x=pos.x,y=pos.y,z=pos.z-1}).name
	if f ~= "air" and minetest.get_node_group(f, "fire") == 0 and minetest.get_item_group(f, "flammable") ~= 0 then
		state = state.."1"
	else 
		state = state.."0"
	end
	--if nothing remove self, if something set fire state
	if state == "000000" then
		local p_pos = area:index(pos.x, pos.y, pos.z)
		data[p_pos] = minetest.get_content_id("air")
	else
		local newfire = minetest.get_content_id("fire:fire_"..state)
		local p_pos = area:index(pos.x, pos.y, pos.z)
		data[p_pos] = newfire	
	end
	vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map()
	vm:update_map()
end
function fire.burn(pos)
	local min = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
	local max = {x=pos.x+1,y=pos.y+1,z=pos.z+1}
	local vm = minetest.get_voxel_manip()	
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()	

	local p_pos = area:index(pos.x+1,pos.y,pos.z)
	local name = minetest.get_name_from_content_id(data[p_pos])
	if minetest.get_item_group(name, "flammable") ~= 0 then
		data[p_pos] = minetest.get_content_id("fire:basic_flame")
		minetest.after(0, function()
			fire.update_state({x=pos.x+1,y=pos.y,z=pos.z})
		end)
	end

	local p_pos = area:index(pos.x-1,pos.y,pos.z)
	local name = minetest.get_name_from_content_id(data[p_pos])
	if minetest.get_item_group(name, "flammable") ~= 0 then
		data[p_pos] = minetest.get_content_id("fire:basic_flame")
		minetest.after(0, function()
			fire.update_state({x=pos.x-1,y=pos.y,z=pos.z})
		end)
	end

	local p_pos = area:index(pos.x,pos.y+1,pos.z)
	local name = minetest.get_name_from_content_id(data[p_pos])
	if minetest.get_item_group(name, "flammable") ~= 0 then
		data[p_pos] = minetest.get_content_id("fire:basic_flame")
		minetest.after(0, function()
			fire.update_state({x=pos.x,y=pos.y+1,z=pos.z})
		end)
	end

	local p_pos = area:index(pos.x,pos.y-1,pos.z)
	local name = minetest.get_name_from_content_id(data[p_pos])
	if minetest.get_item_group(name, "flammable") ~= 0 then
		data[p_pos] = minetest.get_content_id("fire:basic_flame")
		minetest.after(0, function()
			fire.update_state({x=pos.x,y=pos.y-1,z=pos.z})
		end)

	end

	local p_pos = area:index(pos.x,pos.y,pos.z+1)
	local name = minetest.get_name_from_content_id(data[p_pos])
	if minetest.get_item_group(name, "flammable") ~= 0 then
		data[p_pos] = minetest.get_content_id("fire:basic_flame")
		minetest.after(0, function()
			fire.update_state({x=pos.x,y=pos.y,z=pos.z+1})
		end)
	end

	local p_pos = area:index(pos.x,pos.y,pos.z-1)
	local name = minetest.get_name_from_content_id(data[p_pos])
	if minetest.get_item_group(name, "flammable") ~= 0 then
		data[p_pos] = minetest.get_content_id("fire:basic_flame")
		minetest.after(0, function()
			fire.update_state({x=pos.x,y=pos.y,z=pos.z-1})
		end)
	end


	vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map()
	vm:update_map()
end
--POSSIBLY make this radial, or a radial variant with a radius var!
function fire.update_surrounding_flames(pos)
	local min = {x=pos.x-1,y=pos.y-1,z=pos.z-1}
	local max = {x=pos.x+1,y=pos.y+1,z=pos.z+1}
	local vm = minetest.get_voxel_manip()	
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		--local p_pos = area:index(pos.x+x,pos.y+y,pos.z+z)
		--print(dump(data[p_pos]))
	end
	end
	end
	vm:set_data(data)
	vm:calc_lighting()
	vm:write_to_map()
	vm:update_map()

end

-- THIS IS THE DEFAULT FIRE MOD



minetest.register_node("fire:basic_flame", {
	description = "Fire",
	drawtype = "firelike",
	tiles = {{
		name="fire_basic_flame_animated.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	inventory_image = "fire_basic_flame.png",
	light_source = 14,
	groups = {igniter=2,dig_immediate=3},
	drop = '',
	walkable = false,
	buildable_to = true,
	--damage_per_second = 4,

	--on_construct = function(pos)
	--	minetest.after(0, fire.on_flame_add_at, pos)
	--end,

	--on_destruct = function(pos)
	--	minetest.after(0, fire.on_flame_remove_at, pos)
	--end,	
	-- unaffected by explosions
	on_blast = function() end,
})


-- Ignite neighboring nodes
minetest.register_abm({
	nodenames = {"group:igniter"},
	interval = 1,
	chance = 1,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		local flame = meta:get_string("flame")
		print(flame)
		--only do fire functions if the fire is ready
		if flame == "1" then
			fire.burn(pos)
			fire.update_state(pos)
		else
			minetest.after(1.5, function()
				--here, set the meta
				local meta = minetest.get_meta(pos)
				meta:set_string("flame", "1")
			end)
		end
		--fire.update_surrounding_flames(pos)
	end,
})

--[[
fire.D = 6
-- key: position hash of low corner of area
-- value: {handle=sound handle, name=sound name}
fire.sounds = {}

function fire.get_area_p0p1(pos)
	local p0 = {
		x=math.floor(pos.x/fire.D)*fire.D,
		y=math.floor(pos.y/fire.D)*fire.D,
		z=math.floor(pos.z/fire.D)*fire.D,
	}
	local p1 = {
		x=p0.x+fire.D-1,
		y=p0.y+fire.D-1,
		z=p0.z+fire.D-1
	}
	return p0, p1
end

function fire.update_sounds_around(pos)
	local p0, p1 = fire.get_area_p0p1(pos)
	local cp = {x=(p0.x+p1.x)/2, y=(p0.y+p1.y)/2, z=(p0.z+p1.z)/2}
	local flames_p = minetest.find_nodes_in_area(p0, p1, {"fire:basic_flame"})
	--print("number of flames at "..minetest.pos_to_string(p0).."/"
	--		..minetest.pos_to_string(p1)..": "..#flames_p)
	local should_have_sound = (#flames_p > 0)
	local wanted_sound = nil
	if #flames_p >= 9 then
		wanted_sound = {name="fire_large", gain=1.5}
	elseif #flames_p > 0 then
		wanted_sound = {name="fire_small", gain=1.5}
	end
	local p0_hash = minetest.hash_node_position(p0)
	local sound = fire.sounds[p0_hash]
	if not sound then
		if should_have_sound then
			fire.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound, {pos=cp, max_hear_distance = 16, loop=true}),
				name = wanted_sound.name,
			}
		end
	else
		if not wanted_sound then
			minetest.sound_stop(sound.handle)
			fire.sounds[p0_hash] = nil
		elseif sound.name ~= wanted_sound.name then
			minetest.sound_stop(sound.handle)
			fire.sounds[p0_hash] = {
				handle = minetest.sound_play(wanted_sound, {pos=cp, max_hear_distance = 16, loop=true}),
				name = wanted_sound.name,
			}
		end
	end
end

function fire.on_flame_add_at(pos)
	fire.update_sounds_around(pos)
end

function fire.on_flame_remove_at(pos)
	fire.update_sounds_around(pos)
end

function fire.find_pos_for_flame_around(pos)
	return minetest.find_node_near(pos, 1, {"air"})
end

function fire.flame_should_extinguish(pos)
	if minetest.setting_getbool("disable_fire") then return true end
	--return minetest.find_node_near(pos, 1, {"group:puts_out_fire"})
	local p0 = {x=pos.x-2, y=pos.y, z=pos.z-2}
	local p1 = {x=pos.x+2, y=pos.y, z=pos.z+2}
	local ps = minetest.find_nodes_in_area(p0, p1, {"group:puts_out_fire"})
	return (#ps ~= 0)
end

-- Ignite neighboring nodes
minetest.register_abm({
	nodenames = {"group:flammable"},
	neighbors = {"group:igniter"},
	interval = 5,
	chance = 2,
	action = function(p0, node, _, _)
		-- If there is water or stuff like that around flame, don't ignite
		if fire.flame_should_extinguish(p0) then
			return
		end
		local p = fire.find_pos_for_flame_around(p0)
		if p then
			fire.update_state(p0)
			fire.update_surrounding_flames(p0)
		end
	end,
})

-- Rarely ignite things from far
minetest.register_abm({
	nodenames = {"group:igniter"},
	neighbors = {"air"},
	interval = 5,
	chance = 10,
	action = function(p0, node, _, _)
		local reg = minetest.registered_nodes[node.name]
		if not reg or not reg.groups.igniter or reg.groups.igniter < 2 then
			return
		end
		local d = reg.groups.igniter
		local p = minetest.find_node_near(p0, d, {"group:flammable"})
		if p then
			-- If there is water or stuff like that around flame, don't ignite
			if fire.flame_should_extinguish(p) then
				return
			end
			local p2 = fire.find_pos_for_flame_around(p)
			if p2 then
				fire.update_state(p0)
			end
		end
	end,
})

-- Remove flammable nodes and flame
minetest.register_abm({
	nodenames = {"fire:basic_flame"},
	interval = 3,
	chance = 2,
	action = function(p0, node, _, _)
		-- If there is water or stuff like that around flame, remove flame
		if fire.flame_should_extinguish(p0) then
			minetest.remove_node(p0)
			return
		end
		-- Make the following things rarer
		if math.random(1,3) == 1 then
			return
		end
		-- If there are no flammable nodes around flame, remove flame
		if not minetest.find_node_near(p0, 1, {"group:flammable"}) then
			minetest.remove_node(p0)
			return
		end
		if math.random(1,4) == 1 then
			-- remove a flammable node around flame
			local p = minetest.find_node_near(p0, 1, {"group:flammable"})
			if p then
				-- If there is water or stuff like that around flame, don't remove
				if fire.flame_should_extinguish(p0) then
					return
				end
				minetest.remove_node(p)
				nodeupdate(p)
			end
		else
			-- remove flame
			minetest.remove_node(p0)
		end
	end,
})]]--

