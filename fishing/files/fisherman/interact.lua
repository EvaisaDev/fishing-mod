
local dialog_system = dofile_once("mods/fishing/lib/DialogSystem/dialog_system.lua")
dialog_system.dialog_sounds.fisherman = {  
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/1"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/2"},
	--{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/3"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/4"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/5"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/6"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/7"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/8"},
	{bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/9"},
}

dialog_system.char_sounds.fisherman = {  
	--[[{char = "a", bank = "mods/fishing/fishing_mod.bank", event = "special/aa"},
	{char = "e", bank = "mods/fishing/fishing_mod.bank", event = "special/ee"},
	{char = "o", bank = "mods/fishing/fishing_mod.bank", event = "special/oo"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "special/audiojungle"},]]
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/1"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/2"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/4"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/5"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/6"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/7"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/8"},
	{char = " ", bank = "mods/fishing/fishing_mod.bank", event = "fisherman/grunt/9"},
}

dialog_system.distance_to_close = 25

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)

function interacting(entity_who_interacted, entity_interacted, interactable_name)
	-- Remove before shipping
	--GameAddFlagRun("has_quest")

	-- Remove before shipping
	if(not GameHasFlagRun("completed_introduction"))then
		introduction(entity_who_interacted, entity_interacted, interactable_name)
	else
		if(not GameHasFlagRun("has_quest"))then
			shop_or_quest(entity_who_interacted)
		else
			shop_interaction(entity_who_interacted)
		end
	end
end

local greetings = {
	"Hey! If it isn't my witch friend!",
	"Look who it is! The trouble maker!",
	"Great fishing day!",
	"How is my fishing friend doing?",
	"Good day!"
}

function shop_or_quest(entity_who_interacted)

	dialog = dialog_system.open_dialog({
		name = "Fisherman",
		portrait = "mods/fishing/files/fisherman/portrait.xml",
		animation = "stand", 
		typing_sound = "none",
		dialog_sound = "fisherman",
		char_sound = "none",
		every_x_char = 3,
		text = "{@delay 1.4}"..greetings[Random(1, #greetings)].."\nLooking to buy something or need a job?",
		options = {
			{
				text = "What are you selling?",
				func = function(dialog)
					open_shop(dialog, entity_who_interacted)
				end
			},
			{
				text = "What kind of jobs do you have?",
				func = function(dialog)
					open_quests(dialog, entity_who_interacted)
				end
			},
			{
				text = "Nevermind.",
				func = function(dialog)
					dialog.close()
				end
			},
		}
	})
end

function open_quests(dialog, entity_who_interacted)
	EntitySetComponentsWithTagEnabled( entity_id, "open_quests", true )

	dialog.show({
		name = " Fisherman's Jobs ",
		portrait = "mods/fishing/files/fisherman/portrait.xml",
		animation = "stand",
		on_closing = function()
			dialog.message.name = "Fisherman"
			dialog.message.nametag_offset = 0
			EntitySetComponentsWithTagEnabled( entity_id, "open_quests", false )
		end,
		shop_override = shop_buy_loop,
		nametag_offset = 166,
		text = [[
			{@delay 1.4}These are the fish I need right now.
			You can select one of them and bring me that fish.
			If you want to cancel your active job you can talk to me.
		]],
		options = {
			{
				text = "Good bye.",
				func = function(dialog)
					dialog.close()
				end
			},
		}
	})
end

function shop_interaction(entity_who_interacted)
	dialog = dialog_system.open_dialog({
		name = "Fisherman",
		portrait = "mods/fishing/files/fisherman/portrait.xml",
		animation = "stand", 
		typing_sound = "none",
		dialog_sound = "fisherman",
		char_sound = "none",
		every_x_char = 3,
		text = "{@delay 1.4}"..greetings[Random(1, #greetings)].."\nLooking to buy something?",
		options = {
			{
				text = "What are you selling?",
				func = function(dialog)
					open_shop(dialog, entity_who_interacted)
				end
			},
			{
				text = "Nevermind.",
				func = function(dialog)
					dialog.close()
				end
			},
		}
	})
end


function open_shop(dialog, entity_who_interacted)
	local wallet_component = EntityGetFirstComponentIncludingDisabled(entity_who_interacted, "WalletComponent")
	money_in_wallet = ComponentGetValue2(wallet_component, "money")


	if(GameHasFlagRun("refresh_inflation") or EntityGetVariable(entity_id, "player_money", "int") == nil)then
		EntitySetVariable(entity_id, "player_money", "int", money_in_wallet)
	end

	EntitySetComponentsWithTagEnabled( entity_id, "open_shop", true )

	dialog.show({
		name = "Fisherman's Shop",
		portrait = "mods/fishing/files/fisherman/portrait.xml",
		animation = "stand",
		on_closing = function()
			dialog.message.name = "Fisherman"
			dialog.message.nametag_offset = 0
			EntitySetComponentsWithTagEnabled( entity_id, "open_shop", false )
		end,
		shop_override = shop_buy_loop,
		nametag_offset = 166,
		text = [[
			{@delay 1.4}Anything you like?
		]],
		options = {
			{
				text = "Good bye.",
				func = function(dialog)
					dialog.close()
				end
			},
		}
	})
end

function shop_buy_loop(dialog)
	local buy_messages = {
		"Great choice!",
		"I hope you catch some nice fish with that!",
		"Thank you for your business",
		"That is a perfect choice!",
		"I hope you like it!",
		"Lovely choice!",
		"I hope to do business with you again!"
	}
	dialog.show({
		name = "Fisherman's Shop",
		portrait = "mods/fishing/files/fisherman/portrait.xml",
		animation = "stand",
		on_closing = function()
			dialog.message.name = "Fisherman"
			dialog.message.nametag_offset = 0
			EntitySetComponentsWithTagEnabled( entity_id, "open_shop", false )
		end,
		shop_override = shop_buy_loop,
		nametag_offset = 166,
		text = "{@delay 1.4}"..buy_messages[Random(1,#buy_messages)],
		options = {
			{
				text = "Good bye.",
				func = function(dialog)
					dialog.close()
				end
			},
		}
	})
end


function introduction(entity_who_interacted, entity_interacted, interactable_name)
	if(not GameHasFlagRun("talked_about_fishing") and not GameHasFlagRun("talked_about_rod"))then
		dialog = dialog_system.open_dialog({
			name = "Fisherman",
			portrait = "mods/fishing/files/fisherman/portrait.xml",
			animation = "stand", 
			typing_sound = "none",
			dialog_sound = "fisherman",
			char_sound = "none",
			every_x_char = 3,
			text = "{@delay 1.4}Good morning, nice day for fishing ain't it?",
			options = {
				{
					text = "Who are you?",
					enabled = function(stats)
						return true
					end,
					func = function(dialog)
						dialog.show({
							name = "Fisherman",
							portrait = "mods/fishing/files/fisherman/portrait.xml",
							animation = "stand",
							text = [[
								{@delay 1.4}I am just a humble old fisherman.
								Are you that Witch causing trouble down in the mines?
							]],
							options = {
								{
									text = "Trouble?",
									func = function(dialog)
										dialog.show({
											name = "Fisherman",
											portrait = "mods/fishing/files/fisherman/portrait.xml",
											animation = "stand",
											text = [[
												{@delay 1.4}My Hiisi friends told me there was some Witch
												causing all kinds of trouble with crazy wand contraptions.
											]],
											options = {
												{
													text = "That's me!",
													func = function(dialog)
														dialog.show({
															name = "Fisherman",
															portrait = "mods/fishing/files/fisherman/portrait.xml",
															animation = "stand",
															text = [[
																{@delay 1.4}It is dangerous down there you know.
																Maybe you would like a slow fisherman's life instead?
															]],
															options = {
																{
																	text = "I don't have a fishing rod though.",
																	func = function(dialog)
																		dialog.show({
																			name = "Fisherman",
																			portrait = "mods/fishing/files/fisherman/portrait.xml",
																			animation = "stand",
																			text = [[
																				{@delay 1.4}I can sell you this {@color 63a1ff}old fishing rod {@color ffffff}for {@color ffdb63}500 gold{@color ffffff}.
																			]],
																			options = {
																				{
																	
																					text = "Buy the fishing rod. [500 gold]",
																					enabled = function(stats)
																						return true--stats.gold >= 500
																					end,
																					func = function(dialog)
																						local px, py = EntityGetTransform(entity_who_interacted)
													
																						local potion = EntityLoad("mods/fishing/files/rod/default_rod.xml", x, y)
																						
																						local wallet_component = EntityGetFirstComponentIncludingDisabled(entity_who_interacted, "WalletComponent")
																						--ComponentSetValue2(wallet_component, "money", ComponentGetValue2(wallet_component, "money") - 500)
																						GameAddFlagRun("completed_introduction")
																						dialog.show({
																							name = "Fisherman",
																							portrait = "mods/fishing/files/fisherman/portrait.xml",
																							animation = "stand",
																							text = [[
																								{@delay 1.4}Have this {@color 63a1ff}Fish O Matic Tablet {@color ffffff}as well.
																								It acts as your fisherman's Logbook.
																								You can talk to me at any time if you want to buy something.
																								I may also have some jobs for you if you are interested.
																							]],
																							options = {
																								{
																									text = "See you around!",
																									func = function(dialog)
																										dialog.close()
																									end
																								}
																							}
																						})
																					end
													
																				},
																				{
																					text = "Maybe later.",
																					func = function(dialog)
																						GameAddFlagRun("talked_about_rod")
																						dialog.close()
																					end
																				},
																			}
																		})
																	end
																},
																{
																	text = "Maybe one day.",
																	func = function(dialog)
																		GameAddFlagRun("talked_about_fishing")
																		dialog.close()
																	end
																},
															}
														})
													end
												},
												{
													text = "Goodbye.",
												},
											}
										})
									end
								},
								{
									text = "That's me!",
									func = function(dialog)
										dialog.show({
											name = "Fisherman",
											portrait = "mods/fishing/files/fisherman/portrait.xml",
											animation = "stand",
											text = [[
												{@delay 1.4}It is dangerous down there you know.
												Maybe you would like a slow fisherman's life instead?
											]],
											options = {
												{
													text = "I don't have a fishing rod though.",
													func = function(dialog)
														dialog.show({
															name = "Fisherman",
															portrait = "mods/fishing/files/fisherman/portrait.xml",
															animation = "stand",
															text = [[
																{@delay 1.4}I can sell you this {@color 63a1ff}old fishing rod {@color ffffff}for {@color ffdb63}500 gold{@color ffffff}.
															]],
															options = {
																{
													
																	text = "Buy the fishing rod. [500 gold]",
																	enabled = function(stats)
																		return true--stats.gold >= 500
																	end,
																	func = function(dialog)
																		local px, py = EntityGetTransform(entity_who_interacted)
									
																		local potion = EntityLoad("mods/fishing/files/rod/default_rod.xml", x, y)
																		
																		local wallet_component = EntityGetFirstComponentIncludingDisabled(entity_who_interacted, "WalletComponent")
																		--ComponentSetValue2(wallet_component, "money", ComponentGetValue2(wallet_component, "money") - 500)
																		GameAddFlagRun("completed_introduction")
																		dialog.show({
																			name = "Fisherman",
																			portrait = "mods/fishing/files/fisherman/portrait.xml",
																			animation = "stand",
																			text = [[
																				{@delay 1.4}Have this {@color 63a1ff}Fish O Matic Tablet {@color ffffff}as well.
																				It acts as your fisherman's Logbook.
																				You can talk to me at any time if you want to buy something.
																				I may also have some jobs for you if you are interested.
																			]],
																			options = {
																				{
																					text = "See you around!",
																					func = function(dialog)
																						dialog.close()
																					end
																				}
																			}
																		})
																	end
									
																},
																{
																	text = "Maybe later.",
																	func = function(dialog)
																		GameAddFlagRun("talked_about_rod")
																		dialog.close()
																	end
																},
															}
														})
													end
												},
												{
													text = "Maybe one day.",
													func = function(dialog)
														GameAddFlagRun("talked_about_fishing")
														dialog.close()
													end
												},
											}
										})
									end
								},
								{
									text = "Goodbye.",
								},
							}
						})
						
					end
				},
				{
					text = "It sure is, have a great day!",
				},
			}
		})
	elseif(GameHasFlagRun("talked_about_fishing") and not GameHasFlagRun("talked_about_rod"))then
		dialog = dialog_system.open_dialog({
			name = "Fisherman",
			portrait = "mods/fishing/files/fisherman/portrait.xml",
			animation = "stand", 
			typing_sound = "none",
			dialog_sound = "fisherman",
			char_sound = "none",
			every_x_char = 3,
			text = [[
				{@delay 1.4}Welcome back!
				Did you think about becoming a fisherman?
			]],
			options = {
				{
					text = "I don't have a fishing rod though.",
					func = function(dialog)
						dialog.show({
							name = "Fisherman",
							portrait = "mods/fishing/files/fisherman/portrait.xml",
							animation = "stand",
							text = [[
								{@delay 1.4}I can sell you this {@color 63a1ff}old fishing rod {@color ffffff}for {@color ffdb63}500 gold{@color ffffff}.
							]],
							options = {
								{
					
									text = "Buy the fishing rod. [500 gold]",
									enabled = function(stats)
										return true--stats.gold >= 500
									end,
									func = function(dialog)
										local px, py = EntityGetTransform(entity_who_interacted)
	
										local potion = EntityLoad("mods/fishing/files/rod/default_rod.xml", x, y)
										
										local wallet_component = EntityGetFirstComponentIncludingDisabled(entity_who_interacted, "WalletComponent")
										GameAddFlagRun("completed_introduction")
										--ComponentSetValue2(wallet_component, "money", ComponentGetValue2(wallet_component, "money") - 500)
										dialog.show({
											name = "Fisherman",
											portrait = "mods/fishing/files/fisherman/portrait.xml",
											animation = "stand",
											text = [[
												{@delay 1.4}Have this {@color 63a1ff}Fish O Matic Tablet {@color ffffff}as well.
												It acts as your fisherman's Logbook.
												You can talk to me at any time if you want to buy something.
												I may also have some jobs for you if you are interested.
											]],
											options = {
												{
													text = "See you around!",
													func = function(dialog)
														dialog.close()
													end
												}
											}
										})
									end
	
								},
								{
									text = "Maybe later.",
									func = function(dialog)
										GameAddFlagRun("talked_about_rod")
										dialog.close()
									end
								},
							}
						})
					end
				},
				{
					text = "Maybe one day.",
					func = function(dialog)
						GameAddFlagRun("talked_about_fishing")
						dialog.close()
					end
				},
			}
		})
	elseif(GameHasFlagRun("talked_about_fishing") and GameHasFlagRun("talked_about_rod"))then
		dialog = dialog_system.open_dialog({
			name = "Fisherman",
			portrait = "mods/fishing/files/fisherman/portrait.xml",
			animation = "stand", 
			typing_sound = "none",
			dialog_sound = "fisherman",
			char_sound = "none",
			every_x_char = 3,
			text = [[
				{@delay 1.4}I can sell you this {@color 63a1ff}old fishing rod {@color ffffff}for {@color ffdb63}500 gold{@color ffffff}.
			]],
			options = {
				{
	
					text = "Buy the fishing rod. [500 gold]",
					enabled = function(stats)
						return true--stats.gold >= 500
					end,
					func = function(dialog)
						local px, py = EntityGetTransform(entity_who_interacted)

						local potion = EntityLoad("mods/fishing/files/rod/default_rod.xml", x, y)
						
						local wallet_component = EntityGetFirstComponentIncludingDisabled(entity_who_interacted, "WalletComponent")
						--ComponentSetValue2(wallet_component, "money", ComponentGetValue2(wallet_component, "money") - 500)
						
						GameAddFlagRun("completed_introduction")

						dialog.show({
							name = "Fisherman",
							portrait = "mods/fishing/files/fisherman/portrait.xml",
							animation = "stand",
							text = [[
								{@delay 1.4}Have this {@color 63a1ff}Fish O Matic Tablet {@color ffffff}as well.
								It acts as your fisherman's Logbook.
								You can talk to me at any time if you want to buy something.
								I may also have some jobs for you if you are interested.
							]],
							options = {
								{
									text = "See you around!",
									func = function(dialog)
										dialog.close()
									end
								}
							}
						})
					end

				},
				{
					text = "Maybe later.",
				},
			}
		})
	end
end
