local assets =
{
	Asset( "ANIM", "anim/kuro.zip" ),
	Asset( "ANIM", "anim/ghost_kuro_build.zip" ),
}

local skins =
{
	normal_skin = "kuro",
	ghost_skin = "ghost_kuro_build",
}

return CreatePrefabSkin("kuro_none",
{
	base_prefab = "kuro",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"KURO", "CHARACTER"},
	build_name_override = "KURO",
	rarity = "Character",
})