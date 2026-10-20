-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CARRY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Carry")
AddEventHandler("inventory:Carry",function(OtherSource,Mode,Hancuff)
	local Ped = PlayerPedId()
	local Settings = Inventory.ClientItems.Carry

	if Mode == "Attach" then
		local OtherServer = GetPlayerFromServerId(OtherSource)
		local Attachment = Hancuff and Settings.Handcuffed or Settings.Default

		AttachEntityToEntity(Ped,GetPlayerPed(OtherServer),Settings.Bone,Attachment.Offset[1],Attachment.Offset[2],Attachment.Offset[3],Attachment.Rotation[1],Attachment.Rotation[2],Attachment.Rotation[3],true,true,false,true,2,true)
	elseif Mode == "Detach" then
		DetachEntity(Ped,false,false)
	end
end)
