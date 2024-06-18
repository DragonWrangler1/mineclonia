local S = minetest.get_translator("mobs_mc")
local zombiefication_delay = 15

local trading_items = {
<<<<<<< HEAD
	{ itemstring = "vlc_core:obsidian", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlc_core:gravel", weight = 40, amount_min = 8, amount_max = 16 },
	{ itemstring = "vlc_mobitems:leather", weight = 40, amount_min = 4, amount_max = 10 },
	{ itemstring = "vlc_nether:soul_sand", weight = 40, amount_min = 4, amount_max = 16 },
	{ itemstring = "vlc_nether:nether_brick", weight = 40, amount_min = 4, amount_max = 16 },
	{ itemstring = "vlc_mobitems:string", weight = 20, amount_min = 3, amount_max = 9 },
	{ itemstring = "vlc_nether:quartz", weight = 20, amount_min = 4, amount_max = 10 },
	{ itemstring = "vlc_potions:water", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlc_core:iron_nugget", weight = 10, amount_min = 10, amount_max = 36 },
	{ itemstring = "vlc_throwing:ender_pearl", weight = 10, amount_min = 2, amount_max = 6 },
	{ itemstring = "vlc_potions:fire_resistance", weight = 8, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlc_potions:fire_resistance_splash", weight = 8, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlc_books:book", weight = 5, func = function(stack, pr) vlc_enchanting.enchant(stack, "soul_speed", vlc_enchanting.random(pr, 1, vlc_enchanting.enchantments["soul_speed"].max_level)) end },
	{ itemstring = "vlc_armor:boots_iron", weight = 8, func = function(stack, pr) vlc_enchanting.enchant(stack, "soul_speed", vlc_enchanting.random(pr, 1, vlc_enchanting.enchantments["soul_speed"].max_level)) end },
	{ itemstring = "vlc_blackstone:blackstone", weight = 40, amount_min = 8, amount_max = 16 },
	{ itemstring = "vlc_bows:arrow", weight = 40, amount_min = 6, amount_max = 12 },
	{ itemstring = "vlc_core:crying_obsidian", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlc_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
=======
	{ itemstring = "vlf_core:obsidian", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_core:gravel", weight = 40, amount_min = 8, amount_max = 16 },
	{ itemstring = "vlf_mobitems:leather", weight = 40, amount_min = 4, amount_max = 10 },
	{ itemstring = "vlf_nether:soul_sand", weight = 40, amount_min = 4, amount_max = 16 },
	{ itemstring = "vlf_nether:nether_brick", weight = 40, amount_min = 4, amount_max = 16 },
	{ itemstring = "vlf_mobitems:string", weight = 20, amount_min = 3, amount_max = 9 },
	{ itemstring = "vlf_nether:quartz", weight = 20, amount_min = 4, amount_max = 10 },
	{ itemstring = "vlf_potions:water", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_core:iron_nugget", weight = 10, amount_min = 10, amount_max = 36 },
	{ itemstring = "vlf_throwing:ender_pearl", weight = 10, amount_min = 2, amount_max = 6 },
	{ itemstring = "vlf_potions:fire_resistance", weight = 8, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_potions:fire_resistance_splash", weight = 8, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_books:book", weight = 5, func = function(stack, pr) vlf_enchanting.enchant(stack, "soul_speed", vlf_enchanting.random(pr, 1, vlf_enchanting.enchantments["soul_speed"].max_level)) end },
	{ itemstring = "vlf_armor:boots_iron", weight = 8, func = function(stack, pr) vlf_enchanting.enchant(stack, "soul_speed", vlf_enchanting.random(pr, 1, vlf_enchanting.enchantments["soul_speed"].max_level)) end },
	{ itemstring = "vlf_blackstone:blackstone", weight = 40, amount_min = 8, amount_max = 16 },
	{ itemstring = "vlf_bows:arrow", weight = 40, amount_min = 6, amount_max = 12 },
	{ itemstring = "vlf_core:crying_obsidian", weight = 40, amount_min = 1, amount_max = 1 },
	{ itemstring = "vlf_fire:fire_charge", weight = 40, amount_min = 1, amount_max = 1 },
>>>>>>> 3eb27be82 (change naming in mods)
	--{ itemstring = "FIXME:spectral_arrow", weight = 40, amount_min = 6, amount_max = 12 },
}

function mobs_mc.player_wears_gold(player)
	for i=1, 6 do
		local stack = player:get_inventory():get_stack("armor", i)
		local item = stack:get_name()
		if minetest.get_item_group(item, "golden") ~= 0 then
			return true
		end
	end
end

local function check_light(pos, environmental_light, artificial_light, sky_light)
	if artificial_light > 11 then
		return false, "To bright"
	end
	return true, ""
end

local piglin = {
	description = S("Piglin"),
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	persist_in_peaceful = true,
	hp_min = 16,
	hp_max = 16,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	damage = 4,
	reach = 3,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "extra_mobs_piglin.b3d",
	spawn_in_group = 4,
	spawn_in_group_min = 2,
	textures = { {
		"extra_mobs_piglin.png",
<<<<<<< HEAD
		"vlc_bows_bow_2.png",
=======
		"vlf_bows_bow_2.png",
>>>>>>> 3eb27be82 (change naming in mods)
	} },
	visual_size = {x=1, y=1},
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",
		damage = "mobs_mc_zombiepig_hurt",
		death = "mobs_mc_zombiepig_death",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 1.4, -- (was 2.8) hes fast and has bow, but slower compare to hoglin
	drops = {
<<<<<<< HEAD
		{name = "vlc_bows:crossbow",
=======
		{name = "vlf_bows:crossbow",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 10,
		min = 1,
		max = 1,},
	},
	animation = {
		stand_speed = 30,
		walk_speed = 30,
		run_speed = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 440,
		run_end = 459,
	},
	fear_height = 4,
	view_range = 16,
<<<<<<< HEAD
	pick_up = {"vlc_core:gold_ingot"},
=======
	pick_up = {"vlf_core:gold_ingot"},
>>>>>>> 3eb27be82 (change naming in mods)
	on_spawn = function(self)
		self.weapon = self.base_texture[2]
		self.gold_items = 0
		self._attacked_by_player = false
	end,
	do_custom = function(self, dtime)
<<<<<<< HEAD
		if vlc_worlds.pos_to_dimension(self.object:get_pos()) == "overworld" then
			self._zombie_timer = (self._zombie_timer or zombiefication_delay) - dtime
			if self._zombie_timer < 0 then
				vlc_util.replace_mob(self.object, "mobs_mc:zombified_piglin")
=======
		if vlf_worlds.pos_to_dimension(self.object:get_pos()) == "overworld" then
			self._zombie_timer = (self._zombie_timer or zombiefication_delay) - dtime
			if self._zombie_timer < 0 then
				vlf_util.replace_mob(self.object, "mobs_mc:zombified_piglin")
>>>>>>> 3eb27be82 (change naming in mods)
				return
			end
		elseif self.trading then
			self:set_state("stand")
<<<<<<< HEAD
			vlc_util.set_bone_position(self.object, "Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(20,-20,18))
			vlc_util.set_bone_position(self.object, "Head", vector.new(0,6.3,0), vector.new(-40,0,0))
			self.base_texture[2] = "default_gold_ingot.png"
			vlc_util.set_properties(self.object, {textures = self.base_texture})
		else
			vlc_util.set_bone_position(self.object, "Wield_Item", vector.new(.5,4.5,-1.6), vector.new(90,0,20))
			vlc_util.set_bone_position(self.object, "Head", vector.new(0,6.3,0), vector.new(0,0,0))
			vlc_util.set_bone_position(self.object, "Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(0,0,0))
			self.base_texture[2] = self.weapon
			vlc_util.set_properties(self.object, {textures = self.base_texture})
=======
			vlf_util.set_bone_position(self.object, "Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(20,-20,18))
			vlf_util.set_bone_position(self.object, "Head", vector.new(0,6.3,0), vector.new(-40,0,0))
			self.base_texture[2] = "default_gold_ingot.png"
			vlf_util.set_properties(self.object, {textures = self.base_texture})
		else
			vlf_util.set_bone_position(self.object, "Wield_Item", vector.new(.5,4.5,-1.6), vector.new(90,0,20))
			vlf_util.set_bone_position(self.object, "Head", vector.new(0,6.3,0), vector.new(0,0,0))
			vlf_util.set_bone_position(self.object, "Arm_Right_Pitch_Control", vector.new(-3,5.785,0), vector.new(0,0,0))
			self.base_texture[2] = self.weapon
			vlf_util.set_properties(self.object, {textures = self.base_texture})
>>>>>>> 3eb27be82 (change naming in mods)
			self._zombie_timer = nil
		end

		if self.attack and self.attack:is_player() and mobs_mc.player_wears_gold(self.attack) then
			if not self._attacked_by_player then
				self:set_state("stand")
			end
		end
	end,
	on_pick_up  = function(self, itementity)
		local it = ItemStack(itementity.itemstring)
		local item = it:get_name()
<<<<<<< HEAD
		if item == "vlc_core:gold_ingot" and self.state ~= "attack" and self.gold_items and self.gold_items < 3 then
=======
		if item == "vlf_core:gold_ingot" and self.state ~= "attack" and self.gold_items and self.gold_items < 3 then
>>>>>>> 3eb27be82 (change naming in mods)
			it:take_item(1)
			self.object:set_animation({x=0,y=79})
			self.trading = true
			self.gold_items = self.gold_items + 1
<<<<<<< HEAD
			vlc_util.set_bone_position(self.object, "Wield_Item", vector.new(-1.5,4.9,1.8), vector.new(135,0,90))
=======
			vlf_util.set_bone_position(self.object, "Wield_Item", vector.new(-1.5,4.9,1.8), vector.new(135,0,90))
>>>>>>> 3eb27be82 (change naming in mods)
			for _,v in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 7)) do
				if v:is_player() then self:look_at(v:get_pos()) end
			end
			self:set_state("stand")
			minetest.after(5, function(self)
				local pos
				if self then
					self.gold_items = self.gold_items - 1
					if self.gold_items == 0 then
						self.trading = false
						self:set_state("stand")
					end
					pos = self and self.object and self.object:get_pos()
				end
				if pos then
<<<<<<< HEAD
					local its = vlc_loot.get_loot({ stacks_min = 1, stacks_max = 1,items = trading_items }, PseudoRandom(minetest.get_gametime()))
					if its and #its > 0 then
						vlc_util.drop_item_stack(pos, its[1])
=======
					local its = vlf_loot.get_loot({ stacks_min = 1, stacks_max = 1,items = trading_items }, PseudoRandom(minetest.get_gametime()))
					if its and #its > 0 then
						vlf_util.drop_item_stack(pos, its[1])
>>>>>>> 3eb27be82 (change naming in mods)
					end
				end
			end, self)
		end
		return it
	end,
	do_punch = function(self, hitter)
		if hitter:is_player() then
			self._attacked_by_player = true
		end
	end,
	attack_type = "dogshoot",
<<<<<<< HEAD
	arrow = "vlc_bows:arrow_entity",
=======
	arrow = "vlf_bows:arrow_entity",
>>>>>>> 3eb27be82 (change naming in mods)
	shoot_arrow = function(self, pos, dir)
		if self.attack then
			self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
		end
		-- 2-4 damage per arrow
		local dmg = math.max(4, math.random(2, 8))
<<<<<<< HEAD
		vlc_bows.shoot_arrow("vlc_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
=======
		vlf_bows.shoot_arrow("vlf_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
>>>>>>> 3eb27be82 (change naming in mods)
	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = { "player", "mobs_mc:hoglin" },
	check_light = check_light,
}

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:piglin", piglin)

vlc_mobs.register_mob("mobs_mc:sword_piglin",table.merge(piglin,{
=======
vlf_mobs.register_mob("mobs_mc:piglin", piglin)

vlf_mobs.register_mob("mobs_mc:sword_piglin",table.merge(piglin,{
>>>>>>> 3eb27be82 (change naming in mods)
	mesh = "extra_mobs_sword_piglin.b3d",
	textures = {"extra_mobs_piglin.png", "default_tool_goldsword.png"},
	on_spawn = function(self)
		self.gold_items = 0
		self.weapon = self.base_texture[2]
<<<<<<< HEAD
		vlc_util.set_bone_position(self.object, "Wield_Item", vector.new(0,3.9,1.3), vector.new(90,0,0))
	end,
	drops = {
		{name = "vlc_tools:sword_gold",
=======
		vlf_util.set_bone_position(self.object, "Wield_Item", vector.new(0,3.9,1.3), vector.new(90,0,0))
	end,
	drops = {
		{name = "vlf_tools:sword_gold",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 10,
		min = 1,
		max = 1,},
	},
	attack_type = "dogfight",
	animation = {
		stand_speed = 30,
		walk_speed = 30,
		punch_speed = 45,
		run_speed = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 440,
		run_end = 459,
		punch_start = 189,
		punch_end = 198,
	},
}))

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:zombified_piglin",table.merge(piglin,{
=======
vlf_mobs.register_mob("mobs_mc:zombified_piglin",table.merge(piglin,{
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Zombiefied Piglin"),
	-- type="animal", passive=false: This combination is needed for a neutral mob which becomes hostile, if attacked
	type = "animal",
	passive = false,
	spawn_class = "passive",
	do_custom = function() end,
	on_spawn = function() end,
	on_rightclick = function() end,
	attack_animals = true,
	prevents_sleep_when_hostile = true,
	mesh = "extra_mobs_sword_piglin.b3d",
	textures = {"extra_mobs_zombified_piglin.png", "default_tool_goldsword.png", "blank.png"},
	attack_type = "dogfight",
	animation = {
		stand_speed = 30,
		walk_speed = 30,
		punch_speed = 45,
		run_speed = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 440,
		run_end = 459,
		punch_start = 189,
		punch_end = 198,
	},
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	armor = {undead = 90, fleshy = 90},
	group_attack = { "mobs_mc:zombified_piglin" },
	damage = 9,
	reach = 2,
	head_swivel = "head.control",
	bone_eye_height = 2.4,
	head_eye_height = 1.4,
	curiosity = 15,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = .8,
	run_velocity = 2.6,
	pathfinding = 1,
	lava_damage = 0,
	fire_damage = 0,
	fear_height = 4,
	view_range = 16,
	harmed_by_heal = true,
	fire_damage_resistant = true,
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",
		death = "mobs_mc_zombiepig_death",
		damage = "mobs_mc_zombiepig_hurt",
		distance = 16,
	},
}))

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:piglin_brute",table.merge(piglin,{
=======
vlf_mobs.register_mob("mobs_mc:piglin_brute",table.merge(piglin,{
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Piglin Brute"),
	persist_in_peaceful = false,
	xp_min = 20,
	xp_max = 20,
	hp_min = 50,
	hp_max = 50,
	fire_resistant = 1,
	do_custom = function() end,
	on_spawn = function() end,
	on_rightclick = function() end,
	attacks_monsters = true,
	lava_damage = 0,
	fire_damage = 0,
	attack_animals = true,
	mesh = "extra_mobs_sword_piglin.b3d",
	textures = { "extra_mobs_piglin_brute.png", "default_tool_goldaxe.png", "blank.png" },
	attack_type = "dogfight",
	animation = {
		stand_speed = 30,
		walk_speed = 30,
		punch_speed = 45,
		run_speed = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 440,
		run_end = 459,
		punch_start = 189,
		punch_end = 198,
	},
	can_despawn = false,
	group_attack = { "mobs_mc:piglin", "mobs_mc:sword_piglin", "mobs_mc:piglin_brute" },
	drops = {
<<<<<<< HEAD
		{name = "vlc_tools:axe_gold",
=======
		{name = "vlf_tools:axe_gold",
>>>>>>> 3eb27be82 (change naming in mods)
		chance = 8.5,
		min = 1,
		max = 1,},
	}
}))

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:piglin",
	type_of_spawning = "ground",
	dimension = "nether",
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
<<<<<<< HEAD
	min_height = vlc_vars.mg_lava_nether_max,
=======
	min_height = vlf_vars.mg_lava_nether_max,
>>>>>>> 3eb27be82 (change naming in mods)
	aoc = 3,
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	chance = 150,
})

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:sword_piglin",
	type_of_spawning = "ground",
	dimension = "nether",
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
<<<<<<< HEAD
	min_height = vlc_vars.mg_lava_nether_max,
=======
	min_height = vlf_vars.mg_lava_nether_max,
>>>>>>> 3eb27be82 (change naming in mods)
	aoc = 3,
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	chance = 150,
})

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:zombified_piglin",
	type_of_spawning = "lava",
	dimension = "nether",
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
<<<<<<< HEAD
	min_height = vlc_vars.mg_lava_nether_max,
=======
	min_height = vlf_vars.mg_lava_nether_max,
>>>>>>> 3eb27be82 (change naming in mods)
	aoc = 4,
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	chance = 1000,
})

<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:piglin", S("Piglin"), "#7b4a17","#d5c381", 0)
vlc_mobs.register_egg("mobs_mc:piglin_brute", S("Piglin Brute"), "#562b0c","#ddc89d", 0)
vlc_mobs.register_egg("mobs_mc:zombified_piglin", S("Zombie Piglin"), "#ea9393", "#4c7129", 0)
=======
vlf_mobs.register_egg("mobs_mc:piglin", S("Piglin"), "#7b4a17","#d5c381", 0)
vlf_mobs.register_egg("mobs_mc:piglin_brute", S("Piglin Brute"), "#562b0c","#ddc89d", 0)
vlf_mobs.register_egg("mobs_mc:zombified_piglin", S("Zombie Piglin"), "#ea9393", "#4c7129", 0)
>>>>>>> 3eb27be82 (change naming in mods)
