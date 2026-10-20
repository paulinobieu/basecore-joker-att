-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Travel = {}
Boosting = {}
Dismantle = {}
local Settings = Inventory.Dismantle
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEPLATE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GeneratePlate",function()
	repeat
		Plate = Framework.GenerateString("LLDDDLLL")
	until Plate and not Dismantle[Plate] and not Boosting[Plate]

	return Plate
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:BOOSTING
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:Boosting",function(Plate,Status)
	if not Boosting[Plate] then
		Boosting[Plate] = Status
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Delete")
AddEventHandler("garages:Delete",function(Network,Plate)
	if Plate then
		if Dismantle[Plate] then
			local source = Dismantle[Plate]
			if source then
				TriggerClientEvent("dismantle:Reset",source)
			end

			Dismantle[Plate] = nil
		end

		if Boosting[Plate] then
			local source = Framework.Passport(Boosting[Plate].Source)
			if source then
				TriggerClientEvent("boosting:Reset",Boosting[Plate].Source)
			end

			Framework.RemoveBoosting(Boosting[Plate].Passport,Plate)
			Boosting[Plate] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CreateVehicle(Model,Coords)
	local source = source
	local Passport = Framework.Passport(source)
	if Passport then
		local CurrentTimer = os.time() + Settings.VehicleTimeout
		local Vehicle = CreateVehicle(Model,Coords,true,false)

		while not DoesEntityExist(Vehicle) or NetworkGetNetworkIdFromEntity(Vehicle) == 0 do
			if os.time() >= CurrentTimer then
				return false
			end
	
			Wait(100)
		end

		local Plate = Framework.InventoryPlate()

		SetVehicleNumberPlateText(Vehicle,Plate)
		SetVehicleCustomPrimaryColour(Vehicle,math.random(255),math.random(255),math.random(255))
		SetVehicleCustomSecondaryColour(Vehicle,math.random(255),math.random(255),math.random(255))

		Entity(Vehicle).state:set("Nitro",0,true)
		Entity(Vehicle).state:set("Fuel",100,true)
		Entity(Vehicle).state:set("Tower",true,true)

		Dismantle[Plate] = source

		Framework.CallPolice({
			Source = source,
			Passport = Passport,
			Permission = Settings.Police.Permission,
			Name = Settings.Police.Name,
			Vehicle = Framework.VehicleName(Model).." - "..Plate,
			Coords = Coords,
			Code = Settings.Police.Code,
			Color = Settings.Police.Color
		})

		return NetworkGetNetworkIdFromEntity(Vehicle)
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Dismantle")
AddEventHandler("inventory:Dismantle",function(Entity)
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then
		return false
	end

	local Network = Entity[4]
	local Plate,Model = Entity[1],Entity[2]
	local UserVehicle = Framework.PassportPlate(Plate)
	if Active[Passport] or not Framework.VehicleExist(Model) or (not UserVehicle and not Dismantle[Plate]) then
		return false
	end

	Active[Passport] = os.time() + Settings.Duration
	Player(source).state.Buttons = true
	TriggerClientEvent("Progress",source,"Desmanchando",Settings.Duration * 1000)
	Framework.Client.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

	CreateThread(function()
		while Active[Passport] and os.time() < Active[Passport] do
			Wait(100)
		end

		Framework.Client.Destroy(source)
		Player(source).state.Buttons = false

		if not Active[Passport] then
			return false
		end

		Active[Passport] = nil

		if (not UserVehicle and not Dismantle[Plate]) or (UserVehicle and not Framework.SpawnVehicle(Plate)) then
			return false
		end

		TriggerClientEvent("dismantle:Reset",source)
		TriggerEvent("garages:Deleted",Network,Plate)

		local GainExperience = Settings.BaseExperience
		local _,Level = Framework.GetExperience(Passport,Settings.Experience)
		local Amount = Framework.VehiclePrice(Model) * (UserVehicle and Settings.OwnedMultiplier or Settings.GeneratedMultiplier)
		local Valuation = Amount + (Amount * (Settings.LevelMultiplier * Level))

		if Framework.InventoryBuff(Settings.Buff,Passport) then
			Valuation = Valuation * Settings.BuffMultiplier
		end

		for Permission,Multiplier in pairs(Settings.Membership) do
			if Framework.HasService(Passport,Permission) then
				GainExperience = GainExperience + Settings.MembershipExperience
				Valuation = Valuation * (1 + Multiplier)
			end
		end

		local Members = 1
		if Framework.PartyExists(Passport,Settings.PartySize) then
			Members = Members + 1
		end

		if UserVehicle then
			Framework.UpdateVehicleStatus(Plate,"DISMANTLED")
		end

		Framework.PutExperience(Passport,Settings.Experience,GainExperience)
		Framework.GenerateItem(Passport,Settings.RewardItem,Valuation * Members,true)
	end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Experience()
	local source = source
	local Passport = Framework.Passport(source)

	return Passport and Framework.GetExperience(Passport,Settings.Experience) or 0
end
