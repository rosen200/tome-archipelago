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
local class = require"engine.class"
local ap_connection = require("mod.ap_connection")


class:bindHook("ToME:load", ap_connection.connect_to_client)

class:bindHook('Entity:loadList', function(self, data)
  if data.file == '/data/general/encounters/maj-eyal.lua' then
     for i, e in ipairs(data.res) do
	-- Closures do not work here, don't try to make a higher order
	-- function to make these.
	if e.name == "Ruined Dungeon" then
	   e.on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end
		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = _t"Entrance to a ruined dungeon"
		g.display='>' g.color_r=255 g.color_g=0 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="ruined-dungeon" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/ruin_entrance_closed01.png", z=5}
		g.change_level_check = function()
		   local p = game.party:findMember{main=true}
		   if p.ap_zone_ruined_dungeon then
		      return false
		   end
		   game.log("You need to receive Ruined Dungeon from the multiworld.")
		   return true
		end
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Ruined dungeon at", x, y)
		return true
	   end
	end
	if e.name == "Mark of the Spellblaze" then
	   e.on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = _t"Mark of the Spellblaze"
		g.display='>' g.color_r=0 g.color_g=200 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="mark-spellblaze" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/floor_pentagram.png", z=8}
		g.change_level_check = function()
		   local p = game.party:findMember{main=true}
		   if p.ap_zone_spellblaze then
		      return false
		   end
		   game.log("You need to receive Mark of the Spellblaze from the multiworld.")
		   return true
		end
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Mark of the spellblaze at", x, y)
		return true
	   end
	end
	if e.name == "Golem Graveyard" then
	   e.on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = _t"Golem Graveyard"
		g.display='>' g.color_r=0 g.color_g=200 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="golem-graveyard" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="npc/alchemist_golem.png", z=5}
		g.change_level_check = function()
		   local p = game.party:findMember{main=true}
		   if p.ap_zone_golem_graveyard then
		      return false
		   end
		   game.log("You need to receive Golem Graveyard from the multiworld.")
		   return true
		end

		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Golem Graveyard at", x, y)
		return true
	   end
	end
	if e.name == "Ring of Blood" then
	   e.on_encounter = function(self, who)
		local x, y = self:findSpot(who)
		if not x then return end

		local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
		g.name = _t"Hidden compound"
		g.display='>' g.color_r=200 g.color_g=0 g.color_b=0 g.notice = true
		g.change_level=1 g.change_zone="ring-of-blood" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/cave_entrance_closed02.png", z=5}
		g.change_level_check = function()
		   local p = game.party:findMember{main=true}
		   if p.ap_zone_hidden_compound then
		      return false
		   end
		   game.log("You need to receive Ring of Blood from the multiworld.")
		   return true
		end
		g:altered()
		g:initGlow()
		game.zone:addEntity(game.level, g, "terrain", x, y)
		print("[WORLDMAP] Hidden compound at", x, y)
		return true
	   end
	end
     end
  end
  if data.file == '/data/zones/wilderness/grids.lua' then
     for i, e in ipairs(data.res) do
	-- Just like above closures aren't allowed here either, so
	-- writing a function to make these functions isn't possible.
	if e.define_as == "KOR_PUL" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_korpul then
		 return false
	      end
	      game.log("You need to receive Kor'Pul from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "RHALOREN_CAMP" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_rhaloren_camp then
		 return false
	      end
	      game.log("You need to receive Rhaloren Camp from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "HEART_GLOOM" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_heart_gloom then
		 return false
	      end
	      game.log("You need to receive Heart of the Gloom from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "OLD_FOREST_ZONE" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_old_forest then
		 return false
	      end
	      game.log("You need to receive Old Forest from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "MAZE" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_maze then
		 return false
	      end
	      game.log("You need to receive Maze from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "SANDWORM_LAIR" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_sandworm_lair then
		 return false
	      end
	      game.log("You need to receive Sandworm Lair from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "DAIKARA_ZONE" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_daikara then
		 return false
	      end
	      game.log("You need to receive Daikara from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "HALFLING_RUINS" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_halfling_ruins then
		 return false
	      end
	      game.log("You need to receive Halfling Ruins from the multiworld.")
	      return true
	   end
	end
	if e.define_as == "DREADFELL" then
	   e.change_level_check = function()
	      local p = game.party:findMember{main=true}
	      if p.ap_zone_dreadfell then
		 return false
	      end
	      game.log("You need to receive Dreadfell from the multiworld.")
	      return true
	   end
	end
     end
  end
end)
