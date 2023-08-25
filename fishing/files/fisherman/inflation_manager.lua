dofile_once("data/scripts/lib/utilities.lua")
dofile("mods/fishing/definitions/fish_list.lua")
dofile("mods/fishing/definitions/bait_list.lua")
dofile("mods/fishing/files/eva_utils.lua")
dofile("mods/fishing/files/gui_utils.lua")

local entity_id = GetUpdatedEntityID() 

local inflation_countdown = EntityGetVariable(entity_id, "inflation_countdown", "int") or 0

if(inflation_countdown > 0)then
	inflation_countdown = inflation_countdown - 1
end

if(inflation_countdown == 0)then
	inflation_countdown = 18000

	for k, v in pairs(bait_list)do
		local count = EntityGetVariable(entity_id, v.id.."_times_bought", "int") or 0
		if(count > 0)then
			EntitySetVariable(entity_id, v.id.."_times_bought", "int", count - 1)
		end
	end
end


EntitySetVariable(entity_id, "inflation_countdown", "int", inflation_countdown)