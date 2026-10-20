-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("trunkchest",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Open = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
local Store = {
	ratloader = {
		woodlog = true
	},
	stockade = {
		pouch = true
	},
	trash = {
		binbag = true
	},
	flatbed = {
		plastic = true,
		glass = true,
		rubber = true,
		aluminum = true,
		tyres = true,
		copper = true,
		toolbox = true,
		advtoolbox = true
	},
	boxville2 = {
		package = true
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOCKED
-----------------------------------------------------------------------------------------------------------------------------------------
local Blocked = {
	dollar = true,
	dirtydollar = true,
	wetdollar = true,
	promissory1000 = true,
	promissory2000 = true,
	promissory3000 = true,
	promissory4000 = true,
	promissory5000 = true
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Mount()
	local Primary = {}
	local Secondary = {}
	local source = source
	local Passport = vRP.Passport(source)

	if not (Passport and Open[Passport]) then
		return Primary,Secondary
	end

	local function ProcessItem(Slot,v,Prefix,Key,Save)
		if v.amount <= 0 or not ItemExist(v.item) then
			if Prefix == "Inventory" then
				vRP.CleanSlot(Passport,Slot)
			elseif Prefix == "Chest" then
				vRP.CleanSlotChest(Key,Slot,Save)
			end

			return false
		end

		v.key = v.item

		local Item = v.item
		local Meta = v.meta or {}

		if not v.desc then
			if Item == "vehiclekey" and Meta.hash then
				local Consult = exports.oxmysql:single_async("SELECT owner AS Passport, `index` AS Vehicle FROM core_characters_vehicles WHERE plate = ? LIMIT 1",{ Meta.hash })
				if Consult and VehicleExist(Consult.Vehicle) then
					v.desc = "Proprietário: <common>"..vRP.FullName(Consult.Passport).."</common><br>Modelo: <common>"..VehicleName(Consult.Vehicle).."</common><br>Placa: <common>"..Meta.hash.."</common>"
				end
			elseif Item == "propertys" and Meta.hash then
				local Consult = exports.oxmysql:single_async("SELECT * FROM propertys WHERE Serial = ? LIMIT 1",{ Meta.hash })
				if Consult then
					v.desc = "Proprietário: <common>"..vRP.FullName(Consult.Passport).."</common>"
				end
			elseif ItemNamed(Item) and Meta.owner and vRP.Identity(Meta.owner) then
				if Item == "identity" then
					v.desc = "Passaporte: <rare>"..Dotted(Meta.owner).."</rare><br>Nome: <rare>"..vRP.FullName(Meta.owner).."</rare><br>Telefone: <rare>"..vRP.Phone(Meta.owner).."</rare>"
				else
					v.desc = "Proprietário: <common>"..vRP.FullName(Meta.owner).."</common>"
				end
			end
		end

		local Loaded = ItemLoads(Item)
		if Loaded and Meta.charges then
			v.charges = parseInt(Meta.charges * (100 / Loaded))
		end

		if ItemDurability(Item) and Meta.created then
			v.durability = parseInt(os.time() - Meta.created)
			v.days = ItemDurability(Item)
		end

		if Meta.ammo then
			v.ammo = Meta.ammo
		end

		if Meta.attachs then
			v.attachs = Meta.attachs
		end

		return v
	end

	local Inventory = vRP.Inventory(Passport)
	for Slot,v in pairs(Inventory) do
		local Processed = ProcessItem(Slot,v,"Inventory")
		if Processed then
			Primary[Slot] = Processed
		end
	end

	if Open[Passport] and Open[Passport].Data then
		local ChestData = Open[Passport].Data
		local Chest = vRP.GetSrvData(ChestData,true)
		for Slot,v in pairs(Chest) do
			local Processed = ProcessItem(Slot,v,"Chest",ChestData,true)
			if Processed then
				Secondary[Slot] = Processed
			end
		end
	end

	return Primary,Secondary,vRP.GetWeight(Passport),Open[Passport] and Open[Passport].Weight or 0,vRP.InventorySlots(Passport)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Update(Slot,Target,Amount)
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport or not Open[Passport] then
		return false
	end

	local Amount = parseInt(Amount,true)
	if vRP.UpdateChest(Passport,Open[Passport].Data,Slot,Target,Amount,true) then
		TriggerClientEvent("inventory:Update",source)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Store(Item,Slot,Amount,Target)
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport or not Open[Passport] then
		return false
	end

	local Amount = parseInt(Amount)
	if Amount <= 0 then
		return false
	end

	local Split = SplitOne(Item)
	local Data = Open[Passport].Data
	local Model = Open[Passport].Model
	local Weight  = Open[Passport].Weight

	if (Store[Model] and not Store[Model][Split]) or (Blocked[Split] and Store[Model] and not Store[Model][Split]) or (Blocked[Split] and not Store[Model]) then
		TriggerClientEvent("Notify",source,"Aviso","Armazenamento proibido.","amarelo",5000)
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	if Split == "diagram" then
		local NewWeight = Weight + (10 * Amount)
		local MaxWeight = VehicleWeight(Model) * 5

		if NewWeight <= MaxWeight and vRP.TakeItem(Passport,Item,Amount) then
			TriggerClientEvent("inventory:Notify",source,"Sucesso","Armazenamento melhorado.","verde")
			Open[Passport].Weight = NewWeight
		else
			TriggerClientEvent("inventory:Notify",source,"Atenção","Limite atingido.","vermelho")
		end

		TriggerClientEvent("inventory:Update",source)
	else
		if Data and Weight and vRP.StoreChest(Passport,Data,Amount,Weight,Slot,Target,true) then
			TriggerClientEvent("inventory:Update",source)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Take(Slot,Amount,Target)
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport or not Open[Passport] then
		return false
	end

	local Amount = parseInt(Amount,true)
	if vRP.TakeChest(Passport,Open[Passport].Data,Amount,Slot,Target,true) then
		TriggerClientEvent("inventory:Update",source)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Close()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and Open[Passport] then
		Open[Passport] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRUNKCHEST:OPENTRUNK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trunkchest:openTrunk")
AddEventHandler("trunkchest:openTrunk",function(Entity)
	local source = source
	local Plate,Model = Entity[1],Entity[2]
	if not Plate or not Model or not VehicleExist(Model) then
		return false
	end

	local Passport = vRP.Passport(source)
	if not Passport then
		return false
	end

	local Spawn = exports['core-vehicles']:Spawn(Plate)
	if not Spawn or Spawn[2] ~= Model then
		return false
	end

	local OtherPassport = Spawn[1]
	if not OtherPassport then
		return false
	end

	local OtherSource = vRP.Source(OtherPassport)
	if not OtherSource then
		return false
	end

	local Weight = VehicleWeight(Model)
	if Passport ~= OtherPassport and not vRP.Request(OtherSource,"Porta-Malas","Permitir que o mesmo seja aberto por <b>"..vRP.FullName(Passport).."</b>?") then
		return false
	end

	Open[Passport] = { Model = Model, Weight = Weight, Passport = OtherPassport, Data = ("Trunkchest:%s:%s"):format(OtherPassport,Model) }
	TriggerClientEvent("trunkchest:Open",source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	Open[Passport] = nil
end)