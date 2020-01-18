local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/demonkuro.zip"),

    Asset("IMAGE", "images/saveslot_portraits/kuro.tex"),
    Asset("ATLAS", "images/saveslot_portraits/kuro.xml"),
    
    Asset("IMAGE", "images/selectscreen_portraits/kuro.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/kuro.xml"),
    
    Asset("IMAGE", "images/selectscreen_portraits/kuro_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/kuro_silho.xml"),
    
    Asset("IMAGE", "bigportraits/kuro.tex"),
    Asset("ATLAS", "bigportraits/kuro.xml"),
    
    Asset("IMAGE", "images/map_icons/kuro.tex"),
    Asset("ATLAS", "images/map_icons/kuro.xml"),
    
    Asset("IMAGE", "images/avatars/avatar_kuro.tex"),
    Asset("ATLAS", "images/avatars/avatar_kuro.xml"),
    Asset("IMAGE", "images/avatars/avatar_ghost_kuro.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_kuro.xml"),
    Asset("IMAGE", "images/avatars/self_inspect_kuro.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_kuro.xml"),

    Asset("IMAGE", "images/names_kuro.tex"),
    Asset("ATLAS", "images/names_kuro.xml"),
    
    Asset("IMAGE", "bigportraits/kuro_none.tex"),
    Asset("ATLAS", "bigportraits/kuro_none.xml"),
    
    Asset("SOUNDPACKAGE", "sound/reaper.fev"),
    Asset("SOUND", "sound/reaper.fsb"),
}
local prefabs = {}

-- Custom starting inventory
local start_inv = {
    "nightmarefuel",
    "nightmarefuel",
    "nightmarefuel",
    "nightmarefuel",
    "nightmarefuel",
    "nightmarefuel",
    "skull_cane",
    "skull_chest"
}


-- Player vision CC Table
local DEVIL_EYES = {
    day = "images/colour_cubes/day05_cc.tex",
    dusk = "images/colour_cubes/dusk03_cc.tex",
    night = "images/colour_cubes/ruins_dim_cc.tex",
    full_moon = "images/colour_cubes/purple_moon_cc.tex",
}







-- Stats, static
TUNING.KURO.HEALTH_MAX = 275
TUNING.KURO.HUNGER_MAX = 300
TUNING.KURO.SANITY_MAX = 275
TUNING.KURO.MIN_TEMP = -10
TUNING.KURO.MAX_TEMP = 50
TUNING.KURO.COLD_RESISTANCE = 50
TUNING.KURO.HUNGER_HURT_RATE = 1.6

-- Stats for vampire Kuro (default)
TUNING.KURO.HUNGER_RATE = TUNING.WILSON_HUNGER_RATE * 2.6
TUNING.KURO.LIFESTEAL_RATE = 0.02
TUNING.KURO.WALK_SPEED = 4.2
TUNING.KURO.RUN_SPEED = 6.2
TUNING.KURO.HEALTH_ABSORB = 0.1 -- 1 means 100% absorb: no harm
TUNING.KURO.FIRE_DAMAGE_SCALE = 0.5 -- 1 means 100% damage: full damage
TUNING.KURO.HIT_RANGE = 4

-- Stats for vampire Kuro (default)
TUNING.KURO.DEMON.HUNGER_RATE = TUNING.WILSON_HUNGER_RATE * 6.4
TUNING.KURO.DEMON.LIFESTEAL_RATE = 0.08
TUNING.KURO.DEMON.WALK_SPEED = 5.0
TUNING.KURO.DEMON.RUN_SPEED = 7.0
TUNING.KURO.DEMON.HEALTH_ABSORB = 0.3 -- 1 means 100% absorb: no harm
TUNING.KURO.DEMON.FIRE_DAMAGE_SCALE = 0.3 -- 1 means 100% damage: full damage
TUNING.KURO.DEMON.HIT_RANGE = 6

-- Sanity rate
TUNING.KURO.SANITY_DAY_RATE = -0.2
TUNING.KURO.SANITY_DUSK_RATE = 0.08 -- DONT CHANGE! Magical number that can offset normal san drain, in result of san stays its value
TUNING.KURO.SANITY_NIGHT_RATE = 0.5




-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst)
        -- Minimap icon
        inst.MiniMapEntity:SetIcon("kuro.tex")
        
        inst:AddTag("kuro")
        inst:AddTag("bat")
        inst:AddTag("vampire")
        inst:AddTag("vampirekuro")
        
        inst:AddComponent("keyhandler")
end



-- Vampire phase change as the phase of the world
local function OnPhase(inst)
    if TheWorld.state.phase == "day" then
        inst.components.combat.damagemultiplier = 1
    elseif TheWorld.state.phase == "dusk" and inst.transformed then
        inst.components.combat.damagemultiplier = 1.75
    elseif TheWorld.state.phase == "night" and inst.transformed then
        inst.components.combat.damagemultiplier = 2.5
    elseif TheWorld.state.phase == "dusk" and not inst.transformed then
        inst.components.combat.damagemultiplier = 1.25
    elseif TheWorld.state.phase == "night" and not inst.transformed then
        inst.components.combat.damagemultiplier = 1.5
    end
end


-- Reactions of eat
local function OnEat(inst, food)--triggers appearence change and/or hallucinations on eating nightmare fuel
    
    if food and food.components.edible and food.components.edible.foodtype == "NIGHTMARE" then
        inst.components.talker:Say("Umm....My soul")
    elseif food.prefab == "shadow_apple" then
        inst.components.talker:Say("Ummm.....A Deadly Apple...So good!")
    elseif food.prefab == "margarita" then
        inst.components.talker:Say("Umm.....I love this drink.")
    end

end


local function IsValidVictim(victim)
    return victim ~= nil and not ((victim:HasTag("prey") and victim:HasTag("hostile")) or victim:HasTag("veggie") or victim:HasTag("structure") or victim:HasTag("wall") or victim:HasTag("companion")) and victim.components.health ~= nil and victim.components.combat ~= nil
end


local function SpawnSpirit(inst, x, y, z, scale)
    local fx = SpawnPrefab("disease_puff")
    fx.Transform:SetPosition(x, y, z)
    fx.Transform:SetScale(scale, scale, scale)
end


-- Kill someone else
local function OnKilled(inst, data)
    
    local smallScale = 1
    local medScale = 1.3
    local largeScale = 1.6
    local superScale = 2.8
    
    if IsValidVictim(data.victim) then
        
        -- play animation
        local time = data.victim.components.health.destroytime or 2
        local x, y, z = data.victim.Transform:GetWorldPosition()
        local scale = (data.victim:HasTag("smallcreature") and smallScale) or (data.victim:HasTag("largecreature") and largeScale) or (data.victim:HasTag("epic") and superScale) or medScale
        inst:DoTaskInTime(time, SpawnSpirit, x, y, z, scale)
        
        
    end
end


-- Attacked by someone else
local function OnAttacked(inst, data)

    -- print("attack")

end



-- Life Stealing: Kuro himself
local function OnHitOther(inst, data)
    if not inst.components.health:IsDead() then
        inst.components.health:DoDelta(data.damageresolved * TUNING.KURO.LIFESTEAL_RATE)
        
        local fx1 = SpawnPrefab("shadow_puff_large_front")
        fx1.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx1.Transform:SetScale(1.5, 1.3, 1.3)

        -- 1/10 chance to get nightfuel on this hit
        local rand = math.random(0, 9)
        if rand == 2 then
            if data.target.components.lootdropper.loot == nil then
                data.target.components.lootdropper.loot = {}
            end
            table.insert(data.target.components.lootdropper.loot, "nightmarefuel")
        end
        print(rand)

    end
end

local function OnTransform(inst, data)

    -- if ghost, no transform
    if inst:HasTag("playerghost") then return end
    if inst.components.health.currenthealth < 100 and not inst.ONDEMON then return false end -- blood too low to trans

    if data == nil then
        data = {}
    end
    
    if data.onDemon == nil then
        data.onDemon = inst.ONDEMON
        inst.ONDEMON = not inst.ONDEMON
    else
        inst.ONDEMON = data.onDemon
    end

    -- declare set
    local set = TUNING.KURO

    print("onDemon?", data.onDemon)

    -- show anime and initialize set
    if data.onDemon then -- if on demon then to vampire
        
		inst.AnimState:SetBuild("kuro")
		SpawnPrefab("shadow_bishop_fx").Transform:SetPosition(inst:GetPosition():Get())
		SpawnPrefab("shadow_despawn").Transform:SetPosition(inst:GetPosition():Get())

        set = TUNING.KURO
        print("Mode Vampire")

        if inst.STAFF then
            inst.STAFF.components.spellcaster.quickcast = false
        end

    else -- if on vampire then to demon

        inst.components.health:DoDelta(-50, 10, nil, true, nil, true) -- effort

		inst.AnimState:SetBuild("demonkuro")
		SpawnPrefab("shadow_bishop_fx").Transform:SetPosition(inst:GetPosition():Get())
		SpawnPrefab("shadow_shield3").Transform:SetPosition(inst:GetPosition():Get())

        set = TUNING.KURO.DEMON
        print("Mode Demon")

        if inst.STAFF then
            inst.STAFF.components.spellcaster.quickcast = true
        end

    end

    -- update stats by set
    inst.components.locomotor.walkspeed = set.WALK_SPEED
    inst.components.locomotor.runspeed = set.RUN_SPEED
    inst.components.hunger.hungerrate = set.HUNGER_RATE
    inst.components.health.absorb = set.HEALTH_ABSORB
    inst.components.health.fire_damage_scale = set.FIRE_DAMAGE_SCALE
    inst.components.combat.hitrange = set.HIT_RANGE
    inst.components.combat.attackrange = set.HIT_RANGE


end


local function OnBindStaff(inst, data)
    if data == nil or data.staff == nil then
        inst.STAFF = nil
    else
        inst.STAFF = data.staff
    end
end


-- Sanity function
local function SanityFn(inst)

    if TheWorld.state.isday then
		return TUNING.KURO.SANITY_DAY_RATE
	elseif TheWorld.state.isdusk then
        return TUNING.KURO.SANITY_DUSK_RATE
	elseif TheWorld.state.isnight then
        return TUNING.KURO.SANITY_NIGHT_RATE
    else
        return 0
    end

end



-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
        
        math.randomseed(tostring(os.time()):reverse():sub(1, 9))


        -- Skull Cane Staff Binding
        inst.STAFF = nil


        -- Transformation flag
        inst.ONDEMON = false
        
        -- Sound: choose which sounds this character will play
        inst.soundsname = "reaper"
        
        
        -- Stats
        inst.components.health:SetMaxHealth(TUNING.KURO.HEALTH_MAX)
        inst.components.hunger:SetMax(TUNING.KURO.HUNGER_MAX)
        inst.components.sanity:SetMax(TUNING.KURO.SANITY_MAX)

        inst.components.temperature.mintemp = TUNING.KURO.MIN_TEMP
        inst.components.temperature.maxtemp = TUNING.KURO.MAX_TEMP
        inst.components.freezable:SetResistance(TUNING.KURO.COLD_RESISTANCE)

        inst.components.hunger.hurtrate = TUNING.KURO.HUNGER_HURT_RATE

        OnTransform(inst, {onDemon = false})
        
        
        -- Eating Preference Setting
        if inst.components.eater.preferseating then
            table.insert(inst.components.eater.preferseating, FOODTYPE.NIGHTMARE)
            table.insert(inst.components.eater.caneat, FOODTYPE.NIGHTMARE)
            inst:AddTag(FOODTYPE.NIGHTMARE .. "_eater")
        else
            table.insert(inst.components.eater.foodprefs, FOODTYPE.NIGHTMARE)
            inst:AddTag(FOODTYPE.NIGHTMARE .. "_eater")
        end
        inst.components.eater:SetOnEatFn(OnEat)
        

        -- Sanity Fn
        inst.components.sanity.custom_rate_fn = SanityFn

        
        -- Night Vision Config
        inst.components.playervision:ForceNightVision(true)
        inst.components.playervision:SetCustomCCTable(DEVIL_EYES)
        
        
        -- Listening Events
        inst:WatchWorldState("phase", OnPhase)
        inst:ListenForEvent("killed", OnKilled)
        inst:ListenForEvent("attacked", OnAttacked)
        inst:ListenForEvent("onhitother", OnHitOther)
        inst:ListenForEvent("transform", OnTransform)
        inst:ListenForEvent("bindstaff", OnBindStaff)

end



-- KURO Info
-- The character select screen lines
STRINGS.CHARACTER_TITLES.kuro = "The Dark Prince"
STRINGS.CHARACTER_NAMES.kuro = "Kuro"
STRINGS.CHARACTER_DESCRIPTIONS.kuro = "Half Vampire\nHalf Demon\nMaster of Hell"
STRINGS.CHARACTER_QUOTES.kuro = "\"Yuki hahaha...\""

-- Custom speech strings
STRINGS.CHARACTERS.KURO = require "speech_kuro"

-- The character's name as appears in-game
STRINGS.NAMES.kuro = "Kuro"
STRINGS.SKIN_NAMES.kuro = "Kuro"


return MakePlayerCharacter("kuro", prefabs, assets, common_postinit, master_postinit, start_inv)
