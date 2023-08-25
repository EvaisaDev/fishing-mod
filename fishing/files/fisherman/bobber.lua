dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/fishing/files/eva_utils.lua")

bobber = GetUpdatedEntityID()

bobber_parent = EntityGetParent( bobber )

bobber_parent_x, bobber_parent_y = EntityGetTransform(bobber_parent)

children = EntityGetAllChildren( bobber_parent )

connector = nil

if(children)then
	for k, v in pairs(children)do
		if(EntityGetName(v) == "fishing_line_connector")then
			connector = v
		end
	end

	if(connector == nil)then return end

	x, y = EntityGetTransform(bobber)

	local x1, y1 = EntityGetTransform(connector)
	local x2, y2 = EntityGetTransform(bobber)

	y2 = y2 - 4


	did_hit = RaytraceSurfacesAndLiquiform( x2, y2, x2, y2 - 2 )

	if(did_hit)then
		vel_comp = EntityGetFirstComponent(bobber, "VelocityComponent")
		ComponentSetValue2(vel_comp, "mVelocity", 0, -50)
	end


	if(EntityGetVariable(bobber, "rope_entity", "int") == 0)then
		line = EntityLoad("mods/fishing/files/fisherman/rope.xml", x1 + 20, y1)

		EntityAddChild(bobber_parent, line)

		--EntityAddComponent( line, "VerletWorldJointComponent" )
		--EntityAddComponent( line, "VerletWorldJointComponent" )
		
		local verletphysics_comp_found = false
		local last_point_index = 0
		edit_component( line, "VerletPhysicsComponent", function(comp,vars)
			verletphysics_comp_found = true
			last_point_index = ComponentGetValue( comp, "num_points" )
		end)


		
		if verletphysics_comp_found then

			local index = 0
		
			edit_all_components( line, "VerletWorldJointComponent", function(comp,vars)
				
				if index == 0 then
					ComponentSetValueVector2( comp, "world_position", x1, y1 )
				else
					ComponentSetValueVector2( comp, "world_position", x2, y2 )
					vars.verlet_point_index = last_point_index - 1
				end
		
				index = index + 1
			end)

		end   
		

		EntitySetVariable(line, "entity_1", "int", connector)
		EntitySetVariable(line, "entity_2", "int", bobber)


		EntitySetVariable(bobber, "rope_entity", "int", line)
	end
end