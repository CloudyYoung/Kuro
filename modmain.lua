PrefabFiles = {
    "kuro",
    "kuro_none",
    "skull_cane",
    "shadow_projectile",
    "shadow_apple",
    "skull_chest"
}

Assets = {

    Asset("ATLAS", "images/map_icons/kuro.xml"),

	Asset("ATLAS", "images/hud/vampiretab.xml" ),
    
}


RemapSoundEvent("dontstarve/characters/reaper/death_voice", "reaper/characters/reaper/death_voice")
RemapSoundEvent("dontstarve/characters/reaper/hurt", "reaper/characters/reaper/hurt")
RemapSoundEvent("dontstarve/characters/reaper/talk_LP", "reaper/characters/reaper/talk_LP")

AddMinimapAtlas("images/map_icons/kuro.xml")
AddMinimapAtlas("images/inventoryimages/skull_chest.xml")




-- Variables
local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local STRINGS = GLOBAL.STRINGS
local FOODTYPE = GLOBAL.FOODTYPE
local FOODGROUP = GLOBAL.FOODGROUP
local TECH = GLOBAL.TECH
local ACTIONS = GLOBAL.ACTIONS
local Action = GLOBAL.Action
local STRINGS = GLOBAL.STRINGS
local ActionHandler = GLOBAL.ActionHandler

GLOBAL.FOODTYPE.NIGHTMARE = "NIGHTMARE"
GLOBAL.TUNING.KURO = {}
GLOBAL.TUNING.KURO.DEMON = {}
GLOBAL.TUNING.SKULL_CANE = {}





-- Kuro eats nightfuel
local function OnEatNightFuel(inst)
    inst:AddComponent("edible")
    inst.components.edible.foodtype = GLOBAL.FOODTYPE.NIGHTMARE
    inst.components.edible.sanityvalue = 5
    inst.components.edible.hungervalue = 0
    inst.components.edible.healthvalue = 0
end

AddPrefabPostInit("nightmarefuel", OnEatNightFuel)






-- HUD TECH
local KURO_TECH = AddRecipeTab("Kuro Tech", 998, "images/hud/vampiretab.xml", "vampiretab.tex", "kuro")

-- Recipe for Shadow Apple
local shadow_apple_recipe = AddRecipe("shadow_apple", {Ingredient("berries", 6), Ingredient("nightmarefuel", 2)}, KURO_TECH, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages/shadow_apple.xml")

-- Recipe for Living Log
local living_log_recipe = AddRecipe("livinglog", {Ingredient("nightmarefuel", 6), Ingredient("log", 20)}, KURO_TECH, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages/shadow_apple.xml")

-- Recipe for Skull Chest
local skull_chest_recipe = AddRecipe("skull_chest", {Ingredient("nightmarefuel", 8), Ingredient("boneshard", 6), Ingredient("livinglog", 2)}, KURO_TECH, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages/skull_chest.xml")

-- Recipe for Skull Cane
local skull_cane_recipe = AddRecipe("skull_cane", {Ingredient("boneshard", 10), Ingredient("cane", 1), Ingredient("nightmarefuel", 6)}, KURO_TECH, TECH.NONE, nil, nil, nil, nil, nil, "images/inventoryimages/skull_cane.xml", "skull_cane.tex")






-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL.
AddModCharacter("kuro", "MALE")
