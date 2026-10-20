-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp","lib/Tunnel")
Proxy  = module("vrp","lib/Proxy")
vRP   = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-codiguin",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function Notify(source,kind,message)
	if not source or source <= 0 then return end
	TriggerClientEvent("Notify",source,"Codiguin",tostring(message or ""),tostring(kind or "info"),6000)
end

local function NormalizeCode(Code)
	if not Code then return nil end
	local Clean = tostring(Code):upper():gsub("%s","")
	return (Clean ~= "") and Clean or nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORAGE
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetUsedMap(Passport)
	local Data = vRP.UserData(Passport,Codiguin.StorageKey)
	if type(Data) ~= "table" then return {} end
	return Data
end

local function SaveUsedMap(Passport,Used)
	vRP.Query("playerdata/SetData",{
		Passport    = Passport,
		Name        = Codiguin.StorageKey,
		Information = json.encode(Used or {}),
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REWARDS
-----------------------------------------------------------------------------------------------------------------------------------------
local function ApplyRewards(Passport,Entry)
	local Rewards = Entry.rewards or {}
	local Applied = {}

	if Rewards.money and Rewards.money > 0 then
		vRP.GenerateItem(Passport,"dollar",Rewards.money,true)
		Applied[#Applied + 1] = { kind = "money", amount = Rewards.money }
	end

	if Rewards.gems and Rewards.gems > 0 then
		vRP.UpgradeGemstone(Passport,Rewards.gems)
		Applied[#Applied + 1] = { kind = "gems", amount = Rewards.gems }
	end

	if Rewards.vehicle and Rewards.vehicle.model and (Rewards.vehicle.days or 0) > 0 then
		local Ok = false
		if exports["core-vehicles"] and exports["core-vehicles"].generateRentalVehicle then
			Ok = exports["core-vehicles"]:generateRentalVehicle(Passport,Rewards.vehicle.model,Rewards.vehicle.days) and true or false
		end
		Applied[#Applied + 1] = {
			kind  = "vehicle",
			model = Rewards.vehicle.model,
			days  = Rewards.vehicle.days,
			ok    = Ok,
		}
	end

	if type(Rewards.items) == "table" then
		for _,Entry in ipairs(Rewards.items) do
			if Entry and Entry.item and (Entry.amount or 0) > 0 then
				vRP.GenerateItem(Passport,Entry.item,Entry.amount,true)
				Applied[#Applied + 1] = { kind = "item", item = Entry.item, amount = Entry.amount }
			end
		end
	end

	return Applied
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE
-----------------------------------------------------------------------------------------------------------------------------------------
local function Redeem(source,RawCode)
	local Passport = vRP.Passport(source)
	if not Passport then return false,"Sem passport." end

	local Code = NormalizeCode(RawCode)
	if not Code then return false,"Digite um codigo." end

	local Entry = Codiguin.Codes[Code]
	if not Entry then return false,"Codigo invalido." end

	local Used = GetUsedMap(Passport)
	if Used[Code] then return false,"Voce ja resgatou este codigo." end

	Used[Code] = os.time()
	SaveUsedMap(Passport,Used)

	local Applied = ApplyRewards(Passport,Entry)

	if GetResourceState("core_logs") == "started" then
		local Rewards = ""
		for _,Reward in ipairs(Applied) do
			local Label = Reward.kind == "money" and ("R$ "..Reward.amount)
				or Reward.kind == "gems" and (Reward.amount.." diamantes")
				or Reward.kind == "vehicle" and ("veículo "..Reward.model.." ("..Reward.days.." dias)")
				or (Reward.amount.."x "..Reward.item)
			Rewards = Rewards..(Rewards ~= "" and ", " or "")..Label
		end

		exports["core_logs"]:AddLog("CODIGUIN",{
			message = vRP.FullName(Passport).." #"..Passport.." resgatou o código "..Code,
			playerName = vRP.FullName(Passport),
			playerId = Passport,
			Codigo = Code,
			Nome = Entry.label,
			Recompensas = Rewards ~= "" and Rewards or "Nenhuma"
		})
	end

	return true,"Codigo <b>"..Entry.label.."</b> resgatado!",Entry.description
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNNEL
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Redeem(RawCode)
	local source = source
	local Ok,Message,Description = Redeem(source,RawCode)

	if Ok then
		Notify(source,"verde",Message)
	else
		Notify(source,"vermelho",Message)
	end

	return { ok = Ok, message = Message, description = Description }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Codiguin.Command,function(source)
	if source <= 0 then return end
	if not vRP.Passport(source) then return end
	TriggerClientEvent("core-codiguin:Open",source)
end,false)
