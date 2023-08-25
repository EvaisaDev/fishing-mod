dofile_once("data/scripts/lib/utilities.lua")
dofile_once("mods/fishing/files/fish_utils.lua")
dofile("mods/fishing/definitions/fish_list.lua")
dofile("mods/fishing/files/eva_utils.lua")
dofile("mods/fishing/files/gui_utils.lua")
gui = gui or GuiCreate()

current_id = 215215

function new_id()
    current_id = current_id + 1
    return current_id
end

tablet_offset = tablet_offset or 2

book_open = book_open or false

screen_width, screen_height = GuiGetScreenDimensions( gui );

GuiStartFrame(gui)

GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )

selected_fish_id = selected_fish_id or {}

active_fish = active_fish or nil

local player = get_players()[1]

if(player == nil)then return end

player_x,  player_y = EntityGetTransform(player)

local controls_component = EntityGetFirstComponent(player, "ControlsComponent")

local x, y = ComponentGetValue2(controls_component, "mMousePosition")
local virt_x = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X")
local virt_y = MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y")
local scale_x = virt_x / screen_width
local scale_y = virt_y / screen_height
local cx, cy = GameGetCameraPos()
local sx, sy = (x - cx) / scale_x + screen_width / 2 + 1.5, (y - cy) / scale_y + screen_height / 2

if(GuiImageButton( gui, new_id(), screen_width - 25, screen_height - 25 - (ModIsEnabled( "raksa" ) and 20 or 0), "", book_open and "mods/fishing/files/ui/logbook/logbutton_enabled.png" or "mods/fishing/files/ui/logbook/logbutton_disabled.png" ))then

	GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/bullet_burst_of_air/create", player_x, player_y)
	if(book_open)then
		book_open = false
	else
		book_open = true
	end
end

if book_open then

	draw_tablet()
	draw_fish_list()

	if(tablet_offset > 0)then
		tablet_offset = tablet_offset - 0.1
	end
else
	if(tablet_offset < 2)then
		draw_tablet()
		draw_fish_list()
		tablet_offset = tablet_offset + 0.1
	end
end

function draw_tablet()
	GuiZSetForNextWidget( gui, -500 )
	img_width, img_height = GuiGetImageDimensions( gui, "mods/fishing/files/ui/logbook/tablet.png", 1 )
	GuiImage( gui, new_id(), (screen_width / 2) - (img_width / 2), ((screen_height / 2) - (img_height / 2)) + (img_height * tablet_offset), "mods/fishing/files/ui/logbook/tablet.png", 1, 1, 0, 0 )
	
	GuiZSetForNextWidget( gui, -481 )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	GuiImage( gui, new_id(), (screen_width / 2) - (img_width / 2), ((screen_height / 2) - (img_height / 2)) + (img_height * tablet_offset), "mods/fishing/files/ui/logbook/screen.png", 1, 1, 0, 0 )
	
	GuiZSetForNextWidget( gui, -499 )
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	GuiImage( gui, new_id(), (screen_width / 2) - (img_width / 2), ((screen_height / 2) - (img_height / 2)) + (img_height * tablet_offset), "mods/fishing/files/ui/logbook/scanlines.xml", 0.02, 1, 0, 0, GUI_RECT_ANIMATION_PLAYBACK.Loop, "default" )
end

function draw_fish_list()

	local list_width = 130
	local info_width = 138


	-- fish list container
	GuiZSetForNextWidget( gui, -480 )

	--[[
	container_x1 = (screen_width / 2) - (img_width / 2) + 16 + 9
	container_x2 = container_x1 + list_width
	container_y1 = ((screen_height / 2) - (img_height / 2) + 15) + (img_height * tablet_offset)
	container_y2 = container_y1 + 184

	if(sx < container_x1 or sx > container_x2 or sy < container_y1 or sy > container_y2)then
		--GamePrint("Out of bound!")
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.IgnoreContainer )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.Disabled)
	end
	]]

	GuiBeginScrollContainer( gui, new_id(), (screen_width / 2) - (img_width / 2) + 16, ((screen_height / 2) - (img_height / 2) + 15) + (img_height * tablet_offset), list_width, 184, true, 0, 0)

	local count = 0

	Grid(gui, {items=fish_list, x=2, y=2, size=1, padding_y = 78, ui_Scale = true}, function(item) 
		--print(table.dump(item))	
		count = count + 1
		fish_button(item, count)
	end)

	GuiLayoutBeginVertical( gui, 0,0, false, 0, 0 )
	for i = 0, 30 do
		GuiText(gui, 0, 0, "  ")
	end
	GuiLayoutEnd( gui )

	GuiEndScrollContainer( gui )

	-- info container
	GuiZSetForNextWidget( gui, -480 )
	GuiBeginScrollContainer( gui, new_id(), (screen_width / 2) - (img_width / 2) + 27 + list_width, ((screen_height / 2) - (img_height / 2) + 15) + (img_height * tablet_offset), info_width, 184, true, 0, 0)
	GuiLayoutBeginVertical( gui, 0,0, true, 0, 0 )
	draw_info_screen(info_width, 184)
	GuiLayoutEnd( gui )
	GuiEndScrollContainer( gui )	
end

function draw_info_screen(container_width, container_height)
	local fish = active_fish
	if(fish ~= nil)then
		local discovered = GameHasFlagRun("caught_fish_"..fish.id) or fish.always_discovered
		if(discovered)then
			width, height = TextSize(gui, "mods/fishing/files/ui/logbook/header_font", 0, 0, 1, -481, fish.name, 2)
			DrawText(gui, "mods/fishing/files/ui/logbook/header_font", (container_width / 2) - (width / 2), 5, 1, -485, fish.name, "80cde8c5", 2)

			local description = split(fish.description, 35)

			for k,v in pairs(description)do
				GuiColorSetForNextWidget( gui, 214 / 255, 224 / 255, 195 / 255, 1 )
				GuiZSetForNextWidget(gui, -490)
				text_w, text_h = GuiGetTextDimensions( gui, v, 1, 2 )
				GuiText( gui, (container_width / 2) - (text_w / 2), (k == 1 and 20 or 0), v )
			end

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Biomes", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Biomes" )

			for k,v in pairs(fish.biomes)do

				local entry = find_entry_with_id(biome_list, v)
				if(entry ~= nil)then 
		

					GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
					GuiZSetForNextWidget(gui, -490)
					text_w, text_h = GuiGetTextDimensions( gui, entry.ui_name, 1, 2 )
					GuiText( gui, (container_width / 2) - (text_w / 2), 1, entry.ui_name )	
				end
			end

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Liquids", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Liquids" )

			for k,v in pairs(fish.liquids)do
				local entry = find_entry_with_id(materials_list, v)
				if(entry ~= nil)then 
		
					GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
					GuiZSetForNextWidget(gui, -490)
					text_w, text_h = GuiGetTextDimensions( gui, entry.ui_name, 1, 2 )
					GuiText( gui, (container_width / 2) - (text_w / 2), 1, entry.ui_name )
					
				end
			end
			
			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Bait", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Bait" )

			for k,v in pairs(fish.bait_types)do
				local entry = find_entry_with_id(bait_list, v)
				if(entry ~= nil)then 
		
					GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
					GuiZSetForNextWidget(gui, -490)
					text_w, text_h = GuiGetTextDimensions( gui, entry.ui_name, 1, 2 )
					GuiText( gui, (container_width / 2) - (text_w / 2), 1, entry.ui_name )	
				end
			end

			--[[
			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Depth", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Depth" )

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Y"..fish.depth.min.." to ".."Y"..fish.depth.max, 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 1, "Y"..fish.depth.min.." to ".."Y"..fish.depth.max )	
			]]

						
			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Size", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Size" )

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Min: "..fish.sizes.min.."kg", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 1, "Min: "..fish.sizes.min.."kg" )	

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Max: "..fish.sizes.max.."kg", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 1, "Max: "..fish.sizes.max.."kg" )
			
			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Catch Probability", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Catch Probability" )

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, fish.probability.."%", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 1, fish.probability.."%" )	

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 0.7 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, "Difficulty", 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 10, "Difficulty" )

			GuiColorSetForNextWidget( gui, 194 / 255, 204 / 255, 175 / 255, 1 )
			GuiZSetForNextWidget(gui, -490)
			text_w, text_h = GuiGetTextDimensions( gui, fish.difficulty, 1, 2 )
			GuiText( gui, (container_width / 2) - (text_w / 2), 1, fish.difficulty )	


			for i = 0, 10 do
				GuiText(gui, 0, 0, "  ")
			end
		else
			width, height = TextSize(gui, "mods/fishing/files/ui/logbook/header_font", 0, 0, 1, -481, "???", 2)
			DrawText(gui, "mods/fishing/files/ui/logbook/header_font", (container_width / 2) - (width / 2), 5, 1, -485, "???", "80cde8c5", 2)

			local description = split("Try fishing in different liquids and places with different baits to discover this fish.", 35)

			for k,v in pairs(description)do
				GuiColorSetForNextWidget( gui, 214 / 255, 224 / 255, 195 / 255, 1 )
				GuiZSetForNextWidget(gui, -490)
				text_w, text_h = GuiGetTextDimensions( gui, v, 1, 2 )
				GuiText( gui, (container_width / 2) - (text_w / 2), (k == 1 and 20 or 0), v )
			end
		end
	end
end

last_hovered = last_hovered or 0

function fish_button(fish, index)
	
	local offset_x = 0
	local offset_y = 0

	local discovered = GameHasFlagRun("caught_fish_"..fish.id) or fish.always_discovered

	local being_hovered = (last_hovered == index)

	local size_multiplier = being_hovered and 1.005 or 1


	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )


	-- Outline

	GuiZSetForNextWidget(gui, -489)
	GuiColorSetForNextWidget( gui, 0.8, 0.8, 0.8, 1 )
	if(selected_fish_id == index)then
		GuiImage( gui, new_id(), -1, 0, "mods/fishing/files/ui/logbook/button_outline.png", 0.8, (1 * size_multiplier), 0, 0)
	else
		GuiImage( gui, new_id(), -1, 0, "mods/fishing/files/ui/logbook/button_outline.png", 0, (1 * size_multiplier), 0, 0)
	end

	local a, b, c, x, y, width, height = GuiGetPreviousWidgetInfo( gui )

	local background_alpha = discovered and 1 or 0.5

	GuiZSetForNextWidget(gui, -490)
	local img_w, img_h = GuiGetImageDimensions( gui, "mods/fishing/files/ui/logbook/log_backgrounds/default.png", 1 * size_multiplier )
	local next_width = -((width / 2) + (img_w / 2)) - 2
	local next_height = ((height / 2) - (img_h / 2))
	GuiImage( gui, new_id(), next_width, next_height, "mods/fishing/files/ui/logbook/log_backgrounds/default.png", background_alpha, 1 * size_multiplier, 0, 0)

	local clicked, right_clicked, hovered, x, y, width, height = GuiGetPreviousWidgetInfo( gui )
	
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	GuiZSetForNextWidget(gui, -495)
	if(not discovered)then
		GuiColorSetForNextWidget( gui, 0, 0, 0, 1 )
	else
		GuiColorSetForNextWidget( gui, 214 / 255, 224 / 255, 195 / 255, 1 )
	end

	local fish_alpha = discovered and 1 or 0.3

	img_w, img_h = GuiGetImageDimensions( gui, fish.ui_sprite, 1 * size_multiplier)

	GuiImage( gui, new_id(), -((width / 2) + (img_w / 2)), ((height / 2) - (img_h / 2)), fish.ui_sprite, fish_alpha, 1 * size_multiplier, 0, 0)

	a, b, c, x, y, width, height = GuiGetPreviousWidgetInfo( gui )


	
	GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
	GuiColorSetForNextWidget( gui, 214 / 255, 224 / 255, 195 / 255, 1 )
	GuiZSetForNextWidget(gui, -498)

	local ui_name = fish.name

	if(not discovered)then
		ui_name = "???"
	end

	text_w, text_h = GuiGetTextDimensions( gui, ui_name, 1, 2 )
	GuiText( gui, -((width / 2) + (text_w / 2)) - 1, ((height / 2) + (text_h / 2)) - 25, ui_name )

	--GamePrint("Render ID: "..tostring(index))
	--GamePrint("Last hovered ID: "..tostring(last_hovered))

	if(hovered)then
		if(last_hovered ~= index)then
			--GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_selected", cam_x, cam_y )
			GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", player_x, player_y)
		end
		last_hovered = index

		--GamePrint("Hovering over ID "..tostring(last_hovered))
	else

		if(last_hovered == index)then
			--GamePrint("Stopped hovering over ID "..tostring(last_hovered))
			last_hovered = 0
		end
	end

	if(clicked)then
		selected_fish_id = index
		active_fish = fish
		GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", player_x, player_y)
	end


end