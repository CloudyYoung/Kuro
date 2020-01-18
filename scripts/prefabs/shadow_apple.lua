local Assets =
{
	Asset("IMAGE", "images/inventoryimages/shadow_apple.tex"),
	Asset("ATLAS", "images/inventoryimages/shadow_apple.xml"),
	Asset("ANIM", "anim/shadow_apple.zip"),
}


local function DoAreaSleep(inst, range, time)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, range, nil, { "playerghost", "FX", "DECOR", "INLIMBO" }, { "sleeper", "player" })
	local canpvp = not inst:HasTag("player") or TheNet:GetPVPEnabled()
	for i, v in ipairs(ents) do
		if (v == inst or canpvp or not v:HasTag("player")) and not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) then
			local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
			if mount ~= nil then
			    mount:PushEvent("ridersleep", { sleepiness = 7, sleeptime = time + math.random() })
			end
			if v:HasTag("player") then
			    v:PushEvent("yawn", { grogginess = 4, knockoutduration = time + math.random() })
			elseif v.components.sleeper ~= nil then
			    v.components.sleeper:AddSleepiness(7, time + math.random())
			elseif v.components.grogginess ~= nil then
			    v.components.grogginess:AddGrogginess(4, time + math.random())
			else
			    v:PushEvent("knockedout")
			end
		end
	end
end


local function OnEaten(inst, eater)

	
	if eater:HasTag("kuro") then

	else
		eater.SoundEmitter:PlaySound("dontstarve/charlie/warn")

		for i, v in ipairs(AllPlayers) do
			v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, .3, inst, 40)
		end
		
		SpawnPrefab("shadow_despawn").Transform:SetPosition(inst:GetPosition():Get())

		eater:DoTaskInTime(0.5, function() 
			DoAreaSleep(eater, TUNING.MANDRAKE_SLEEP_RANGE, 5)
		end)
	end


end

local function fn()

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	inst.AnimState:SetBank("shadowapple")
	inst.AnimState:SetBuild("shadowapple")
	inst.AnimState:PlayAnimation("idle", false)
	

	if not TheWorld.ismastersim then
	    return inst
	end

	inst:AddTag("preparedfood")
	inst:AddTag("shadow_apple")

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 30
	inst.components.edible.hungervalue = 5
	inst.components.edible.sanityvalue = 20
	inst.components.edible:SetOnEatenFn(OnEaten)
	inst.components.edible.foodtype = FOODTYPE.VEGGIE

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/shadow_apple.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW * 2)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("bait")

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 5
	inst.components.tradable.dubloonvalue = 5

	return inst
end



STRINGS.NAMES.SHADOW_APPLE = "Shadow Apple"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHADOW_APPLE = "Smell's good. But look dangerous!"
STRINGS.RECIPE_DESC.SHADOW_APPLE = "An apple from Hell"


return Prefab( "common/inventory/shadow_apple", fn, Assets )