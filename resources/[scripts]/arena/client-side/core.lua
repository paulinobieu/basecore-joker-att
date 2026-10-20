-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
vSERVER = Tunnel.getInterface("arena")
Tunnel.bindInterface("arena",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Exit = nil
local Arena = "0"
local Guarded = nil
local KillStreek = 0
local FeedCooldown = GetGameTimer()

local function IsInCoreGameMatch()
	return GetResourceState("core-game") == "started" and LocalPlayer.state.inCoreGameMatch
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADPEDLIST
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Blip = AddBlipForCoord(Init["Coords"]["xyz"])
	SetBlipSprite(Blip,433)
	SetBlipDisplay(Blip,4)
	SetBlipAsShortRange(Blip,true)
	SetBlipColour(Blip,62)
	SetBlipScale(Blip,0.7)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Arena de Airsoft")
	EndTextCommandSetBlipName(Blip)

	while true do
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)
		if LocalPlayer["state"]["Arena"] then
			if Arena ~= "0" and Polyz[Arena] and not Polyz[Arena]:isPointInside(Coords) then
				TriggerEvent("arena:Exit")
			end
		else
			if #(Coords - Init["Coords"]["xyz"]) <= 100 then
				if not Guarded and LoadModel(Init["Model"]) then
					Guarded = CreatePed(26,Init["Model"],Init["Coords"]["x"],Init["Coords"]["y"],Init["Coords"]["z"] - 1,Init["Coords"]["w"],false,false)

					SetEntityInvincible(Guarded,true)
					FreezeEntityPosition(Guarded,true)
					DecorSetBool(Guarded,"CREATIVE_PED",true)
					SetEntityAsMissionEntity(Guarded,true,true)
					SetBlockingOfNonTemporaryEvents(Guarded,true)

					if LoadAnim("anim@heists@heist_corona@single_team") then
						TaskPlayAnim(Guarded,"anim@heists@heist_corona@single_team","single_team_loop_boss",8.0,8.0,-1,1,0,0,0,0)
					end

					exports.ox_target:addBoxZone({
						coords = Init["Coords"]["xyz"],
						size = vec3(0.75,0.75,2.0),
						rotation = Init["Coords"]["w"],
						name = "Arena",
						options = {
							{
								name = "arena:enter:1",
								label = "Entrar: Pistolas",
								icon = "fa-solid fa-gun",
								distance = 1.75,
								onSelect = function()
									TriggerEvent("arena:Enter","1")
								end
							},{
								name = "arena:enter:2",
								label = "Entrar: Sub-Metralhadoras",
								icon = "fa-solid fa-gun",
								distance = 1.75,
								onSelect = function()
									TriggerEvent("arena:Enter","2")
								end
							},{
								name = "arena:enter:3",
								label = "Entrar: Rifles",
								icon = "fa-solid fa-gun",
								distance = 1.75,
								onSelect = function()
									TriggerEvent("arena:Enter","3")
								end
							}
						}
					})
				end
			else
				if Guarded then
					exports.ox_target:removeZone("Arena")

					if DoesEntityExist(Guarded) then
						DeleteEntity(Guarded)
					end

					Guarded = nil
				end
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARENA:ENTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("arena:Enter")
AddEventHandler("arena:Enter",function(Number)
	local Ped = PlayerPedId()
	if not LocalPlayer["state"]["Arena"] and Zones[Number] and vSERVER.CheckEnter(Zones[Number]) then
		Arena = Number
		Exit = GetEntityCoords(Ped)
		SendNUIMessage({ Action = "Show" })
		LocalPlayer["state"]:set("Arena",true,true)
		LocalPlayer["state"]:set("Route",Zones[Number]["Route"],true)

		local Respawn = math.random(#Zones[Number]["Respawn"])
		SetEntityCoords(Ped,Zones[Number]["Respawn"][Respawn])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARENA:EXIT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("arena:Exit",function()
	if LocalPlayer["state"]["Arena"] and Zones[Arena] and vSERVER.CheckExit() then
		local Ped = PlayerPedId()
		if GetEntityHealth(Ped) <= 100 then
			exports.survival:Revive(200)
		end

		LocalPlayer["state"]:set("Arena",false,true)
		TriggerEvent("inventory:CleanWeapons",true)
		SendNUIMessage({ Action = "Hide" })
		SetEntityCoords(Ped,Exit)
		KillStreek = 0
		Arena = "0"
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARENA:RESPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("arena:Respawn",function()
	if LocalPlayer["state"]["Arena"] then
		exports.survival:Revive(200,true)
		local Respawn = math.random(#Zones[Arena]["Respawn"])
		SetEntityCoords(PlayerPedId(),Zones[Arena]["Respawn"][Respawn])
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
for _,v in pairs(Zones) do
	AddStateBagChangeHandler("Arena:"..v["Route"],nil,function(Name,Key,Value)
		if LocalPlayer["state"]["Arena"] and LocalPlayer["state"]["Route"] == v["Route"] then
			SendNUIMessage({ Action = "Players", Players = Value, Streek = KillStreek })
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ARENA:RESETSTREEK
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("arena:ResetStreek",function()
	SendNUIMessage({ Action = "Players", Players = GlobalState["Arena:"..LocalPlayer["state"]["Route"]], Streek = 0 })
	KillStreek = 0
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GAMEEVENTTRIGGERED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("gameEventTriggered",function(Event,Message)
	local CurrentTimer = GetGameTimer()
	if Event ~= "CEventNetworkEntityDamage" or not (LocalPlayer.state.Arena or IsInCoreGameMatch()) or LocalPlayer.state.Death then
		return false
	end

	local Ped = PlayerPedId()
	local Route = LocalPlayer.state.Route
	local Victim,Attacker = Message[1],Message[2]
	local Network = NetworkGetPlayerIndexFromPed(Attacker)

	if IsPedAPlayer(Victim) and Victim ~= Attacker and GetEntityHealth(Victim) <= 100 and FeedCooldown < CurrentTimer then
		FeedCooldown = CurrentTimer + 1000

		if Ped == Attacker then
			SendNUIMessage({ Action = "Players", Players = GlobalState["Arena:"..Route], Streek = KillStreek + 1 })
			KillStreek = KillStreek + 1
		end

		if Ped == Victim then
			TriggerServerEvent("arena:Death",GetPlayerServerId(Network),Route)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INFINITE STAMINA
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if LocalPlayer["state"]["Arena"] then
			RestorePlayerStamina(PlayerId(),1.0)
			Wait(0)
		else
			Wait(1000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Config(Number)
	return Zones[Number] or {}
end
