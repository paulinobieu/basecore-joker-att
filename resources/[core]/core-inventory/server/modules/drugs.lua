-----------------------------------------------------------------------------------------------------------------------------------------
-- LIST
-----------------------------------------------------------------------------------------------------------------------------------------
local List = Inventory.Drugs.Products
local Settings = Inventory.Drugs.Settings
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKDRUGS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckDrugs()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport then
		for Item,v in pairs(List) do
			local Price = math.random(v.Price.Min,v.Price.Max)
			local Amount = math.random(v.Amount.Min,v.Amount.Max)

			if Framework.ConsultItem(Passport,Item,Amount) then
				Drugs[Passport] = { Item,Amount,Price * Amount,v.Percentage }

				return v.Timer
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENTDRUGS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.PaymentDrugs()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] and Drugs[Passport] and Framework.TakeItem(Passport,Drugs[Passport][1],Drugs[Passport][2]) then
		Active[Passport] = true

		local GainExperience = Settings.BaseExperience
		local Amount = Drugs[Passport][3]
		local _,Level = Framework.GetExperience(Passport,Settings.Experience)
		local Valuation = Amount + Amount * (Settings.LevelMultiplier * Level)

		if Framework.InventoryBuff(Settings.Buff,Passport) then
			Valuation = Valuation + (Valuation * Settings.BuffMultiplier)
		end

		for Permission,Multiplier in pairs(Settings.Membership) do
			if Framework.HasService(Passport,Permission) then
				Valuation = Valuation + (Valuation * Multiplier)
				GainExperience = GainExperience + Settings.MembershipExperience
			end
		end

		local SprayPermission = Framework.Client.SprayExist(source)
		if SprayPermission and Framework.HasService(Passport,SprayPermission) then
			Valuation = Valuation + (Valuation * Settings.SprayMultiplier)
			GainExperience = GainExperience + Settings.SprayExperience
		end

		TriggerClientEvent("player:Residual",source,Settings.Residual)
		Framework.GenerateItem(Passport,Settings.RewardItem,Valuation,true)
		Framework.PutExperience(Passport,Settings.Experience,GainExperience)
		Framework.UpgradeStress(Passport,Settings.Stress)

		do
			local Coords = Framework.GetEntityCoords(source)
			Framework.Log("VENDEU-DROGA",{
				message = Framework.FullName(Passport).." #"..Passport.." vendeu "..Drugs[Passport][2].."x "..(Framework.ItemName(Drugs[Passport][1]) or Drugs[Passport][1]).." por R$ "..math.floor(Valuation).." (dinheiro sujo)",
				playerName = Framework.FullName(Passport),
				playerId = Passport,
				Item = (Framework.ItemName(Drugs[Passport][1]) or Drugs[Passport][1]).." ("..Drugs[Passport][1]..")",
				Quantidade = Drugs[Passport][2],
				Valor = math.floor(Valuation),
				NivelTraffic = Level,
				Coords = ("%.1f, %.1f, %.1f"):format(Coords.x,Coords.y,Coords.z)
			})
		end

		Framework.CallPolice({
			Source = source,
			Passport = Passport,
			Permission = Settings.Police.Permission,
			Name = Settings.Police.Name,
			Percentage = Drugs[Passport][4],
			Wanted = Settings.Police.Wanted,
			Code = Settings.Police.Code,
			Color = Settings.Police.Color
		})

		Active[Passport] = nil
		Drugs[Passport] = nil
	end
end
