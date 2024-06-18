--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:pig", {
=======
vlf_mobs.register_mob("mobs_mc:pig", {
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Pig"),
	type = "animal",
	spawn_class = "passive",
	runaway = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 0.865, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_pig.b3d",
	textures = {{
		"mobs_mc_pig.png", -- base
		"blank.png", -- saddle
	}},
	head_swivel = "head.control",
	bone_eye_height = 7.5,
	head_eye_height = 0.8,
	horizontal_head_height=-1,
	curiosity = 3,
	head_yaw="z",
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 3,
	follow_velocity = 3.4,
	drops = {
<<<<<<< HEAD
		{name = "vlc_mobitems:porkchop",
=======
		{name = "vlf_mobitems:porkchop",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 1,
		min = 1,
		max = 3,
		looting = "common",},
	},
	fear_height = 4,
	sounds = {
		random = "mobs_pig",
		death = "mobs_pig_angry",
		damage = "mobs_pig",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 60,
		run_start = 0, run_end = 40, run_speed = 90,
	},
	child_animations = {
		stand_start = 41, stand_end = 41,
		walk_start = 41, walk_end = 81, walk_speed = 90,
		run_start = 41, run_end = 81, run_speed = 135,
	},
	follow = {
<<<<<<< HEAD
		"vlc_farming:potato_item",
		"vlc_farming:carrot_item",
		"vlc_farming:beetroot_item",
		"vlc_mobitems:carrot_on_a_stick"
	},
	view_range = 8,
	on_lightning_strike = function(self, pos, pos2, objects)
		 vlc_util.replace_mob(self.object, "mobs_mc:zombified_piglin")
=======
		"vlf_farming:potato_item",
		"vlf_farming:carrot_item",
		"vlf_farming:beetroot_item",
		"vlf_mobitems:carrot_on_a_stick"
	},
	view_range = 8,
	on_lightning_strike = function(self, pos, pos2, objects)
		 vlf_util.replace_mob(self.object, "mobs_mc:zombified_piglin")
>>>>>>> 3eb27be82 (change naming in mods)
		 return true
	end,
	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v3 then
			local vsize = self.object:get_properties().visual_size
			self.v3 = 0
			self.max_speed_forward = 4
			self.max_speed_reverse = 2
			self.accel = 4
			self.terrain_type = 3
			self.driver_attach_at = {x = 0.0, y = 6.5, z = -3.75}
			self.driver_eye_offset = {x = 0, y = 3, z = 0}
			self.driver_scale = {x = 1/vsize.x, y = 1/vsize.y}
			self.base_texture = self.texture_list[1]
			self.object:set_properties({textures = self.base_texture})
		end

		-- if driver present allow control of horse
<<<<<<< HEAD
		if self.driver and self.driver:get_wielded_item():get_name() == "vlc_mobitems:carrot_on_a_stick" then

			vlc_mobs.drive(self, "walk", "stand", false, dtime)
=======
		if self.driver and self.driver:get_wielded_item():get_name() == "vlf_mobitems:carrot_on_a_stick" then

			vlf_mobs.drive(self, "walk", "stand", false, dtime)
>>>>>>> 3eb27be82 (change naming in mods)

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
		-- Feed pig
<<<<<<< HEAD
		if wielditem:get_name() ~= "vlc_mobitems:carrot_on_a_stick" then
			if self:feed_tame(clicker, 1, true, false) then return end
		end
		if vlc_mobs.protect(self, clicker) then return end
=======
		if wielditem:get_name() ~= "vlf_mobitems:carrot_on_a_stick" then
			if self:feed_tame(clicker, 1, true, false) then return end
		end
		if vlf_mobs.protect(self, clicker) then return end
>>>>>>> 3eb27be82 (change naming in mods)

		if self.child then
			return
		end

		-- Put saddle on pig
		local item = clicker:get_wielded_item()
<<<<<<< HEAD
		if item:get_name() == "vlc_mobitems:saddle" and self.saddle ~= "yes" then
=======
		if item:get_name() == "vlf_mobitems:saddle" and self.saddle ~= "yes" then
>>>>>>> 3eb27be82 (change naming in mods)
			self.base_texture = {
				"mobs_mc_pig.png", -- base
				"mobs_mc_pig_saddle.png", -- saddle
			}
			self.object:set_properties({
				textures = self.base_texture
			})
			self.saddle = "yes"
			self.tamed = true
			self.drops = {
<<<<<<< HEAD
				{name = "vlc_mobitems:porkchop",
				chance = 1,
				min = 1,
				max = 3,},
				{name = "vlc_mobitems:saddle",
=======
				{name = "vlf_mobitems:porkchop",
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
				local inv = clicker:get_inventory()
				local stack = inv:get_stack("main", clicker:get_wield_index())
				stack:take_item()
				inv:set_stack("main", clicker:get_wield_index(), stack)
			end
<<<<<<< HEAD
			minetest.sound_play({name = "vlc_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
=======
			minetest.sound_play({name = "vlf_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
>>>>>>> 3eb27be82 (change naming in mods)
			return
		end

			-- Should make pig go faster when right clicked with carrot on a stick.
			-- FIXME: needs work on the going faster part.
<<<<<<< HEAD
		--[[if self.driver and clicker == self.driver and self.driver:get_wielded_item():get_name() == "vlc_mobitems:carrot_on_a_stick" then
=======
		--[[if self.driver and clicker == self.driver and self.driver:get_wielded_item():get_name() == "vlf_mobitems:carrot_on_a_stick" then
>>>>>>> 3eb27be82 (change naming in mods)
			if not self.v3 then
				self.v3 = 0
				self.max_speed_forward = 100
				self.accel = 10
			end
			if not minetest.is_creative_enabled(clicker:get_player_name()) then

				local inv = self.driver:get_inventory()
				-- 26 uses
				if wielditem:get_wear() > 63000 then
					-- Break carrot on a stick
					local def = wielditem:get_definition()
					if def.sounds and def.sounds.breaks then
						minetest.sound_play(def.sounds.breaks, {pos = clicker:get_pos(), max_hear_distance = 8, gain = 0.5}, true)
					end
<<<<<<< HEAD
					wielditem = {name = "vlc_fishing:fishing_rod", count = 1}
=======
					wielditem = {name = "vlf_fishing:fishing_rod", count = 1}
>>>>>>> 3eb27be82 (change naming in mods)
				else
					wielditem:add_wear(2521)
				end
				inv:set_stack("main",self.driver:get_wield_index(), wielditem)
			end
		end]]

		-- Mount or detach player
<<<<<<< HEAD
		if self.driver and clicker == self.driver then -- and self.driver:get_wielded_item():get_name() ~= "vlc_mobitems:carrot_on_a_stick" then -- Note: This is for when the ability to make the pig go faster is implemented
			-- Detach if already attached
			vlc_mobs.detach(clicker, {x=1, y=0, z=0})
=======
		if self.driver and clicker == self.driver then -- and self.driver:get_wielded_item():get_name() ~= "vlf_mobitems:carrot_on_a_stick" then -- Note: This is for when the ability to make the pig go faster is implemented
			-- Detach if already attached
			vlf_mobs.detach(clicker, {x=1, y=0, z=0})
>>>>>>> 3eb27be82 (change naming in mods)
			return

		elseif not self.driver and self.saddle == "yes" then
			-- Ride pig if it has a saddle

<<<<<<< HEAD
			vlc_mobs.attach(self, clicker)
=======
			vlf_mobs.attach(self, clicker)
>>>>>>> 3eb27be82 (change naming in mods)
			return

		-- Capture pig
		elseif not self.driver and clicker:get_wielded_item():get_name() ~= "" then
<<<<<<< HEAD
			vlc_mobs.capture_mob(self, clicker, 0, 5, 60, false, nil)
=======
			vlf_mobs.capture_mob(self, clicker, 0, 5, 60, false, nil)
>>>>>>> 3eb27be82 (change naming in mods)
		end
	end,

	on_breed = function(parent1, parent2)
		local pos = parent1.object:get_pos()
<<<<<<< HEAD
		local child = vlc_mobs.spawn_child(pos, parent1.name)
=======
		local child = vlf_mobs.spawn_child(pos, parent1.name)
>>>>>>> 3eb27be82 (change naming in mods)
		if child then
			local ent_c = child:get_luaentity()
			ent_c.tamed = true
			ent_c.owner = parent1.owner
			return false
		end
	end,

	after_activate = function(self, staticdata, def, dtime)
		if self.saddle == "yes" then -- Make saddle load upon rejoin
			self.base_texture = {
				"mobs_mc_pig.png", -- base
				"mobs_mc_pig_saddle.png", -- saddle
			}
			self.object:set_properties({
				textures = self.base_texture
			})
		end
	end,
})

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:pig",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	min_height = mobs_mc.water_level + 3,
	biomes = {
		"flat",
		"MegaTaiga",
		"MegaSpruceTaiga",
		"ExtremeHills",
		"ExtremeHills_beach",
		"ExtremeHillsM",
		"ExtremeHills+",
		"StoneBeach",
		"Plains",
		"Plains_beach",
		"SunflowerPlains",
		"Taiga",
		"Taiga_beach",
		"Forest",
		"Forest_beach",
		"FlowerForest",
		"FlowerForest_beach",
		"BirchForest",
		"BirchForestM",
		"RoofedForest",
		"Savanna",
		"Savanna_beach",
		"SavannaM",
		"Jungle",
		"BambooJungle",
		"Jungle_shore",
		"JungleM",
		"JungleM_shore",
		"JungleEdge",
		"JungleEdgeM",
		"Swampland",
		"Swampland_shore"
	},
	chance = 100,
})

-- spawn eggs
<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:pig", S("Pig"), "#f0a5a2", "#db635f", 0)
=======
vlf_mobs.register_egg("mobs_mc:pig", S("Pig"), "#f0a5a2", "#db635f", 0)
>>>>>>> 3eb27be82 (change naming in mods)
