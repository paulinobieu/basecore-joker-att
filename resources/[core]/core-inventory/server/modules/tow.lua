-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:TOW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Tow")
AddEventHandler("inventory:Tow",function(Vehicle,Selected,Mode)
	local source = source
	local Players = Framework.Client.Players(source)
	for _,v in pairs(Players) do
		Framework.async(function()
			TriggerClientEvent("inventory:ClientTow",v,Vehicle,Selected,Mode)
		end)
	end
end)
