-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Open = {}
local Cooldown = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHESTITENS
-----------------------------------------------------------------------------------------------------------------------------------------
local ChestItens = Inventory.Chest.Items
local Settings = Inventory.Chest.Settings
local Target = Inventory.Chest.Target

local function NearChest(source,Name)
	local Coords = Framework.GetEntityCoords(source)
	for _,Chest in ipairs(Inventory.Chest.Locations) do
		if Chest.Name == Name and #(Coords - Chest.Coords) <= ((Chest.Distance or Target.Distance) + Target.ServerTolerance) then
			return true
		end
	end

	if GetResourceState("core-admin") ~= "started" then
		return false
	end

	local Chest = Framework.DatabaseSingle("SELECT coords_x, coords_y, coords_z, distance FROM core_admin_chests WHERE name = ? LIMIT 1",{ Name })
	if Chest then
		local Distance = tonumber(Chest.distance) or Target.Distance
		return #(Coords - vec3(tonumber(Chest.coords_x),tonumber(Chest.coords_y),tonumber(Chest.coords_z))) <= (Distance + Target.ServerTolerance)
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ChestPermissions(Name,Mode,Item)
	local source = source
	local Passport = Framework.Passport(source)

	if not Inventory.General.Features.Chests or not Passport then
		return false
	end

	if (Mode == "Normal" or Mode == "Personal" or Mode == "Leader" or Mode == "Member" or Mode == "PersonalGroup") and not NearChest(source,Name) then
		return false
	end

	if Mode == "Personal" then
		-- Cargo do compartimento pessoal: prioriza a coluna Permission da DB
		-- pros baús hardcoded antigos que dependiam do nome.
		local ServiceName = Framework.SplitOne(Name)
		local Consult = Framework.SingleQuery("chests/GetChests",{ Name = Name })
		if Consult and Consult.Permission and Consult.Permission ~= "" then
			ServiceName = Consult.Permission
		end

		if Framework.HasService(Passport,ServiceName) then
			Open[Passport] = {
				Name = "Personal:"..Passport,
				Weight = Settings.Personal.Weight,
				Save = true,
				Slots = Settings.Personal.Slots
			}

			return true
		end
	elseif Mode == "Tray" then
		local isRecycle = (Name == Settings.Recycle.Name)

		Open[Passport] = {
			Slots = Settings.Tray.Slots,
			Name = Name,
			Save = true,
			Recycle = isRecycle,
			Weight = isRecycle and Settings.Recycle.Weight or Settings.Tray.Weight
		}

		return true
	elseif Mode == "Custom" or Mode == "Trash" then
		if Framework.SplitBoolean(Name,"Helicrash",":") and Cooldown[Name] and Cooldown[Name] > os.time() then
			TriggerClientEvent("Notify",source,"Atenção","Aguarde até que esfrie o compartimento.","amarelo",10000)
			Framework.Client.DowngradeHealth(source,Settings.HelicrashDamage)

			return false
		end

		Open[Passport] = {
			Name = (Mode == "Trash" and "Trash:"..Name or Name),
			Weight = Settings.Custom.Weight,
			Slots = Settings.Custom.Slots,
			Mode = "Custom"
		}

		return true
	elseif Mode == "Item" then
		local UniqueName = Framework.SplitOne(Name,":")
		if ChestItens[UniqueName] then
			Open[Passport] = {
				Name = Name,
				Save = true,
				Unique = UniqueName,
				Slots = ChestItens[UniqueName].Slots,
				Weight = ChestItens[UniqueName].Weight,
				Item = Item
			}

			return true
		end
	elseif Mode == "Leader" or Mode == "Member" or Mode == "PersonalGroup" then
		-- Baú de Organização (criado pelo painel admin, modo 4):
		-- Membro = qualquer rank do cargo.
		-- Pessoal = compartimento individual (100kg) por jogador, qualquer rank.
		-- Compartimentos separados: ChestLeader:<Name>, ChestMember:<Name> e ChestPersonal:<Name>:<Passport>.
		-- Não exige estar em serviço (HasGroup ao invés de HasService).
		-- Criados automaticamente já com 5000kg/500 slots (vale pro Líder e pro Membro).
		local Consult = Framework.SingleQuery("chests/GetChests",{ Name = Name })
		if not Consult then
			Framework.Query("chests/AddChests",{ Name = Name })
			Framework.Update("chests/SetWeight",{ Name = Name, Weight = Settings.Organization.Weight, Slots = Settings.Organization.Slots })
			Consult = Framework.SingleQuery("chests/GetChests",{ Name = Name })
		end

		local hasAccess = false
		if Consult and Consult.Permission then
			if Mode == "Leader" then
				hasAccess = Framework.HasGroup(Passport,Consult.Permission,Settings.Organization.LeaderLevel) ~= false
			else
				hasAccess = Framework.HasGroup(Passport,Consult.Permission) ~= false
			end
		end

		if hasAccess then
			if Mode == "PersonalGroup" then
				Open[Passport] = {
					Name = "ChestPersonal:"..Name..":"..Passport,
					Weight = Settings.Organization.PersonalWeight,
					Slots = Settings.Organization.PersonalSlots,
					Save = true
				}

				return true
			end

			local StorageName = (Mode == "Leader") and ("ChestLeader:"..Name) or ("ChestMember:"..Name)

			Open[Passport] = {
				Weight = Consult.Weight,
				Chest = Name,
				Slots = Consult.Slots,
				Name = StorageName,
				Permission = Consult.Permission,
				Save = true
			}

			return true
		end
	else
		local Consult = Framework.SingleQuery("chests/GetChests",{ Name = Name })
		if not Consult then
			Framework.Query("chests/AddChests",{ Name = Name })
			Consult = Framework.SingleQuery("chests/GetChests",{ Name = Name })
		end

		if Consult and Framework.HasService(Passport,Consult.Permission) then
			local IsPremium = Framework.Permissions(Consult.Permission, "Premium") > os.time()

			Open[Passport] = {
				Weight = IsPremium and Consult.Weight * Settings.PremiumWeightMultiplier or Consult.Weight,
				Chest = Name,
				Slots = Consult.Slots,
				Name = "Chest:"..Name,
				Permission = Consult.Permission,
				Save = true
			}

			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ChestMount()
	local source = source
	local Passport = Framework.Passport(source)

	if not (Passport and Open[Passport]) then
		return false
	end

	local function ProcessItem(Slot,v,Prefix,Key,Save)
		if v.amount <= 0 or not Framework.ItemExist(v.item) then
			if Prefix == "Inventory" then
				Framework.CleanSlot(Passport,Slot)
			elseif Prefix == "Chest" then
				Framework.CleanSlotChest(Key,Slot,Save)
			end

			return false
		end

		v.key = v.item

		local Item = v.item
		local Meta = v.meta or {}

		if Prefix == "Inventory" and ChestItens[Item] and ChestItens[Item].Close then
			v.block = true
		end

		if not v.desc then
			if Item == "vehiclekey" and Meta.hash then
				local Consult = Framework.DatabaseSingle("SELECT owner AS Passport, `index` AS Vehicle FROM core_characters_vehicles WHERE plate = ? LIMIT 1",{ Meta.hash })
				if Consult and Framework.VehicleExist(Consult.Vehicle) then
					v.desc = "Proprietário: <common>"..Framework.FullName(Consult.Passport).."</common><br>Modelo: <common>"..Framework.VehicleName(Consult.Vehicle).."</common><br>Placa: <common>"..Meta.hash.."</common>"
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

		return v
	end

	local Primary = {}
	local Inventory = Framework.Inventory(Passport)
	for Slot,v in pairs(Inventory) do
		local Processed = ProcessItem(Slot,v,"Inventory")
		if Processed then
			Primary[Slot] = Processed
		end
	end

	local Secondary = {}
	if Open[Passport] and Open[Passport].Name then
		local ChestData = Open[Passport].Name
		local Chest = Framework.GetSrvData(ChestData,Open[Passport].Save)
		for Slot,v in pairs(Chest) do
			local Processed = ProcessItem(Slot,v,"Chest",ChestData,Open[Passport].Save)
			if Processed then
				Secondary[Slot] = Processed
			end
		end
	end

	return Primary,Secondary,Framework.GetWeight(Passport),Open[Passport].Weight,Framework.InventorySlots(Passport),Open[Passport].Slots
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STORE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ChestStore(Item,Slot,Amount,Target,Inactived)
	local source = source
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)

	if not (Passport and Open[Passport] and not Inactived) then
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	local PlayerInventory = Framework.Inventory(Passport)
	local SlotData = PlayerInventory[tostring(Slot)]
	if not SlotData or SlotData.amount < Amount then
		TriggerClientEvent("inventory:Update",source)
		return false
	end
	Item = SlotData.item

	if Open[Passport].Recycle then
		local Recycled = Framework.ItemRecycle(Item)
		if Recycled and Framework.TakeItem(Passport,Item,Amount) then
			for Index,Number in pairs(Recycled) do
				Framework.GenerateItem(Passport,Index,Number * Amount)
			end

			TriggerClientEvent("inventory:Update",source)
		else
			TriggerClientEvent("inventory:Notify",source,"Atenção",Framework.ItemName(Item).." não pode ser reciclado.","amarelo")
			TriggerClientEvent("inventory:Update",source)
		end

		return false
	end

	if Inventory.General.Features.ChestUpgrade and Item == Settings.Upgrade.Item and Open[Passport].Chest and Framework.TakeItem(Passport,Item,Amount) then
		Framework.DatabaseUpdate("UPDATE chests SET Weight = Weight + ?, Slots = Slots + ? WHERE Name = ?",{ Settings.Upgrade.Weight * Amount, Settings.Upgrade.Slots * Amount, Open[Passport].Chest })
		TriggerClientEvent("inventory:Notify",source,"Sucesso","Armazenamento melhorado.","verde")
		Open[Passport].Weight = Open[Passport].Weight + (Settings.Upgrade.Weight * Amount)
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	local CleanedItem = Framework.SplitOne(Item)
	local Unique = Open[Passport].Unique
	if (ChestItens[CleanedItem] and ChestItens[CleanedItem].Block) or (Unique and ChestItens[Unique] and ChestItens[Unique].Itens and not ChestItens[Unique].Itens[CleanedItem]) then
		if Unique and CleanedItem == Unique then
			TriggerClientEvent("inventory:Open",source,{ Type = "Inventory", Resource = "inventory", Right = "Proximidade" },true)
		else
			TriggerClientEvent("inventory:Update",source)
		end

		return false
	end

	if Framework.StoreChest(Passport,Open[Passport].Name,Amount,Open[Passport].Weight,Slot,Target,Open[Passport].Save,ChestItens[Unique]) then
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ChestTake(Item,Slot,Amount,Target)
	local source = source
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)

	if not Passport or not Open[Passport] then
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	local Name = Open[Passport].Name
	local Saved = Open[Passport].Save
	local Chest = Framework.GetSrvData(Name,Saved)
	local SlotData = Chest[tostring(Slot)]
	if not SlotData or SlotData.amount < Amount then
		TriggerClientEvent("inventory:Update",source)
		return false
	end
	Item = SlotData.item
	if Framework.TakeChest(Passport,Name,Amount,Slot,Target,Saved) then
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	local Data = Framework.GetSrvData(Name,Saved)
	if (Open[Passport].Mode or Open[Passport].Item) and json.encode(Data) == "[]" then
		if Open[Passport].Item and Framework.TakeItem(Passport,Open[Passport].Item) then
			TriggerClientEvent("inventory:Open",source,{ Type = "Inventory", Resource = "inventory", Right = "Baú" },true)
		end

		if Framework.SplitBoolean(Name,"Helicrash",":") then
			GlobalState.Helibox = (GlobalState.Helibox or 1) - 1
		elseif Framework.SplitBoolean(Name,"Halloween",":") then
			GlobalState.Hallobox = (GlobalState.Hallobox or 1) - 1
			GlobalState[Name] = false
		end
	end

	return true
end

function Core.ChestCanUpgrade()
	local Passport = Framework.Passport(source)
	return Inventory.General.Features.ChestUpgrade and Passport and Open[Passport] and Open[Passport].Chest and true or false
end

function Core.ChestQuoteUpgrade()
	local Passport = Framework.Passport(source)
	local Data = Passport and Open[Passport]
	if not Inventory.General.Features.ChestUpgrade or not Data or not Data.Chest then return false end

	return {
		title = "Melhorar bau",
		description = "Use "..Settings.Upgrade.Amount.." "..Framework.ItemName(Settings.Upgrade.Item).." para aumentar a capacidade deste bau em "..Settings.Upgrade.Weight.." kg.",
		price = Settings.Upgrade.Amount,
		currency = "Diagrama",
		currentCapacity = Data.Weight,
		nextCapacity = Data.Weight + Settings.Upgrade.Weight,
		capacityUnit = "kg",
		confirmLabel = "Usar diagrama",
		cancelLabel = "Cancelar"
	}
end

function Core.ChestConfirmUpgrade()
	local source = source
	local Passport = Framework.Passport(source)
	local Data = Passport and Open[Passport]
	if not Inventory.General.Features.ChestUpgrade or not Data or not Data.Chest or Data.Upgrading then return false end

	Data.Upgrading = true
	local Success = false
	if Framework.TakeItem(Passport,Settings.Upgrade.Item,Settings.Upgrade.Amount) then
		Framework.DatabaseUpdate("UPDATE chests SET Weight = Weight + ?, Slots = Slots + ? WHERE Name = ?",{ Settings.Upgrade.Weight * Settings.Upgrade.Amount, Settings.Upgrade.Slots * Settings.Upgrade.Amount, Data.Chest })
		Data.Weight = Data.Weight + (Settings.Upgrade.Weight * Settings.Upgrade.Amount)
		Success = true
		TriggerClientEvent("inventory:Notify",source,"Sucesso","Armazenamento melhorado.","verde")
	else
		TriggerClientEvent("inventory:Notify",source,"Atencao","Voce precisa de 1 diagrama.","amarelo")
	end
	Data.Upgrading = nil
	return Success
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ChestUpdate(Slot,Target,Amount)
	local source = source
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)

	if not Passport or not Open[Passport] then
		return false
	end

	local Name = Open[Passport].Name
	local Saved = Open[Passport].Save
	if Framework.UpdateChest(Passport,Name,Slot,Target,Amount,Saved) then
		TriggerClientEvent("inventory:Update",source)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:COOLDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("chest:Cooldown",function(Name)
	Cooldown[Name] = os.time() + Settings.HelicrashCooldown
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST:ARMOUR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chest:Armour")
AddEventHandler("chest:Armour",function(Name)
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then return end

	-- Pega o cargo da DB; fallback pra "Policia" pros baús hardcoded antigos.
	local ServiceName = Settings.ArmourFallbackPermission
	if Name then
		local Consult = Framework.SingleQuery("chests/GetChests",{ Name = Name })
		if Consult and Consult.Permission and Consult.Permission ~= "" then
			ServiceName = Consult.Permission
		end
	end

	if Framework.HasService(Passport,ServiceName) then
		Framework.Armour(source,Settings.Armour)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Open[Passport] then
		Open[Passport] = nil
	end
end)
