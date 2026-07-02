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
local _M = loadPrevious(...)
local ap_connection = require("mod.ap_connection")

local base_changelevel = _M.changeLevel
function _M:changeLevel(lev, zone, params)
   base_changelevel(self, lev, zone, params)
   ap_connection.ap_sync()
end
