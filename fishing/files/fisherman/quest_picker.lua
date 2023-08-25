dofile_once("data/scripts/lib/utilities.lua")
dofile("mods/fishing/definitions/fish_list.lua")
dofile("mods/fishing/files/gui_utils.lua")

gui = gui or GuiCreate()
local entity_id = GetUpdatedEntityID()

local player = get_players()[1]

if(player == nil)then
	return
end

current_id = 1353251

function new_id()
    current_id = current_id + 1
    return current_id
end

GuiStartFrame(gui)

screen_width, screen_height = GuiGetScreenDimensions( gui );
GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )

local shop_width = 296
local shop_height = 156

--last_height = last_height or 0

QuestButton = function(fish)
	GuiZSetForNextWidget(gui, -450)
	AutoBox(gui, new_id(), 0, 0, function() 
		GuiLayoutBeginHorizontal(gui, 8, 8, true)
			-- set Z to -455
			GuiZSet(gui, -455)
			-- create a GUI text with the fish name
			GuiText(gui, 0, 0, fish.name)
			-- get the text dimensions of fish.name
			local text_width, text_height = GuiGetTextDimensions(gui, fish.name)
			-- get the image dimensions of the fish ui sprite
			local image_width, image_height = GuiGetImageDimensions(gui, fish.ui_sprite)
		GuiLayoutEnd(gui)
	end)
	
	--GuiBeginScrollContainer( gui, new_id(), 0, 0, shop_width - 5, 50, true, 2, 2 ) 

	--GuiEndScrollContainer( gui )
	--local clicked, right_clicked, hovered, x, y, width, height, draw_x, draw_y, draw_width, draw_height = GuiGetPreviousWidgetInfo( gui )
	--last_height = height
	--GamePrint(last_height)
end

GuiZSetForNextWidget(gui, -445)
GuiBeginScrollContainer( gui, new_id(), (screen_width / 2 - (shop_width / 2)) - 2, ((screen_height / 2 - (shop_height / 2)) - 2) - 26, shop_width, shop_height, true, 2, 2 ) 
	GuiLayoutBeginVertical(gui, 0, 0, true)
		QuestButton(fish_list[1])
	GuiLayoutEnd(gui)
	GuiText(gui, 0, 0, "  ")
GuiEndScrollContainer( gui )


