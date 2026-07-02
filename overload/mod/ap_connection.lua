-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
local class = require "class"
local socket = require("socket")

local ap_zone_items = {}
ap_zone_items["Kor'Pul"] = "ap_zone_korpul"
ap_zone_items["Rhaloren Camp"] = "ap_zone_rhaloren_camp"
ap_zone_items["Heart of the Gloom"] = "ap_zone_heart_gloom"
ap_zone_items["Old Forest"] = "ap_zone_old_forest"
ap_zone_items["Maze"] = "ap_zone_maze"
ap_zone_items["Sandworm Lair"] = "ap_zone_sandworm_lair"
ap_zone_items["Daikara"] = "ap_zone_daikara"
ap_zone_items["Halfling Ruins"] = "ap_zone_halfling_ruins"
ap_zone_items["Ruined Dungeon"] = "ap_zone_ruined_dungeon"
ap_zone_items["Ring of Blood"] = "ap_zone_hidden_compound"
ap_zone_items["Golem Graveyard"] = "ap_zone_golem_graveyard"
ap_zone_items["Mark of the Spellblaze"] = "ap_zone_spellblaze"
ap_zone_items["Dreadfell"] = "ap_zone_dreadfell"


module("mod.ap_connection", package.seeall, class.make)

function connect_to_client()
   ap_socket = socket.tcp()
   ap_socket:settimeout(1000)
   local connection_success, err = ap_socket:connect("localhost", 31821)
   if not connection_success then
      ap_socket = nil
   end
end

function send_kill_location(enemy_name)
   if not ap_socket then
      game.log("Archipelago failed to connect. Reload your save file to retry.")
      return
   end
   if not game.player.ap_enemies_defeated then
      game.player.ap_enemies_defeated = {}
   end
   game.player.ap_enemies_defeated[enemy_name] = true
   local sent, err = ap_socket:send("APLOCATION " .. enemy_name .. "\n")
   if not sent then
      game.log("Failed to send " .. enemy_name .. ": " .. err)
      return
   end
end

-- Proper Mutexes don't appear available, this guard variable will have to do.
local ap_syncing = false
   
function ap_sync()
   if not ap_socket then
      game.log("Archipelago failed to connect. Reload your save file to retry.")
      return
   end
   local p = game.party:findMember{main=true}
   if not p then
      game.log("No player?")
      return
   end
   if ap_syncing then
      game.log("Warning: AP attempted to sync while desynced or already syncing")
      return
   end
   ap_syncing = true
   -- Check for a desync.
   local receivable, sendable = socket.select({ ap_socket }, nil, 0)
   if next(receivable) ~= nil then
      game.log("Warning: AP desync detected. Please reload your save file.")
      -- Keep ap_syncing true to block future sync attempts
      return
   end
   if not p.ap_items_received then
      game.log("Setting AP received")
      p.ap_items_received = 0
   end
   game.log("Sending request for items")
   local sent, err = ap_socket:send("APSENDITEMS " .. tostring(p.ap_items_received) .. "\n")
   if not sent then
      game.log("Failed to request items " .. err)
      ap_syncing = false
      return
   end
   local message, err = ap_socket:receive()
   if not message then
      game.log("Failed to receive items: " .. err)
      ap_syncing = false
      return
   end
   local num_items = tonumber(assert(message:match"^APNUMITEMS (.*)"))
   if num_items == 0 then
      game.log("No new items from AP")
      send_all_locations()
      ap_syncing = false
      return
   end
   game.log("Receiving " .. tostring(num_items) .. " from AP")
   for i=1,num_items,1 do
      local message, err = ap_socket:receive()
      if not message then
	 game.log("Failed to receive item: " .. err)
	 ap_syncing = false
	 return
      end
      local item_name = assert(message:match"^APITEM (.*)")
      give_item(item_name)
   end
   send_all_locations()
   ap_syncing = false
end

function send_all_locations()
   if game.player.ap_enemies_defeated then
      for enemy_name, _ in pairs(game.player.ap_enemies_defeated) do
	 ap_socket:send("APLOCATION " .. enemy_name .. "\n")
      end
   end
end


function give_item(item_name)
   game.log("Received item " .. item_name)
   game.player.ap_items_received = game.player.ap_items_received + 1
   local zone_var = ap_zone_items[item_name]
   if zone_var ~= nil then
      game.player[zone_var] = true
   elseif item_name == "Tale of Maj'Eyal" then
      -- Do nothing
      game.log("You must write your own tale!")
   elseif item_name == "20 Gold" then
      game.player:incMoney(20)
   elseif item_name == "Random Artifact" then
      make_randart()
   elseif item_name == "Generic Talent Point" then
      game.player.unused_generics = (game.player.unused_generics or 0) + 1
   elseif item_name == "Class Talent Point" then
      game.player.unused_talents = (game.player.unused_talents or 0) + 1
   elseif item_name == "Category Talent Point" then
      game.player.unused_talents_types = (game.player.unused_talents_types or 0) + 1
   elseif item_name == "Prodigy Point" then
      game.player.unused_prodigies = (game.player.unused_prodigies or 0) + 1
   elseif item_name == "Stat Point" then
      game.player.unused_stats = (game.player.unused_stats or 0) + 1
   elseif item_name == "Extra Life" then
      game.player.easy_mode_lifes = (game.player.easy_mode_lifes or 0) + 1
   else
      game.log(item_name .. " is an unknown item!")
   end
end

local randart_bases = {
   "iron longsword",
   "steel longsword",
   "dwarven-steel longsword",
   "stralite longsword",
   "voratun longsword",
   "iron mace",
   "steel mace",
   "dwarven-steel mace",
   "stralite mace",
   "voratun mace",
   "iron waraxe",
   "steel waraxe",
   "dwarven-steel waraxe",
   "stralite waraxe",
   "voratun waraxe",
   "iron greatsword",
   "steel greatsword",
   "dwarven-steel greatsword",
   "stralite greatsword",
   "voratun greatsword",
   "iron greatmaul",
   "steel greatmaul",
   "dwarven-steel greatmaul",
   "stralite greatmaul",
   "voratun greatmaul",
   "iron battleaxe",
   "steel battleaxe",
   "dwarven-steel battleaxe",
   "stralite battleaxe",
   "voratun battleaxe",
   "coral trident",
   "blue-steel trident",
   "deep-steel trident",
   "orite trident",
   "orichalcum trident",
   "iron dagger",
   "steel dagger",
   "dwarven-steel dagger",
   "stralite dagger",
   "voratun dagger",
   "elm staff",
   "ash staff",
   "yew staff",
   "elven-wood staff",
   "dragonbone staff",
   "mossy mindstar",
   "vined mindstar",
   "thorny mindstar",
   "pulsing mindstar",
   "living mindstar",
   "elm longbow",
   "ash longbow",
   "yew longbow",
   "elven-wood longbow",
   "dragonbone longbow",
   "rough leather sling",
   "cured leather sling",
   "hardened leather sling",
   "reinforced leather sling",
   "drakeskin leather sling",
   "quiver of elm arrows",
   "quiver of ash arrows",
   "quiver of yew arrows",
   "quiver of elven-wood arrows",
   "quiver of dragonbone arrows",
   "pouch of iron shots",
   "pouch of steel shots",
   "pouch of dwarven-steel shots",
   "pouch of stralite shots",
   "pouch of voratun shots",
   "linen robe",
   "woollen robe",
   "cashmere robe",
   "silk robe",
   "elven-silk robe",
   "rough leather armor",
   "cured leather armor",
   "hardened leather armor",
   "reinforced leather armor",
   "drakeskin leather armor",
   "iron mail armor",
   "steel mail armor",
   "dwarven-steel mail armor",
   "stralite mail armor",
   "voratun mail armor",
   "iron plate armor",
   "steel plate armor",
   "dwarven-steel plate armor",
   "stralite plate armor",
   "voratun plate armor",
   "rough leather cap",
   "hardened leather cap",
   "drakeskin leather cap",
   "iron helm",
   "dwarven-steel helm",
   "voratun helm",
   "linen wizard hat",
   "cashmere wizard hat",
   "elven-silk wizard hat",
   "pair of rough leather boots",
   "pair of hardened leather boots",
   "pair of drakeskin leather boots",
   "pair of iron boots",
   "pair of dwarven-steel boots",
   "pair of voratun boots",
   "linen cloak",
   "cashmere cloak",
   "elven-silk cloak",
   "rough leather belt",
   "hardened leather belt",
   "drakeskin leather belt",
   "rough leather gloves",
   "hardened leather gloves",
   "drakeskin leather gloves",
   "iron gauntlets",
   "dwarven-steel gauntlets",
   "voratun gauntlets",
   "iron shield",
   "steel shield",
   "dwarven-steel shield",
   "stralite shield",
   "voratun shield",
   "iron pickaxe",
   "dwarven-steel pickaxe",
   "voratun pickaxe",
   "elm wand",
   "yew wand",
   "dragonbone want",
   "elm totem",
   "yew totem",
   "dragonbone totem",
   "iron torque",
   "dwarven-steel torque",
   "voratun torque",
}

function make_randart()
   local base_idx = math.random(134)
   local base = randart_bases[base_idx]
   o = game.zone:makeEntity(game.level, "object", {name=base, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
   art = game.state:generateRandart{base=o, lev=game.player.level, egos=3}
   art:identify(true)
   game.player:addObject(game.player.INVEN_INVEN, art)
end
