minetest.register_craft({
	type = "shapeless",
	output = "vlc_fireworks:rocket_1 3",
	recipe = {"vlc_core:paper", "vlc_mobitems:gunpowder"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_fireworks:rocket_2 3",
	recipe = {"vlc_core:paper", "vlc_mobitems:gunpowder", "vlc_mobitems:gunpowder"},
})

minetest.register_craft({
	type = "shapeless",
	output = "vlc_fireworks:rocket_3 3",
	recipe = {"vlc_core:paper", "vlc_mobitems:gunpowder", "vlc_mobitems:gunpowder", "vlc_mobitems:gunpowder"},
})