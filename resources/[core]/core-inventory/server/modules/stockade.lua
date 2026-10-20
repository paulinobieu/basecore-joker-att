-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Stockades = {}
local Settings = Inventory.Stockade
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:STOCKADE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Stockade")
AddEventHandler("inventory:Stockade",function(Vehicle)
	local source = source
	local Plate = Vehicle[1]
	local Passport = Framework.Passport(source)
	local _,Total = Framework.NumPermission(Settings.Alert.Permission)
	if Passport and not Active[Passport] and Total >= Settings.Police and not Framework.PassportPlate(Plate) then
		if not Stockades[Plate] then
			Stockades[Plate] = Settings.Compartments

			Framework.CallPolice({
				Source = source,
				Passport = Passport,
				Permission = Settings.Alert.Permission,
				Name = Settings.Alert.Name,
				Code = Settings.Alert.Code,
				Color = Settings.Alert.Color
			})
		end

		if Stockades[Plate] <= 0 then
			TriggerClientEvent("Notify",source,"Atenção","Compartimento vazio.","amarelo",5000)

			return false
		end

		if not Framework.InventoryClient.CheckWeapon(source,Settings.Weapon) then
			TriggerClientEvent("Notify",source,"Atenção","<b>"..Settings.WeaponName.."</b> não encontrado.","amarelo",5000)

			return false
		end

		Active[Passport] = os.time() + Settings.Duration
		Stockades[Plate] = Stockades[Plate] - 1
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Roubando",Settings.Duration * 1000)
		Framework.Client.playAnim(source,false,{"oddjobs@shop_robbery@rob_till","loop"},true)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Framework.Client.Destroy(source)
				Active[Passport] = nil
				Player(source)["state"]["Buttons"] = false
				Framework.GenerateItem(Passport,Settings.Reward.Item,Settings.Reward.Amount,true)
			end
		end)
	end
end)
