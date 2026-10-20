-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Admin = {}
local Players = {}
local Sourcers = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- INV
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("inv",function(source,Message)
	if not Inventory.General.Features.Inspect then return end
	local Passport = Framework.Passport(source)
	if not Passport or not Framework.HasGroup(Passport,"Admin") then
		return false
	end

	if Admin[Passport] then
		return false
	end

	local Number = Message[1]
	if not Number then
		return false
	end

	local OtherPassport = Framework.parseInt(Number,true)
	if not OtherPassport or OtherPassport == Passport then
		return false
	end

	local OtherSource = Framework.Source(OtherPassport)
	if not OtherSource or not Framework.DoesEntityExist(OtherSource) then
		return false
	end

	if Players[OtherPassport] then
		return false
	end

	Admin[Passport] = true
	Sourcers[Passport] = OtherSource
	Players[Passport] = OtherPassport

	TriggerClientEvent("inspect:Open",source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSPECT:PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inspect:Player")
AddEventHandler("inspect:Player",function(OtherSource)
	if not Inventory.General.Features.Inspect then return end
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport or not Framework.DoesEntityExist(OtherSource) then
		return false
	end

	local OtherPassport = Framework.Passport(OtherSource)
	if not OtherPassport or Players[OtherPassport] then
		return false
	end

	local IsPolice = Framework.HasGroup(Passport,"Policia")
	local IsOtherPolice = Framework.HasService(OtherPassport,"Policia")
	local OtherHealth = Framework.GetHealth(OtherSource)

	local CanInspect = false
	if IsPolice then
		CanInspect = true
	elseif OtherHealth <= 100 then
		CanInspect = true
	else
		CanInspect = Framework.Request(OtherSource,"Revistar","Você aceita ser revistado?")
	end

	if not CanInspect or IsOtherPolice then
		return false
	end

	local Distance = #(Framework.GetEntityCoords(source) - Framework.GetEntityCoords(OtherSource))
	if Distance > 2.0 then
		return false
	end

	Sourcers[Passport] = OtherSource
	Players[Passport] = OtherPassport

	TriggerClientEvent("inventory:Close",OtherSource)
	TriggerClientEvent("inspect:Open",source)
	FreezePlayer(OtherSource,true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.InspectMount()
	if not Inventory.General.Features.Inspect then return false end
	local source = source
	local Passport = Framework.Passport(source)
	if Passport then
		local Primary = {}
		local Inv = Framework.Inventory(Passport)
		for Slot,v in pairs(Inv) do
			if v.amount <= 0 or not Framework.ItemExist(v.item) then
				Framework.CleanSlot(Passport,Slot)
			else
				v.key = v.item

				local Item = v.item
				local Meta = v.meta or {}

				if not v.desc then
					if Item == "vehiclekey" and Meta.hash then
						local Consult = Framework.VehicleData(Meta.hash)
						if Consult and Consult.owner and Framework.VehicleExist(Consult.index) then
							v.desc = "Proprietário: <common>"..Framework.FullName(Consult.owner).."</common><br>Modelo: <common>"..Framework.VehicleName(Consult.index).."</common><br>Placa: <common>"..Meta.hash.."</common>"
						end
					elseif Item == "propertys" and Meta.hash then
						local Consult = Framework.DatabaseSingle("SELECT * FROM propertys WHERE Serial = ? LIMIT 1",{ Meta.hash })
						if Consult then
							v.desc = "Proprietário: <common>"..Framework.FullName(Consult.Passport).."</common>"
						end
					elseif Framework.ItemNamed(Item) and Meta.owner and Framework.Identity(Meta.owner) then
						if Item == "identity" then
							v.desc = "Passaporte: <rare>"..Framework.Dotted(Meta.owner).."</rare><br>Nome: <rare>"..Framework.FullName(Meta.owner).."</rare><br>Telefone: <rare>"..Framework.Phone(Meta.owner).."</rare>"
						else
							v.desc = "Proprietário: <common>"..Framework.FullName(Meta.owner).."</common>"
						end
					end
				end

				local Loaded = Framework.ItemLoads(Item)
				if Loaded and Meta.charges then
					v.charges = Framework.parseInt(Meta.charges * (100 / Loaded))
				end

				if Framework.ItemDurability(Item) and Meta.created then
					v.durability = Framework.parseInt(os.time() - Meta.created)
					v.days = Framework.ItemDurability(Item)
				end

				if Meta.ammo then
					v.ammo = Meta.ammo
				end

				if Meta.attachs then
					v.attachs = Meta.attachs
				end

				Primary[Slot] = v
			end
		end

		local Secondary = {}
		local Inv = Framework.Inventory(Players[Passport])
		for Slot,v in pairs(Inv) do
			if v.amount <= 0 or not Framework.ItemExist(v.item) then
				Framework.CleanSlot(Players[Passport],Slot)
			else
				v.key = v.item

				local Item = v.item
				local Meta = v.meta or {}

				if not v.desc then
					if Item == "vehiclekey" and Meta.hash then
						local Consult = Framework.VehicleData(Meta.hash)
						if Consult and Consult.owner and Framework.VehicleExist(Consult.index) then
							v.desc = "Proprietário: <common>"..Framework.FullName(Consult.owner).."</common><br>Modelo: <common>"..Framework.VehicleName(Consult.index).."</common><br>Placa: <common>"..Meta.hash.."</common>"
						end
					elseif Item == "propertys" and Meta.hash then
						local Consult = Framework.DatabaseSingle("SELECT * FROM propertys WHERE Serial = ? LIMIT 1",{ Meta.hash })
						if Consult then
							v.desc = "Proprietário: <common>"..Framework.FullName(Consult.Passport).."</common>"
						end
					elseif Framework.ItemNamed(Item) and Meta.owner and Framework.Identity(Meta.owner) then
						if Item == "identity" then
							v.desc = "Passaporte: <rare>"..Framework.Dotted(Meta.owner).."</rare><br>Nome: <rare>"..Framework.FullName(Meta.owner).."</rare><br>Telefone: <rare>"..Framework.Phone(Meta.owner).."</rare>"
						else
							v.desc = "Proprietário: <common>"..Framework.FullName(Meta.owner).."</common>"
						end
					end
				end

				local Loaded = Framework.ItemLoads(Item)
				if Loaded and Meta.charges then
					v.charges = Framework.parseInt(Meta.charges * (100 / Loaded))
				end

				if Framework.ItemDurability(Item) and Meta.created then
					v.durability = Framework.parseInt(os.time() - Meta.created)
					v.days = Framework.ItemDurability(Item)
				end

				if Meta.ammo then
					v.ammo = Meta.ammo
				end

				if Meta.attachs then
					v.attachs = Meta.attachs
				end

				Secondary[Slot] = v
			end
		end

		return Primary,Secondary,Framework.GetWeight(Passport),Framework.GetWeight(Players[Passport]),Framework.InventorySlots(Passport),Framework.InventorySlots(Players[Passport])
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESET
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.InspectReset()
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then
		return false
	end

	local Target = Sourcers[Passport]
	if Target then
		if Framework.DoesEntityExist(Target) and not Admin[Passport] then
			FreezePlayer(Target,false)
		end

		Sourcers[Passport] = nil
	end

	Players[Passport] = nil
	Admin[Passport] = nil

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.InspectStore(Item,Slot,Amount,Target)
	if not Inventory.General.Features.Inspect then return false end
	local source = source
	local Slot = tostring(Slot)
	local Target = tostring(Target)
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)
	local SlotData = Passport and Framework.Inventory(Passport)[Slot]
	if not SlotData or SlotData.amount < Amount then return false end
	Item = SlotData.item
	if not Passport or not Sourcers[Passport] or not Framework.DoesEntityExist(Sourcers[Passport]) or Framework.ItemLocked(Item) then
		return false
	end

	if not Admin[Passport] and #(Framework.GetEntityCoords(source) - Framework.GetEntityCoords(Sourcers[Passport])) > 2.0 then return false end
	local SelectPlayer = Players[Passport]
	if not SelectPlayer or Framework.BlockDelete(Item) or Framework.MaxItens(SelectPlayer,Item,Amount) then
		TriggerClientEvent("inventory:Update",source)
		return false
	end

	if not Framework.CheckWeight(SelectPlayer,Item,Amount) then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Mochila sobrecarregada.","amarelo")
		TriggerClientEvent("inventory:Update",source)
		return false
	end

	if not Framework.GiveItem(SelectPlayer,Item,Amount,true,Target) then
		TriggerClientEvent("inventory:Update",source)
		return false
	else
		if not Framework.TakeItem(Passport,Item,Amount,true,Slot) then
			Framework.RemoveItem(SelectPlayer,Item,Amount)
			TriggerClientEvent("inventory:Update",source)
			return false
		end
	end

	if Framework.ItemType(Item) == "Armamento" then
		TriggerClientEvent("inventory:Update",source)
	end

	Framework.Discord("Inspect","**[PASSAPORTE]:** "..Passport.."\n**[REVISTADO]:** "..SelectPlayer.."\n**[MODO]:** Enviou\n**[ITEM]:** "..Item.."\n**[QUANTIDADE]:** "..Amount.."x")
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.InspectTake(Item,Slot,Target,Amount)
	if not Inventory.General.Features.Inspect then return false end
	local source = source
	local Slot = tostring(Slot)
	local Target = tostring(Target)
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)
	local SelectPlayer = Passport and Players[Passport]
	local SlotData = SelectPlayer and Framework.Inventory(SelectPlayer)[Slot]
	if not SlotData or SlotData.amount < Amount then return false end
	Item = SlotData.item
	if not Passport or not Sourcers[Passport] or not Framework.DoesEntityExist(Sourcers[Passport]) or Framework.ItemLocked(Item) then
		return false
	end

	if not Admin[Passport] and #(Framework.GetEntityCoords(source) - Framework.GetEntityCoords(Sourcers[Passport])) > 2.0 then return false end
	if not SelectPlayer or Framework.BlockDelete(Item) or Framework.MaxItens(Passport,Item,Amount) then
		TriggerClientEvent("inventory:Update",source)
		return false
	end

	if not Framework.CheckWeight(Passport,Item,Amount) then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Mochila sobrecarregada.","amarelo")
		TriggerClientEvent("inventory:Update",source)
		return false
	end

	if not Framework.GiveItem(Passport,Item,Amount,true,Target) then
		TriggerClientEvent("inventory:Update",source)
		return false
	else
		if not Framework.TakeItem(SelectPlayer,Item,Amount,true,Slot) then
			Framework.RemoveItem(Passport,Item,Amount)
			TriggerClientEvent("inventory:Update",source)
			return false
		end
	end

	if Framework.ItemType(Item) == "Armamento" then
		TriggerClientEvent("inventory:Update",source)
	end

	Framework.Discord("Inspect","**[PASSAPORTE]:** "..Passport.."\n**[REVISTADO]:** "..SelectPlayer.."\n**[MODO]:** Retirou\n**[ITEM]:** "..Item.."\n**[QUANTIDADE]:** "..Amount.."x")
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FREEZEPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function FreezePlayer(source,Toggle)
	local Ped = GetPlayerPed(source)
	if DoesEntityExist(Ped) then
		FreezeEntityPosition(Ped,Toggle)
	end
end
