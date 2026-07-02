local _M = loadPrevious(...)
local ap_connection = require("mod.ap_connection")

local base_die = _M.die
function _M:die(src, death_note)
	local dead = base_die(self, src, death_note)

	if dead then
	   ap_connection.send_kill_location(self.name)
	end
end
