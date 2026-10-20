-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFYPUSH (despacho policial)
-- Parâmetros: cds, code, title, author, location {x,y,z}
-----------------------------------------------------------------------------------------------------------------------------------------
local PoliceLocCoords = {}

RegisterNetEvent("NotifyPush")
AddEventHandler("NotifyPush", function(cds, code, title, author, location)
	if type(cds) == "table" then
		local t = cds
		location = t.location or (t.x and t.y and t.z and { x = t.x, y = t.y, z = t.z })
		author   = t.author or t.name or ""
		title    = t.title or t.message or ""
		code     = "10-" .. tostring(t.code or "")
		cds      = t.cds or string.format("DYN_%d", GetGameTimer())
	end

	local locationStr
	if type(location) == "table" and location.x then
		local streetHash, crossingHash = GetStreetNameAtCoord(location.x, location.y, location.z)
		local street   = ConvertStreet(GetStreetNameFromHashKey(streetHash) or "")
		local crossing = ConvertStreet(GetStreetNameFromHashKey(crossingHash) or "")
		if crossing ~= "" then
			locationStr = street .. " c/ " .. crossing
		else
			locationStr = street ~= "" and street or string.format("%.0f, %.0f", location.x, location.y)
		end
		PoliceLocCoords[cds] = location
	else
		locationStr = tostring(location or "")
	end

	SendNUIMessage({ action = "notify:police", payload = {
		cds       = cds,
		code      = code,
		title     = title,
		author    = author,
		location  = locationStr,
		timestamp = string.format("%02d:%02d", GlobalState.Hours or 0, GlobalState.Minutes or 0),
	}})

	PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", false)

	if location and location.x then
		local BlipType  = 161
		local BlipColor = 3
		if code == "Tiroteio" then
			BlipType  = 110
			BlipColor = 1
		elseif code == "Acidente" then
			BlipType  = 577
			BlipColor = 3
		elseif code == "Roubo" then
			BlipType  = 473
			BlipColor = 1
		end

		local Blip = AddBlipForCoord(location.x, location.y, location.z)
		SetBlipSprite(Blip, BlipType)
		SetBlipColour(Blip, BlipColor)
		SetBlipScale(Blip, 0.8)
		SetBlipAsShortRange(Blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(code .. ": " .. title)
		EndTextCommandSetBlipName(Blip)

		SetTimeout(60000, function()
			if DoesBlipExist(Blip) then RemoveBlip(Blip) end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HISTORICO POLICIAL (F2)
-----------------------------------------------------------------------------------------------------------------------------------------
local PoliceHistoryOpen = false

RegisterKeyMapping("hudpolicehistory", "Histórico de Despachos", "keyboard", "F2")
RegisterCommand("hudpolicehistory", function()
	PoliceHistoryOpen = not PoliceHistoryOpen
	SendNUIMessage({ action = "notify:police:historyVisibility", payload = PoliceHistoryOpen })
	SetNuiFocus(PoliceHistoryOpen, PoliceHistoryOpen)
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FECHAR HISTÓRICO (Esc no NUI)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:police:closeHistory", function(_, cb)
	PoliceHistoryOpen = false
	SendNUIMessage({ action = "notify:police:historyVisibility", payload = false })
	SetNuiFocus(false, false)
	cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MARCAR LOCALIZAÇÃO (fecha histórico e define waypoint)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:police:markLocation", function(cds, cb)
	local coords = PoliceLocCoords[cds]
	if coords then
		SetNewWaypoint(coords.x, coords.y)
	end
	PoliceHistoryOpen = false
	SendNUIMessage({ action = "notify:police:historyVisibility", payload = false })
	SetNuiFocus(false, false)
	cb(true)
end)
