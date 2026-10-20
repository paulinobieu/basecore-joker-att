-----------------------------------------------------------------------------------------------------------------------------------------
-- ITENS
-----------------------------------------------------------------------------------------------------------------------------------------
local Itens = Inventory.MoneyWash.Items
local Settings = Inventory.MoneyWash.Settings
-----------------------------------------------------------------------------------------------------------------------------------------
-- WASHERS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Washers(Value)
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then
		return false
	end

	Value = Framework.parseInt(Value,true)
	local RewardItem = Settings.RewardPrefix..Value
	local Data = Itens[RewardItem]
	if not Data then
		return false
	end

	if Framework.TakeItem(Passport,Settings.InputItem,Value) then
		Framework.CallPolice({
			Source = source,
			Passport = Passport,
			Permission = Settings.Police.Permission,
			Name = Settings.Police.Name,
			Percentage = Data.Police,
			Wanted = Settings.Police.Wanted,
			Code = Settings.Police.Code,
			Color = Settings.Police.Color
		})

		Framework.GenerateItem(Passport,RewardItem,1,true)

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEYWASH:SWAP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("moneywash:Swap")
AddEventHandler("moneywash:Swap",function()
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then
		return false
	end

	local Notify = false
	for ItemName,v in pairs(Itens) do
		local Amount,FullName = table.unpack(Framework.InventoryItemAmount(Passport,ItemName))

		if Amount > 0 and FullName ~= "" then
			if Framework.TakeItem(Passport,FullName,Amount) then
				local Multiplier = Framework.HasGroup(Passport,Settings.Permission) and v.Permission or v.Percentage
				local Total = v.Value * Multiplier

				Framework.GenerateItem(Passport,Settings.SwapReward,Amount * Total)
				Notify = true
			end
		end
	end

	if Notify then
		TriggerClientEvent("Notify",source,"Sucesso","Troca concluída.","verde",5000)
	else
		TriggerClientEvent("Notify",source,"Aviso","Promissórias não encontradas.","amarelo",5000)
	end
end)
