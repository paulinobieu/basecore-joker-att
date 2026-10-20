-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vSERVER = Tunnel.getInterface("target")
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function DoAcademy(Number)
	if not Academy[Number] or GlobalState["Academy-"..Number] then
		return false
	end

	local Ped = PlayerPedId()

	SetEntityHeading(Ped,Academy[Number]["Coords"]["w"])
	SetEntityCoords(Ped,Academy[Number]["Coords"]["xyz"])
	TriggerEvent("emotes",Academy[Number]["Anim"])

	if vSERVER.Academy(Number) then
		TriggerEvent("Progress","Malhando",30000)

		SetTimeout(30000,function()
			vSERVER.AcademyWeight(Number)
			vRP.Destroy()
		end)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while GetResourceState("sleepless_interact") ~= "started" do
		Wait(500)
	end

	for Index,v in pairs(Academy) do
		exports.sleepless_interact:addCoords(v["Target"],{
			name = "Academy:"..Index,
			label = "Exercitar",
			icon = "dumbbell",
			distance = 1.75,
			canInteract = function()
				return not GlobalState["Academy-"..Index]
			end,
			onSelect = function()
				DoAcademy(Index)
			end
		})
	end
end)
