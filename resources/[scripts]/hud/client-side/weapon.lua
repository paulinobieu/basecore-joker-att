-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local AmmoMax = -1
local AmmoMin = -1
local Active  = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS BRIDGE
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResolveBaseWeapon(Item)
	if not Item or Item == "" then return Item end
	if GetResourceState("core-skins") ~= "started" then return Item end

	local Ok,Result = pcall(function() return exports["core-skins"]:GetBaseWeapon(Item) end)
	if Ok and type(Result) == "string" and Result ~= "" then return Result end
	return Item
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:WEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Weapon", function(Status, Name)
if Status then
Active = true

local BaseName = ResolveBaseWeapon(Name)

while Active do
local Ped = PlayerPedId()
local _, Min = GetAmmoInClip(Ped, Name)
local Max    = GetAmmoInPedWeapon(Ped, Name)

if AmmoMax ~= Max or AmmoMin ~= Min then
AmmoMax = Max
AmmoMin = Min

local Loader = Max - Min
if Loader < 0 then Loader = 0 end

local weaponData = hudConfig.weapons and hudConfig.weapons[BaseName]
local imgFile     = weaponData and (weaponData.index:match("(.-)%.[^%.]+$") or weaponData.index)
local image       = imgFile and (hudConfig.armoryUrl .. imgFile .. ".png") or ""
local name        = weaponData and weaponData.name or (ItemName and ItemName(BaseName) or tostring(BaseName))

SendNUIMessage({ action = "set:weapon", payload = {
image = image,
name  = name,
ammo  = { current = Min, loader = Loader },
}})
end

Wait(100)
end
else
SendNUIMessage({ action = "set:weapon", payload = nil })
Active = false
AmmoMax = -1
AmmoMin = -1
end
end)
