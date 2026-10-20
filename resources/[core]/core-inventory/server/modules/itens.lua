-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLE FLAGS
-----------------------------------------------------------------------------------------------------------------------------------------
local function VehicleFlags(Plate)
	Plate = (Plate or ""):gsub(" ","")
	if Plate == "" then return nil,"" end
	local Name = "vehicleFlags:"..Plate
	local Query = Framework.Query("entitydata/GetData",{ Name = Name })
	local Data = (Query and Query[1] and json.decode(Query[1].Information)) or {}
	return Data,Name
end

InventoryItemHelpers = {}

function InventoryItemHelpers.SaveVehicleFlag(Plate,Key,Value)
	local Data,Name = VehicleFlags(Plate)
	if not Data then return end
	Data[Key] = Value
	Framework.Query("entitydata/SetData",{ Name = Name, Information = json.encode(Data) })
end

AddEventHandler("core-vehicles:vehicleCreated",function(Plate,NetId)
	local Data = VehicleFlags(Plate)
	if not Data or (not Data.Drift and not Data.Seatbelt) then return end
	local Veh = NetworkGetEntityFromNetworkId(NetId)
	if Veh and Veh ~= 0 and DoesEntityExist(Veh) then
		if Data.Drift then Entity(Veh).state:set("Drift",true,true) end
		if Data.Seatbelt then Entity(Veh).state:set("Seatbelt",true,true) end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLUEPRINTSTART
-----------------------------------------------------------------------------------------------------------------------------------------
for Item,v in pairs(Framework.ListItem) do
	if v.Blueprint then
		Use["blueprint_"..Item] = function(source,Passport,Amount,Slot,Full)
			Users.Blueprints[Passport] = Users.Blueprints[Passport] or {}

			if Users.Blueprints[Passport][Item] then
				TriggerClientEvent("inventory:Notify",source,"Aviso","Já possui este aprendizado.","amarelo")
				return false
			end

			if Framework.TakeItem(Passport,Full,1,true,Slot) then
				TriggerClientEvent("inventory:Notify",source,"Sucesso","Aprendizado adicionado.","verde")
				TriggerClientEvent("inventory:Update",source)
				Users.Blueprints[Passport][Item] = true

				return true
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLESSTART
-----------------------------------------------------------------------------------------------------------------------------------------
for Model,v in pairs(Framework.VehicleList()) do
	if v.item then
		Use["vehicle_"..Model] = function(source,Passport,Amount,Slot,Full)
			if Framework.SelectVehicle(Passport,Model) then
				TriggerClientEvent("inventory:Notify",source,"Aviso","Já possui um <b>"..Framework.VehicleName(Model).."</b>.","amarelo")
				return false
			end

			local StockLimit = Framework.VehicleStock(Model)
			if StockLimit and Framework.Scalar("vehicles/Count",{ Vehicle = Model }) >= StockLimit then
				TriggerClientEvent("inventory:Notify",source,"Aviso","Estoque insuficiente.","amarelo")
				return false
			end

			if Framework.TakeItem(Passport,Full,1,false,Slot) then
				local Result = Framework.GiveVehicle(Passport,Model)
				if not Result or not Result.ok then
					Framework.GenerateItem(Passport,Full,1,true)
					TriggerClientEvent("inventory:Notify",source,"Aviso","Não foi possível adicionar o veículo.","amarelo")
					return false
				end

				if type(v.Item) == "number" then
					Framework.DatabaseUpdate("UPDATE core_characters_vehicles SET expire_time = ?, expired = 0 WHERE plate = ?",{ os.time() + (86400 * v.Item), Result.plate })
				end

				TriggerClientEvent("inventory:Notify",source,"Sucesso","Veículo <b>"..Framework.VehicleName(Model).."</b> adicionado.","verde")
				TriggerClientEvent("inventory:Update",source)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPRAYS
-----------------------------------------------------------------------------------------------------------------------------------------
for NameItem,v in pairs(Inventory.Spray.Groups) do
	Use[NameItem] = function(source,Passport,Amount,Slot,Full,Item,Split)
		if Framework.InventoryClient.CheckInterior(source) then
			TriggerClientEvent("Notify",source,"Atenção","Só pode ser posicionado fora de interiores.","amarelo",5000)
			return false
		end

		for Index,Info in pairs(SaveObjects) do
			if Info.Permission and Info.Permission == v[1] and Info.Mode == "Sprays" then
				TriggerClientEvent("Notify",source,"Atenção","O grupo já possui um spray aplicado.","amarelo",5000)
				return false
			end
		end

		if Framework.Client.SprayExist(source,500) then
			TriggerClientEvent("Notify",source,"Atenção","No momento você não pode prosseguir porque outro grupo está dominando a localidade.","amarelo",5000)
			return false
		end

		TriggerClientEvent("inventory:Close",source)

		local Application,Coords = Framework.InventoryClient.SprayControlling(source,NameItem)
		if Application and Coords then
			Active[Passport] = os.time() + 999
			Player(source).state.Buttons = true
			TriggerClientEvent("Progress",source,"Agitando",5000)
			Framework.Client.CreateObjects(source,"switch@franklin@lamar_tagging_wall","lamar_tagging_wall_loop_lamar","prop_cs_spray_can",1,28422)

			SetTimeout(5000,function()
				if Active[Passport] then
					Active[Passport] = os.time() + 10
					TriggerClientEvent("Progress",source,"Colocando",10000)
					TriggerClientEvent("sounds:Private",source,"sprays",0.5)
					Framework.Client.CreateObjects(source,"switch@franklin@lamar_tagging_wall","lamar_tagging_exit_loop_lamar","prop_cs_spray_can",1,28422)

					CreateThread(function()
						while Active[Passport] and os.time() < Active[Passport] do
							Wait(100)
						end

						if Active[Passport] then
							Framework.Client.Destroy(source)
							Active[Passport] = nil

							if not Framework.Client.SprayExist(source,500) and Framework.TakeItem(Passport,Full,1,true,Slot) then
								repeat
									Selected = Framework.GenerateString("DDLLDDLL")
								until Selected and not Objects[Selected]

								Objects[Selected] = { Coords = Coords, Object = NameItem, Mode = "Sprays", Timer = os.time() + Inventory.Objects.Settings.SprayDuration, Ground = true, Color = v[2], Permission = v[1], Bucket = GetPlayerRoutingBucket(source) }
								Framework.Discord("Sprays","**[PASSAPORTE]:** "..Passport.."\n**[Item]:** "..NameItem.."\n**[Coords]:** "..Coords[1]..","..Coords[2]..","..Coords[3])
								SaveObjects[Selected] = Objects[Selected]

								TriggerClientEvent("objects:Adicionar",-1,Selected,Objects[Selected])
							end
						end

						Player(source).state.Buttons = false
					end)
				else
					Player(source).state.Buttons = false
				end
			end)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLONES
-----------------------------------------------------------------------------------------------------------------------------------------
for _,v in ipairs(Framework.Clones) do
	for _,w in ipairs(Framework.Puritys) do
		Use[v.Clone.."clone_"..w.Percent] = function(source,Passport,Amount,Slot,Full,Item,Split)
			Player(source).state.Buttons = true
			TriggerClientEvent("inventory:Close",source)

			local Hash = v.Hash
			local Application,Coords = Framework.Client.ObjectControlling(source,Hash)
			if Application and Coords and not Framework.InventoryClient.ObjectExists(source,Coords,Hash) and Framework.TakeItem(Passport,Full,1,true,Slot) then
				Framework.CreatePlant(Hash,Coords,GetPlayerRoutingBucket(source),v.Clone,{ Min = v.Min, Max = v.Max },w.Percent)
			end

			Player(source).state.Buttons = false
		end
	end
end
