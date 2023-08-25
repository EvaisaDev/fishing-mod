dofile_once("data/scripts/lib/coroutines.lua")
dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/fishing/files/eva_utils.lua")
dofile_once("mods/fishing/files/gui_utils.lua")
entity_id = GetUpdatedEntityID()

gui = GuiCreate()



lifetime_component = EntityGetFirstComponent(entity_id, "LifetimeComponent")


if(lifetime_component == nil)then
	return
end
--print(background_sprite)

reverse = false

speed = 1.5

bobber = EntityGetVariable(entity_id, "bobber_id", "int") or nil

speed_add = EntityGetVariable(entity_id, "speed", "int") or 0

--GamePrint("Speed Add = "..speed_add)

speed = speed + ((speed_add / 100) * 2)

catch_frame = Random(0, 92)

current_frame = 50

--GamePrint("Speed = "..speed)

if(bobber ~= nil)then

	async_loop(function()

		kill_frame = ComponentGetValue2(lifetime_component, "kill_frame")
		--GamePrint("lifetime: "..tostring(kill_frame - GameGetFrameNum()))
		if(kill_frame - GameGetFrameNum() == 1 or GameHasFlagRun("kill_fishing_challenge_ui"))then
			GameRemoveFlagRun("kill_fishing_challenge_ui")
			GuiDestroy(gui)
			EntityKill(entity_id)
			--GamePrint("Rawr as heck")
		else
			

			GuiStartFrame(gui)
			GuiIdPushString( gui, "fishing" )
			
			w, h = GuiGetScreenDimensions( gui )

			GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )
			
			if(not EntityHasFlag(bobber, "return_bobber"))then
				if(current_frame >= 99)then
					reverse = true
				end
				if(current_frame <= 1)then
					reverse = false
				end

				if(reverse)then
					current_frame = current_frame - speed
				else
					current_frame = current_frame + speed
				end

				if(current_frame >= catch_frame and current_frame <= catch_frame + 8)then
					GameAddFlagRun("allow_catch_fish")
					--GamePrint("Current frame allows catching.")
				else
					GameRemoveFlagRun("allow_catch_fish")
				end
			end


			--GamePrint("Current fish frame: "..current_frame)

			GuiZSetForNextWidget(gui, -510)
			img_w, img_h = GuiGetImageDimensions( gui, "mods/fishing/files/ui/square.png", 1 )
			GuiImage( gui, NextID(), (((w / 2) - (img_w / 2)) - 50) + 100, h - 53.5 - 5, "mods/fishing/files/ui/square.png", 1, 1, 7, 0 )

			GuiZSetForNextWidget(gui, -510)
			img_w, img_h = GuiGetImageDimensions( gui, "mods/fishing/files/ui/square.png", 1 )
			GuiImage( gui, NextID(), (((w / 2) - (img_w / 2)) - 50), h - 53.5 - 5, "mods/fishing/files/ui/square.png", 1, 1, 7, 0 )

			GuiZSetForNextWidget(gui, -510)
			img_w, img_h = GuiGetImageDimensions( gui, "mods/fishing/files/ui/square.png", 100 )
			GuiImage( gui, NextID(), (w / 2) - (img_w / 2), h - 50 - 5, "mods/fishing/files/ui/square.png", 1, 100, 1, 0 )

			GuiColorSetForNextWidget( gui, 1, 0.3, 0.3, 0.5 )
			GuiZSetForNextWidget(gui, -512)
			img_w, img_h = GuiGetImageDimensions( gui, "mods/fishing/files/ui/square.png", 1 )
			GuiImage( gui, NextID(), (((w / 2) - (img_w / 2)) - 50) + catch_frame, h - 50 - 5, "mods/fishing/files/ui/square.png", 1, 8, 1, 0 )

			GuiColorSetForNextWidget( gui, 1, 1, 1, 0.5 )
			GuiZSetForNextWidget(gui, -514)
			img_w, img_h = GuiGetImageDimensions( gui, "mods/fishing/files/ui/square.png", 1 )
			GuiImage( gui, NextID(), (((w / 2) - (img_w / 2)) - 50) + current_frame, h - 53.5 - 5, "mods/fishing/files/ui/square.png", 1, 1, 7, 0 )
		end
		wait(0.1)
	end)
end