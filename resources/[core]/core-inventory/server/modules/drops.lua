-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEDROP
-----------------------------------------------------------------------------------------------------------------------------------------
local function RemoveDrop(Route,Number)
	local List = Drops[Route]
	if not List or not List[Number] then
		return false
	end

	TriggerClientEvent("inventory:DropsRemover",-1,Route,Number)
	List[Number] = nil

	if next(List) == nil then
		Drops[Route] = nil
	end

	return true
end
local Settings = Inventory.Drops
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEDROPREMOVAL
-----------------------------------------------------------------------------------------------------------------------------------------
local function HandleDropRemoval(Route,Number,v)
	if RemoveDrop(Route,Number) and v.key and Framework.ItemUnique(v.key) then
		local Unique = v.meta and v.meta.hash and (v.key..":"..v.meta.hash)
		if Unique then
			Framework.RemSrvData(Unique)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVESERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SaveServer",function(Silenced)
	if Silenced then
		return false
	end

	for Route,List in pairs(Drops) do
		local Clone = {}
		for Index,v in pairs(List) do
			Clone[Index] = v
		end

		for Number,v in pairs(Clone) do
			HandleDropRemoval(Route,Number,v)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADREMOVE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		Wait(Settings.CleanupInterval)

		local CurrentTimer = os.time()
		for Route,List in pairs(Drops) do
			for Number,v in pairs(List) do
				if v.created and v.created <= CurrentTimer then
					HandleDropRemoval(Route,Number,v)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEDROPS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Drops",function(Passport,source,Item,Amount,Force,Coords,Meta)
	if not Inventory.General.Features.GroundDrops then return false end
	Amount = Framework.parseInt(Amount,true)
	if Amount < 1 or not Framework.ItemExist(Item) then
		return false
	end

	local Name,Metadata = Framework.ItemMetaParse(Item)
	if Meta ~= nil then
		Metadata = Meta
	elseif not Force then
		Name,Metadata = Framework.SortMetaItem(Passport,Name)
	end

	Metadata = Metadata or {}

	-- sorteio e a gravacao precisam acontecer sem ceder a thread no meio, senao
	-- duas sacolas simultaneas disputam a mesma chave.
	local Position = Coords or Framework.GetEntityCoords(source)
	if not Position or (Position.x == 0.0 and Position.y == 0.0 and Position.z == 0.0) then
		return false
	end

	local Route = GetPlayerRoutingBucket(source) or 0
	Drops[Route] = Drops[Route] or {}

	local Selected
	for Number = 1,Settings.IdentifierAttempts do
		local Generate = Framework.GenerateString("DDDDDD")
		if not Drops[Route][Generate] then
			Selected = Generate
			break
		end
	end

	if not Selected then
		return false
	end

	local Provisory = {
		route = Route,
		id = Selected,
		amount = Amount,
		created = os.time() + Settings.Lifetime,
		coords = Position,
		key = Name,
		meta = next(Metadata) ~= nil and Metadata or nil
	}

	if Name == "vehiclekey" and Metadata.hash then
		CreateThread(function()
			local Consult = Framework.VehicleData(Metadata.hash)
			if Consult and Consult.owner and Framework.VehicleExist(Consult.index) then
				Provisory.desc = ("Proprietário: <common>%s</common><br>Modelo: <common>%s</common><br>Placa: <common>%s</common>"):format(Framework.FullName(Consult.owner),Framework.VehicleName(Consult.index),Metadata.hash)
			end
		end)
	end

	local Loaded = Framework.ItemLoads(Name)
	if Loaded and Metadata.charges then
		Provisory.charges = Framework.parseInt(Metadata.charges * (100 / Loaded))
	end

	local Durability = Framework.ItemDurability(Name)
	if Durability and Metadata.created then
		Provisory.durability = math.max(0,os.time() - Metadata.created)
		Provisory.days = Durability
	end

	Drops[Route][Selected] = Provisory

	TriggerClientEvent("inventory:DropsAdicionar",-1,Route,Selected,Provisory)

	return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Drops(Item,Slot,Amount)
	if not Inventory.General.Features.GroundDrops then return false end
	local source = source
	if Framework.IsInCoreGameMatch(source) then return false end
	Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)
	local SlotData = Passport and Framework.Inventory(Passport)[tostring(Slot)]
	if not SlotData or SlotData.amount < Amount then return false end
	Item = SlotData.item
	if not Passport or Amount < 1 or not Framework.ItemExist(Item) or Framework.ItemLocked(Item) then
		return false
	end

	if Active[Passport] or Player(source).state.Handcuff or Framework.Wanted(Passport) or Framework.InsideVehicle(source) then
		TriggerClientEvent("inventory:Update",source)
		return false
	end

	Active[Passport] = true

	local Meta = SlotData.meta
	local Success = false
	if Framework.TakeItem(Passport,Item,Amount,false,Slot) then
		Success = Framework.InventoryDrops(Passport,source,Item,Amount,true,nil,Meta)

		-- a sacola pode falhar depois do item ja ter saido do inventario: sem a
		-- devolucao o item some sem virar drop nenhum
		if not Success then
			Framework.GiveItem(Passport,Item,Amount,false,Slot,Meta)
		end
	end

	Active[Passport] = nil

	if not Success then
		TriggerClientEvent("inventory:Update",source)
	end

	return Success
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PICKUP
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Pickup(Number,Route,Target,Amount)
	if not Inventory.General.Features.GroundDrops then return false end
	local source = source
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)
	if not Passport or Amount < 1 or not Target or Active[Passport] then
		return false
	end

	local Info = Drops[Route] and Drops[Route][Number]
	if not Info or not Info.key or Info.amount < Amount then
		return false
	end

	Active[Passport] = true

	local Inv = Framework.Inventory(Passport)
	if Inv[Target] and Inv[Target].item ~= Info.key then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Slot inválido.","amarelo")
		goto finish
	end

	if Framework.MaxItens(Passport,Info.key,Amount) then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Limite atingido.","amarelo")
		goto finish
	end

	if not Framework.CheckWeight(Passport,Info.key,Amount) then
		TriggerClientEvent("inventory:Notify",source,"Aviso","Mochila cheia.","amarelo")
		goto finish
	end

	if Framework.GiveItem(Passport,Info.key,Amount,false,Target,Info.meta) then
		Info.amount = Info.amount - Amount

		if Info.amount <= 0 then
			RemoveDrop(Route,Number)
		else
			TriggerClientEvent("inventory:DropsAtualizar",-1,Route,Number,Info.amount)
		end

		Active[Passport] = nil

		return true
	end

	::finish::

	TriggerClientEvent("inventory:Update",source)
	Active[Passport] = nil

	return false
end
