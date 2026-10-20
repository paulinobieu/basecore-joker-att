-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
ScubaMask = nil
ScubaTank = nil
local Settings = Inventory.ClientItems.Scuba
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:SCUBAREMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:ScubaRemove")
AddEventHandler("inventory:ScubaRemove",function()
	if ScubaMask and DoesEntityExist(ScubaMask) then
		TriggerServerEvent("DeleteObject",NetworkGetNetworkIdFromEntity(ScubaMask))
		ScubaMask = nil
	end

	if ScubaTank and DoesEntityExist(ScubaTank) then
		TriggerServerEvent("DeleteObject",NetworkGetNetworkIdFromEntity(ScubaTank))
		ScubaTank = nil
	end

	SetEnableScuba(PlayerPedId(),false)
	SetPedMaxTimeUnderwater(PlayerPedId(),Settings.DefaultUnderwaterTime)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:SCUBA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Scuba")
AddEventHandler("inventory:Scuba",function()
	if ScubaMask or ScubaTank then
		TriggerEvent("inventory:ScubaRemove")
	else
		local Ped = PlayerPedId()
		local Coords = GetEntityCoords(Ped)

		local Networked = Framework.VRPServer.CreateObject(Settings.Tank.Model,Coords["x"],Coords["y"],Coords["z"])
		if not Networked then return end

		ScubaTank = LoadNetwork(Networked)
		while not DoesEntityExist(ScubaTank) do
			Wait(100)
		end

		local Networked = Framework.VRPServer.CreateObject(Settings.Mask.Model,Coords["x"],Coords["y"],Coords["z"])
		if not Networked then return end

		ScubaMask = LoadNetwork(Networked)
		while not DoesEntityExist(ScubaMask) do
			Wait(100)
		end

		AttachEntityToEntity(ScubaTank,Ped,GetPedBoneIndex(Ped,Settings.Tank.Bone),Settings.Tank.Offset[1],Settings.Tank.Offset[2],Settings.Tank.Offset[3],Settings.Tank.Rotation[1],Settings.Tank.Rotation[2],Settings.Tank.Rotation[3],true,true,false,true,2,true)
		AttachEntityToEntity(ScubaMask,Ped,GetPedBoneIndex(Ped,Settings.Mask.Bone),Settings.Mask.Offset[1],Settings.Mask.Offset[2],Settings.Mask.Offset[3],Settings.Mask.Rotation[1],Settings.Mask.Rotation[2],Settings.Mask.Rotation[3],true,true,false,true,2,true)
		SetPedMaxTimeUnderwater(Ped,Settings.MaximumUnderwaterTime)
		SetEntityLodDist(ScubaMask,Settings.LodDistance)
		SetEntityLodDist(ScubaTank,Settings.LodDistance)
		SetEnableScuba(Ped,true)
	end
end)
