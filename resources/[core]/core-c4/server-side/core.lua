local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-c4", Core)
vCLIENT = Tunnel.getInterface("core-c4")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = {}
local Cooldowns = {}
local Exploded = {}
local Pickups = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKSYSTEMS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckSystems(AtmId, AtmCoords)
	local source = source
	local Passport = vRP.Passport(source)

	if not Passport or type(AtmId) ~= "string" or AtmId == "" then
		return false
	end

	if Active[Passport] then
		return false
	end

	if Config.PermittedTime then
		local Hour = tonumber(os.date("%H"))
		if Hour < Config.PermittedTime[1] or Hour >= Config.PermittedTime[2] then
			TriggerClientEvent("Notify", source, "Atenção", "Este caixa eletrônico só pode ser roubado entre "..Config.PermittedTime[1].."h e "..Config.PermittedTime[2].."h.", "amarelo", 5000)
			return false
		end
	end

	if Cooldowns[AtmId] and os.time() < Cooldowns[AtmId] then
		TriggerClientEvent("Notify", source, "Atenção", "Aguarde "..CompleteTimers(Cooldowns[AtmId] - os.time())..".", "amarelo", 5000)
		return false
	end

	local Mode = nil
	local ItemCheck = vRP.ConsultItem(Passport, Config.ItemC4, 1)
	if ItemCheck then
		Mode = "c4"
	else
		ItemCheck = vRP.ConsultItem(Passport, Config.ItemLockpick, 1)
		if ItemCheck then
			Mode = "lockpick"
		end
	end

	if not Mode then
		TriggerClientEvent("Notify", source, "Atenção", "Precisa de <b>1x C4</b> ou <b>1x Pé de Cabra</b>.", "amarelo", 5000)
		return false
	end

	if vRP.AmountService(Config.Police.Permission) < Config.Police.MinAmount then
		TriggerClientEvent("Notify", source, "Atenção", "Contingente indisponível.", "amarelo", 5000)
		return false
	end

	Active[Passport] = true

	if Mode == "c4" then
		if not vRP.TakeItem(Passport, ItemCheck.Item, 1, true) then
			Active[Passport] = nil
			return false
		end

		exports["vrp"]:CallPolice({
			Source = source,
			Passport = Passport,
			Coords = AtmCoords,
			Permission = Config.Police.Permission,
			Name = Config.Police.CallPolice.Name,
			Percentage = Config.Police.CallPolice.Percentage,
			Wanted = Config.Police.CallPolice.C4.Wanted,
			Code = Config.Police.CallPolice.Code,
			Color = Config.Police.CallPolice.Color
		})
	else
		if math.random(100) >= Config.Robbery.Lockpick.BreakChance then
			vRP.RemoveItem(Passport, ItemCheck.Item, 1, true)
		end

		exports["vrp"]:CallPolice({
			Source = source,
			Passport = Passport,
			Coords = AtmCoords,
			Permission = Config.Police.Permission,
			Name = Config.Police.CallPolice.Name,
			Percentage = Config.Police.CallPolice.Percentage,
			Wanted = Config.Police.CallPolice.Lockpick.Wanted,
			Code = Config.Police.CallPolice.Code,
			Color = Config.Police.CallPolice.Color
		})
	end

	return Mode
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEATMEXPLODED
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.UpdateAtmExploded(AtmId, AtmCoords, ModelHash)

	local source = source
	local Passport = vRP.Passport(source)

	if not Active[Passport] or type(AtmId) ~= "string" or AtmId == "" then
		return false
	end

	Active[Passport] = nil
	Exploded[AtmId] = true
	Cooldowns[AtmId] = os.time() + Config.Robbery.Cooldown

	local Valuation = math.random(Config.Robbery.Valuation.Min, Config.Robbery.Valuation.Max)

	if exports["party"]:DoesExist(Passport, 2) then
		Valuation = Valuation * Config.Robbery.Valuation.Multipliers.Party
	end

	if exports["core-inventory"]:Buffs("Dexterity", Passport) then
		Valuation = Valuation * Config.Robbery.Valuation.Multipliers.Dexterity
	end

	for Permission, Multiplier in pairs(Config.Robbery.Valuation.Multipliers.Services) do
		if vRP.HasService(Passport, Permission) then
			Valuation = Valuation * (1 + Multiplier)
		end
	end

	Pickups[AtmId] = {
		Passport = Passport,
		Source = source,
		Amount = math.floor(Valuation),
		Collected = 0,
		Total = Config.Robbery.Pickups.Total,
		Coords = AtmCoords
	}

	TriggerClientEvent("eletronics:setDrop", source, AtmId, AtmCoords, ModelHash)

	if GetResourceState("core_logs") == "started" then
		exports["core_logs"]:AddLog("ROUBO-ATM",{
			message = vRP.FullName(Passport).." #"..Passport.." explodiu o ATM "..AtmId.." com C4 (R$ "..math.floor(Valuation).." em dinheiro sujo)",
			playerName = vRP.FullName(Passport),
			playerId = Passport,
			Atm = AtmId,
			Valor = math.floor(Valuation),
			Coords = AtmCoords and ("%.1f, %.1f, %.1f"):format(AtmCoords.x,AtmCoords.y,AtmCoords.z) or nil
		})
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYPICKUP
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.TryPickup(AtmId)
	local Passport = vRP.Passport(source)
	local PickupData = Pickups[AtmId]

	if not PickupData or PickupData.Collected >= PickupData.Total then
		return false
	end

	local Amount = math.max(math.floor(PickupData.Amount / PickupData.Total), 1)

	if vRP.GiveItem(Passport, "dirtydollar", Amount, true) then
		PickupData.Collected = PickupData.Collected + 1

		if PickupData.Collected >= PickupData.Total then
			Pickups[AtmId] = nil
			Exploded[AtmId] = nil
		end

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ABORTROBBERY
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.AbortRobbery(AtmId)
	local Passport = vRP.Passport(source)

	Active[Passport] = nil
	Pickups[AtmId] = nil
	Exploded[AtmId] = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect", function(Passport)
	Active[Passport] = nil
end)
