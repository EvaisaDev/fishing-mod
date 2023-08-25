dofile_once("mods/fishing/files/eva_utils.lua")
dofile_once("mods/fishing/files/fish_utils.lua")
dofile_once("mods/fishing/definitions/fish_list.lua")
dofile_once("data/scripts/lib/utilities.lua")

bobber = GetUpdatedEntityID()

fishing_frame = tonumber(GlobalsGetValue(bobber.."_frame", 0))

x, y = EntityGetTransform(bobber)

projectile_component = EntityGetFirstComponent(bobber, "ProjectileComponent")

bobber_owner = ComponentGetValue2(projectile_component, "mWhoShot")

player = get_players()[1]

rod = EntityGetVariable(bobber, "rod_entity", "int")

return_bobber = EntityHasFlag(bobber, "return_bobber")

function has_catch() 
	return EntityHasFlag(bobber, "has_catch") 
end


GlobalsSetValue(bobber.."_frame", fishing_frame + 1)

fish_string = EntityGetVariable(bobber, "catch_id", "string") or nil

fish = nil

for k, v in pairs(fish_list)do
	if(v.id == fish_string)then
		fish = v
	end
end

if(bobber_owner == 0 and fishing_frame <= 10)then
	EntitySetVariable(bobber, "fish_count", "int", Random(3, 7))
	return 
elseif(bobber_owner == 0 and fishing_frame > 10)then
	print("Death to the bobber!")

	EntityKill(bobber)
	return 
end

if(bobber_owner ~= player or player == nil)then
	print("rawr")
	rope_entity = EntityGetVariable(bobber, "rope_entity", "int")
	if(rope_entity ~= nil and rope_entity ~= 0)then
		EntityKill(rope_entity)
	end
	EntityKill(bobber)
	return
end

owner_x, owner_y = EntityGetTransform(bobber_owner)


if(rod == nil or rod == 0)then
	rods = EntityGetInRadiusWithTag(owner_x, owner_y, 10, "fishing_rod") or {}

	rod = rods[1]

	EntitySetVariable(bobber, "rod_entity", "int", rod or 0)
end

if(rod == nil)then
	return
end

local x1, y1, rotation = EntityGetTransform(rod)
local x2, y2 = EntityGetTransform(bobber)

y2 = y2 - 4

local rx = math.cos(rotation)
local ry = math.sin(rotation)

x1 = x1 + (rx * 30)
y1 = y1 + (ry * 30)

trajectoryHeight = -50


if return_bobber then

	fish_in_range2 = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish_sprite") or {}

	for k, v in pairs(fish_in_range2)do
		
		local fish_x, fish_y = EntityGetTransform(v) 
		EntityLoad("mods/fishing/files/poof_black.xml", fish_x, fish_y)
		--EntityKill(v)
	end
	
	fish_in_range = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish") or {}

	for k, v in pairs(fish_in_range)do
		
		EntityKill(v)
	end


	player_x = EntityGetVariable(bobber, "last_position_player_x", "int")
	player_y = EntityGetVariable(bobber, "last_position_player_y", "int")

	bobber_x = EntityGetVariable(bobber, "last_position_x", "int")
	bobber_y = EntityGetVariable(bobber, "last_position_y", "int")

	GamePrint("Returning to master.")
	
	local cTime = math.max(math.min((GameGetFrameNum() - EntityGetVariable(bobber, "frame_num_start", "int")) / 20, 2),0)

	--GamePrint(cTime)

	current_x = math.lerp(bobber_x, player_x, cTime);
	current_y = math.lerp(bobber_y, player_y, cTime);

	current_y = current_y + (trajectoryHeight * math.sin(math.clamp(cTime / 2, 0, 1) * math.pi))

	EntityApplyTransform(bobber, current_x, current_y)

	if(cTime == 2)then
		if(has_catch())then
			
			
			
			--print(tostring(fish))
			fish_size = EntityGetVariable(bobber, "weight", "float")
			
			GameAddFlagRun("caught_fish_"..fish.id)

			local total_count = tonumber(GlobalsGetValue( "count_"..fish.id, "0" ))

			GlobalsSetValue( "count_"..fish.id, tostring(total_count + 1) )


			--GamePrint(fish.name)
			if(fish.splash_screen)then
				catch_ui(fish, fish_size)
				GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/chest/create", owner_x, owner_y)
			end
			if(fish.drop_fish)then
				fish_object = create_fish_object(fish, owner_x, owner_y, fish_size)
			end
		end
		GameAddFlagRun("kill_fishing_challenge_ui")
		EntityKill(bobber);
	end
end


if(EntityGetVariable(bobber, "rope_entity", "int") == 0)then
	line = EntityLoad("mods/fishing/files/line/rope.xml", owner_x, owner_y)
	
	EntityAddChild(bobber_owner, line)

	EntityAddComponent( line, "VerletWorldJointComponent" )
	EntityAddComponent( line, "VerletWorldJointComponent" )

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

	EntitySetVariable(line, "entity_1", "int", rod)
	EntitySetVariable(line, "entity_2", "int", bobber)
	
	EntitySetVariable(rod, "bobber_entity", "int", bobber)
	EntitySetVariable(rod, "rope_entity", "int", line)

	EntitySetVariable(bobber, "rope_entity", "int", line)
end

in_liquid = false;

--GamePrint("Has catch? "..tostring(has_catch()))

if(not return_bobber and not (has_catch()))then

	did_hit = RaytraceSurfacesAndLiquiform( x2, y2 - 2, x2, y2 - 4 )

	if(did_hit)then

		
		in_liquid = true

		vel_comp = EntityGetFirstComponent(bobber, "VelocityComponent")
		ComponentSetValue2(vel_comp, "mVelocity", 0, -50)
	end

end

if(not return_bobber and has_catch())then

	if(GameGetFrameNum() % 10 == 0)then

		did_hit = RaytraceSurfacesAndLiquiform( x2, y2 - 8, x2, y2 - 10 )

		if(did_hit)then

			
			in_liquid = true

			vel_comp = EntityGetFirstComponent(bobber, "VelocityComponent")
			ComponentSetValue2(vel_comp, "mVelocity", 0, -50)
		end

	end
end


if(return_bobber and not GameHasFlagRun("allow_catch_fish") and EntityHasFlag(bobber,"has_catch"))then
	EntityRemoveFlag(bobber,"has_catch")

	direction_sound = get_direction( owner_x, owner_y, x, y )

	direction_sound_x, direction_sound_y = rad_to_vec( direction_sound )

	GamePlaySound( "data/audio/Desktop/materials.bank", "collision/wood_break", owner_x + (direction_sound_x * 1.2), owner_y + (direction_sound_y * 1.2))
	GamePlaySound( "data/audio/Desktop/materials.bank", "materials/liquid_splash", owner_x + (direction_sound_x * 1.2), owner_y + (direction_sound_y * 1.2))
	GamePlaySound( "data/audio/Desktop/materials.bank", "collision/chain_break	", owner_x + (direction_sound_x * 1.2), owner_y + (direction_sound_y * 1.2))

	EntityLoad("mods/fishing/files/splash2.xml", x, y)
	EntityRemoveFlag(bobber, "is_catch_allowed")
	EntityAddFlag(bobber, "failed_catch")

	EntityLoad("mods/fishing/files/poof_black.xml", x2, y2)

	EntitySetComponentsWithTagEnabled( bobber, "fish_catch", false )

	GamePrint("The fish got away!")

	fish_in_range2 = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish_sprite") or {}

	for k, v in pairs(fish_in_range2)do
		
		local fish_x, fish_y = EntityGetTransform(v) 
		EntityLoad("mods/fishing/files/poof_black.xml", fish_x, fish_y)
		--EntityKill(v)
	end
	
	fish_in_range = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish") or {}

	for k, v in pairs(fish_in_range)do
		
		EntityKill(v)
	end
end

catch_frame = EntityGetVariable(bobber, "catch_frame", "int") or GameGetFrameNum()

if(fish ~= nil and not return_bobber)then
	--GamePrint(tostring((GameGetFrameNum() - catch_frame) / 60)..">"..tostring(fish.catch_seconds))

	if(has_catch() and ((GameGetFrameNum() - catch_frame) / 60) > fish.catch_seconds)then
		EntityRemoveFlag(bobber,"has_catch")

		direction_sound = get_direction( owner_x, owner_y, x, y )

		direction_sound_x, direction_sound_y = rad_to_vec( direction_sound )

		GamePlaySound( "data/audio/Desktop/materials.bank", "collision/wood_break", owner_x + (direction_sound_x * 1.2), owner_y + (direction_sound_y * 1.2))
		GamePlaySound( "data/audio/Desktop/materials.bank", "materials/liquid_splash", owner_x + (direction_sound_x * 1.2), owner_y + (direction_sound_y * 1.2))
		EntityLoad("mods/fishing/files/splash2.xml", x, y)
		EntityRemoveFlag(bobber, "is_catch_allowed")
		EntityAddFlag(bobber, "failed_catch")

		EntityLoad("mods/fishing/files/poof_black.xml", x2, y2)

		EntitySetComponentsWithTagEnabled( bobber, "fish_catch", false )

		GamePrint("The fish got away!")

		fish_in_range2 = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish_sprite") or {}

		for k, v in pairs(fish_in_range2)do
			
			local fish_x, fish_y = EntityGetTransform(v) 
			EntityLoad("mods/fishing/files/poof_black.xml", fish_x, fish_y)
			--EntityKill(v)
		end
		
		fish_in_range = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish") or {}
	
		for k, v in pairs(fish_in_range)do
			
			EntityKill(v)
		end
	
	end
end
if(in_liquid)then

	-- Check if water is atleast 20 pixels deep
	did_hit = RaytraceSurfaces( x2, y2, x2, y2 + 50 )

	if(not did_hit)then
		-- Code that runs when the bobber is in a liquid
		--local material_inventory = EntityGetFirstComponent(bobber, "MaterialInventoryComponent")

		local liquid_type = nil

		local material_sucker = EntityGetFirstComponent(bobber, "MaterialSuckerComponent")

		local material_id = ComponentGetValue2( material_sucker, "last_material_id");

		if(material_id)then
			liquid_type = CellFactory_GetName(material_id)

			GamePrint(liquid_type)
		end

		--[[
		if(material_inventory)then
			local count_per_material_type = ComponentGetValue2( material_inventory, "count_per_material_type");
			for k,v in pairs(count_per_material_type) do
				if v ~= 0 then --material exists in the inventory
					liquid_type = CellFactory_GetName(k-1)
				end
			end
		end
		]]

		if( liquid_type ~= nil )then

			allow_catch = EntityHasFlag(bobber, "is_catch_allowed")

			--GamePrint("Any fish? ModCheck: "..tostring(any_fish_available(liquid_type)))

			if(any_fish_available(liquid_type))then
				fish_in_range = EntityGetInRadiusWithTag(x2, y2, 200, "cosmetic_fish") or {}

				

				if(not has_catch() and not EntityHasFlag(bobber, "failed_catch"))then
					if(#fish_in_range <= EntityGetVariable(bobber, "fish_count", "int"))then
						new_fish = EntityCreateNew()
						EntityAddTag(new_fish, "cosmetic_fish")

						EntityAddChild(bobber, new_fish)

						if(#fish_in_range == EntityGetVariable(bobber, "fish_count", "int"))then
							EntityAddFlag(bobber, "is_catch_allowed")
						end

						

						fish_x = x2
						fish_y = y2 + 10 + Random(5, 20)

						did_hit_left, left_x, left_y = RaytraceSurfaces( fish_x, fish_y, fish_x - 30, fish_y )
						did_hit_right, right_x, right_y = RaytraceSurfaces( fish_x, fish_y, fish_x + 30, fish_y )

						fish_width = math.min(math.min(math.abs(fish_x - left_x) * 2, math.abs(right_x - fish_x) * 2), 50) - 10

						if(fish_width > 5)then

							--GamePrint("Fish Width: "..fish_width)

							EntitySetTransform(new_fish, fish_x, fish_y)

							EntitySetVariable(new_fish, "offset_x", "int", fish_x - x2)
							EntitySetVariable(new_fish, "offset_y", "int", fish_y - y2)


							EntityAddComponent2(new_fish, "LuaComponent", {
								execute_on_added = true,
								script_source_file="mods/fishing/files/relative_inherit.lua",
								execute_every_n_frame=1,
							})
							--ComponentObjectSetValue2(inherit_transform, "Transform", "position", fish_x - x, fish_y - y)
							
							
							fish_sprite = EntityLoad("mods/fishing/files/fish/shadows/fish"..Random(1, 5)..".xml", x2 + Random(-20, 20), y2 + 10 + Random(5, 20))

							

							EntitySetVariable(fish_sprite, "fish_width", "int", fish_width)

							EntityAddChild(new_fish, fish_sprite)

							EntityAddTag(fish_sprite, "cosmetic_fish_sprite")
	
						end
					end
				end

				-- GamePrint(liquid_type)
				-- We are in a liquid and know the type of the liquid

				if(allow_catch and not EntityHasFlag(bobber, "failed_catch"))then

					caught_fish = (Random(1, 10000) / 1000) <= 1000.05

					if(caught_fish and not has_catch())then


						EntityAddFlag(bobber,"has_catch")

						EntitySetComponentsWithTagEnabled( bobber, "bait_sprite", false )

						EntitySetComponentsWithTagEnabled( bobber, "fish_catch", true )


						EntityLoad("mods/fishing/files/splash.xml", x, y)

						direction_sound = get_direction( owner_x, owner_y, x, y )

						direction_sound_x, direction_sound_y = rad_to_vec( direction_sound )

						
						GamePlaySound( "data/audio/Desktop/animals.bank", "animals/generic/attack_bite", owner_x + (direction_sound_x * 1.2), owner_y + (direction_sound_y * 1.2))
						
						

						EntitySetVariable(bobber, "catch_frame", "int", GameGetFrameNum())

						fish = catch(EntityGetVariable(bobber, "bait_type", "string"), x, y, liquid_type)


						EntitySetVariable(bobber, "catch_id", "string", fish.id)


						fish_size = Random(fish.sizes.min * 100, fish.sizes.max * 100) / 100

						EntitySetVariable(bobber, "weight", "float", fish_size)

						local ui = EntityCreateNew()

						speed = ((fish.difficulty / 100) + ((fish_size / fish.sizes.max) / 3)) * 100--((100 - ((fish.sizes.max + (fish_size*-1)) * 100 / (fish.sizes.max - fish.sizes.min))) / 100) * fish.difficulty

						--GamePrint("speed = "..tostring(speed))

						EntitySetVariable(ui, "speed", "int", speed)

						EntitySetVariable(ui, "bobber_id", "int", bobber)

						EntityAddComponent2(ui, "LifetimeComponent", {
							lifetime = fish.catch_seconds * 60
						})
					
						EntityAddComponent2(ui, "LuaComponent", {
							script_source_file="mods/fishing/files/ui/catch_challenge.lua",
							vm_type="ONE_PER_COMPONENT_INSTANCE",
							execute_on_added=true,
							execute_every_n_frame=-1,
							execute_times=1,
							enable_coroutines=true,
						})

						--GamePrint(has_catch())
					end
				end
			end
		end
	end
end