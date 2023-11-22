--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

--###################
--################### VILLAGER
--###################
-- Summary: Villagers are complex NPCs, their main feature allows players to trade with them.

-- TODO: Particles
-- TODO: 4s Regeneration I after trade unlock
-- TODO: Behaviour:
-- TODO: Run into house on rain or danger, open doors
-- TODO: Internal inventory, trade with other villagers
-- TODO: Schedule stuff (work,sleep,father)
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local allow_nav_hacks = minetest.settings:get_bool("mcl_mob_allow_nav_hacks",false)
local work_dist = 4

local S = minetest.get_translator(modname)
local F = minetest.formspec_escape

-- playername-indexed table containing the previously used tradenum
local player_tradenum = {}
-- playername-indexed table containing the objectref of trader, if trading formspec is open
local player_trading_with = {}

local DEFAULT_WALK_CHANCE = 33 -- chance to walk in percent, if no player nearby
local PLAYER_SCAN_INTERVAL = 5 -- every X seconds, villager looks for players nearby
local PLAYER_SCAN_RADIUS = 4 -- scan radius for looking for nearby players

local RESETTLE_DISTANCE = 100 -- If a mob is transported this far from home, it gives up bed and job and resettles

local PATHFINDING = "gowp"

local COMPASS = "mcl_compass:compass"
if minetest.registered_aliases[COMPASS] then
	COMPASS = minetest.registered_aliases[COMPASS]
end

local tiernames = {
	S("Novice"),
	S("Apprentice"),
	S("Journeyman"),
	S("Expert"),
	S("Master")
}

local badges = {
	"mobs_mc_stone.png",
	"mobs_mc_iron.png",
	"mobs_mc_gold.png",
	"mobs_mc_emerald.png",
	"mobs_mc_diamond.png",
}

local WORK = "work"
local SLEEP = "sleep"
local HOME = "home"
local GATHERING = "gathering"

mobs_mc.jobsites = {}
mobs_mc.professions = {}

function mobs_mc.register_villager_profession(title, record)

	-- TODO should we allow overriding jobs?
	-- If so what needs to be considered?
	if mobs_mc.professions[title] then
		minetest.log("error", "This job already exists")
		return
	end

	mobs_mc.professions[title] = record

	if record.jobsite then
		table.insert(mobs_mc.jobsites, record.jobsite)
	end
end

for title, record in pairs(dofile(modpath.."/villagers/trades.lua")) do
	mobs_mc.register_villager_profession(title, record)
end

local function stand_still(self)
	self.walk_chance = 0
	self.jump = false
end

local function init_trader_vars(self)
	if not self._max_trade_tier then
		self._max_trade_tier = 1
	end
	if not self._locked_trades then
		self._locked_trades = 0
	end
	if not self._trading_players then
		self._trading_players = {}
	end
end

local function get_badge_textures(self)
	local t = mobs_mc.professions[self._profession].texture
	if self._profession == "unemployed"	then
		t = mobs_mc.professions[self._profession].textures -- ideally both scenarios should be textures with a list containing 1 or multiple
	end

	if self._profession == "unemployed" or self._profession == "nitwit" then return t end
	local tier = self._max_trade_tier or 1
	return {
		t .. "^" .. badges[tier]
	}
end

local function set_textures(self)
	local badge_textures = get_badge_textures(self)
	self.base_texture = badge_textures
	self.object:set_properties({textures=badge_textures})
end

local function should_sleep(self)
	local starts = 18000
	local ends = 6000

	if self._profession == "nitwit" then
		starts = 20000
		ends = 8000
	end

	local tod = minetest.get_timeofday()
	tod = (tod * 24000) % 24000
	return tod >= starts or tod < ends
end

local function should_go_home(self)
	local weather = mcl_weather.get_weather()

	if weather == "thunder" or weather == "rain" or weather == "snow" then
		return true
	end

	local starts = 17000
	local ends = 18000

	if self._profession == "nitwit" then
		starts = 19000
		ends = 20000
	end

	local tod = minetest.get_timeofday()
	tod = (tod * 24000) % 24000
	return tod >= starts and tod < ends
end

function get_activity(self, tod)
	if not tod then
		tod = minetest.get_timeofday()
	end
	tod = (tod * 24000) % 24000

	local work_start = 6000
	local lunch_start = 14000
	local lunch_end = 16000
	local work_end = 17000

	local activity
	if should_sleep(self) then
		activity = SLEEP
	elseif should_go_home(self) then
		activity = HOME
	elseif self._profession == "nitwit" then
		activity = "chill"
	elseif tod >= lunch_start and tod < lunch_end then
		activity = GATHERING
	elseif tod >= work_start and tod < work_end then
		activity = WORK
	else
		activity = "chill"
	end

	return activity
end

local function find_closest_bed(self)
	local p = self.object:get_pos()

	local unclaimed_beds = {}
	local nn2 = minetest.find_nodes_in_area(vector.offset(p,-48,-48,-48),vector.offset(p,48,48,48), {"group:bed"})
	if nn2 then
		for a,b in pairs(nn2) do
			local bed_node = minetest.get_node(b)
			local bed_name = bed_node.name
			local is_bed_bottom = string.find(bed_name,"_bottom")

			local bed_meta = minetest.get_meta(b)
			local owned_by = bed_meta:get_string("villager")

			-- TODO Why is it looking for a new bed if it has a bed and the bed is in the area?
			if (owned_by and owned_by == self._id) then
				bed_meta:set_string("villager", nil)
				bed_meta:set_string("infotext", nil)
				owned_by = nil
			end

			if is_bed_bottom then
				local bed_top_meta = minetest.get_meta(mcl_beds.get_bed_top (b))
				local owned_by_player = bed_top_meta:get_string("player")

				if owned_by == "" and (not owned_by_player or owned_by_player == "") then
					table.insert(unclaimed_beds, b)
				end
			end
		end
	end

	local distance_to_closest_block = nil
	local closest_block = nil

	if unclaimed_beds then
		for i,b in pairs(unclaimed_beds) do
			local distance_to_block = vector.distance(p, b)
			if not distance_to_closest_block or distance_to_closest_block > distance_to_block then
				closest_block = b
				distance_to_closest_block = distance_to_block
			end
		end
	end

	return closest_block
end

local function find_closest_unclaimed_block (p, requested_block_types)
	local nn = minetest.find_nodes_in_area(vector.offset(p,-48,-48,-48),vector.offset(p,48,48,48), requested_block_types)

	local distance_to_closest_block = nil
	local closest_block = nil

	for i,n in pairs(nn) do
		local m = minetest.get_meta(n)

		if m:get_string("villager") == "" then
			local distance_to_block = vector.distance(p, n)
			if not distance_to_closest_block or distance_to_closest_block > distance_to_block then
				closest_block = n
				distance_to_closest_block = distance_to_block
			end
		end
	end
	return closest_block
end

local function check_bed (entity)
	local b = entity._bed
	if not b then
		return false
	end

	local n = minetest.get_node(b)

	local is_bed_bottom = string.find(n.name,"_bottom")
	if n and not is_bed_bottom then
		entity._bed = nil --the stormtroopers have killed uncle owen
		return false
	else
		return true
	end
end

local function go_home(entity, sleep)

	local b = entity._bed
	if not b then
		return
	end

	local bed_node = minetest.get_node(b)
	if not bed_node then
		entity._bed = nil
		return
	end

	if vector.distance(entity.object:get_pos(),b) < 2 then
		if sleep then
			entity.order = SLEEP
		end
	else
		if sleep and entity.order == SLEEP then
			entity.order = nil
			return
		end

		entity:gopath(b,function(entity,b)
			local b = entity._bed

			if not b then
				return false
			end

			if not minetest.get_node(b) then
				return false
			end

			if vector.distance(entity.object:get_pos(),b) < 2 then
				return true
			end
		end, true)
	end
end



local function take_bed (entity)
	if not entity then return end

	local p = entity.object:get_pos()

	local closest_block = find_closest_bed(entity)

	if closest_block then
		local distance_to_block = vector.distance(p, closest_block)
		if distance_to_block < 2 then
			local m = minetest.get_meta(closest_block)
			local owner = m:get_string("villager")
			if owner and owner ~= "" and owner ~= entity._id then
				if entity.order == "stand" then entity.order = nil end
				return
			end

			if entity.order ~= SLEEP then
				entity.order = SLEEP
				m:set_string("villager", entity._id)
				m:set_string("infotext", S("A villager sleeps here"))
				entity._bed = closest_block
			end
		else
			entity:gopath(closest_block,function(self) end)
		end
	else
		if entity.order == "stand" then entity.order = nil end
	end
end

local function has_golem(pos)
	for _,o in pairs(minetest.get_objects_inside_radius(pos,16)) do
		local l = o:get_luaentity()
		if l and l.name == "mobs_mc:iron_golem" then return true end
	end
end

local function monsters_near(self)
	for _,o in pairs(minetest.get_objects_inside_radius(self.object:get_pos(),10)) do
		local l = o:get_luaentity()
		if l and l.type =="monster" then return true end
	end
end

local function has_summon_participants(self)
	local r = 0
	for _,o in pairs(minetest.get_objects_inside_radius(self.object:get_pos(),10)) do
		local l = o:get_luaentity()
		--TODO check for gossiping
		if l and l.name == "mobs_mc:villager" then r = r + 1 end
	end
	return r > 2
end

local below_vec = vector.new(0, -1, 0)

local function get_ground_below_floating_object (float_pos)
	local pos = float_pos
	repeat
		pos = vector.add(pos, below_vec)
		local node = minetest.get_node(pos)
	until node.name ~= "air"

	-- If pos is 1 below float_pos, then just return float_pos as there is no air below it
	if pos.y == float_pos.y - 1 then
		return float_pos
	end

	return pos
end

local function summon_golem(self)
	vector.offset(self.object:get_pos(),-10,-10,-10)
	local nn = minetest.find_nodes_in_area_under_air(vector.offset(self.object:get_pos(),-8,-6,-8),vector.offset(self.object:get_pos(),8,6,8),{"group:solid","group:water"})
	table.shuffle(nn)
	for _,n in pairs(nn) do
		local up = minetest.find_nodes_in_area(vector.offset(n,0,1,0),vector.offset(n,0,3,0),{"air"})
		if up and #up >= 3 then
			-- Set home for summoned golem
			local obj = minetest.add_entity(vector.offset(n,0,1,0),"mobs_mc:iron_golem")
			local ent = obj:get_luaentity()
			if ent then
				local bell = minetest.find_node_near(n, 48, {"mcl_bells:bell"})
				if not bell and self._bed then
					bell = minetest.find_node_near(self._bed, 48, {"mcl_bells:bell"})
				end

				if bell then
					ent._home = get_ground_below_floating_object(bell)
				else
					ent._home = n
				end

				return obj
			end
		end
	end
end

local function check_summon(self,dtime)
	-- TODO has selpt in last 20?
	if self._summon_timer and self._summon_timer > 30 then
		local pos = self.object:get_pos()
		self._summon_timer = 0
		if has_golem(pos) then return end
		if not monsters_near(self) then return end
		if not has_summon_participants(self) then return end
		summon_golem(self)
	elseif self._summon_timer == nil  then
		self._summon_timer = 0
	end
	self._summon_timer = self._summon_timer + dtime
end
--[[
local function debug_trades(self)
	if not self or not self._trades then return end
	local trades = minetest.deserialize(self._trades)
	if trades and type(trades) == "table" then
		for trader, trade in pairs(trades) do
			for tr3, tr4 in pairs (trade) do
				mcl_log("Key: ".. tostring(tr3))
				mcl_log("Value: ".. tostring(tr4))
			end
		end
	end
end
--]]
local function has_traded (self)
	if not self._trades then
		return false
	end
	local cur_trades_tab = minetest.deserialize(self._trades)
	if cur_trades_tab and type(cur_trades_tab) == "table" then
		for trader, trades in pairs(cur_trades_tab) do
			if trades.traded_once then
				return true
			end
		end
	end
	return false
end

local function unlock_trades (self)
	if not self._trades then
		return false
	end
	local has_unlocked = false

	local trades = minetest.deserialize(self._trades)
	if trades and type(trades) == "table" then
		for trader, trade in pairs(trades) do
			local trade_tier_too_high = trade.tier > self._max_trade_tier
			if not trade_tier_too_high then
				if trade["locked"] == true then
					trade.locked = false
					trade.trade_counter = 0
					has_unlocked = true
				end
			end
		end
		if has_unlocked then
			self._trades = minetest.serialize(trades)
		end
	end
end

----- JOBSITE LOGIC
local function get_profession_by_jobsite(js)
	for k,v in pairs(mobs_mc.professions) do
		if v.jobsite == js then
			return k
		-- Catch Nitwit doesn't have a jobsite
		elseif v.jobsite and v.jobsite:find("^group:") then
			local group = v.jobsite:gsub("^group:", "")
			if minetest.get_item_group(js, group) > 0 then
				return k
			end
		end
	end
end

local function employ(self,jobsite_pos)
	local n = minetest.get_node(jobsite_pos)
	local m = minetest.get_meta(jobsite_pos)
	local p = get_profession_by_jobsite(n.name)
	if p and m:get_string("villager") == "" then
		m:set_string("villager",self._id)
		m:set_string("infotext", S("A villager works here"))
		self._jobsite = jobsite_pos

		if not has_traded(self) then
			self._profession=p
			set_textures(self)
		end
		return true
	end
end


local function look_for_job(self, requested_jobsites)
	local p = self.object:get_pos()

	local closest_block = find_closest_unclaimed_block(p, requested_jobsites)

	if closest_block then
		local gp = self:gopath(closest_block,function(self)
			if self and self.state == "stand" then
				self.order = WORK
			end
		end)

		if gp then
			return closest_block
		end
	end

	return nil
end



local function get_a_job(self)
	if self.order == WORK then self.order = nil end

	local requested_jobsites = mobs_mc.jobsites
	if has_traded (self) then
		requested_jobsites = {mobs_mc.professions[self._profession].jobsite}
		-- Only pass in my jobsite to two functions here
	end

	local p = self.object:get_pos()
	local n = minetest.find_node_near(p,1,requested_jobsites)
	if n and employ(self,n) then return true end

	if self.state ~= PATHFINDING then
		look_for_job(self, requested_jobsites)
	end
end

local function retrieve_my_jobsite (self)
	if not self or not self._jobsite then
		return
	end
	local n = mcl_vars.get_node(self._jobsite)
	local m = minetest.get_meta(self._jobsite)
	if m:get_string("villager") == self._id then
		return n
	end
	return
end

local function remove_job (self)
	self._jobsite = nil
	if not has_traded(self) then
		self._profession = "unemployed"
		self._trades = nil
		set_textures(self)
	end
end

local function validate_jobsite(self)
	if self._profession == "unemployed" then return false end

	local job_block = retrieve_my_jobsite (self)
	if not job_block then
		if self.order == WORK then
			self.order = nil
		end

		remove_job (self)
		return false
	else
		local resettle = vector.distance(self.object:get_pos(),self._jobsite) > RESETTLE_DISTANCE
		if resettle then
			local m = minetest.get_meta(self._jobsite)
			m:set_string("villager", nil)
			m:set_string("infotext", nil)
			remove_job (self)
			return false
		end
		return true
	end
end

local function do_work (self)
	if self.child then
		return
	end

	-- Don't try if looking_for_work, or gowp possibly
	if validate_jobsite(self) then

		local jobsite2 = retrieve_my_jobsite (self)
		local jobsite = self._jobsite

		if self and jobsite2 and self._jobsite then
			local distance_to_jobsite = vector.distance(self.object:get_pos(),self._jobsite)

			if distance_to_jobsite < work_dist then
				if self.state ~= PATHFINDING and  self.order ~= WORK then
					self.order = WORK
					unlock_trades(self)
				end
			else
				if self.order == WORK then
					self.order = nil
					return
				end
				self:gopath(jobsite, function(self,jobsite)
					if not self then
						return false
					end
					if not self._jobsite then
						return false
					end
					if vector.distance(self.object:get_pos(),self._jobsite) < work_dist then
						return true
					end
				end)
			end
		end
	elseif self._profession == "unemployed" or has_traded(self) then
		get_a_job(self)
	end
end

local function teleport_to_town_bell(self)
	local looking_for_type = {}
	table.insert(looking_for_type, "mcl_bells:bell")

	local p = self.object:get_pos()
	local nn =
		minetest.find_nodes_in_area(vector.offset(p, -48, -48, -48), vector.offset(p, 48, 48, 48), looking_for_type)

	for _, n in pairs(nn) do
		local target_point = get_ground_below_floating_object(n)

		if target_point then
			self.object:set_pos(target_point)
			return
		end
	end
end

local function go_to_town_bell(self)
	if self.order == GATHERING then
		return
	end

	if not self:ready_to_path() then
		return
	end

	local looking_for_type={}
	table.insert(looking_for_type, "mcl_bells:bell")

	local p = self.object:get_pos()
	local nn = minetest.find_nodes_in_area(vector.offset(p,-48,-48,-48),vector.offset(p,48,48,48), looking_for_type)

	--Ideally should check for closest available. It'll make pathing easier.
	for _,n in pairs(nn) do
		local target_point = get_ground_below_floating_object(n)

		local gp = self:gopath(target_point,function(self)
			if self then
				self.order = GATHERING
			end
		end)

		if gp then
			return n
		end

	end

	return nil
end
--[[
local function validate_bed(self)
	if not self or not self._bed then
		return false
	end
	local n = mcl_vars.get_node(self._bed)
	if not n then
		self._bed = nil
		return false
	end

	local bed_valid = true

	local m = minetest.get_meta(self._bed)

	local resettle = vector.distance(self.object:get_pos(),self._bed) > RESETTLE_DISTANCE
	if resettle then
		m:set_string("villager", nil)
		self._bed = nil
		bed_valid = false
		return false
	end

	local owned_by_player = m:get_string("player")
	if owned_by_player ~= "" then
		m:set_string("villager", nil)
		self._bed = nil
		bed_valid = false
		return false
	end

	if m:get_string("villager") ~= self._id then
		self._bed = nil
		return false
	else
		return true
	end

end
--]]

local function sleep_over(self)
	local p = self.object:get_pos()
	local distance_to_closest_bed = 1000
	local closest_bed = nil
	local nn2 =
		minetest.find_nodes_in_area(vector.offset(p, -48, -48, -48), vector.offset(p, 48, 48, 48), { "group:bed" })

	if nn2 then
		for a, b in pairs(nn2) do
			local distance_to_bed = vector.distance(p, b)
			if distance_to_closest_bed > distance_to_bed then
				closest_bed = b
				distance_to_closest_bed = distance_to_bed
			end
		end
	end

	if closest_bed and distance_to_closest_bed >= 3 then
		self:gopath(closest_bed)
	end
end

local function do_activity(self)
	-- Maybe just check we're pathfinding first?
	if self.following then
		return
	end

	-- If no bed then it's the first thing to do, even at night
	if not check_bed(self) then
		take_bed(self)
	end

	if not should_sleep(self) then
		if self.order == SLEEP then
			self.order = nil
		end
	else
		if allow_nav_hacks then
			-- When a night is skipped telport villagers to their bed or bell
			if self.last_skip == nil then
				self.last_skip = 0
			end
			local last_skip = mcl_beds.last_skip()
			if self.last_skip < last_skip then
				self.last_skip = last_skip
				if check_bed(self) then
					self.object:set_pos(self._bed)
				else
					teleport_to_town_bell(self)
				end
			end
		end
	end

	-- Only check in day or during thunderstorm but wandered_too_far code won't work
	local wandered_too_far = false
	if check_bed(self) then
		wandered_too_far = (self.state ~= PATHFINDING) and (vector.distance(self.object:get_pos(), self._bed) > 50)
	end

	local activity = get_activity(self)

	-- This needs to be most important to least important
	-- TODO separate sleep and home activities when villagers can sleep
	if activity == SLEEP or activity == HOME then
		if check_bed(self) then
			go_home(self, true)
		else
			-- If it's sleepy time and we don't have a bed, hide in someone elses house
			sleep_over(self)
		end
	elseif activity == WORK then
		do_work(self)
	elseif activity == GATHERING then
		go_to_town_bell(self)
	elseif wandered_too_far then
		go_home(self, false)
	else
		self.order = nil
	end
end

local function update_max_tradenum(self)
	if not self._trades then
		return
	end
	local trades = minetest.deserialize(self._trades)
	for t=1, #trades do
		local trade = trades[t]
		if trade.tier > self._max_trade_tier then
			self._max_tradenum = t - 1
			return
		end
	end
	self._max_tradenum = #trades
end

local function init_trades(self, inv)
	local profession = mobs_mc.professions[self._profession]
	local trade_tiers = profession.trades
	if trade_tiers == nil then
		-- Empty trades
		self._trades = false
		return
	end

	local max_tier = #trade_tiers
	local trades = {}
	for tiernum=1, max_tier do
		local tier = trade_tiers[tiernum]
		for tradenum=1, #tier do
			local trade = tier[tradenum]
			local wanted1_item = trade[1][1]
			local wanted1_count = math.random(trade[1][2], trade[1][3])
			local offered_item = trade[2][1]
			local offered_count = math.random(trade[2][2], trade[2][3])

			local offered_stack = ItemStack({name = offered_item, count = offered_count})
			if mcl_enchanting.is_enchanted(offered_item) then
				if mcl_enchanting.is_book(offered_item) then
					offered_stack = mcl_enchanting.enchant_uniform_randomly(offered_stack, {"soul_speed"})
				else
					mcl_enchanting.enchant_randomly(offered_stack, math.random(5, 19), false, false, true)
					mcl_enchanting.unload_enchantments(offered_stack)
				end
			end

			local wanted = { wanted1_item .. " " ..wanted1_count }
			if trade[1][4] then
				local wanted2_item = trade[1][4]
				local wanted2_count = math.random(trade[1][5], trade[1][6])
				table.insert(wanted, wanted2_item .. " " ..wanted2_count)
			end

			table.insert(trades, {
				wanted = wanted,
				offered = offered_stack:to_table(),
				tier = tiernum, -- tier of this trade
				traded_once = false, -- true if trade was traded at least once
				trade_counter = 0, -- how often the this trade was mate after the last time it got unlocked
				locked = false, -- if this trade is locked. Locked trades can't be used
			})
		end
	end
	self._trades = minetest.serialize(trades)
	minetest.deserialize(self._trades)
end

local function move_stack(inv1, list1, inv2, list2, stack, pos)
	if stack and inv1:contains_item(list1, stack) and inv2:room_for_item(list2, stack) then
		return inv2:add_item(list2, inv1:remove_item(list1, stack))
	elseif pos and not inv2:room_for_item(list2, stack) then
		mcl_util.drop_item_stack(pos, stack)
		inv1:remove_item(list1, stack)
	end
end

local function move_index(inv1, list1, inv2, list2, index, pos)
	move_stack(inv1, list1, inv2, list2, inv1:get_stack(list1, index), pos)
end

local function set_trade(trader, player, inv, concrete_tradenum)
	local trades = minetest.deserialize(trader._trades)
	if not trades then
		init_trades(trader)
		trades = minetest.deserialize(trader._trades)
		if not trades then
			--minetest.log("error", "Failed to select villager trade!")
			return
		end
	end
	local name = player:get_player_name()

	-- Stop tradenum from advancing into locked tiers or out-of-range areas
	if concrete_tradenum > trader._max_tradenum then
		concrete_tradenum = trader._max_tradenum
	elseif concrete_tradenum < 1 then
		concrete_tradenum = 1
	end
	player_tradenum[name] = concrete_tradenum
	local trade = trades[concrete_tradenum]
	local wanted1 = ItemStack(trade.wanted[1])
	local wanted2 = ItemStack(trade.wanted[2])
	inv:set_stack("wanted", 1, wanted1)
	local offered = ItemStack(trade.offered)
	-- Only load enchantments for enchanted items; fixes unnecessary metadata being applied to regular items from villagers.
	if mcl_enchanting.is_enchanted(offered:get_name()) then
		mcl_enchanting.load_enchantments(offered)
	end
	inv:set_stack("offered", 1, offered)
	if trade.wanted[2] then
		inv:set_stack("wanted", 2, wanted2)
	else
		inv:set_stack("wanted", 2, "")
	end

	local plinv = player:get_inventory()
	local pos = player:get_pos()
	 move_index(inv, "input", plinv, "main", 1, pos)
	 move_index(inv, "input", plinv, "main", 2, pos)
	if wanted1 then
		move_stack(plinv, "main", inv, "input", wanted1)
	end
	if wanted2 then
		move_stack(plinv, "main", inv, "input", wanted2)
	end

end

-- Trade spec templates, some with args to use with string.format
-- arg 1 = %s = title
-- arg 2 = %i = scroller max val
local fs_header_template = [[
formspec_version[6]
size[15.2,9.3]
position[0.5,0.5]

label[7.5,0.3;%s]
style_type[label;textcolor=white]

scrollbaroptions[min=1;max=%i;thumbsize=1]
scrollbar[3.4,0.05;0.2,9.1;vertical;trade_scroller;1]
scroll_container[0.1,0.1;3.50,9.5;trade_scroller;vertical]

]]

-- arg 1 = %f = H
-- arg 2 = %s = level
local fs_level_template = [[
style_type[label;textcolor=#323232]
label[0.1,%f2;%s]
style_type[label;textcolor=white]

]]

-- arg 1 = %f = H for container
-- arg 2 = %i = trade number
-- arg 3 = %s = wanted 1
-- arg 4 = %s = wanted 1 tooltip
-- arg 5 = %s = wanted 1 count
local fs_trade_start_template = [[
container[0.1,%f2]
	button[0.0,0.0;3.05,0.6;trade_%i;]

	item_image[0.02,0.03;0.5,0.5;%s]
	tooltip[0.1,0.0;0.5,0.5;%s]
	label[0.3,0.35;%s]

]]

-- arg 1 = %s = wanted 2
-- arg 2 = %s = wanted 2 tooltip
-- arg 3 = %s = wanted 2 count
local fs_trade_wants2_template = [[

	item_image[0.4,0.03;0.5,0.5;%s]
	tooltip[0.4,0.1;0.5,0.5;%s]
	label[0.7,0.35;%s]

]]

-- This should be what is in mcl_inventory_button9_pressed with the pressed button
-- image used as the unpressed option
local fs_trade_pushed_template = [[
	style_type[button;border=false;bgimg=mcl_inventory_button9_pressed.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]

]]

-- This should be what is in mcl_inventory_button9
local fs_trade_unpush_template = [[
	style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]

]]

local fs_trade_arrow_template = [[
	image[1.8,0.15;0.5,0.32;gui_crafting_arrow.png]

]]

local fs_trade_diabled_template = [[
	image[1.8,0.15;0.5,0.32;mobs_mc_trading_formspec_disabled.png]

]]

-- arg 1 = %s = offered
-- arg 2 = %s = offered tooltip
-- arg 3 = %s = offered count
local fs_trade_end_template = [[
	item_image[2.5,0.03;0.5,0.5;%s]
	tooltip[2.5,0.0;0.5,0.5;%s]
	label[2.8,0.35;%s]

container_end[]

]]

local fs_footer_template = [[

scroll_container_end[]

image[9.5,1.0;1.0,0.5;gui_crafting_arrow.png]
image[9.5,2.25;1.0,0.5;gui_crafting_arrow.png]

]] ..
mcl_formspec.get_itemslot_bg_v4(6.4,2.0,2,1)
..
mcl_formspec.get_itemslot_bg_v4(11.1,2.0,1,1)
..
mcl_formspec.get_itemslot_bg_v4(3.97,3.98,9,3)
..
mcl_formspec.get_itemslot_bg_v4(3.97,7.98,9,1)
 ..
[[

 list[current_player;main;3.97,3.98;9,3;9]
 list[current_player;main;3.97,7.98;9,1;]

]]

-- arg 1 = %s = wanted
-- arg 2 = %s = wanted tooltip
-- arg 3 = %s = wanted count
local fs_wants_template = [[

	item_image[6.4,0.75;1.0,1.0;%s]
	tooltip[6.4,0.75;1.0,1.0;%s]
	label[7.20,1.7;%s]

]]

-- arg 1 = %s = wanted 2
-- arg 2 = %s = wanted 2 tooltip
-- arg 3 = %s = wanted 2 count
local fs_wants2_template = [[

	item_image[7.6,0.75;1.0,1.0;%s]
	tooltip[7.6,0.75;1.0,1.0;%s]
	label[8.5,1.7;%s]

]]

-- arg 1 = %s = offered
-- arg 2 = %s = offered tooltip
-- arg 3 = %s = offered count
local fs_offered_template = [[

	item_image[11.1,0.75;1.0,1.0;%s]
	tooltip[11.1,0.75;1.0,1.0;%s]
	label[11.95,1.7;%s]

]]

-- arg 1 = %s = tradeinv
-- arg 2 = %s = tradeinv
-- arg 3 = %s = tradeinv
-- arg 4 = %s = tradeinv
local fs_footer_template2 = [[

list[%s;input;6.4,2.0;2,1;]
list[%s;output;11.1,2.0;1,1;]
listring[%s;output]
listring[current_player;main]
listring[%s;input]
listring[current_player;main]
]]

-- set to empty for 1 so no number shows
local function count_string(count)
	if count == 1 then
		count = ""
	end
	return count
end

local button_buffer = 0.65

local function show_trade_formspec(playername, trader, tradenum)
	if not trader._trades then
		return
	end
	if not tradenum then
		tradenum = 0
	end

	local tradeinv_name = "mobs_mc:trade_" .. playername
	local tradeinv = F("detached:" .. tradeinv_name)

	local profession = mobs_mc.professions[trader._profession].name

	local inv = minetest.get_inventory({ type = "detached", name = "mobs_mc:trade_" .. playername })
	if not inv then
		return
	end

	local tiername = tiernames[trader._max_trade_tier] or S("Master")

	local formspec = ""

	local last_tier = 0
	local h = 0.0
	local trade_str = ""

	for i, trade in pairs(minetest.deserialize(trader._trades)) do
		local wanted1 = ItemStack(trade.wanted[1])
		local wanted2 = ItemStack(trade.wanted[2])
		local offered = ItemStack(trade.offered)

		if mcl_enchanting.is_enchanted(offered:get_name()) then
			mcl_enchanting.load_enchantments(offered)
		end

		local row_str = ""
		if last_tier ~= trade.tier then
			if trade.tier > trader._max_trade_tier then
				break
			end

			last_tier = trade.tier
			h = h + 0.3
			row_str = string.format(fs_level_template, h, tiernames[trade.tier])
			h = h + 0.2
		end

		if i == tradenum then
			row_str = row_str .. fs_trade_pushed_template

			trade_str = string.format(
				fs_wants_template,
				wanted1:get_name(),
				F(wanted1:get_description()),
				count_string(wanted1:get_count())
			)

			if not wanted2:is_empty() then
				trade_str = trade_str
					.. string.format(
						fs_wants2_template,
						wanted2:get_name(),
						F(wanted2:get_description()),
						count_string(wanted2:get_count())
					)
			end

			trade_str = trade_str
				.. string.format(
					fs_offered_template,
					offered:get_name(),
					F(offered:get_description()),
					count_string(offered:get_count())
				)
		end

		row_str = row_str
			.. string.format(
				fs_trade_start_template,
				h,
				i,
				wanted1:get_name(),
				F(wanted1:get_description()),
				count_string(wanted1:get_count())
			)

		if not wanted2:is_empty() then
			row_str = row_str
				.. string.format(
					fs_trade_wants2_template,
					wanted2:get_name(),
					F(wanted2:get_description()),
					count_string(wanted2:get_count())
				)
		end

		if trade.locked then
			row_str = row_str .. fs_trade_diabled_template
		else
			row_str = row_str .. fs_trade_arrow_template
		end

		row_str = row_str
			.. string.format(
				fs_trade_end_template,
				offered:get_name(),
				F(offered:get_description()),
				count_string(offered:get_count())
			)

		if i == tradenum then
			row_str = row_str .. fs_trade_unpush_template
		end

		formspec = formspec .. row_str
		h = h + button_buffer
	end

	local header =
		string.format(fs_header_template, F(minetest.colorize("#313131", profession .. " - " .. tiername)), h * 8)

	formspec = header .. formspec .. fs_footer_template

	if trade_str ~= "" then
		formspec = formspec .. trade_str
			.. string.format(fs_footer_template2, tradeinv, tradeinv, tradeinv, tradeinv)
	end

	minetest.sound_play("mobs_mc_villager_trade", { to_player = playername, object = trader.object }, true)
	minetest.show_formspec(playername, tradeinv_name, formspec)
end

local function update_offer(inv, player, sound)
	local name = player:get_player_name()
	local trader = player_trading_with[name]
	local tradenum = player_tradenum[name]
	if not trader or not tradenum then
		return false
	end
	local trades = minetest.deserialize(trader._trades)
	if not trades then
		return false
	end
	local trade = trades[tradenum]
	if not trade then
		return false
	end
	local wanted1, wanted2 = inv:get_stack("wanted", 1), inv:get_stack("wanted", 2)
	local input1, input2 = inv:get_stack("input", 1), inv:get_stack("input", 2)

	-- BEGIN OF SPECIAL HANDLING OF COMPASS
	-- These 2 functions are a complicated check to check if the input contains a
	-- special item which we cannot check directly against their name, like
	-- compass.
	-- TODO: Remove these check functions when compass and clock are implemented
	-- as single items.
	local function check_special(special_item, group, wanted1, wanted2, input1, input2)
		if minetest.registered_aliases[special_item] then
			special_item = minetest.registered_aliases[special_item]
		end
		if wanted1:get_name() == special_item then
			local function check_input(input, wanted, group)
				return minetest.get_item_group(input:get_name(), group) ~= 0 and input:get_count() >= wanted:get_count()
			end
			if check_input(input1, wanted1, group) then
				return true
			elseif check_input(input2, wanted1, group) then
				return true
			else
				return false
			end
		end
		return false
	end
	-- Apply above function to all items which we consider special.
	-- This function succeeds if ANY item check succeeds.
	local function check_specials(wanted1, wanted2, input1, input2)
		return check_special(COMPASS, "compass", wanted1, wanted2, input1, input2)
	end
	-- END OF SPECIAL HANDLING OF COMPASS

	if (
			((inv:contains_item("input", wanted1) and
			(wanted2:is_empty() or inv:contains_item("input", wanted2))) or
			-- BEGIN OF SPECIAL HANDLING OF COMPASS
			check_specials(wanted1, wanted2, input1, input2)) and
			-- END OF SPECIAL HANDLING OF COMPASS
			(trade.locked == false)) then
		inv:set_stack("output", 1, inv:get_stack("offered", 1))
		if sound then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name,object=trader.object}, true)
		end
		return true
	else
		inv:set_stack("output", 1, ItemStack(""))
		if sound then
			minetest.sound_play("mobs_mc_villager_deny", {to_player = name,object=trader.object}, true)
		end
		return false
	end
end

-- Returns a single itemstack in the given inventory to the player's main inventory, or drop it when there's no space left
local function return_item(itemstack, dropper, pos, inv_p)
	if dropper:is_player() then
		-- Return to main inventory
		if inv_p:room_for_item("main", itemstack) then
			inv_p:add_item("main", itemstack)
		else
			-- Drop item on the ground
			local v = dropper:get_look_dir()
			local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
			p.x = p.x+(math.random(1,3)*0.2)
			p.z = p.z+(math.random(1,3)*0.2)
			local obj = minetest.add_item(p, itemstack)
			if obj then
				v.x = v.x*4
				v.y = v.y*4 + 2
				v.z = v.z*4
				obj:set_velocity(v)
				obj:get_luaentity()._insta_collect = false
			end
		end
	else
		-- Fallback for unexpected cases
		minetest.add_item(pos, itemstack)
	end
	return itemstack
end

local function return_fields(player)
	local name = player:get_player_name()
	local inv_t = minetest.get_inventory({type="detached", name = "mobs_mc:trade_"..name})
	local inv_p = player:get_inventory()
	if not inv_t or not inv_p then
		return
	end
	for i=1, inv_t:get_size("input") do
		local stack = inv_t:get_stack("input", i)
		return_item(stack, player, player:get_pos(), inv_p)
		stack:clear()
		inv_t:set_stack("input", i, stack)
	end
	inv_t:set_stack("output", 1, "")
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 14) == "mobs_mc:trade_" then
		local name = player:get_player_name()
		if fields.quit then
			-- Get input items back
			return_fields(player)
			-- Reset internal "trading with" state
			local trader = player_trading_with[name]
			if trader then
				trader._trading_players[name] = nil
			end
			player_trading_with[name] = nil
		else
			local trader = player_trading_with[name]
			if not trader or not trader.object:get_luaentity() then
				return
			end
			local trades = trader._trades
			if not trades then
				return
			end
			local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
			if not inv then
				return
			end
			for i, trade in pairs(minetest.deserialize(trader._trades)) do
				if fields["trade_" .. i] then
					set_trade(trader, player, inv, i)
					update_offer(inv, player, false)
					show_trade_formspec(name, trader, i)
					break
				end
			end
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	return_fields(player)
	player_tradenum[name] = nil
	local trader = player_trading_with[name]
	if trader then
		trader._trading_players[name] = nil
	end
	player_trading_with[name] = nil

end)

-- Return true if player is trading with villager, and the villager entity exists
local function trader_exists(playername)
	local trader = player_trading_with[playername]
	return trader ~= nil and trader.object:get_luaentity() ~= nil
end

local trade_inventory = {
	allow_take = function(inv, listname, index, stack, player)
		if listname == "input" then
			return stack:get_count()
		elseif listname == "output" then
			if not trader_exists(player:get_player_name()) then
				return 0
			-- Begin Award Code
			-- May need to be moved if award gets unlocked in the wrong cases.
			elseif trader_exists(player:get_player_name()) then
				awards.unlock(player:get_player_name(), "mcl:whatAdeal")
			-- End Award Code
			end
			-- Only allow taking full stack
			local count = stack:get_count()
			if count == inv:get_stack(listname, index):get_count() then
				-- Also update output stack again.
				-- If input has double the wanted items, the
				-- output will stay because there will be still
				-- enough items in input after the trade
				local wanted1 = inv:get_stack("wanted", 1)
				local wanted2 = inv:get_stack("wanted", 2)
				local input1 = inv:get_stack("input", 1)
				local input2 = inv:get_stack("input", 2)
				wanted1:set_count(wanted1:get_count()*2)
				wanted2:set_count(wanted2:get_count()*2)
				-- BEGIN OF SPECIAL HANDLING FOR COMPASS
				local function special_checks(wanted1, input1, input2)
					if wanted1:get_name() == COMPASS then
						local compasses = 0
						if (minetest.get_item_group(input1:get_name(), "compass") ~= 0) then
							compasses = compasses + input1:get_count()
						end
						if (minetest.get_item_group(input2:get_name(), "compass") ~= 0) then
							compasses = compasses + input2:get_count()
						end
						return compasses >= wanted1:get_count()
					end
					return false
				end
				-- END OF SPECIAL HANDLING FOR COMPASS
				if (inv:contains_item("input", wanted1) and
					(wanted2:is_empty() or inv:contains_item("input", wanted2)))
					-- BEGIN OF SPECIAL HANDLING FOR COMPASS
					or special_checks(wanted1, input1, input2) then
					-- END OF SPECIAL HANDLING FOR COMPASS
					return -1
				else
					-- If less than double the wanted items,
					-- remove items from output (final trade,
					-- input runs empty)
					return count
				end
			else
				return 0
			end
		else
			return 0
		end
	end,
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		if from_list == "input" and to_list == "input" then
			return count
		elseif from_list == "output" and to_list == "input" then
			if not trader_exists(player:get_player_name()) then
				return 0
			end
			local move_stack = inv:get_stack(from_list, from_index)
			if inv:get_stack(to_list, to_index):item_fits(move_stack) then
				return count
			end
		end
		return 0
	end,
	allow_put = function(inv, listname, index, stack, player)
		if listname == "input" then
			if not trader_exists(player:get_player_name()) then
				return 0
			else
				return stack:get_count()
			end
		else
			return 0
		end
	end,
	on_put = function(inv, listname, index, stack, player)
		update_offer(inv, player, true)
	end,
	on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		if from_list == "output" and to_list == "input" then
			inv:remove_item("input", inv:get_stack("wanted", 1))
			local wanted2 = inv:get_stack("wanted", 2)
			if not wanted2:is_empty() then
				inv:remove_item("input", inv:get_stack("wanted", 2))
			end
			local name = player:get_player_name()
			local trader = player_trading_with[name]
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name ,object=trader.object}, true)
		end
		update_offer(inv, player, true)
	end,
	on_take = function(inv, listname, index, stack, player)
		local accept
		local name = player:get_player_name()
		if listname == "output" then
			local wanted1 = inv:get_stack("wanted", 1)
			inv:remove_item("input", wanted1)
			local wanted2 = inv:get_stack("wanted", 2)
			if not wanted2:is_empty() then
				inv:remove_item("input", inv:get_stack("wanted", 2))
			end
			-- BEGIN OF SPECIAL HANDLING FOR COMPASS
			if wanted1:get_name() == COMPASS then
				for n=1, 2 do
					local input = inv:get_stack("input", n)
					if minetest.get_item_group(input:get_name(), "compass") ~= 0 then
						input:set_count(input:get_count() - wanted1:get_count())
						inv:set_stack("input", n, input)
						break
					end
				end
			end
			-- END OF SPECIAL HANDLING FOR COMPASS
			local trader = player_trading_with[name]
			local tradenum = player_tradenum[name]

			local trades
			trader._traded = true
			if trader and trader._trades then
				trades = minetest.deserialize(trader._trades)
			end
			if trades then
				local trade = trades[tradenum]
				local unlock_stuff = false
				if not trade.traded_once then
					-- Unlock all the things if something was traded
					-- for the first time ever
					unlock_stuff = true
					trade.traded_once = true
				elseif trade.trade_counter == 0 and math.random(1,5) == 1 then
					-- Otherwise, 20% chance to unlock if used freshly reset trade
					unlock_stuff = true
				end
				local update_formspec = false
				if unlock_stuff then
					-- First-time trade unlock all trades and unlock next trade tier
					if trade.tier + 1 > trader._max_trade_tier then
						trader._max_trade_tier = trader._max_trade_tier + 1
						if trader._max_trade_tier > 5 then
							trader._max_trade_tier =  5
						end
						set_textures(trader)
						update_max_tradenum(trader)
						update_formspec = true
					end
					for t=1, #trades do
						trades[t].locked = false
						trades[t].trade_counter = 0
					end
					trader._locked_trades = 0
					-- Also heal trader for unlocking stuff
					-- TODO: Replace by Regeneration I
					trader.health = math.min((trader.object:get_properties().hp_max or 20), trader.health + 4)
				end
				trade.trade_counter = trade.trade_counter + 1
				-- Semi-randomly lock trade for repeated trade (not if there's only 1 trade)
				if trader._max_tradenum > 1 then
					if trade.trade_counter >= 12 then
						trade.locked = true
					elseif trade.trade_counter >= 2 then
						local r = math.random(1, math.random(4, 10))
						if r == 1 then
							trade.locked = true
						end
					end
				end

				if trade.locked then
					inv:set_stack("output", 1, "")
					update_formspec = true
					trader._locked_trades = trader._locked_trades + 1
					-- Check if we managed to lock ALL available trades. Rare but possible.
					if trader._locked_trades >= trader._max_tradenum then
						-- Emergency unlock! Unlock all other trades except the current one
						for t=1, #trades do
							if t ~= tradenum then
								trades[t].locked = false
								trades[t].trade_counter = 0
							end
						end
						trader._locked_trades = 1
						-- Also heal trader for unlocking stuff
						-- TODO: Replace by Regeneration I
						trader.health = math.min((trader.object:get_properties().hp_max or 20), trader.health + 4)
					end
				end
				trader._trades = minetest.serialize(trades)
				if update_formspec then
					show_trade_formspec(name, trader, tradenum)
				end
			else
				minetest.log("error", "[mobs_mc] Player took item from trader output but player_trading_with or player_tradenum is nil!")
			end

			accept = true
		elseif listname == "input" then
			update_offer(inv, player, false)
		end
		local trader = player_trading_with[name]
		if accept then
			minetest.sound_play("mobs_mc_villager_accept", {to_player = name,object=trader.object}, true)
		else
			minetest.sound_play("mobs_mc_villager_deny", {to_player = name,object=trader.object}, true)
		end
	end,
}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_tradenum[name] = 1
	player_trading_with[name] = nil

	-- Create or get player-specific trading inventory
	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
	if not inv then
		inv = minetest.create_detached_inventory("mobs_mc:trade_"..name, trade_inventory, name)
	end
	inv:set_size("input", 2)
	inv:set_size("output", 1)
	inv:set_size("wanted", 2)
	inv:set_size("offered", 1)
end)

--[------[ MOB REGISTRATION AND SPAWNING ]-------]

local pick_up = { "mcl_farming:bread", "mcl_farming:carrot_item", "mcl_farming:beetroot_item" , "mcl_farming:potato_item" }

mcl_mobs.register_mob("mobs_mc:villager", {
	description = S("Villager"),
	type = "npc",
	spawn_class = "passive",
	passive = true,
	hp_min = 20,
	hp_max = 20,
	head_swivel = "head.control",
	bone_eye_height = 6.3,
	head_eye_height = 2.2,
	curiosity = 10,
	runaway = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = {
		"mobs_mc_villager.png",
		"mobs_mc_villager.png", --hat
	},
	makes_footstep_sound = true,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	drops = {},
	can_despawn = false,
	-- TODO: sounds
	sounds = {
		random = "mobs_mc_villager",
		damage = "mobs_mc_villager_hurt",
		distance = 10,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 25,
		run_start = 0, run_end = 40, run_speed = 25,
		head_shake_start = 60, head_shake_end = 70, head_shake_loop = false,
		head_nod_start = 50, head_nod_end = 60, head_nod_loop = false,
	},
	child_animations = {
		stand_start = 71, stand_end = 71,
		walk_start = 71, walk_end = 111, walk_speed = 37,
		run_start = 71, run_end = 111, run_speed = 37,
		head_shake_start = 131, head_shake_end = 141, head_shake_loop = false,
		head_nod_start = 121, head_nod_end = 131, head_nod_loop = false,
	},
	follow = pick_up,
	nofollow = true,
	view_range = 16,
	fear_height = 4,
	jump = true,
	walk_chance = DEFAULT_WALK_CHANCE,
	_bed = nil,
	_id = nil,
	_profession = "unemployed",
	look_at_player = true,
	pick_up = pick_up,
	can_open_doors = true,
	on_pick_up = function(self,itementity)
		local clicker
		local it = ItemStack(itementity.itemstring)
		for _,p in pairs(minetest.get_connected_players()) do
			if vector.distance(p:get_pos(),self.object:get_pos()) < 10 then
				clicker = p
			end
		end
		if clicker and not self.horny then
			self:feed_tame(clicker, 1, true, false, true)
			it:take_item(1)
		end
		return it
	end,
	on_rightclick = function(self, clicker)
		if self.child or self._profession == "unemployed" or self._profession == "nitwit" then
			self.order = nil
			return
		end

		if self.state == PATHFINDING then
			self.state = "stand"
		end
		-- Can we remove now we possibly have fixed root cause
		if self.state == "attack" then
			-- Need to stop villager getting in attack state. This is a workaround to allow players to fix broken villager.
			self.state = "stand"
			self.attack = nil
		end
		-- Don't do at night. Go to bed? Maybe do_activity needs it's own method
		if validate_jobsite(self) and self.order ~= WORK then
			minetest.log("warning","[mobs_mc] villager has jobsite but doesn't work")
			--self:gopath(self._jobsite,function()
			--	minetest.log("sent to jobsite")
			--end)
		else
			self.state = "stand" -- cancel gowp in case it has messed up
			--self.order = nil -- cancel work if working
		end

		-- Initiate trading
		init_trader_vars(self)
		local name = clicker:get_player_name()
		self._trading_players[name] = true

		if self._trades == nil or self._trades == false then
			--minetest.log("Trades is nil so init")
			init_trades(self)
		end
		update_max_tradenum(self)
		if self._trades == false then
			--minetest.log("Trades is false. no right click op")
			-- Villager has no trades, rightclick is a no-op
			return
		end

		player_trading_with[name] = self

		local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
		if not inv then
			return
		end

		set_trade(self, clicker, inv, 1)

		show_trade_formspec(name, self)

		-- Behaviour stuff:
		-- Make villager look at player and stand still
		local selfpos = self.object:get_pos()
		local clickerpos = clicker:get_pos()
		local dir = vector.direction(selfpos, clickerpos)
		self.object:set_yaw(minetest.dir_to_yaw(dir))
		stand_still(self)
	end,

	_player_scan_timer = 0,
	_trading_players = {}, -- list of playernames currently trading with villager (open formspec)
	do_custom = function(self, dtime)
		check_summon(self,dtime)

		-- Stand still if player is nearby.
		if not self._player_scan_timer then
			self._player_scan_timer = 0
		end
		self._player_scan_timer = self._player_scan_timer + dtime

		-- Check infrequently to keep CPU load low
		if self._player_scan_timer > PLAYER_SCAN_INTERVAL then

			self._player_scan_timer = 0
			local selfpos = self.object:get_pos()
			local objects = minetest.get_objects_inside_radius(selfpos, PLAYER_SCAN_RADIUS)
			local has_player = false

			for o, obj in pairs(objects) do
				if obj:is_player() then
					has_player = true
					break
				end
			end
			if has_player then
				--minetest.log("verbose", "[mobs_mc] Player near villager found!")
				stand_still(self)
			else
				--minetest.log("verbose", "[mobs_mc] No player near villager found!")
				self.walk_chance = DEFAULT_WALK_CHANCE
				self.jump = true
			end

			do_activity (self)

		end
	end,

	on_spawn = function(self)
		if not self._profession then
			self._profession = "unemployed"
			if math.random(100) == 1 then
				self._profession = "nitwit"
			end
		end
		if self._id then
			set_textures(self)
			return
		end
		self._id=minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
		set_textures(self)
	end,
	after_activate = set_textures,
	on_die = function(self, pos, cmi_cause)
		-- Close open trade formspecs and give input back to players
		local trading_players = self._trading_players
		if trading_players then
			for name, _ in pairs(trading_players) do
				minetest.close_formspec(name, "mobs_mc:trade_"..name)
				local player = minetest.get_player_by_name(name)
				if player then
					return_fields(player)
				end
			end
		end

		local bed = self._bed
		if bed then
			local bed_meta = minetest.get_meta(bed)
			bed_meta:set_string("villager", nil)
			bed_meta:set_string("infotext", nil)
		end
		local jobsite = self._jobsite
		if jobsite then
			local jobsite_meta = minetest.get_meta(jobsite)
			jobsite_meta:set_string("villager", nil)
			jobsite_meta:set_string("infotext", nil)
		end

		if cmi_cause and cmi_cause.puncher then
			local l = cmi_cause.puncher:get_luaentity()
			if l and math.random(2) == 1 and( l.name == "mobs_mc:zombie" or l.name == "mobs_mc:baby_zombie" or l.name == "mobs_mc:villager_zombie" or l.name == "mobs_mc:husk") then
				mcl_util.replace_mob(self.object,"mobs_mc:villager_zombie")
				return true
			end
		end
	end,
	on_lightning_strike = function(self, pos, pos2, objects)
		 mcl_util.replace_mob(self.object, "mobs_mc:witch")
		 return true
	end,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:villager", S("Villager"), "#563d33", "#bc8b72", 0)
