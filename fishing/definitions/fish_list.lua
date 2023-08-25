fish_list = {
	{
		id = "chuckle_fish", -- Internal Identifier
		name = "Chucklefish", -- Name
		description = "Haven't I seen this fish before somewhere?", -- Description
		drop_fish = true, -- Drops the fish as a item on catch. [LEGACY, MAY BE REMOVED]
		splash_screen = true, -- Show splash screen on catch
		always_discovered = false, -- Always show fish in the logbook
		sizes = { -- Size range in kg
 			min = 3, 
			max = 15.5
		}, 
		price = 10000, -- Unused right now
		probability = 5, -- Probability of catching the fish
		difficulty = 5, -- Skill check difficulty [SUBJECT TO CHANGE]
		catch_seconds = 3, -- Seconds to catch the fish before it escaped
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png", -- Sprite of the fish item when dropped. [LEGACY, MAY BE REMOVED]
		ui_sprite = "mods/fishing/files/ui/fish/chuckle_fish.png", -- Sprite on the log book and splash screen
		bait_types = { -- Bait types that can be used to catch the fish, using IDs defined in bait_list.lua
			"any"
		},
		biomes = {  -- Biomes that the fish can be caught in, using IDs defined in biome_list.lua
			"any"
		},
		liquids = { -- Liquids that the fish can be caught in
			"water"
		},
		func = function(fish, x, y) -- function that runs when the fish is caught, can be used to for example spawn items, like if you catch a potion flask or something.

		end
	},
	{
		id = "basic_fish",
		name = "Eväkäs",
		description = "A common fish.",
		drop_fish = true,
		splash_screen = true,
		always_discovered = true,
		sizes = {min = 0.2, max = 2.5},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/basic_fish.png",
		bait_types = {"any"},
		biomes = {"any"},
		liquids = {"water"},
		func = function(fish, x, y)

		end
	},
	{
		id = "basic_fish",
		name = "Suureväkäs ",
		description = "A large common fish.",
		drop_fish = true,
		splash_screen = true,
		always_discovered = true,
		sizes = {min = 1.0, max = 4.5},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/basic_fish_2.png",
		bait_types = {"any"},
		biomes = {"any"},
		liquids = {"water"},
		func = function(fish, x, y)

		end
	},
	{
		id = "hamis_fish",
		name = "Aquatic Hämis",
		description = "This hämis seems to have evolved to live in water.",
		drop_fish = true,
		splash_screen = true,
		always_discovered = false,
		sizes = {min = 1.0, max = 4.5},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/hamisfish.png",
		bait_types = {"any"},
		biomes = {"any"},
		liquids = {"water"},
		func = function(fish, x, y)

		end
	},
	{
		id = "eel",
		name = "Nahkiainen",
		description = "Seems to be some kind of weird Lamprey",
		drop_fish = true,
		splash_screen = true,
		always_discovered = true,
		sizes = {min = 2.0, max = 9.0},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/eel.png",
		bait_types = {"any"},
		biomes = {"any"},
		liquids = {"water"},
		func = function(fish, x, y)

		end
	},
	{
		id = "squid",
		name = "Pikkuturso",
		description = "Seems to be some kind of weird Lamprey",
		drop_fish = true,
		splash_screen = true,
		always_discovered = false,
		sizes = {min = 1.5, max = 4.0},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/tentacler.png",
		bait_types = {"any"},
		biomes = {"any"},
		liquids = {"water"},
		func = function(fish, x, y)

		end
	},
	{
		id = "flask",
		name = "Flask",
		description = "A potion flask with some kind of material inside.",
		drop_fish = true,
		splash_screen = true,
		always_discovered = false,
		sizes = {min = 0.5, max = 5.0},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/potion.png",
		bait_types = {"any"},
		biomes = {"any"},
		liquids = {"water"},
		func = function(fish, x, y)

		end
	},
}

--[[
for i = 1, 20 do
	table.insert(fish_list, {
		id = "debug_fish_"..i,
		name = "Debug Fish",
		description = "It seems to be a fish for testing purposes.",
		drop_fish = true,
		splash_screen = true,
		always_discovered = true,
		sizes = {min = 3, max = 15.5},
		price = 10000,
		probability = 100,
		difficulty = 5,
		catch_seconds = 3,
		sprite = "mods/fishing/files/fish/sprites/standard_fish.png",
		ui_sprite = "mods/fishing/files/ui/fish/debug_fish.png",
		catch_background = "mods/fishing/files/ui/catch_backgrounds/default.png",
		log_background = "mods/fishing/files/ui/logbook/log_backgrounds/default.png",
		depth = {min = -1000000, max = 1000000},
		bait_types = {{type = "FISH_STICK", ui_name = "Fish Stick"}},
		biomes = {{biome = "any", ui_name = "Any"}},
		liquids = {{materials = {"water"}, ui_name = "Water"}},
		func = function(fish, x, y)

		end
	})
end
]]