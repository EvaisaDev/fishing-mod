dofile_once("data/scripts/lib/utilities.lua")
dofile("mods/fishing/definitions/fish_list.lua")
dofile("mods/fishing/definitions/bait_list.lua")
dofile("mods/fishing/files/eva_utils.lua")
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

timeouts = timeouts or {}
was_hovering = was_hovering or {}

GuiBeginScrollContainer( gui, new_id(), (screen_width / 2 - (shop_width / 2)) - 2, ((screen_height / 2 - (shop_height / 2)) - 2) - 26, shop_width, shop_height, true, 2, 2 ) 

local shop_bait = {}

for k, v in pairs(bait_list)do
	if(v.price)then
		table.insert(shop_bait, v)
	end
end

Grid(gui, {items=shop_bait, x=0, y=0, size=4, padding_y = 78, offset_x = 2, ui_Scale = true}, function(item) 
	if(item.id ~= "any")then

		local times_bought = EntityGetVariable(entity_id, item.id.."_times_bought", "int") or 0

		local wallet_component = EntityGetFirstComponentIncludingDisabled(player, "WalletComponent")
		money_in_wallet = ComponentGetValue2(wallet_component, "money")

		local open_money = EntityGetVariable(entity_id, "player_money", "int") or 0


		local max_price_in_shop = 0

		for k, v in pairs(shop_bait)do
			if(v.price > max_price_in_shop)then
				max_price_in_shop = v.price
			end
		end


		current_item_price = item.price * 1.5 ^ times_bought


		local pre_rounded_price = math.max(item.price, current_item_price)

		local money_plus_tax = pre_rounded_price + (((item.price / max_price_in_shop) * open_money) / 4)

		local full_price = math.floor(((money_plus_tax + item.price/2) / item.price) * item.price); --math.floor(current_item_price * math.floor(pre_rounded_price / current_item_price))


		if(full_price > 9999999)then
			full_price = 9999999
		end



		if(money_in_wallet < full_price)then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		end

		GuiZSetForNextWidget(gui, -451)

		GuiOptionsAddForNextWidget( gui, GUI_OPTION.DrawNoHoverAnimation )
		GuiZSetForNextWidget(gui, -400)
		clicked = GuiImageButton( gui, new_id(), 0, 0, "", "mods/fishing/files/fisherman/button.png" )
		GuiTooltip( gui, "", item.ui_description )
		local last_clicked = false

		if(timeouts[item.id] == nil)then
			timeouts[item.id] = 0
		end

		if(was_hovering[item.id] == nil)then
			was_hovering[item.id] = false
		end

		if(clicked)then
			timeouts[item.id] = 10
		else
			if(timeouts[item.id] > 0)then
				timeouts[item.id] = timeouts[item.id] - 1
				last_clicked = true
			end
		end
		
		a, right_clicked, hovered, x, y, width, height = GuiGetPreviousWidgetInfo( gui )



		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.Align_HorizontalCenter )
		GuiZSetForNextWidget(gui, -420)

		if(last_clicked)then
			GuiColorSetForNextWidget( gui, 54 / 255, 42 / 255, 21 / 255, 1 )
		elseif(hovered)then
			GuiColorSetForNextWidget( gui, 126 / 255, 98 / 255, 57 / 255, 1 )
		else
			GuiColorSetForNextWidget( gui, 72 / 255, 55 / 255, 32 / 255, 1 )
		end

		text_w, text_h = GuiGetTextDimensions( gui, item.ui_name, 1, 2 )
		GuiText( gui, -(width / 2) - 2, (height / 2) - 29, item.ui_name )

		if(last_clicked)then
			GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1 )
		else
			GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
		end

		img_w, img_h = GuiGetImageDimensions( gui, item.sprite, 1 )

		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiZSetForNextWidget( gui, -410 )

		GuiImage( gui, new_id(), (-((img_w / 2) + (text_w / 2))) - 4, 30, item.sprite, 1, 1, 0, 0 )

		if(last_clicked)then
			GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1 )
		else
			GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
		end


		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiZSetForNextWidget( gui, -409 )
		GuiColorSetForNextWidget( gui, 0, 0, 0, 1 )
		GuiImage( gui, new_id(), -img_w, 32, item.sprite, 0.6, 1, 0, 0 )



		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiZSetForNextWidget( gui, -401 )


		if(last_clicked)then
			GuiImage( gui, new_id(), (((width - img_w) / 2) - width) - 2, 0, "mods/fishing/files/fisherman/button_clicked.png", 1, 1, 0, 0 )
		elseif(hovered)then
			GuiImage( gui, new_id(), (((width - img_w) / 2) - width) - 2, 0, "mods/fishing/files/fisherman/button_hover.png", 1, 1, 0, 0 )
		else
			GuiImage( gui, new_id(), (((width - img_w) / 2) - width) - 2, 0, "mods/fishing/files/fisherman/button.png", 1, 1, 0, 0 )
		end

		local offset_x, offset_y = -23, 52

		if(last_clicked)then
			GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 0.7 )
		else
			GuiColorSetForNextWidget( gui, 1, 1, 1, 0.7 )
		end

		local pricetag_image = "mods/fishing/files/fisherman/pricetag_1.png"

		if(full_price > 9999 and full_price <= 99999)then
			pricetag_image = "mods/fishing/files/fisherman/pricetag_2.png"
			offset_x = -26
		elseif(full_price > 99999)then
			pricetag_image = "mods/fishing/files/fisherman/pricetag_3.png"
			offset_x = -30
		end

		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiZSetForNextWidget( gui, -420 )
		text_w, text_h = GuiGetTextDimensions( gui, " $"..tostring(full_price), 1, 2 )
		GuiText( gui, ((0 + offset_x) - ((text_w / 2) + 2)), 0 + offset_y, " $"..tostring(full_price) ) 

		if(last_clicked)then
			GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1 )
		else
			GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
		end


		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiZSetForNextWidget( gui, -405 )
		GuiImage( gui, new_id(), (-width - text_w - offset_x) + (text_w / 2), 0, pricetag_image, 1, 1, 0, 0 )	

		if(last_clicked)then
			GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1 )
		else
			GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
		end

		GuiColorSetForNextWidget( gui, 0, 0, 0, 1 )
		GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
		GuiZSetForNextWidget( gui, -404 )
		GuiImage( gui, new_id(), -width, 2, pricetag_image, 0.6, 1, 0, 0 )	

		if(money_in_wallet < full_price)then
			GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiZSetForNextWidget( gui, -419 )
			GuiImage( gui, new_id(), -width - 8, 0, "mods/fishing/files/fisherman/crossed_out.png", 1, 1, 0, 0 )
		end


		if(hovered and not was_hovering[item.id])then
			GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_select", 0, 0)
		end




		if(clicked)then
			x, y = EntityGetTransform(entity_id)
			CreateItemActionEntity( item.id, x, y )
			ComponentSetValue2(wallet_component, "money", money_in_wallet - full_price)
			GamePlaySound( "data/audio/Desktop/ui.bank", "ui/button_click", 0, 0)
			EntityAddFlag(entity_id, "player_bought")
			EntitySetVariable(entity_id, item.id.."_times_bought", "int", times_bought + 1)
			EntitySetVariable(entity_id, "inflation_countdown", "int", 18000)
		end

		if(hovered)then
			was_hovering[item.id] = true
		else
			was_hovering[item.id] = false
		end
	end
end)

GuiText(gui, 0, 0, "  ")

GuiEndScrollContainer( gui )
