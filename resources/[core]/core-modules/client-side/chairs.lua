-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local OutChair = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAIRS
-----------------------------------------------------------------------------------------------------------------------------------------
local Chairs = {
	[-1235256368] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.0, Heading = 90.0 },
	[538002882] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = -0.1, Heading = 180.0 },
	[-1118419705] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[-377849416] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[-109356459] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[-1692811878] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[-729914417] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[1577885496] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[1889748069] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[1816935351] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[1037469683] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.4, Heading = 180.0 },
	[536071214] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[438342263] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.25, Heading = 180.0 },
	[2129125614] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[195568113] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.51, Heading = 180.0 },
	[1827229923] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 },
	[-1078931853] = { OffsetX = 0.0, OffsetY = 0.0, OffsetZ = 0.5, Heading = 180.0 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Models = {}
	for Model in pairs(Chairs) do
		Models[#Models + 1] = Model
	end

	exports.ox_target:addModel(Models,{
		{
			name = "target:chair",
			label = "Sentar",
			icon = "fa-solid fa-chair",
			distance = 1.0,
			onSelect = function(Data)
				local Network = nil
				if NetworkGetEntityIsNetworked(Data.entity) then
					Network = NetworkGetNetworkIdFromEntity(Data.entity)
				end

				TriggerEvent("target:Chair",{ Data.entity,GetEntityModel(Data.entity),Network,GetEntityCoords(Data.entity),IsEntityDead(Data.entity) })
			end
		}
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET:UPCHAIR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("target:UpChair")
AddEventHandler("target:UpChair",function()
	if not OutChair or not LocalPlayer.state.Chair then
		return false
	end

	local Ped = PlayerPedId()
	SetEntityCoords(Ped,OutChair.x,OutChair.y,OutChair.z - 1)
	LocalPlayer.state:set("Chair",false,false)
	FreezeEntityPosition(Ped,false)
	OutChair = nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET:CHAIR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("target:Chair")
AddEventHandler("target:Chair",function(Vars)
	if OutChair or LocalPlayer.state.Chair then
		return false
	end

	local Model = Vars[2]
	local Entitys = Vars[1]

	if Chairs[Model] then
		local Ped = PlayerPedId()

		FreezeEntityPosition(Ped,false)
		FreezeEntityPosition(Entitys,true)
		LocalPlayer.state:set("Chair",true,false)

		OutChair = GetEntityCoords(Ped)
		SetEntityCoords(Ped,Vars[4].x,Vars[4].y,Vars[4].z + 0.5)
		SetEntityHeading(Ped,GetEntityHeading(Entitys) - Chairs[Model].Heading)

		TaskStartScenarioAtPosition(Ped,"PROP_HUMAN_SEAT_CHAIR_UPRIGHT",Vars[4].x + Chairs[Model].OffsetX,Vars[4].y + Chairs[Model].OffsetY,Vars[4].z + Chairs[Model].OffsetZ,GetEntityHeading(Entitys) - Chairs[Model].Heading,0,true,true)
	end
end)
