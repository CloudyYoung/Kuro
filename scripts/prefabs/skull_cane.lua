local assets=
{
    Asset("ANIM", "anim/skull_cane.zip"),
    Asset("ANIM", "anim/swap_skull_cane.zip"),
    Asset("ATLAS", "images/inventoryimages/skull_cane.xml"),
    Asset("IMAGE", "images/inventoryimages/skull_cane.tex"),
}

local prefabs = 
{
	
}


-- Stats
TUNING.SKULL_CANE.DAMAGE = TUNING.RUINS_BAT_DAMAGE * 1 -- Calc: 43 * 1.75: Final damage
TUNING.SKULL_CANE.HIT_RANGE = TUNING.TOADSTOOL_SPOREBOMB_HIT_RANGE
TUNING.SKULL_CANE.WALK_SPEED_MULT = TUNING.CANE_SPEED_MULT - 0.15



local function Transform(inst, target, pos)

    -- print("equipped?", inst.components.equippable.isequipped)
    -- print("owner?", inst.components.inventoryitem.owner)

    local owner = inst.components.inventoryitem.owner

    if owner:HasTag("playerghost") then return false end
    if not owner:HasTag("kuro") then return false end
    if not inst.components.equippable.isequipped then return false end


    owner:PushEvent("transform")

	return true
end



local function OnEquip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_object", "swap_skullcane", "swap_skullcane")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")


    if not owner:HasTag("playerghost") and owner:HasTag("kuro") then
        inst:AddTag("castfrominventory")
        owner:PushEvent("bindstaff", {staff = inst})
    end

end

 

local function OnUnequip(inst, owner)

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst:RemoveTag("castfrominventory")
    owner:PushEvent("bindstaff")

end

local function SwingSpell(inst, attacker, target)
    attacker.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
end




local function fn()
  
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("skullcane")
    inst.AnimState:SetBuild("skullcane")
    inst.AnimState:PlayAnimation("idle")


    inst:AddTag("sharp")


    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SKULL_CANE.DAMAGE)
    inst.components.weapon:SetRange(TUNING.SKULL_CANE.HIT_RANGE, TUNING.SKULL_CANE.HIT_RANGE)
    inst.components.weapon:SetProjectile("shadow_projectile")
    inst.components.weapon:SetOnProjectileLaunch(SwingSpell)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "skull_cane"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skull_cane.xml"

    -- inst:AddTag("waterproofer")
    -- inst:AddComponent("waterproofer")
    -- inst.components.waterproofer:SetEffectiveness(1) -- 100% water proof

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
    inst.components.equippable.walkspeedmult = TUNING.SKULL_CANE.WALK_SPEED_MULT


    -- Transform (as spellcaster)
    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.quickcast = false -- to demon show anim, to vapire not show
    inst.components.spellcaster:SetSpellFn(Transform)


    MakeHauntableLaunch(inst) -- hauntable, eg. frog


    inst:RemoveComponent("hauntable") -- not hauntable




    return inst
end



STRINGS.NAMES.SKULL_CANE = "Skull Cane"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKULL_CANE = "Oh, hell."
STRINGS.RECIPE_DESC.SKULL_CANE = "A cane with dark magic from Hell"


return Prefab("common/inventory/skull_cane", fn, assets, prefabs) 

