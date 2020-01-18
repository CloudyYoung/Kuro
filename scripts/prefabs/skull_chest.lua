require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/skull_chest.zip"),
    Asset("ATLAS", "images/inventoryimages/skull_chest.xml"),
    Asset("IMAGE", "images/inventoryimages/skull_chest.tex"),

	Asset("ATLAS", "images/inventoryimages/ui_chest_5x5.xml"),
    Asset("IMAGE", "images/inventoryimages/ui_chest_5x5.tex"),
    Asset("ANIM", "anim/ui_chest_5x5.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("closed", false)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")
end


local skull_chest =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_5x5",
        animbuild = "ui_chest_5x5",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 3, -1, -1 do
    for x = -1, 3 do
        table.insert(skull_chest.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end



local containers = require("containers")
containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, skull_chest.widget.slotpos ~= nil and #skull_chest.widget.slotpos or 0)

local _widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
	local pref = prefab or container.inst.prefab
	if pref == "skull_chest" then
		for k, v in pairs(skull_chest) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
	else
		return _widgetsetup(container, prefab, data)
	end
end



local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("skull_chest.tex")

    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("MagicalChest")
    inst.AnimState:PlayAnimation("closed")

    inst:AddTag("structure")
    inst:AddTag("chest")
    -- inst:AddTag("fridge")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("skull_chest")

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    --AddHauntableDropItemOrWork(inst)

    return inst
end



STRINGS.NAMES.SKULL_CHEST = "Skull Chest"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKULL_CHEST = "For vampire and demon only!"
STRINGS.RECIPE_DESC.SKULL_CHEST = "Storing stuff in dark space"


return Prefab( "common/skull_chest", fn, assets), 
    MakePlacer("common/skull_chest_placer", "chest", "skull_chest", "closed")
