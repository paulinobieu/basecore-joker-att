local Clipset = "move_ped_wpn_jerrycan_generic"
local Enabled = false
local AppliedPed = 0

local function ResetWeaponMovement()
	if AppliedPed ~= 0 and DoesEntityExist(AppliedPed) then
		ResetPedWeaponMovementClipset(AppliedPed,0.25)
	end

	AppliedPed = 0
end

local function LoadClipset()
	if HasAnimSetLoaded(Clipset) then
		return true
	end

	RequestAnimSet(Clipset)

	local Timeout = GetGameTimer() + 5000
	while Enabled and not HasAnimSetLoaded(Clipset) and GetGameTimer() < Timeout do
		Wait(0)
	end

	return HasAnimSetLoaded(Clipset)
end

RegisterCommand("baixararma",function()
	Enabled = not Enabled

	if not Enabled then
		ResetWeaponMovement()
	end
end,false)

CreateThread(function()
	while true do
		if Enabled then
			local Ped = PlayerPedId()
			local Armed = not IsPedDeadOrDying(Ped,true) and not IsPedInAnyVehicle(Ped,false) and IsPedArmed(Ped,4)

			if Armed and LoadClipset() then
				if AppliedPed ~= 0 and AppliedPed ~= Ped then
					ResetWeaponMovement()
				end

				SetPedWeaponMovementClipset(Ped,Clipset,0.50)
				AppliedPed = Ped
			elseif AppliedPed ~= 0 then
				ResetWeaponMovement()
			end

			Wait(100)
		else
			Wait(500)
		end
	end
end)

AddEventHandler("onClientResourceStop",function(Resource)
	if Resource == GetCurrentResourceName() then
		Enabled = false
		ResetWeaponMovement()
	end
end)
