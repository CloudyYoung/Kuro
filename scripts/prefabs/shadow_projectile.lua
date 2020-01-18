local assets =
{
    Asset("ANIM", "anim/shadow_bishop.zip")
}

local SMASHABLE_WORK_ACTIONS =
{
    CHOP = false,
    DIG = false,
    HAMMER = false,
    MINE = false,
    ATTACK = true,
}

local SMASHABLE_TAGS = { "_combat" }

for k, v in pairs(SMASHABLE_WORK_ACTIONS) do
    table.insert(SMASHABLE_TAGS, k.."_workable")
end

local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost" }


local function RemoveMe(inst)
    inst.SoundEmitter:KillSound("bats")
    inst:DoTaskInTime(0.5, ErodeAway)
end

local function OnThrown(inst)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/bishop/attack_1", "bats")
    inst:DoTaskInTime(0.5, RemoveMe)
end

local function OnHit(inst, owner, target)
    inst.SoundEmitter:KillSound("bats")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("shadow_bishop")
    inst.AnimState:SetBuild("shadow_bishop")
    inst.AnimState:PlayAnimation("atk_side_loop", true)
    inst.AnimState:PushAnimation("atk_side_loop", true)
        inst.Transform:SetScale(1, 1, 1)
    inst.AnimState:SetMultColour(1, 1, 1, .8)

    inst:AddTag("projectile")
    inst:AddTag("scarytoprey")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetHitDist(0)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)

    inst.persists = false
    return inst
end



return Prefab("shadow_projectile", fn, assets)
