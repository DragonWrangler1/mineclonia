--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### STRIDER
--###################


local strider = {
	description = S("Strider"),
	type = "animal",
	passive = true,
	spawn_class = "passive",
	hp_min = 20,
	hp_max = 20,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	damage = 2,
	reach = 2,
	collisionbox = {-.6, -0.01, -.6, .6, 1.94, .6},
	visual = "mesh",
	mesh = "extra_mobs_strider.b3d",
	textures = { {
		"extra_mobs_strider.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 4,
	runaway = true,
	drops = {
<<<<<<< HEAD
		{name = "vlc_mobsitems:string",
=======
		{name = "vlf_mobsitems:string",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 2,
		max = 5,},
	},
	animation = {
		stand_speed = 15,
		walk_speed = 15,
		run_speed = 30,
		stand_start = 5,
		stand_end = 5,
		walk_start = 1,
		walk_end = 20,
	},
<<<<<<< HEAD
	follow = { "vlc_crimson:warped_fungus" },
=======
	follow = { "vlf_crimson:warped_fungus" },
>>>>>>> 3eb27be82 (change naming in mods)
	lava_damage = 0,
	fire_damage = 0,
	light_damage = 0,
	water_damage = 5,
	fear_height = 4,
	view_range = 16,
	fire_resistant = true,
	floats_on_lava = 1,
	floats = 0,
	can_spawn = function(pos)
<<<<<<< HEAD
		local l = minetest.find_node_near(pos,2,{"vlc_nether:nether_lava_source","vlc_nether:nether_lava_flowing"})
=======
		local l = minetest.find_node_near(pos,2,{"vlf_nether:nether_lava_source","vlf_nether:nether_lava_flowing"})
>>>>>>> 3eb27be82 (change naming in mods)
		return l ~= nil
	end,
	do_custom = function(self, dtime)

<<<<<<< HEAD
		if minetest.find_node_near(self.object:get_pos(), 2, {"vlc_core:lava_source","vlc_core:lava_flowing","vlc_nether:nether_lava_source","vlc_nether:nether_lava_flowing"}) then
=======
		if minetest.find_node_near(self.object:get_pos(), 2, {"vlf_core:lava_source","vlf_core:lava_flowing","vlf_nether:nether_lava_source","vlf_nether:nether_lava_flowing"}) then
>>>>>>> 3eb27be82 (change naming in mods)
			if self.driver then
				self.walk_velocity = 4
				self.run_velocity = 8
			else
				self.walk_velocity = 2
				self.run_velocity = 4
			end
			self.base_texture[1] = "extra_mobs_strider.png"
			self.shaking = false
		else
			self.base_texture[1] = "extra_mobs_strider_cold.png"
			self.walk_velocity = .5
			self.run_velocity = 1
			self.shaking = true
		end

		self.object:set_properties({textures=self.base_texture, shaking=self.shaking, run_velocity=self.run_velocity, walk_velocity=self.walk_velocity})

		-- set needed values if not already present
		if not self.v2 then
			local vsize = self.object:get_properties().visual_size
			self.v2 = 0
			self.max_speed_forward = 8
			self.max_speed_reverse = 4
			self.accel = 2
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 5.5, z = -1.75}
			self.driver_eye_offset = {x = 0, y = 10, z = 0}
			self.driver_scale = {x = 1/vsize.x, y = 1/vsize.y}
		end

		-- if driver present allow control of horse
		if self.driver then
			local pos = self.object:get_pos()
			local v = self.object:get_velocity()
			self.object:set_velocity(vector.new(v.x,0,v.z))
<<<<<<< HEAD
			vlc_mobs.drive(self, "walk", "stand", false, dtime)
=======
			vlf_mobs.drive(self, "walk", "stand", false, dtime)
>>>>>>> 3eb27be82 (change naming in mods)
			local l = minetest.find_node_near(pos,2,{"group:lava"})
			if l then self.object:set_pos(vector.new(pos.x,l.y+0.5,pos.z)) end
			return false -- skip rest of mob functions
		end

		return true
	end,

	on_die = function(self, pos)

		-- drop saddle when horse is killed while riding
		-- also detach from horse properly
		if self.driver then
<<<<<<< HEAD
			vlc_mobs.detach(self.driver, {x = 1, y = 0, z = 1})
=======
			vlf_mobs.detach(self.driver, {x = 1, y = 0, z = 1})
>>>>>>> 3eb27be82 (change naming in mods)
		end
	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

		local wielditem = clicker:get_wielded_item()

<<<<<<< HEAD
		if wielditem:get_name() == "vlc_crimson:warped_fungus" then
=======
		if wielditem:get_name() == "vlf_crimson:warped_fungus" then
>>>>>>> 3eb27be82 (change naming in mods)
			if self:feed_tame(clicker, 1, true, true) then return end
		end

		if self.child then
			return
		end

		local item = clicker:get_wielded_item()
<<<<<<< HEAD
		if item:get_name() == "vlc_mobitems:saddle" and self.saddle ~= "yes" then
=======
		if item:get_name() == "vlf_mobitems:saddle" and self.saddle ~= "yes" then
>>>>>>> 3eb27be82 (change naming in mods)
			self.base_texture = {
				"extra_mobs_strider.png",
				"mobs_mc_pig_saddle.png", -- saddle
			}
			self.object:set_properties({
				textures = self.base_texture
			})
			self.saddle = "yes"
			self.tamed = true
			self.drops = {
<<<<<<< HEAD
				{name = "vlc_mobitems:string",
				chance = 1,
				min = 1,
				max = 3,},
				{name = "vlc_mobitems:saddle",
=======
				{name = "vlf_mobitems:string",
				chance = 1,
				min = 1,
				max = 3,},
				{name = "vlf_mobitems:saddle",
>>>>>>> 3eb27be82 (change naming in mods)
				chance = 1,
				min = 1,
				max = 1,},
			}
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				wielditem:take_item(1)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), wielditem)
			end
<<<<<<< HEAD
			minetest.sound_play({name = "vlc_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
=======
			minetest.sound_play({name = "vlf_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
>>>>>>> 3eb27be82 (change naming in mods)
			return
		end

		-- Mount or detach player
		if self.driver and clicker == self.driver then
			-- Detach if already attached
<<<<<<< HEAD
			vlc_mobs.detach(clicker, {x=1, y=0, z=0})
			return

		elseif not self.driver and self.saddle == "yes" and wielditem:get_name() == "vlc_mobitems:warped_fungus_on_a_stick" then
			-- Ride pig if it has a saddle and player uses a carrot on a stick

			vlc_mobs.attach(self, clicker)
=======
			vlf_mobs.detach(clicker, {x=1, y=0, z=0})
			return

		elseif not self.driver and self.saddle == "yes" and wielditem:get_name() == "vlf_mobitems:warped_fungus_on_a_stick" then
			-- Ride pig if it has a saddle and player uses a carrot on a stick

			vlf_mobs.attach(self, clicker)
>>>>>>> 3eb27be82 (change naming in mods)

			if not minetest.is_creative_enabled(clicker:get_player_name()) then

				local inv = self.driver:get_inventory()
				-- 26 uses
				if wielditem:get_wear() > 63000 then
					-- Break carrot on a stick
					local def = wielditem:get_definition()
					if def.sounds and def.sounds.breaks then
						minetest.sound_play(def.sounds.breaks, {pos = clicker:get_pos(), max_hear_distance = 8, gain = 0.5}, true)
					end
					wielditem = {name = mobs_mc.items.fishing_rod, count = 1}
				else
					wielditem:add_wear(2521)
				end
				inv:set_stack("main",self.driver:get_wield_index(), wielditem)
			end
			return
		end
	end,
}
<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:strider", strider)

vlc_mobs.register_mob("mobs_mc:baby_strider",table.merge(strider,{
=======
vlf_mobs.register_mob("mobs_mc:strider", strider)

vlf_mobs.register_mob("mobs_mc:baby_strider",table.merge(strider,{
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Baby Strider"),
	collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3},
	xp_min = 13,
	xp_max = 13,
	textures = { {
		"extra_mobs_strider.png",
		"blank.png",
	} },
	walk_velocity = 1.2,
	run_velocity = 2.4,
	child = 1,
}))

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:strider",
	type_of_spawning = "lava",
	dimension = "nether",
	chance = 200,
})

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:baby_strider",
	type_of_spawning = "lava",
	dimension = "nether",
	chance = 20,
})

-- spawn eggs
<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:strider", S("Strider"), "#000000", "#FF0000", 0)
=======
vlf_mobs.register_egg("mobs_mc:strider", S("Strider"), "#000000", "#FF0000", 0)
>>>>>>> 3eb27be82 (change naming in mods)
