-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Settings = Inventory.ClientItems.Tow
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:TOW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Tow")
AddEventHandler("inventory:Tow",function(Selected)
	local Ped = PlayerPedId()
	local Selected = Selected[3]
	local Vehicle = GetLastDrivenVehicle()
	if DoesEntityExist(Selected) and DoesEntityExist(Vehicle) and not Entity(Selected)["state"]["Tower"] and GetEntityArchetypeName(Vehicle) == Settings.TruckModel and not IsPedInAnyVehicle(Ped) then
		local Coords = GetEntityCoords(Selected)
		local OtherCoords = GetEntityCoords(Vehicle)

		if #(Coords - OtherCoords) <= Settings.MaximumDistance then
			if Entity(Selected)["state"]["Tow"] then
				TriggerServerEvent("inventory:Tow",NetworkGetNetworkIdFromEntity(Vehicle),NetworkGetNetworkIdFromEntity(Selected),false)
			else
				LocalPlayer["state"]["Cancel"] = true
				LocalPlayer["state"]["Commands"] = true

				TaskTurnPedToFaceEntity(Ped,Selected,Settings.ActionDuration)
				TriggerEvent("sounds:Private",Settings.Sound.Name,Settings.Sound.Volume)
				Framework.playAnim(false,{Settings.Animation.Dict,Settings.Animation.Name},true)

				SetTimeout(Settings.ActionDuration,function()
					Framework.Destroy()

					LocalPlayer["state"]["Cancel"] = false
					LocalPlayer["state"]["Commands"] = false
					Entity(Vehicle)["state"]:set("Tow",true,true)
					Entity(Selected)["state"]:set("Tow",true,true)

					TriggerServerEvent("inventory:Tow",NetworkGetNetworkIdFromEntity(Vehicle),NetworkGetNetworkIdFromEntity(Selected),true)
				end)
			end
		else
			TriggerEvent("Notify","Aviso","O reboque precisa estar próximo do veículo.","amarelo",5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLIENTTOW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:ClientTow")
AddEventHandler("inventory:ClientTow",function(Vehicle,Selected,Mode)
	if NetworkDoesNetworkIdExist(Vehicle) and NetworkDoesNetworkIdExist(Selected) then
		local Vehicle = NetToEnt(Vehicle)
		local Selected = NetToEnt(Selected)
		if DoesEntityExist(Vehicle) and DoesEntityExist(Selected) then
			if Mode then
				local Model = GetEntityModel(Selected)
				local Dimensions = GetModelDimensions(Model)

				AttachEntityToEntity(Selected,Vehicle,GetEntityBoneIndexByName(Vehicle,Settings.Attachment.Bone),Settings.Attachment.Offset[1],Settings.Attachment.Offset[2],Settings.Attachment.Offset[3] - Dimensions["z"],0,0,0,true,true,true,true,2,true)
			else
				DetachEntity(Selected,false,false)

				local Heading = GetEntityHeading(Vehicle)
				local Coords = GetOffsetFromEntityInWorldCoords(Vehicle,Settings.DetachOffset[1],Settings.DetachOffset[2],Settings.DetachOffset[3])
				SetEntityCoords(Selected,Coords["x"],Coords["y"],Coords["z"],false,false,false,false)
				SetEntityHeading(Selected,Heading)
				SetVehicleOnGroundProperly(Selected)

				if Entity(Vehicle)["state"]["Tow"] then
					Entity(Vehicle)["state"]:set("Tow",nil,true)
				end

				if Entity(Selected)["state"]["Tow"] then
					Entity(Selected)["state"]:set("Tow",nil,true)
				end
			end
		end
	end
end)
