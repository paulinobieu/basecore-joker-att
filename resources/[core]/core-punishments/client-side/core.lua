-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Blocked = false
local Prisoned = false
local BlockRemaining = 0
local PrisonRemaining = 0
local ShowNotify = true
local ReviveAccum = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORMAT
-----------------------------------------------------------------------------------------------------------------------------------------
local function FormatTime(s)
	if s <= 0 then
		return "Expirado"
	end

	return string.format("%02d dias, %02d horas, %02d minutos, %02d segundos",math.floor(s / 86400),math.floor((s % 86400) / 3600),math.floor((s % 3600) / 60),s % 60)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-punishments:Apply")
AddEventHandler("core-punishments:Apply",function(ptype,expires,remaining,reason)
	if ptype == "block" then
		if expires > 0 and remaining > 0 then
			Blocked = true
			BlockRemaining = remaining
			SendNUIMessage({ blockExpires = FormatTime(remaining) })
		else
			Blocked = false
			BlockRemaining = 0
			SendNUIMessage({ blockExpires = 0 })
		end
	elseif ptype == "prison" then
		if expires > 0 and remaining > 0 then
			if not Prisoned then
				SetEntityCoords(PlayerPedId(),Punishments.PrisonCoords.x,Punishments.PrisonCoords.y,Punishments.PrisonCoords.z,1,0,0,0)
			end

			Prisoned = true
			PrisonRemaining = remaining
			SendNUIMessage({ prisonExpires = FormatTime(remaining) })
		else
			local wasPrisoned = Prisoned
			Prisoned = false
			PrisonRemaining = 0
			SendNUIMessage({ prisonExpires = 0 })
			if wasPrisoned then
				SetEntityCoords(PlayerPedId(),Punishments.PrisonRelease.x,Punishments.PrisonRelease.y,Punishments.PrisonRelease.z,1,0,0,0)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-punishments:ToggleNotify")
AddEventHandler("core-punishments:ToggleNotify",function()
	ShowNotify = not ShowNotify
	if not ShowNotify then
		SendNUIMessage({ blockExpires = 0, prisonExpires = 0 })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD: DISABLE CONTROLS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local ms = 999
		if Blocked or Prisoned then
			ms = 1
			local ped = PlayerPedId()
			DisablePlayerFiring(ped,true)
			DisableControlAction(0,24,true)
			DisableControlAction(0,25,true)
			DisableControlAction(0,47,true)
			DisableControlAction(0,58,true)
			DisableControlAction(0,140,true)
			DisableControlAction(0,141,true)
			DisableControlAction(0,142,true)
			DisableControlAction(0,257,true)
			DisableControlAction(0,263,true)
			DisableControlAction(0,264,true)
		end

		Wait(ms)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD: BLOCK COUNTDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Blocked and BlockRemaining > 0 and ShowNotify then
			BlockRemaining = BlockRemaining - 1
			if BlockRemaining > 0 then
				SendNUIMessage({ blockExpires = FormatTime(BlockRemaining) })
			else
				Blocked = false
				BlockRemaining = 0
				SendNUIMessage({ blockExpires = 0 })
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD: PRISON BOUNDARY + REVIVE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local ms = 10000
		if Prisoned then
			ms = 999
			local ped = PlayerPedId()
			local coords = GetEntityCoords(ped)
			local dist = #(coords - Punishments.PrisonCoords)

			if dist > Punishments.PrisonRadius then
				SetEntityCoords(ped,Punishments.PrisonCoords.x,Punishments.PrisonCoords.y,Punishments.PrisonCoords.z,1,0,0,0)
			end

			if GetEntityHealth(ped) <= 101 then
				ReviveAccum = ReviveAccum + 1
				if ReviveAccum >= Punishments.ReviveDelay then
					ReviveAccum = 0
					TriggerServerEvent("core-punishments:Revive")
				end
			else
				ReviveAccum = 0
			end
		end

		Wait(ms)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD: PRISON COUNTDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Prisoned and PrisonRemaining > 0 and ShowNotify then
			PrisonRemaining = PrisonRemaining - 1
			if PrisonRemaining > 0 then
				SendNUIMessage({ prisonExpires = FormatTime(PrisonRemaining) })
			else
				Prisoned = false
				PrisonRemaining = 0
				SendNUIMessage({ prisonExpires = 0 })
				SetEntityCoords(PlayerPedId(),Punishments.PrisonRelease.x,Punishments.PrisonRelease.y,Punishments.PrisonRelease.z,1,0,0,0)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("IsTied",function()
	return Blocked
end)

exports("IsPrisoned",function()
	return Prisoned
end)
-----------------------------------------------------------------------------------------------------------------------------------------
