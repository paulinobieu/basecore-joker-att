-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Blip = nil
local Plate = nil
local Position = 1
local Tank = "tanker"
local Delivery = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUELSTATIONS:INIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("fuelstations:Init")
AddEventHandler("fuelstations:Init",function(Routes,Heading)
	if Delivery then
		return false
	end

	Position = 1
	Delivery = Routes

	-- O caminhão nasce no ponto de entrega do posto (último item da rota) com o
	-- heading do model do posto, e não 8 metros à frente do player: quem inicia
	-- o serviço está dentro da loja, e o offset jogava o veículo dentro da
	-- parede ou em cima do telhado.
	local Coords = Routes[#Routes]
	local _,Networked = vGARAGE.ServerVehicle("packer",vec4(Coords.x,Coords.y,Coords.z,Heading or 0.0),nil,0,nil,1000,0,false)
	if not Networked then
		Delivery = false
		TriggerEvent("Notify","Central de Empregos","Não foi possível preparar o caminhão. Tente novamente.","vermelho",5000)
		return false
	end

	local Entity = LoadNetwork(Networked)
	while not DoesEntityExist(Entity) do
		Wait(100)
	end
	SetVehicleOnGroundProperly(Entity)

	TriggerEvent("Notify","Central de Empregos","Entre no caminhão e siga até o ponto marcado<br>para carregar e transportar o combustível.","default",5000)

	BlipMarked()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUELSTATIONS:FINISH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("fuelstations:Finish")
AddEventHandler("fuelstations:Finish",function(Routes)
	if Delivery then
		Delivery = false

		if DoesBlipExist(Blip) then
			RemoveBlip(Blip)
		end

		Position = 1
		Plate = nil
		Blip = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		if Delivery then
			local Ped = PlayerPedId()
			local Vehicle = GetLastDrivenVehicle()
			if IsEntityAVehicle(Vehicle) and GetEntityArchetypeName(Vehicle) == "packer" then
				local Coords = GetEntityCoords(Ped)
				local Destiny = Delivery[Position]
				if Destiny then
					local Distance = #(Coords - Destiny)

					if Distance <= 200 then
						TimeDistance = 1
						DrawMarker(1,Destiny.x,Destiny.y,Destiny.z - 3,0,0,0,0,0,0,12.0,12.0,8.0,255,255,255,25,0,0,0,0)
						DrawMarker(21,Destiny.x,Destiny.y,Destiny.z + 1,0,0,0,0,180.0,130.0,3.0,3.0,2.0,88,101,242,175,0,0,0,1)

						if Distance <= 10 and IsControlJustPressed(1,38) then
							if Position >= #Delivery then
								if not IsPedInAnyVehicle(Ped) and GetVehicleNumberPlateText(Vehicle) == Plate then
									local Vehicle,Network,Platex,Model = vRP.VehicleList(10)
									if Vehicle and Model == Tank then
										Delivery = false
										vSERVER.Payment()
										TriggerServerEvent("garages:Delete",Network,Platex)

										if DoesBlipExist(Blip) then
											RemoveBlip(Blip)
											Blip = nil
										end
									end
								end
							else
								local Heading = GetEntityHeading(Vehicle)
								Plate = GetVehicleNumberPlateText(Vehicle)
								local Coords = GetOffsetFromEntityInWorldCoords(Vehicle,0.0,-12.0,0.0)
								local _,Networked = vGARAGE.ServerVehicle("tanker",vec4(Coords.x,Coords.y,Coords.z,Heading),nil,0,nil,1000,0,false)
								if Networked then
									local Entity = LoadNetwork(Networked)
									while not DoesEntityExist(Entity) do
										Wait(100)
									end

									SetVehicleOnGroundProperly(Entity)
									Position += 1
									BlipMarked()
								end
							end
						end
					end
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIPMARKED
-----------------------------------------------------------------------------------------------------------------------------------------
function BlipMarked()
	if DoesBlipExist(Blip) then
		RemoveBlip(Blip)
	end

	local Destiny = Delivery[Position]
	if not Destiny then
		return false
	end

	Blip = AddBlipForCoord(Destiny.x,Destiny.y,Destiny.z)
	SetBlipSprite(Blip,12)
	SetBlipColour(Blip,77)
	SetBlipScale(Blip,0.9)
	SetBlipRoute(Blip,true)
	SetBlipAsShortRange(Blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Caminhoneiro")
	EndTextCommandSetBlipName(Blip)
end