-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Delay = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEFAULT
-----------------------------------------------------------------------------------------------------------------------------------------
local Default = Inventory.Objects.World
local Settings = Inventory.Objects.Settings
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADINITOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local LootToggles = {
		LootMedics = Framework.Loot and Framework.Loot.Medics,
		LootWeapons = Framework.Loot and Framework.Loot.Weapons,
		LootSupplies = Framework.Loot and Framework.Loot.Supplies,
		LootLegendary = Framework.Loot and Framework.Loot.Legendary
	}

	for _,v in pairs(Default) do
		if v.Mode and LootToggles[v.Mode] == false then
			goto continue
		end

		repeat
			Selected = Framework.GenerateString("DDLLDDLL")
		until Selected and not Objects[Selected]

		Objects[Selected] = v

		::continue::
	end

	local Consult = Framework.Query("entitydata/GetData",{ Name = "SaveObjects" })
	SaveObjects = Consult and Consult[1] and json.decode(Consult[1].Information) or {}

	for Index,v in pairs(SaveObjects) do
		if v.Item and Framework.ItemDurability(v.Item) and Framework.CheckDamaged(v.Item) then
			SaveObjects[Index] = nil
		else
			Objects[Index] = v
		end
	end

	while true do
		local CurrentTimer = os.time()
		for Permission,v in pairs(Delay) do
			local Number = v.Number

			if v.Timer <= CurrentTimer and Objects[Number] then
				TriggerClientEvent("objects:Remover",-1,Number)

				SaveObjects[Number] = nil
				Delay[Permission] = nil
				Objects[Number] = nil
			end
		end

		Wait(Settings.CleanupInterval)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("objects",function(source,Message)
	local Passport = Framework.Passport(source)
	if not Passport or not Message[1] or not Framework.HasGroup(Passport,"Admin",4) then
		return false
	end

	local Hash = Message[1]
	local Success,Coords = Framework.Client.ObjectControlling(source,Hash)

	if Success and Coords then
		local Selected
		repeat
			Selected = Framework.GenerateString("DDLLDDLL")
		until Selected and not Objects[Selected]

		local Data = {
			Coords = Coords,
			Object = Hash,
			Mode = "Store",
			Ground = true,
			Bucket = GetPlayerRoutingBucket(source)
		}

		Objects[Selected] = Data
		TriggerClientEvent("objects:Adicionar",-1,Selected,Data)

		Framework.Archive("coordenadas.txt",json.encode(Data))
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:STOREOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:StoreObjects")
AddEventHandler("inventory:StoreObjects",function(Number)
	local source = source
	local Object = Objects[Number]
	local Passport = Framework.Passport(source)

	if not Passport or not Object or Active[Passport] then
		return false
	end

	Active[Passport] = true

	local Coords = Object.Coords
	local CurrentTimer = os.time()
	local Permission = Object.Permission or false
	local IsAdmin = Framework.HasService(Passport,"Admin")

	if Object.Timer and Object.Timer >= CurrentTimer then
		TriggerClientEvent("Notify",source,"Atenção","Aguarde "..Framework.CompleteTimers(Object.Timer - CurrentTimer)..".","amarelo",5000)
		Active[Passport] = nil
		return false
	end

	if Object.Mode ~= "Sprays" then
		local Item = Object.Item
		if Item and Item ~= "spikestrips" then
			if not IsAdmin and Object.Passport and Object.Passport ~= Passport then
				Active[Passport] = nil
				return false
			end

			if not Framework.MaxItens(Passport,Item) and Framework.CheckWeight(Passport,Item) then
				Framework.GiveItem(Passport,Item,1,true)
			else
				TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","amarelo",5000)
				Framework.InventoryDrops(Passport,source,Item,1,true)
			end
		end

		TriggerClientEvent("objects:Remover",-1,Number)
		SaveObjects[Number] = nil
		Objects[Number] = nil
	else
		if not Delay[Permission] then
			Delay[Permission] = { Timer = CurrentTimer + Settings.SprayViolationDuration, Number = Number }

			for _,OtherSource in pairs(Framework.NumPermission(Permission)) do
				Framework.async(function()
					Framework.Client.PlaySound(OtherSource,"ATM_WINDOW","HUD_FRONTEND_DEFAULT_SOUNDSET")
					TriggerClientEvent("NotifyPush",OtherSource,{ code = Settings.Police.Code, title = Settings.Police.Title, x = Coords[1], y = Coords[2], z = Coords[3], color = Settings.Police.Color })
				end)
			end

			TriggerClientEvent("Notify",source,"Atenção","O grupo responsável foi avisado que o spray foi violado. Nos próximos <b>"..math.floor(Settings.SprayViolationDuration / 60).." minutos</b> se ninguém proteger o mesmo será removido.","amarelo",Settings.SprayViolationNotifyDuration)
		elseif Framework.HasService(Passport,Permission) then
			Delay[Permission] = nil
			TriggerClientEvent("Notify",source,"Atenção","Remoção cancelada.","amarelo",5000)
		end
	end

	Active[Passport] = nil
end)
