dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/fishing/files/eva_utils.lua")

entity = GetUpdatedEntityID()

x, y, r = EntityGetTransform(entity)

offset_x = x + 100
offset_y = y + 10

if(EntityGetVariable(entity, "direction", "int") > 0)then
	EntityApplyTransform( entity, x, y, r, -1, 1 )
	offset_x = x - 100
	offset_y = y + 10
end

bobber = EntityLoad("mods/fishing/files/fisherman/bobber.xml", offset_x, offset_y )

EntityAddChild( entity, bobber )