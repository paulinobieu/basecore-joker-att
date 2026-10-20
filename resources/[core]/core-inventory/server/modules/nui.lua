local Crafting = Inventory.Crafting.Recipes
local Missions = Inventory.Crafting.Missions
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Mount(Bluepage)
	local source = source
	if Framework.IsInCoreGameMatch(source) then return false end
	local Passport = Framework.Passport(source)
	if not Passport then
		return false
	end

	local Primary = {}
	local Secondary = {}
	local Inventory = Framework.Inventory(Passport)

	for Slot,v in pairs(Inventory) do
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
						v.desc = ("Proprietário: <common>%s</common><br>Modelo: <common>%s</common><br>Placa: <common>%s</common>"):format(Framework.FullName(Consult.owner),Framework.VehicleName(Consult.index),Meta.hash)
					end
				elseif Item == "propertys" and Meta.hash then
					local Consult = Framework.DatabaseSingle("SELECT Passport FROM propertys WHERE Serial = ? LIMIT 1",{ Meta.hash })
					if Consult then
						v.desc = ("Proprietário: <common>%s</common>"):format(Framework.FullName(Consult.Passport))
					end
				elseif Framework.ItemNamed(Item) and Meta.owner then
					if Framework.Identity(Meta.owner) then
						if Item == "identity" then
							v.desc = ("Passaporte: <rare>%s</rare><br>Nome: <rare>%s</rare><br>Telefone: <rare>%s</rare>"):format(Framework.Dotted(Meta.owner),Framework.FullName(Meta.owner),Framework.Phone(Meta.owner))
						else
							v.desc = ("Proprietário: <common>%s</common>"):format(Framework.FullName(Meta.owner))
						end
					end
				end
			end

			local Loaded = Framework.ItemLoads(Item)
			if Loaded and Meta.charges then
				v.charges = Framework.parseInt(Meta.charges * (100 / Loaded))
			end

			local Durability = Framework.ItemDurability(Item)
			if Durability and Meta.created then
				v.durability = Framework.parseInt(os.time() - Meta.created)
				v.days = Durability
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

	if Bluepage then
		local Blueprints = Users.Blueprints[Passport]
		if not Blueprints then
			Blueprints = {}
			Users.Blueprints[Passport] = Blueprints
		end

		local Count = 0
		for Item in pairs(Blueprints) do
			local Data = Framework.ItemExist(Item)
			if Data and Data.Blueprint then
				local Entry = { key = Item, amount = 1 }

				local Craft = Crafting[Item]
				if Craft and Craft.Required then
					Entry.required = Craft.Required
				end

				Secondary[tostring(Count)] = Entry
				Count = Count + 1
			else
				Blueprints[Item] = nil
			end
		end

		return Primary,Secondary,Framework.GetWeight(Passport),Framework.InventorySlots(Passport)
	end

	return Primary,Framework.GetWeight(Passport),Framework.InventorySlots(Passport)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MISSIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Missions()
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then
		return {}
	end

	local List = {}
	local Consult = Framework.SimpleData(Passport,"Missions") or {}

	for Index,v in pairs(Missions) do
		List[Index] = {
			Xp = v.Xp,
			Code = v.Code,
			Title = v.Title,
			Description = v.Description,
			Required = v.Required,
			Rewards = v.Rewards,
			Active = Consult[v.Code] == true
		}
	end

	return {
		Experience = Framework.GetExperience(Passport,"Missions"),
		Levels = Framework.TableLevel(),
		List = List
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESCUEMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.RescueMission(Index)
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then
		return false
	end

	local Mission = Missions[Index]
	if not Mission then
		return false
	end

	local Code = Mission.Code
	if not Code then
		return false
	end

	local Consult = Framework.SimpleData(Passport,"Missions") or {}
	if Consult and Consult[Code] then
		return false
	end

	local Consume = {}
	for Item,Amount in pairs(Mission.Required) do
		local ConsultItem = Framework.ConsultItem(Passport,Item,Amount)
		if not ConsultItem then
			TriggerClientEvent("inventory:Notify",source,"Atenção","Precisa de <default>"..Framework.Dotted(Amount).."x "..Framework.ItemName(Item).."</default>.","vermelho")
			return false
		end

		Consume[#Consume + 1] = {
			Item = ConsultItem.Item,
			Amount = Amount
		}
	end

	for Number = 1,#Consume do
		local v = Consume[Number]
		Framework.RemoveItem(Passport,v.Item,v.Amount)
	end

	for Item,Amount in pairs(Mission.Rewards) do
		Framework.GenerateItem(Passport,Item,Amount)
	end

	if Mission.Xp and Mission.Xp > 0 then
		Framework.PutExperience(Passport,"Missions",Mission.Xp)
	end

	Consult[Code] = true

	Framework.Query("playerdata/SetData",{
		Passport = Passport,
		Name = "Missions",
		Information = json.encode(Consult)
	})

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFTING
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Crafting(Item,Amount,Target)
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport or not Item or not Crafting[Item] then
		return false
	end

	Target = tostring(Target)
	Amount = Framework.parseInt(Amount,true)
	if Amount <= 0 then
		return false
	end

	if Amount > 1 and (Framework.ItemUnique(Item) or Framework.ItemLoads(Item)) then
		Amount = 1
	end

	local Craft = Crafting[Item]
	local Multiplier = Craft.Amount * Amount
	if Framework.MaxItens(Passport,Item,Multiplier) then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Limite atingido.","amarelo",5000)
		return false
	end

	if not Framework.CheckWeight(Passport,Item,Multiplier) then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Mochila Sobrecarregada.","amarelo")
		return false
	end

	local Inventory = Framework.Inventory(Passport)
	if Inventory[Target] and Inventory[Target].item ~= Item then
		return false
	end

	local ItemList = {}
	for Index,Value in pairs(Craft.Required) do
		local RequiredAmount = Value * Amount
		local ConsultItem = Framework.ConsultItem(Passport,Index,RequiredAmount)
		if not ConsultItem then
			TriggerClientEvent("inventory:Notify",source,"Atenção","Precisa de <default>"..Framework.Dotted(RequiredAmount).."x "..Framework.ItemName(Index).."</default>.","vermelho")
			return false
		end

		ItemList[ConsultItem.Item] = RequiredAmount
	end

	for Index,Value in pairs(ItemList) do
		Framework.RemoveItem(Passport,Index,Value)
	end

	Framework.GenerateItem(Passport,Item,Multiplier,false,Target)
	TriggerClientEvent("inventory:Blueprint",source)

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.SpawnItem(OtherPassport,Item,Amount,Mode,Distance)
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport or not Item or not Amount or Amount <= 0 then
		return false
	end

	if not Framework.ItemExist(Item) or not Framework.HasGroup(Passport,"Admin") then
		return false
	end

	local function GiveItem(TargetPassport)
		if TargetPassport then
			Framework.GenerateItem(TargetPassport,Item,Amount,true)

			if Passport == TargetPassport then
				TriggerClientEvent("inventory:Update",source)
			end
		end
	end

	if Mode == "player" then
		if not OtherPassport then
			return false
		end

		if Framework.Source(OtherPassport) then
			GiveItem(OtherPassport)
			TriggerClientEvent("inventory:Notify",source,"Sucesso","Entregue ao destinatário.","verde",5000)
		else
			local Selected
			local Consult = Framework.GetSrvData("Offline:"..OtherPassport,true)

			repeat
				Selected = Framework.GenerateString("DDLLDDLL")
			until Selected and not Consult[Selected]

			Consult[Selected] = { Item = Item, Amount = Amount }
			Framework.SetSrvData("Offline:"..OtherPassport,Consult,true)
			TriggerClientEvent("inventory:Notify",source,"Sucesso","Adicionado à lista de entregas.","verde",5000)
		end

		Framework.Discord("Item","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport.."\n**[ITEM]:** "..Item.."\n**[QUANTIDADE]:** "..Amount.."\n**[MODO]:** "..Mode)
	elseif Mode == "area" then
		Distance = Distance or 10

		local Coords = Framework.GetEntityCoords(source)
		for _,OtherSource in ipairs(GetPlayers()) do
			Framework.async(function()
				local TargetPassport = Framework.Passport(OtherSource)
				local OtherCoords = Framework.GetEntityCoords(OtherSource)
				if OtherCoords and #(Coords - OtherCoords) <= Distance then
					GiveItem(TargetPassport)
				end
			end)
		end

		TriggerClientEvent("inventory:Notify",source,"Sucesso","Entregue a todos da área.","verde",5000)
		Framework.Discord("Item","**[ADMIN]:** "..Passport.."\n**[ITEM]:** "..Item.."\n**[QUANTIDADE]:** "..Amount.."\n**[MODO]:** "..Mode.."\n**[DISTÂNCIA]:** "..Distance)
	elseif Mode == "all" then
		for TargetPassport in pairs(Framework.Players()) do
			Framework.async(function()
				GiveItem(TargetPassport)
			end)
		end

		TriggerClientEvent("inventory:Notify",source,"Sucesso","Entregue a todos do servidor.","verde",5000)
		Framework.Discord("Item","**[ADMIN]:** "..Passport.."\n**[ITEM]:** "..Item.."\n**[QUANTIDADE]:** "..Amount.."\n**[MODO]:** "..Mode)
	end

	return true
end
