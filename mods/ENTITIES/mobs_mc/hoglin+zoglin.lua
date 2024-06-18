--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### hoglin
--###################

local hoglin = {
	description = S("Hoglin"),
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	persist_in_peaceful = true,
	hp_min = 40,
	hp_max = 40,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	dogfight_interval = 3,
	custom_attack_interval = 3,
	damage = 4,
	reach = 3,
	collisionbox = {-.6, -0.01, -.6, .6, 1.4, .6},
	visual = "mesh",
	mesh = "extra_mobs_hoglin.b3d",
	textures = { {
		"extra_mobs_hoglin.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 1.3, -- ( was 2.8 )  < 2.4 is slow and 2.6 < is fast
	retaliates = true,
	group_attack = true,
	avoid_from = {
<<<<<<< HEAD
		"vlc_crimson:warped_fungus",
		"vlc_flowerpots:flower_pot_warped_fungus",
		"vlc_portals:portal",
		"vlc_beds:respawn_anchor",
		"vlc_beds:respawn_anchor_charged_1",
		"vlc_beds:respawn_anchor_charged_2",
		"vlc_beds:respawn_anchor_charged_3",
		"vlc_beds:respawn_anchor_charged_4",
	},
	follow = {"vlc_crimson:crimson_fungus"},
=======
		"vlf_crimson:warped_fungus",
		"vlf_flowerpots:flower_pot_warped_fungus",
		"vlf_portals:portal",
		"vlf_beds:respawn_anchor",
		"vlf_beds:respawn_anchor_charged_1",
		"vlf_beds:respawn_anchor_charged_2",
		"vlf_beds:respawn_anchor_charged_3",
		"vlf_beds:respawn_anchor_charged_4",
	},
	follow = {"vlf_crimson:crimson_fungus"},
>>>>>>> 3eb27be82 (change naming in mods)
	drops = {
		{
			name = "mobs_mcitems:leather",
			chance = 1,
			min = 0,
			max = 1,
		},
		{
<<<<<<< HEAD
			name = "vlc_mobitems:porkchop",
=======
			name = "vlf_mobitems:porkchop",
>>>>>>> 3eb27be82 (change naming in mods)
			chance = 1,
			min = 2,
			max = 4,
		},
	},
	animation = {
		stand_speed = 7,
		walk_speed = 7,
		run_speed = 15,
		stand_start = 24,
		stand_end = 24,
		walk_start = 11,
		walk_end = 21,
		run_start = 1,
		run_end = 10,
		punch_start = 22,
		punch_end = 32,
	},
	fear_height = 4,
	view_range = 32,
	floats = 0,
	custom_attack = function(self)
		if self.state == "attack" and self.reach > vector.distance(self.object:get_pos(), self.attack:get_pos()) then
			self.attack:add_velocity({x=0,y=13,z=0})
<<<<<<< HEAD
			vlc_util.deal_damage(self.attack, self.damage, {type = "mob"})
		end
	end,
	do_custom = function(self)
		if vlc_worlds.pos_to_dimension(self.object:get_pos()) == "overworld" then
			vlc_util.replace_mob(self.object, "mobs_mc:zoglin")
=======
			vlf_util.deal_damage(self.attack, self.damage, {type = "mob"})
		end
	end,
	do_custom = function(self)
		if vlf_worlds.pos_to_dimension(self.object:get_pos()) == "overworld" then
			vlf_util.replace_mob(self.object, "mobs_mc:zoglin")
>>>>>>> 3eb27be82 (change naming in mods)
		end
	end,
	on_rightclick = function(self, clicker)
		if self:feed_tame(clicker, 1, true, false) then return end
	end,
	attack_animals = true,
}
<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:hoglin", hoglin)

vlc_mobs.register_mob("mobs_mc:zoglin",table.merge(hoglin,{
=======
vlf_mobs.register_mob("mobs_mc:hoglin", hoglin)

vlf_mobs.register_mob("mobs_mc:zoglin",table.merge(hoglin,{
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Zoglin"),
	fire_resistant = 1,
	textures = {"extra_mobs_zoglin.png"},
	do_custom = function() end,
	attacks_monsters = true,
	lava_damage = 0,
	fire_damage = 0,
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
}))

<<<<<<< HEAD
vlc_mobs.register_mob("mobs_mc:baby_hoglin",table.merge(hoglin,{
=======
vlf_mobs.register_mob("mobs_mc:baby_hoglin",table.merge(hoglin,{
>>>>>>> 3eb27be82 (change naming in mods)
	description = S("Baby Hoglin"),
	collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3},
	xp_min = 20,
	xp_max = 20,
	visual_size = {x=hoglin.visual_size.x/2, y=hoglin.visual_size.y/2},
	textures = { {
		"extra_mobs_hoglin.png",
		"blank.png",
	} },
	walk_velocity = 1.2,
	run_velocity = 1.6,
	child = 1,
}))

<<<<<<< HEAD
vlc_mobs.spawn_setup({
=======
vlf_mobs.spawn_setup({
>>>>>>> 3eb27be82 (change naming in mods)
	name = "mobs_mc:hoglin",
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
	chance = 200,
})

-- spawn eggs
<<<<<<< HEAD
vlc_mobs.register_egg("mobs_mc:hoglin", S("Hoglin"), "#85682e", "#2b2140", 0)
=======
vlf_mobs.register_egg("mobs_mc:hoglin", S("Hoglin"), "#85682e", "#2b2140", 0)
>>>>>>> 3eb27be82 (change naming in mods)
