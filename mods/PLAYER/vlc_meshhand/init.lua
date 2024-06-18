local vlc_skins_enabled = minetest.global_exists("vlc_skins")
vlc_meshhand = { }

-- This is a fake node that should never be placed in the world
local node_def = {
	description = "",
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "opaque" or false,
	visual_scale = 1,
	wield_scale = {x=1,y=1,z=1},
	paramtype = "light",
	drawtype = "mesh",
	node_placement_prediction = "",
	on_construct = function(pos)
		local name = minetest.get_node(pos).name
		local message = "[vlc_meshhand] Trying to construct " .. name .. " at " .. minetest.pos_to_string(pos)
		minetest.log("error", message)
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function(_, _, _) return ItemStack() end,
	groups = {
		dig_immediate = 3,
		not_in_creative_inventory = 1,
		dig_speed_class = 1,
	},
	tool_capabilities = {
		full_punch_interval = 0.25,
		max_drop_level = 0,
		groupcaps = { },
		damage_groups = { fleshy = 1 },
	},
	_vlc_diggroups = {
		handy = { speed = 1, level = 1, uses = 0 },
		axey = { speed = 1, level = 1, uses = 0 },
		shovely = { speed = 1, level = 1, uses = 0 },
		hoey = { speed = 1, level = 1, uses = 0 },
		pickaxey = { speed = 1, level = 0, uses = 0 },
		swordy = { speed = 1, level = 0, uses = 0 },
		swordy_cobweb = { speed = 1, level = 0, uses = 0 },
		shearsy = { speed = 1, level = 0, uses = 0 },
		shearsy_wool = { speed = 1, level = 0, uses = 0 },
		shearsy_cobweb = { speed = 1, level = 0, uses = 0 },
	},
	range = tonumber(minetest.settings:get("vlc_hand_range")) or 4.5
}

-- This is for _vlc_autogroup to know about the survival hand tool capabilites
vlc_meshhand.survival_hand_tool_caps = node_def.tool_capabilities

local creative_hand_range = tonumber(minetest.settings:get("vlc_hand_range_creative")) or 10
if vlc_skins_enabled then
	-- Generate a node for every skin
	local list = vlc_skins.get_skin_list()
	for _, skin in pairs(list) do
		if skin.slim_arms then
			local female = table.copy(node_def)
			female._vlc_hand_id = skin.id
			female.mesh = "vlc_meshhand_female.b3d"
			female.tiles = {skin.texture}
			minetest.register_node("vlc_meshhand:" .. skin.id, female)
		else
			local male = table.copy(node_def)
			male._vlc_hand_id = skin.id
			male.mesh = "vlc_meshhand.b3d"
			male.tiles = {skin.texture}
			minetest.register_node("vlc_meshhand:" .. skin.id, male)
		end

		local node_def = table.copy(node_def)
		node_def._vlc_hand_id = skin.id
		node_def.tiles = { skin.texture }
		node_def.mesh = skin.slim_arms and "vlc_meshhand_female.b3d" or "vlc_meshhand.b3d"
		if skin.creative then
			node_def.range = creative_hand_range
			node_def.groups.dig_speed_class = 7
			node_def.tool_capabilities.groupcaps.creative_breakable = { times = { 0 }, uses = 0 }
		end
		minetest.register_node("vlc_meshhand:" .. skin.id, node_def)
	end
else
	node_def._vlc_hand_id = "hand"
	node_def.mesh = "vlc_meshhand.b3d"
	node_def.tiles = { "character.png" }
	minetest.register_node("vlc_meshhand:hand_surv", node_def)

	node_def = table.copy(node_def)
	node_def.range = creative_hand_range
	node_def.groups.dig_speed_class = 7
	node_def.tool_capabilities.groupcaps.creative_breakable = { times = { 0 }, uses = 0 }
	minetest.register_node("vlc_meshhand:hand_crea", node_def)
end

function vlc_meshhand.update_player(player)
	if vlc_skins_enabled then
		local node_id = vlc_skins.get_node_id_by_player(player)
		player:get_inventory():set_stack("hand", 1, "vlc_meshhand:" .. node_id)
	else
		local creative = minetest.is_creative_enabled(player:get_player_name())
		player:get_inventory():set_stack("hand", 1, "vlc_meshhand:hand" .. (creative and "_crea" or "_surv"))
	end
end

if vlc_skins_enabled then
	vlc_player.register_on_visual_change(vlc_meshhand.update_player)
else
	minetest.register_on_joinplayer(vlc_meshhand.update_player)
end

vlc_gamemode.register_on_gamemode_change(vlc_meshhand.update_player)

-- This is needed to deal damage when punching mobs
-- with random items in hand in survival mode
minetest.override_item("", {
	tool_capabilities = vlc_meshhand.survival_hand_tool_caps
})
