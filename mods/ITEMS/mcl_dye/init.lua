-- To make recipes that will work with any dye ever made by anybody, define
-- them based on groups.
-- You can select any group of groups, based on your need for amount of colors.
-- basecolor: 9, excolor: 17, unicolor: 89
--
-- Example of one shapeless recipe using a color group:
-- Note: As this uses basecolor_*, you'd need 9 of these.
-- minetest.register_craft({
--     type = "shapeless",
--     output = "<mod>:item_yellow",
--     recipe = {"<mod>:item_no_color", "group:basecolor_yellow"},
-- })

mcl_dye = {}

local S = minetest.get_translator(minetest.get_current_modname())

-- Other mods can use these for looping through available colors
mcl_dye.basecolors = {"white", "grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta"}
mcl_dye.excolors = {"white", "lightgrey", "grey", "darkgrey", "black", "red", "orange", "yellow", "lime", "green", "aqua", "cyan", "sky_blue", "blue", "violet", "magenta", "red_violet"}

-- Base color groups:
-- - basecolor_white
-- - basecolor_grey
-- - basecolor_black
-- - basecolor_red
-- - basecolor_yellow
-- - basecolor_green
-- - basecolor_cyan
-- - basecolor_blue
-- - basecolor_magenta

-- Extended color groups (* = equal to a base color):
-- * excolor_white
-- - excolor_lightgrey
-- * excolor_grey
-- - excolor_darkgrey
-- * excolor_black
-- * excolor_red
-- - excolor_orange
-- * excolor_yellow
-- - excolor_lime
-- * excolor_green
-- - excolor_aqua
-- * excolor_cyan
-- - excolor_sky_blue
-- * excolor_blue
-- - excolor_violet
-- * excolor_magenta
-- - excolor_red_violet

-- The whole unifieddyes palette as groups:
-- - unicolor_<excolor>
-- For the following, no white/grey/black is allowed:
-- - unicolor_medium_<excolor>
-- - unicolor_dark_<excolor>
-- - unicolor_light_<excolor>
-- - unicolor_<excolor>_s50
-- - unicolor_medium_<excolor>_s50
-- - unicolor_dark_<excolor>_s50

-- Local stuff
local dyelocal = {}

-- This collection of colors is partly a historic thing, partly something else.
dyelocal.dyes = {
	{"white", "mcl_dye_white",	    S("Bone Meal"),     {dye=1, craftitem=1, basecolor_white=1,   excolor_white=1,     unicolor_white=1}},
	{"grey", "dye_grey",      	    S("Light Grey Dye"),      {dye=1, craftitem=1, basecolor_grey=1,    excolor_grey=1,      unicolor_grey=1}},
	{"dark_grey", "dye_dark_grey", 	    S("Grey Dye"), {dye=1, craftitem=1, basecolor_grey=1,    excolor_darkgrey=1,  unicolor_darkgrey=1}},
	{"black", "mcl_dye_black",     	    S("Ink Sac"),     {dye=1, craftitem=1, basecolor_black=1,   excolor_black=1,     unicolor_black=1}},
	{"violet", "dye_violet",    	    S("Purple Dye"),    {dye=1, craftitem=1, basecolor_magenta=1, excolor_violet=1,    unicolor_violet=1}},
	{"blue", "mcl_dye_blue",      	    S("Lapis Lazuli"),      {dye=1, craftitem=1, basecolor_blue=1,    excolor_blue=1,      unicolor_blue=1}},
	{"lightblue", "mcl_dye_light_blue", S("Light Blue Dye"),      {dye=1, craftitem=1, basecolor_blue=1,    excolor_blue=1,   unicolor_light_blue=1}},
	{"cyan", "dye_cyan",      	    S("Cyan Dye"),      {dye=1, craftitem=1, basecolor_cyan=1,    excolor_cyan=1,      unicolor_cyan=1}},
	{"dark_green", "dye_dark_green",    S("Cactus Green"),{dye=1, craftitem=1, basecolor_green=1,   excolor_green=1,     unicolor_dark_green=1}},
	{"green", "mcl_dye_lime",           S("Lime Dye"),     {dye=1, craftitem=1, basecolor_green=1,   excolor_green=1,     unicolor_green=1}},
	{"yellow", "dye_yellow",            S("Dandelion Yellow"),    {dye=1, craftitem=1, basecolor_yellow=1,  excolor_yellow=1,    unicolor_yellow=1}},
	{"brown", "mcl_dye_brown",          S("Cocoa Beans"),     {dye=1, craftitem=1, basecolor_brown=1,  excolor_orange=1,    unicolor_dark_orange=1, compostability = 65}},
	{"orange", "dye_orange",            S("Orange Dye"),    {dye=1, craftitem=1, basecolor_orange=1,  excolor_orange=1,    unicolor_orange=1}},
	{"red", "dye_red",                  S("Rose Red"),       {dye=1, craftitem=1, basecolor_red=1,     excolor_red=1,       unicolor_red=1}},
	{"magenta", "dye_magenta",          S("Magenta Dye"),   {dye=1, craftitem=1, basecolor_magenta=1, excolor_red_violet=1,unicolor_red_violet=1}},
	{"pink", "dye_pink",                S("Pink Dye"),      {dye=1, craftitem=1, basecolor_red=1,     excolor_red=1,       unicolor_light_red=1}},
}

local mg_name = minetest.get_mapgen_setting("mg_name")

dyelocal.unicolor_to_dye_id = {}
for d=1, #dyelocal.dyes do
	for k, _ in pairs(dyelocal.dyes[d][4]) do
		if string.sub(k, 1, 9) == "unicolor_" then
			dyelocal.unicolor_to_dye_id[k] = dyelocal.dyes[d][1]
		end
	end
end

-- Takes an unicolor group name (e.g. “unicolor_white”) and returns a corresponding dye name (if it exists), nil otherwise.
function mcl_dye.unicolor_to_dye(unicolor_group)
	local color = dyelocal.unicolor_to_dye_id[unicolor_group]
	if color then
		return "mcl_dye:" .. color
	else
		return nil
	end
end

-- Define items
for _, row in ipairs(dyelocal.dyes) do
	local name = row[1]
	-- White and brown dyes are defined explicitly below
	if name ~= "white" and name ~= "brown" then
		local img = row[2]
		local description = row[3]
		local groups = row[4]
		local item_name = "mcl_dye:"..name
		local item_image = img..".png"
		minetest.register_craftitem(item_name, {
			inventory_image = item_image,
			description = description,
			_doc_items_longdesc = S("This item is a dye which is used for dyeing and crafting."),
			_doc_items_usagehelp = S("Rightclick on a sheep to dye its wool. Other things are dyed by crafting."),
			groups = groups,
			stack_max = 64,
		})
	end
end



mcl_dye.bone_meal_callbacks = {}

function mcl_dye.register_on_bone_meal_apply(func)
	table.insert(mcl_dye.bone_meal_callbacks, func)
end

local function apply_bone_meal(pointed_thing,user)
	-- Bone meal currently spawns all flowers found in the plains.
	local flowers_table_plains = {
		"mcl_flowers:dandelion",
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",

		"mcl_flowers:oxeye_daisy",
		"mcl_flowers:tulip_orange",
		"mcl_flowers:tulip_red",
		"mcl_flowers:tulip_white",
		"mcl_flowers:tulip_pink",
		"mcl_flowers:azure_bluet",
	}
	local flowers_table_simple = {
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",
	}
	local flowers_table_swampland = {
		"mcl_flowers:blue_orchid",
	}
	local flowers_table_flower_forest = {
		"mcl_flowers:dandelion",
		"mcl_flowers:poppy",
		"mcl_flowers:oxeye_daisy",
		"mcl_flowers:tulip_orange",
		"mcl_flowers:tulip_red",
		"mcl_flowers:tulip_white",
		"mcl_flowers:tulip_pink",
		"mcl_flowers:azure_bluet",
		"mcl_flowers:allium",
	}

	local pos = pointed_thing.under
	local n = minetest.get_node(pos)
	if n.name == "" then return false end

	for _, func in pairs(mcl_dye.bone_meal_callbacks) do
		if func(pointed_thing, user) then
			return true
		end
	end

	if minetest.get_item_group(n.name, "mushroom") == 1 then
		mcl_dye.add_bone_meal_particle(pos)
		-- Try to grow huge mushroom

		-- Must be on a dirt-type block
		local below = minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z})
		if below.name ~= "mcl_core:mycelium" and below.name ~= "mcl_core:dirt" and minetest.get_item_group(below.name, "grass_block") ~= 1 and below.name ~= "mcl_core:coarse_dirt" and below.name ~= "mcl_core:podzol" then
			return false
		end

		-- Select schematic
		local schematic, offset, height
		if n.name == "mcl_mushrooms:mushroom_brown" then
			schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts"
			offset = { x = -3, y = -1, z = -3 }
			height = 8
		elseif n.name == "mcl_mushrooms:mushroom_red" then
			schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_red.mts"
			offset = { x = -2, y = -1, z = -2 }
			height = 8
		else
			return false
		end
		-- 40% chance
		if math.random(1, 100) <= 40 then
			-- Check space requirements
			for i=1,3 do
				local cpos = vector.add(pos, {x=0, y=i, z=0})
				if minetest.get_node(cpos).name ~= "air" then
					return false
				end
			end
			local yoff = 3
			local minp, maxp = {x=pos.x-3, y=pos.y+yoff, z=pos.z-3}, {x=pos.x+3, y=pos.y+yoff+(height-3), z=pos.z+3}
			local diff = vector.subtract(maxp, minp)
			diff = vector.add(diff, {x=1,y=1,z=1})
			local totalnodes = diff.x * diff.y * diff.z
			local goodnodes = minetest.find_nodes_in_area(minp, maxp, {"air", "group:leaves"})
			if #goodnodes < totalnodes then
				return false
			end

			-- Place the huge mushroom
			minetest.remove_node(pos)
			local place_pos = vector.add(pos, offset)
			local ok = minetest.place_schematic(place_pos, schematic, 0, nil, false)
			return ok ~= nil
		end
		return false
	-- Wheat, Potato, Carrot, Pumpkin Stem, Melon Stem: Advance by 2-5 stages
	elseif string.find(n.name, "mcl_farming:wheat_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_wheat", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:potato_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_potato", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:carrot_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_carrot", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:pumpkin_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_pumpkin_stem", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:melontige_") then
		mcl_dye.add_bone_meal_particle(pos)
		local stages = math.random(2, 5)
		return mcl_farming:grow_plant("plant_melon_stem", pos, n, stages, true)
	elseif string.find(n.name, "mcl_farming:beetroot_") then
		mcl_dye.add_bone_meal_particle(pos)
		-- Beetroot: 75% chance to advance to next stage
		if math.random(1, 100) <= 75 then
			return mcl_farming:grow_plant("plant_beetroot", pos, n, 1, true)
		end
	elseif string.find(n.name, "mcl_farming:sweet_berry_bush_") then
		mcl_dye.add_bone_meal_particle(pos)
		if n.name == "mcl_farming:sweet_berry_bush_3" then
			return minetest.add_item(vector.offset(pos,math.random()-0.5,math.random()-0.5,math.random()-0.5),"mcl_farming:sweet_berry")
		else
			return mcl_farming:grow_plant("plant_sweet_berry_bush", pos, n, 1, true)
		end
	elseif n.name == "mcl_cocoas:cocoa_1" or n.name == "mcl_cocoas:cocoa_2" then
		mcl_dye.add_bone_meal_particle(pos)
		-- Cocoa: Advance by 1 stage
		mcl_cocoas.grow(pos)
		return true
	elseif minetest.get_item_group(n.name, "grass_block") == 1 then
		-- Grass Block: Generate tall grass and random flowers all over the place
		for i = -7, 7 do
			for j = -7, 7 do
				for y = -1, 1 do
					pos = vector.offset(pointed_thing.above, i, y, j)
					n = minetest.get_node(pos)
					local n2 = minetest.get_node(vector.offset(pos, 0, -1, 0))

					if n.name ~= "" and n.name == "air" and (minetest.get_item_group(n2.name, "grass_block_no_snow") == 1) then
						-- Randomly generate flowers, tall grass or nothing
						if math.random(1, 100) <= 90 / ((math.abs(i) + math.abs(j)) / 2)then
							-- 90% tall grass, 10% flower
							mcl_dye.add_bone_meal_particle(pos, {amount = 4})
							if math.random(1,100) <= 90 then
								local col = n2.param2
								minetest.add_node(pos, {name="mcl_flowers:tallgrass", param2=col})
							else
								local flowers_table
								local biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
								if biome == "Swampland" or biome == "Swampland_shore" or biome == "Swampland_ocean" or biome == "Swampland_deep_ocean" or biome == "Swampland_underground" then
									flowers_table = flowers_table_swampland
								elseif biome == "FlowerForest" or biome == "FlowerForest_beach" or biome == "FlowerForest_ocean" or biome == "FlowerForest_deep_ocean" or biome == "FlowerForest_underground" then
									flowers_table = flowers_table_flower_forest
								elseif biome == "Plains" or biome == "Plains_beach" or biome == "Plains_ocean" or biome == "Plains_deep_ocean" or biome == "Plains_underground" or biome == "SunflowerPlains" or biome == "SunflowerPlains_ocean" or biome == "SunflowerPlains_deep_ocean" or biome == "SunflowerPlains_underground" then
									flowers_table = flowers_table_plains
								else
									flowers_table = flowers_table_simple
								end
								minetest.add_node(pos, {name=flowers_table[math.random(1, #flowers_table)]})
							end
						end
					end
				end
			end
		end
		return true

	-- Double flowers: Drop corresponding item
	elseif n.name == "mcl_flowers:rose_bush" or n.name == "mcl_flowers:rose_bush_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:rose_bush")
		return true
	elseif n.name == "mcl_flowers:peony" or n.name == "mcl_flowers:peony_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:peony")
		return true
	elseif n.name == "mcl_flowers:lilac" or n.name == "mcl_flowers:lilac_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:lilac")
		return true
	elseif n.name == "mcl_flowers:sunflower" or n.name == "mcl_flowers:sunflower_top" then
		mcl_dye.add_bone_meal_particle(pos)
		minetest.add_item(pos, "mcl_flowers:sunflower")
		return true

	elseif n.name == "mcl_flowers:tallgrass" then
		mcl_dye.add_bone_meal_particle(pos)
		-- Tall Grass: Grow into double tallgrass
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_grass", param2 = n.param2 })
			minetest.set_node(toppos, { name = "mcl_flowers:double_grass_top", param2 = n.param2 })
			return true
		end

	elseif n.name == "mcl_flowers:fern" then
		mcl_dye.add_bone_meal_particle(pos)
		-- Fern: Grow into large fern
		local toppos = { x=pos.x, y=pos.y+1, z=pos.z }
		local topnode = minetest.get_node(toppos)
		if minetest.registered_nodes[topnode.name].buildable_to then
			minetest.set_node(pos, { name = "mcl_flowers:double_fern", param2 = n.param2 })
			minetest.set_node(toppos, { name = "mcl_flowers:double_fern_top", param2 = n.param2 })
			return true
		end
	end

	return false
end

mcl_dye.apply_bone_meal = apply_bone_meal

minetest.register_craftitem("mcl_dye:brown", {
	inventory_image = "mcl_dye_brown.png",
	_tt_help = S("Grows at the side of jungle trees"),
	_doc_items_longdesc = S("Cocoa beans are a brown dye and can be used to plant cocoas."),
	_doc_items_usagehelp = S("Rightclick a sheep to turn its wool brown. Rightclick on the side of a jungle tree trunk (Jungle Wood) to plant a young cocoa."),
	description = S("Cocoa Beans"),
	stack_max = 64,
	groups = dyelocal.dyes[12][4],
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_cocoas.place(itemstack, placer, pointed_thing, "mcl_cocoas:cocoa_1")
	end,
})

-- Dye mixing
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:dark_grey 2",
	recipe = {"mcl_dye:black", "mcl_dye:white"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:lightblue 2",
	recipe = {"mcl_dye:blue", "mcl_dye:white"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:grey 3",
	recipe = {"mcl_dye:black", "mcl_dye:white", "mcl_dye:white"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:grey 2",
	recipe = {"mcl_dye:dark_grey", "mcl_dye:white"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:green 2",
	recipe = {"mcl_dye:dark_green", "mcl_dye:white"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 4",
	recipe = {"mcl_dye:blue", "mcl_dye:white", "mcl_dye:red", "mcl_dye:red"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 3",
	recipe = {"mcl_dye:pink", "mcl_dye:red", "mcl_dye:blue"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:magenta 2",
	recipe = {"mcl_dye:violet", "mcl_dye:pink"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:pink 2",
	recipe = {"mcl_dye:red", "mcl_dye:white"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:cyan 2",
	recipe = {"mcl_dye:blue", "mcl_dye:dark_green"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:violet 2",
	recipe = {"mcl_dye:blue", "mcl_dye:red"},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_dye:orange 2",
	recipe = {"mcl_dye:yellow", "mcl_dye:red"},
})

-- Dye creation
minetest.register_craft({
	output = "mcl_dye:yellow",
	recipe = {{"mcl_flowers:dandelion"}},
})
minetest.register_craft({
	output = "mcl_dye:yellow 2",
	recipe = {{"mcl_flowers:sunflower"}},
})
minetest.register_craft({
	output = "mcl_dye:blue",
	recipe = {{"mcl_flowers:cornflower"}},
})

minetest.register_craft({
	output = "mcl_dye:lightblue",
	recipe = {{"mcl_flowers:blue_orchid"}},
})
minetest.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:azure_bluet"}},
})
minetest.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:oxeye_daisy"}},
})
minetest.register_craft({
	output = "mcl_dye:grey",
	recipe = {{"mcl_flowers:tulip_white"}},
})
minetest.register_craft({
	output = "mcl_dye:magenta",
	recipe = {{"mcl_flowers:allium"}},
})
minetest.register_craft({
	output = "mcl_dye:magenta 2",
	recipe = {{"mcl_flowers:lilac"}},
})
minetest.register_craft({
	output = "mcl_dye:orange",
	recipe = {{"mcl_flowers:tulip_orange"}},
})
minetest.register_craft({
	output = "mcl_dye:pink",
	recipe = {{"mcl_flowers:tulip_pink"}},
})
minetest.register_craft({
	output = "mcl_dye:pink 2",
	recipe = {{"mcl_flowers:peony"}},
})
minetest.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_farming:beetroot_item"}},
})
minetest.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_flowers:poppy"}},
})
minetest.register_craft({
	output = "mcl_dye:red",
	recipe = {{"mcl_flowers:tulip_red"}},
})
minetest.register_craft({
	output = "mcl_dye:red 2",
	recipe = {{"mcl_flowers:rose_bush"}},
})
minetest.register_craft({
	output = "mcl_dye:white",
	recipe = {{"mcl_flowers:lily_of_the_valley"}},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dye:dark_green",
	recipe = "mcl_core:cactus",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_dye:green",
	recipe = "group:sea_pickle",
	cooktime = 10,
})

minetest.register_craft({
	output = "mcl_dye:white 3",
	recipe = {{"mcl_mobitems:bone"}},
})
