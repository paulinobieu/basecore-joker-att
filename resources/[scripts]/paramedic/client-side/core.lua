-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("paramedic",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Damaged = {}
local Bleedings = 0
local InjuryCooldown = 0
local NextBloodDamage = 0

local function IsInCoreGameMatch()
	return GetResourceState("core-game") == "started" and LocalPlayer.state.inCoreGameMatch
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPLOSIVEWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
local ExplosiveWeapons = {
	[126349499] = true,
	[1064738331] = true,
	[85055149] = true,
	[-135142818] = true
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GAMEEVENTTRIGGERED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("gameEventTriggered",function(Event,Message)
	if Event ~= "CEventNetworkEntityDamage" or LocalPlayer.state.Arena or IsInCoreGameMatch() then
		return false
	end

	local Ped = PlayerPedId()
	if Ped ~= Message[1] then
		return false
	end

	local Health = GetEntityHealth(Ped)
	if Health <= 100 then
		return false
	end

	local DamageWeapon = Message[7]
	if ExplosiveWeapons[DamageWeapon] then
		SetPedToRagdoll(Ped,2500,2500,0,false,false,false)
		return false
	end

	local CurrentTimer = GetNetworkTime()
	if CurrentTimer < InjuryCooldown then
		return false
	end

	InjuryCooldown = CurrentTimer + 1000

	local Hit,BoneId = GetPedLastDamageBone(Ped)
	if not Hit or BoneId == 0 or Damaged[BoneId] then
		return false
	end

	Damaged[BoneId] = true
	Bleedings = math.min(Bleedings + 1,5)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBLOODTICK
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 1000
		local CurrentTimer = GetNetworkTime()

		if not LocalPlayer.state.Arena and not IsInCoreGameMatch() then
			local Ped = PlayerPedId()
			if Bleedings >= 2 and GetEntityHealth(Ped) > 100 then
				if CurrentTimer >= NextBloodDamage then
					NextBloodDamage = CurrentTimer + 15000

					ApplyDamageToPed(Ped,1,false)
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARAMEDIC:RESET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("paramedic:Reset")
AddEventHandler("paramedic:Reset",function()
	Damaged = {}
	Bleedings = 0
	InjuryCooldown = 0
	NextBloodDamage = 0

	ClearPedBloodDamage(PlayerPedId())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLEEDING
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Bleeding()
	return Bleedings
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANDAGE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Bandage()
	for BoneId in pairs(Damaged) do
		local Humane = Bone(BoneId)

		TriggerEvent("sounds:Private","bandage",0.5)
		TriggerEvent("Notify","Atenção","Passou ataduras no(a) <b>"..Humane.."</b>.","amarelo",10000)

		Damaged[BoneId] = nil
		Bleedings = math.max(Bleedings - 1,0)

		if Bleedings <= 0 then
			ClearPedBloodDamage(PlayerPedId())
		end

		return Humane
	end

	return ""
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARAMEDIC:INJURIES
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("paramedic:Injuries",function()
	if next(Damaged) == nil then
		TriggerEvent("Notify","Aviso","Nenhum ferimento encontrado.","amarelo",5000)
		return false
	end

	local Index = 1
	local Injuries = {}

	for BoneId in pairs(Damaged) do
		Injuries[#Injuries + 1] = string.format("<b>%d</b>: %s<br>",Index,Bone(BoneId))
		Index = Index + 1
	end

	TriggerEvent("Notify","Ferimentos",table.concat(Injuries),"amarelo",10000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIAGNOSTIC
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Diagnostic()
	return Damaged,Bleedings
end
