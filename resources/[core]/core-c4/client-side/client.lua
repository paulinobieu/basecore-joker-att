local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-c4", Core)
vSERVER = Tunnel.getInterface("core-c4")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local IsPlayerStealing = false
local BOMB_HASH = GetHashKey("prop_c4_final")
local MONEY_HASH = GetHashKey("bkr_prop_money_unsorted_01")
local PROP_OFFSET = {
	[GetHashKey("prop_atm_01")] = { off = vec3(0.0, -0.31, 0.75), rot = vec3(0.0, 90.0, 0.0), money = { pos = vec3(0.0, -1.0, 0.0), range = 1.1 } },
	[GetHashKey("prop_atm_02")] = { off = vec3(0.20, 0.02, 1.05), rot = vec3(0.0, 0.0, 0.0), money = { pos = vec3(0.0, -1.0, 0.0), range = 1.1 } },
	[GetHashKey("prop_atm_03")] = { off = vec3(0.20, 0.02, 1.05), rot = vec3(0.0, 0.0, 0.0), money = { pos = vec3(0.0, -1.0, 0.0), range = 1.1 } },
	[GetHashKey("prop_fleeca_atm")] = { off = vec3(0.20, 0.02, 1.05), rot = vec3(0.0, 0.0, 0.0), money = { pos = vec3(0.0, -1.0, 0.0), range = 1.1 } }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATMID
-----------------------------------------------------------------------------------------------------------------------------------------
local function buildAtmId(entity)
	local coords = GetEntityCoords(entity)
	return string.format("%.2f_%.2f_%.2f", coords.x, coords.y, coords.z)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local hashes = {}
	for _, model in ipairs(Config.AtmModels) do
		hashes[#hashes + 1] = GetHashKey(model)
	end

	exports.ox_target:addModel(hashes, {
		{
			name = "eletronics:opensystem",
			label = "Roubar",
			icon = "fa-solid fa-bolt",
			distance = 1.5,
			onSelect = function(data)
				TriggerEvent("eletronics:openSystem", { data.entity, GetEntityModel(data.entity), (NetworkGetEntityIsNetworked(data.entity) and NetworkGetNetworkIdFromEntity(data.entity) or nil), GetEntityCoords(data.entity), IsEntityDead(data.entity) })
			end
		},
		{
			name = "core-bank:open:atm",
			label = "Abrir",
			icon = "fa-solid fa-building-columns",
			distance = 1.5,
			onSelect = function(data)
				TriggerEvent("core-bank:open", { data.entity, GetEntityModel(data.entity), (NetworkGetEntityIsNetworked(data.entity) and NetworkGetNetworkIdFromEntity(data.entity) or nil), GetEntityCoords(data.entity), IsEntityDead(data.entity) })
			end
		}
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
local function cancelPlayer(status, setBackpack)
	if setBackpack then
		TriggerEvent("core-customization:setParts",{ backpack = { item = 0, texture = 0 } })
	end

	LocalPlayer["state"]:set("Buttons", status, true)
	LocalPlayer["state"]:set("Commands", status, true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNBOMB
-----------------------------------------------------------------------------------------------------------------------------------------
local function spawnBomb(coords, atmProp, offsetData)
	LoadModel(BOMB_HASH)
	local bombProp = CreateObject(BOMB_HASH, coords)
	local timeout = GetGameTimer() + 5000
	repeat
		Wait(10)
	until DoesEntityExist(bombProp) or GetGameTimer() > timeout
	SetModelAsNoLongerNeeded(BOMB_HASH)
	if atmProp ~= 0 then
		if DoesEntityExist(bombProp) then
			AttachEntityToEntity(bombProp, atmProp, 0, offsetData.off.x, offsetData.off.y, offsetData.off.z, offsetData.rot.x, offsetData.rot.y, offsetData.rot.z, false, false, false, true, 0, true)
		end
	else
		FreezeEntityPosition(bombProp, true)
		SetEntityCollision(bombProp, false)
	end
	return bombProp
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETRANDOMCIRCULARCOORDS
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetRandomCircularCoords(position, radius)
	local angle = GetRandomFloatInRange(0.1, 6.2)
	return vec3(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNMONEY
-----------------------------------------------------------------------------------------------------------------------------------------
local function spawnMoney(centerCoords, maxRange)
	local spawnCoords = GetRandomCircularCoords(centerCoords, GetRandomFloatInRange(0.0, maxRange))
	local moneyProp = CreateObjectNoOffset(MONEY_HASH, spawnCoords)
	local timeout = GetGameTimer() + 5000
	repeat
		Wait(10)
	until DoesEntityExist(moneyProp) or GetGameTimer() > timeout
	if DoesEntityExist(moneyProp) then
		SetEntityHeading(moneyProp, math.random(360) + 0.0)
		PlaceObjectOnGroundProperly(moneyProp)
	end
	return { prop = moneyProp, coords = GetEntityCoords(moneyProp) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RUNROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
local function runRobbery(atm)
	local ped = PlayerPedId()
	local model = GetEntityModel(atm)
	local offset = PROP_OFFSET[model]
	if not offset then return end

	local atmCoords = GetEntityCoords(atm)
	local atmId = buildAtmId(atm)

	local mode = vSERVER.CheckSystems(atmId, atmCoords)
	if not mode then return end

	local isLockpick = mode == "lockpick"
	cancelPlayer(true, true)

	local offsetCoords = GetOffsetFromEntityInWorldCoords(atm, offset.money.pos)
	SetEntityHeading(ped, GetEntityHeading(atm))
	SetEntityCoords(ped, offsetCoords.x, offsetCoords.y, offsetCoords.z)

	if isLockpick then
		vRP.playAnim(false, { "oddjobs@shop_robbery@rob_till", "loop" }, true)
	else
		vRP.CreateObjects("anim@heists@ornate_bank@thermal_charge", "thermal_charge", "prop_c4_final_green", 0, 28422, 0.0, 0.0, 0.0, 260.0, 0.0, 0.0)
	end

	local timeout = GetGameTimer() + (Config.Timers.Preparation * 1000)
	repeat
		Wait(10)
	until GetGameTimer() > timeout
	vRP.Destroy()
	cancelPlayer(false)

	if not isLockpick then
		local bombProp = spawnBomb(atmCoords, atm, offset)
		SendNUIMessage({ time = Config.Timers.BombCountdown })
		timeout = GetGameTimer() + (Config.Timers.BombCountdown * 1000)
		repeat
			Wait(10)
		until GetGameTimer() > timeout
		DeleteObject(bombProp)
		AddExplosion(atmCoords.x, atmCoords.y, atmCoords.z, Config.Explosion.Type, Config.Explosion.Scale, true, false, Config.Explosion.CamShake)
	end

	vSERVER.UpdateAtmExploded(atmId, atmCoords, model)
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETDROP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("eletronics:setDrop", function(atmId, dropCoords, modelHash)
	local ped = PlayerPedId()
	local plyVeh = GetVehiclePedIsUsing(ped)
	local offset = PROP_OFFSET[modelHash]
	if not offset or not dropCoords then return end

	LoadModel(MONEY_HASH)
	local propList = {}
	SetEntityDrawOutlineColor(255, 255, 255, 150)
	for i = 1, Config.Robbery.Pickups.Total do
		propList[i] = spawnMoney(dropCoords, offset.money.range)
		SetEntityDrawOutline(propList[i].prop, true)
	end
	SetModelAsNoLongerNeeded(MONEY_HASH)
	TriggerEvent("Notify", "Atenção", "O caixa explodiu! Colete o dinheiro antes que a polícia chegue.", "amarelo", 8000)

	local dist, delay
	while true do
		delay = 500
		dist = #(GetEntityCoords(ped) - dropCoords)
		if dist <= Config.Distances.MarkerProximity then
			delay = 0
			for _, v in pairs(propList) do
				DrawMarker(1, v.coords.xy, v.coords.z - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.02, 0.02, 0.9, 240, 83, 0, 150, false, false, 2)
			end
			if dist <= Config.Distances.Pickup and IsControlPressed(0, 38) and plyVeh == 0 then
				if vSERVER.TryPickup(atmId) then
					cancelPlayer(true)
					vRP.playAnim(true, { "amb@world_human_bum_wash@male@high@base", "base" }, false)
					local listLength = #propList
					if DoesEntityExist(propList[listLength].prop) then
						DeleteEntity(propList[listLength].prop)
					end
					local timeout = GetGameTimer() + (Config.Timers.PickupAnim * 1000)
					repeat
						Wait(10)
					until GetGameTimer() > timeout
					vRP.stopAnim(true)
					cancelPlayer(false)
					propList[listLength] = nil
					if listLength == 1 then
						TriggerEvent("Notify", "Sucesso", "Dinheiro coletado. Fuja da área o mais rápido possível", "verde", 8000)
						break
					end
				else
					TriggerEvent("Notify", "Sucesso", "Dinheiro coletado. Fuja da área o mais rápido possível", "verde", 8000)
					break
				end
			end
		elseif dist > Config.Distances.Abort then
			vSERVER.AbortRobbery(atmId)
			TriggerEvent("Notify", "Erro", "Você se afastou demais da área", "vermelho", 8000)
			for i = 1, #propList do
				DeleteEntity(propList[i].prop)
			end
			break
		end
		Wait(delay)
	end
	IsPlayerStealing = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOWTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("eletronics:showTimer", function(time)
	SendNUIMessage({ time = time or 15 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("eletronics:openSystem", function(Selected)
	if LocalPlayer.state.Policia or LocalPlayer.state.PoliciaAcao then
		return
	end

	if IsPlayerStealing then
		return
	end

	local atm = Selected and Selected[1]
	if not atm or not DoesEntityExist(atm) then
		return
	end

	IsPlayerStealing = true
	IsPlayerStealing = runRobbery(atm)
end)
