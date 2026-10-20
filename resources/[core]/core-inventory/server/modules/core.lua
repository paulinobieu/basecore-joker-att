-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Arena = {}
Drugs = {}
Drops = {}
Carry = {}
Active = {}
Plates = {}
Trunks = {}
Objects = {}
Robberys = {}
Attention = {}
SaveObjects = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERS
-----------------------------------------------------------------------------------------------------------------------------------------
Users = {
	Blueprints = {},
	Skins = {}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUFFS
-----------------------------------------------------------------------------------------------------------------------------------------
Buffs = {
	["Dexterity"] = {},
	["Luck"] = {}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRODUCTS
-----------------------------------------------------------------------------------------------------------------------------------------
local Products = Inventory.Loot.Products
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOTS
-----------------------------------------------------------------------------------------------------------------------------------------
local Loots = Inventory.Loot.Containers
local LootPlayers = {}
local Settings = Inventory.Actions
local WeaponSettings = Inventory.Weapons
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEND
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Send(Slot,Amount)
	local source = source
	if Framework.IsInCoreGameMatch(source) then return false end
	local Slot = tostring(Slot)
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)
	local ClosestPed = Framework.Client.ClosestPed(source)
	if Passport and not Active[Passport] and ClosestPed and not Framework.Wanted(Passport) then
		local Inv = Framework.Inventory(Passport)
		if not Inv[Slot] or not Inv[Slot].item then
			return false
		end

		local Item = Inv[Slot].item
		local Meta = Framework.ItemMetaClone(Inv[Slot].meta)
		local OtherPassport = Framework.Passport(ClosestPed)

		if not Framework.MaxItens(OtherPassport,Item,Amount) then
			if Framework.CheckWeight(OtherPassport,Item,Amount) then
				Active[Passport] = os.time() + 3
				Player(source).state.Cancel = true
				Player(source).state.Buttons = true
				Player(ClosestPed).state.Cancel = true
				Player(ClosestPed).state.Buttons = true
				Framework.Client.CreateObjects(source,"mp_safehouselost@","package_dropoff","prop_paper_bag_small",16,28422,0.0,-0.05,0.05,180.0,0.0,0.0)

				CreateThread(function()
					while Active[Passport] and os.time() < Active[Passport] do
						Wait(100)
					end

					if Active[Passport] then
						Framework.Client.Destroy(source)
						Active[Passport] = nil
						Player(source).state.Cancel = false
						Player(source).state.Buttons = false
						Player(ClosestPed).state.Cancel = false
						Player(ClosestPed).state.Buttons = false

						if Framework.TakeItem(Passport,Item,Amount,true,Slot) and Framework.GiveItem(OtherPassport,Item,Amount,true,nil,Meta) then
							TriggerClientEvent("inventory:Update",source)
							TriggerClientEvent("inventory:Update",ClosestPed)
							Framework.Discord("Send","**[ENVIOU]:** "..Passport.."\n**[RECEBEU]:** "..OtherPassport.."\n**[ITEM]:** "..Amount.."x "..Item)

							local Coords = Framework.GetEntityCoords(source)
							Framework.Log("ENVIOU-ITEM",{
								message = Framework.FullName(Passport).." #"..Passport.." enviou "..Amount.."x "..Framework.ItemName(Item).." para "..Framework.FullName(OtherPassport).." #"..OtherPassport,
								playerName = Framework.FullName(Passport),
								playerId = Passport,
								Destinatario = Framework.FullName(OtherPassport),
								DestinatarioId = OtherPassport,
								Item = Framework.ItemName(Item).." ("..Item..")",
								Quantidade = Amount,
								Coords = ("%.1f, %.1f, %.1f"):format(Coords.x,Coords.y,Coords.z)
							})

							return true
						end
					end
				end)
			else
				TriggerClientEvent("inventory:Notify",source,"Aviso","Mochila Sobrecarregada.","amarelo")
			end
		else
			TriggerClientEvent("inventory:Notify",source,"Aviso","Limite atingido.","amarelo",5000)
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Use(Slot,Amount)
	local source = source
	local Slot = tostring(Slot)
	local Amount = Framework.parseInt(Amount,true)
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] then
		local Inv = Framework.Inventory(Passport)
		if not Inv[Slot] or not Inv[Slot].item then
			return
		end

		local Meta = Inv[Slot].meta
		local Full,Item = Inv[Slot].item,Inv[Slot].item

		-- Os handlers de `Use` recebem `Split` desde antes do metadado e leem
		-- dele o dono, a placa e as cargas. Reconstituir a string antiga aqui
		-- mantem os 15 que dependem disso funcionando sem reescrever cada um.
		local Split = Framework.splitString(Framework.ItemMetaLegacy(Full,Meta))


		local WaterItem = Framework.ItemWater(Item)
		local WaterEntity = Framework.Client.IsEntityInWater(source)
		local WaterCondition = WaterItem and ((WaterItem == "Out" and WaterEntity) or (WaterItem == "In" and not WaterEntity))
		if (Player(source).state.Handcuff and Item ~= "lockpick") or WaterCondition then
			return
		end

		if Framework.ItemDurability(Full) and Framework.CheckDamaged(Full,Meta) then
			TriggerClientEvent("inventory:Notify",source,"Aviso","Item danificado.","amarelo")
			return
		end

		if Framework.ItemTypeCheck(Full,"Armamento") and Framework.parseInt(Slot) <= 3 then
			if Player(source).state.Safezone or (Framework.InsideVehicle(source) and not Framework.ItemVehicle(Full)) then
				return
			end

			if Framework.ItemPolice(Full) and not Framework.HasService(Passport,WeaponSettings.PolicePermission) then
				TriggerClientEvent("inventory:Notify",source,"Atenção","Armamento de uso exclusivo policial.","vermelho")
				return
			end

			if Framework.InventoryClient.ReturnWeapon(source) then
				local Check,AmmoClip,Weapon = Framework.InventoryClient.StoreWeapon(source)

				if Check then
					WriteAmmo(Passport,Framework.ResolveBaseWeapon(Weapon),AmmoClip,Equipped[Passport])
					Equipped[Passport] = nil

					TriggerClientEvent("inventory:NotifyItem",source,{ Framework.ResolveBaseWeapon(Weapon),-1 })
				end
			else
				local Skin = nil
				local AmmoClip = Framework.parseInt(Meta and Meta.ammo)
				local Attach = AttachList(Meta)


				local SkinKey = (Framework.ItemPolice(Full) and Framework.WeaponBase(Item)) or Item

				if Users.Skins[Passport] and Users.Skins[Passport][SkinKey] then
					Skin = Users.Skins[Passport][SkinKey]
				end

				local Identity,Display
				if Framework.ItemPolice(Full) then
					Identity = Item
					Display = Framework.ResolveWeaponSkin(Passport,SkinKey)
				else
					Identity = Framework.ResolveWeaponSkin(Passport,Item)
				end

				if Framework.InventoryClient.TakeWeapon(source,Identity,AmmoClip,Attach,false,Skin,Display) then
					Equipped[Passport] = tostring(Slot)

					TriggerClientEvent("inventory:NotifyItem",source,{ Full,1 })
				end
			end
		elseif Framework.ItemTypeCheck(Full,"Arremesso") then
			if Framework.InventoryClient.ReturnWeapon(source) then
				local Check,AmmoClip,Weapon = Framework.InventoryClient.StoreWeapon(source)

				if Check then
					WriteAmmo(Passport,Framework.ResolveBaseWeapon(Weapon),AmmoClip,Equipped[Passport])
					Equipped[Passport] = nil

					TriggerClientEvent("inventory:NotifyItem",source,{ Framework.ResolveBaseWeapon(Weapon),-1 })
				end
			else
				local AlternativeWeapon = Framework.ResolveWeaponSkin(Passport,Item)

				if Framework.InventoryClient.TakeWeapon(source,AlternativeWeapon,1,nil,Full) then
					TriggerClientEvent("inventory:NotifyItem",source,{ Full,1 })
				end
			end
		elseif Use[Item] and (Framework.ItemTypeCheck(Full,"Consumível") or Framework.ItemTypeCheck(Full,"Usável")) then
			Use[Item](source,Passport,Amount,Slot,Full,Item,Split)
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Cancel")
AddEventHandler("inventory:Cancel",function()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport then
		if Active[Passport] then
			Active[Passport] = nil
			TriggerClientEvent("Progress",source,"Cancelando",1000)
		end

		if Player(source)["state"]["Buttons"] then
			Player(source)["state"]["Buttons"] = false
		end

		if Carry[Passport] then
			if Framework.Passport(Carry[Passport]) then
				TriggerClientEvent("inventory:Carry",Carry[Passport],nil,"Detach")
				Framework.Client.Destroy(Carry[Passport])

				if Player(Carry[Passport])["state"]["Carry"] then
					Player(Carry[Passport])["state"]["Carry"] = false
				end
			end

			if Player(source)["state"]["Carry"] then
				Player(source)["state"]["Carry"] = false
			end

			Carry[Passport] = nil
		end

		if Player(source)["state"]["ItemCamera"] then
			TriggerClientEvent("inventory:Camera",source)
		end

		if Player(source).state.SecurityCam then
			TriggerClientEvent("securitycam:Destroy",source)
		end

		if Robberys[Passport] then
			TriggerEvent("inventory:RobberyActive",Robberys[Passport].Mode,Robberys[Passport].Number)
			Robberys[Passport] = nil
		end

		Framework.Client.Destroy(source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VERIFYWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.VerifyWeapon(Item,Ammo)
	local source = source
	local Passport = Framework.Passport(source)
	Item = Framework.ResolveBaseWeapon(Item)
	if Passport and not Framework.ConsultItem(Passport,Item,1) then
		Equipped[Passport] = nil

		TriggerClientEvent("inventory:RemoveWeapon",source,Item)
		TriggerClientEvent("inventory:Update",source)

		return false
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKEXISTWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckExistWeapons(Item)
	local source = source
	local Passport = Framework.Passport(source)
	Item = Framework.ResolveBaseWeapon(Item)
	if Passport and Item ~= "" and Item and not Framework.ConsultItem(Passport,Item,1) then
		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVETHROWING
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.RemoveThrowing(Item)
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and Item ~= "" and Item ~= nil then
		Framework.TakeItem(Passport,Item)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVENTWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.PreventWeapons(Item,Ammo)
	local source = source
	local Passport = Framework.Passport(source)
	Item = Framework.ResolveBaseWeapon(Item)
	if Passport then
		WriteAmmo(Passport,Item,Ammo)

		if Framework.ItemTypeCheck(Item,"Armamento") and Framework.ConsultItem(Passport,Item) then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Loot")
AddEventHandler("inventory:Loot",function(Number,Box)
	local Consult = nil
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and Loots[Box] then
		LootPlayers[Box] = LootPlayers[Box] or {}
		if not LootPlayers[Box][Number] then
			LootPlayers[Box][Number] = {}
		end

		if Loots[Box]["Item"] then
			Consult = Framework.ConsultItem(Passport,Loots[Box]["Item"])
			if not Consult then
				TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>1x "..Framework.ItemName(Loots[Box]["Item"]).."</b>.","amarelo",5000)
				return false
			end
		end

		if LootPlayers[Box][Number][Passport] then
			if os.time() <= LootPlayers[Box][Number][Passport] then
				TriggerClientEvent("Notify",source,"Atenção","Aguarde "..Framework.CompleteTimers(LootPlayers[Box][Number][Passport] - os.time())..".","amarelo",5000)
				return false
			end
		end

		if Loots[Box]["Code"] then
			local Keyboard = Framework.Keyboard.Password(source,"Senha")
			if not Keyboard or (Keyboard[1] and Keyboard[1] ~= Loots[Box]["Code"]) then
				TriggerClientEvent("Notify",source,"Acesso Restrito","Senha incorreta.","vermelho",5000)
				return false
			end
		end

		Active[Passport] = os.time() + 10
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Vasculhando",10000)
		LootPlayers[Box][Number][Passport] = os.time() + Loots[Box]["Cooldown"]
		Framework.Client.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Framework.Client.Destroy(source)
				Active[Passport] = nil
				Player(source)["state"]["Buttons"] = false

				if not Loots[Box]["Item"] or (Loots[Box]["Item"] and Consult and Framework.RemoveCharges(Passport,Loots[Box]["Item"])) then
					local Result = Framework.RandPercentage(Loots[Box]["List"])
					if not Framework.MaxItens(Passport,Result["Item"],Result["Valuation"]) and Framework.CheckWeight(Passport,Result["Item"],Result["Valuation"]) then
						Framework.GenerateItem(Passport,Result["Item"],Result["Valuation"],true)

						if Loots[Box]["Permission"] and Framework.HasService(Passport,Loots[Box]["Permission"]) then
							Framework.GenerateItem(Passport,"dollar",275,true)
						end
					else
						TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","amarelo",5000)
						Framework.InventoryDrops(Passport,source,Result["Item"],Result["Valuation"])

						if Loots[Box]["Permission"] and Framework.HasService(Passport,Loots[Box]["Permission"]) then
							Framework.InventoryDrops(Passport,source,"dollar",275)
						end
					end
				end
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:SAVEARENA
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:SaveArena",function(Passport)
	if not Arena[Passport] then
		Arena[Passport] = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:APPLYARENA
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:ApplyArena",function(Passport)
	if Arena[Passport] then
		Framework.ReloadWeapons(source)
		Arena[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES:DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("garages:Delete")
AddEventHandler("garages:Delete",function(Network,Plate)
	if Plates[Plate] then
		Plates[Plate] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CHANGEPLATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:ChangePlate")
AddEventHandler("inventory:ChangePlate",function(Entitys)
	local source = source
	local Plate = Entitys[1]
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] and not Plates[Plate] then
		if not Framework.ConsultItem(Passport,Settings.ChangePlate.Item,Settings.ChangePlate.Amount) then
			TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>"..Settings.ChangePlate.Amount.."x "..Framework.ItemName(Settings.ChangePlate.Item).."</b>.","amarelo",5000)

			return false
		end

		Active[Passport] = os.time() + Settings.ChangePlate.Duration
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Trocando",Settings.ChangePlate.Duration * 1000)
		Framework.Client.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Framework.Client.Destroy(source)
				Active[Passport] = nil
				Player(source)["state"]["Buttons"] = false

				if Framework.TakeItem(Passport,Settings.ChangePlate.Item,Settings.ChangePlate.Amount,true) then
					local Networked = NetworkGetEntityFromNetworkId(Entitys[4])
					if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 2 then
						local NewPlate = Framework.GeneratePlate()
						SetVehicleNumberPlateText(Networked,NewPlate)
						Plates[NewPlate] = true

						TriggerEvent("garages:ChangePlate",Plate,NewPlate)

						if not Framework.PassportPlate(NewPlate) then
							Entity(Networked)["state"]:set("Lockpick",Passport,true)
						else
							Entity(Networked)["state"]:set("Lockpick",true,true)
						end
					end
				end
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STEALTRUNK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:StealTrunk")
AddEventHandler("inventory:StealTrunk",function(Entity)
	if not Inventory.General.Features.Trunks then return end
	local source = source
	local Weapon = Settings.StealTrunk.Weapon
	local Passport = Framework.Passport(source)
	local Plate,Model = Entity[1],Entity[2]

	if not Passport or Active[Passport] then
		return false
	end

	if not Framework.InventoryClient.CheckWeapon(source,Weapon) then
		TriggerClientEvent("Notify",source,"Aviso","<b>"..Framework.ItemName(Weapon).."</b> não encontrado.","amarelo",5000)

		return false
	end

	if Framework.PassportPlate(Plate) then
		TriggerClientEvent("Notify",source,"Aviso","Veículo protegido pela seguradora.","amarelo",1000)

		return false
	end

	if Trunks[Plate] and os.time() < Trunks[Plate] then
		TriggerClientEvent("chest:Open",source,"StealTrunk:"..Plate,"Custom",false,true)

		return false
	end

	Framework.Client.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

	if not Framework.Task(source,Settings.StealTrunk.Task.Amount,Settings.StealTrunk.Task.Time) then
		Framework.Client.Destroy(source)

		return false
	end

	Active[Passport] = os.time() + Settings.StealTrunk.Duration
	Player(source).state.Buttons = true
	TriggerClientEvent("Progress",source,"Vasculhando",Settings.StealTrunk.Duration * 1000)
	TriggerClientEvent("player:Residual",source,Settings.StealTrunk.Residual)

	Framework.CallPolice({
		Source = source,
		Passport = Passport,
		Permission = Settings.StealTrunk.Police.Permission,
		Name = Settings.StealTrunk.Police.Name,
		Vehicle = Framework.VehicleName(Model).." - "..Plate,
		Percentage = Settings.StealTrunk.Police.Percentage,
		Wanted = Settings.StealTrunk.Police.Wanted,
		Color = Settings.StealTrunk.Police.Color,
		Code = Settings.StealTrunk.Police.Code
	})

	CreateThread(function()
		while Active[Passport] and os.time() < Active[Passport] do
			Wait(100)
		end

		if Active[Passport] then
			Framework.Client.Destroy(source)
			Active[Passport] = nil
			Player(source).state.Buttons = false

			if not Trunks[Plate] or os.time() >= Trunks[Plate] then
				Trunks[Plate] = os.time() + Settings.StealTrunk.Cooldown

				if Framework.MountContainer(Passport,"StealTrunk:"..Plate,Framework.IlegalItens,math.random(Settings.StealTrunk.Multiplier),false,false,Settings.StealTrunk.Money) then
					TriggerClientEvent("chest:Open",source,"StealTrunk:"..Plate,"Custom",false,true)

					local Coords = Framework.GetEntityCoords(source)
					Framework.Log("ROUBOU-PORTAMALAS",{
						message = Framework.FullName(Passport).." #"..Passport.." roubou o porta-malas do veículo "..Framework.VehicleName(Model).." ("..Plate..")",
						playerName = Framework.FullName(Passport),
						playerId = Passport,
						Veiculo = Framework.VehicleName(Model),
						Placa = Plate,
						Coords = ("%.1f, %.1f, %.1f"):format(Coords.x,Coords.y,Coords.z)
					})
				end
			end
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMALS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Animals")
AddEventHandler("inventory:Animals",function(Entity)
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] and Entity[5] then
		local MyEntity,Mode = Framework.InventoryClient.Animals(source)

		if MyEntity == Entity[1] then
			if Framework.InventoryClient.CheckWeapon(source,Settings.Hunting.Weapon) then
				if Framework.CheckWeight(Passport,Settings.Hunting.WeightItem) then
					Active[Passport] = os.time() + Settings.Hunting.Duration
					Player(source)["state"]["Buttons"] = true
					TriggerClientEvent("Progress",source,"Esfolando",Settings.Hunting.Duration * 1000)
					Framework.Client.playAnim(source,false,{"amb@medic@standing@kneel@base","base"},true)
					Framework.Client.playAnim(source,true,{"anim@gangops@facility@servers@bodysearch@","player_search"},true)

					CreateThread(function()
						while Active[Passport] and os.time() < Active[Passport] do
							Wait(100)
						end

						if Active[Passport] then
							Framework.Client.Destroy(source)
							Active[Passport] = nil
							Player(source)["state"]["Buttons"] = false

							local Star = math.random(Settings.Hunting.Stars)

							Framework.UpgradeStress(Passport,Star)
							TriggerEvent("DeletePed",Entity[3])
							Framework.PutExperience(Passport,Settings.Hunting.Experience,Settings.Hunting.ExperienceAmount)
							Framework.GenerateItem(Passport,Settings.Hunting.MeatItem,Star,true)
							Framework.GenerateItem(Passport,Mode..Star.."star",1,true)
						end
					end)
				else
					TriggerClientEvent("Notify",source,"Aviso","Mochila Sobrecarregada.","amarelo",5000)
				end
			else
				TriggerClientEvent("Notify",source,"Atenção","Você precisa do <b>"..Framework.ItemName(Settings.Hunting.Weapon).."</b> em mãos.","amarelo",5000)
			end
		else
			TriggerClientEvent("Notify",source,"Atenção","Carcaça animal não é sua.","amarelo",5000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAKEPRODUCTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Products")
AddEventHandler("inventory:Products",function(Service)
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] and Products[Service] then
		if Products[Service]["Item"] and not Framework.ConsultItem(Passport,Products[Service]["Item"]) then
			TriggerClientEvent("Notify",source,"Atenção","Precisa de <b>1x "..Framework.ItemName(Products[Service]["Item"]).."</b>.","amarelo",5000)

			return false
		end

		if Products[Service]["Police"] and not Framework.Task(source,Settings.ProductsPolice.Task.Amount,Settings.ProductsPolice.Task.Time) then
			Framework.CallPolice({
				Source = source,
				Passport = Passport,
				Permission = Settings.ProductsPolice.Permission,
				Name = Settings.ProductsPolice.Name,
				Wanted = Settings.ProductsPolice.Wanted,
				Code = Settings.ProductsPolice.Code,
				Color = Settings.ProductsPolice.Color
			})
		end

		TriggerClientEvent("Progress",source,"Produzindo",Products[Service]["Timer"] * 1000)
		Active[Passport] = os.time() + Products[Service]["Timer"]
		Player(source)["state"]["Buttons"] = true

		if Products[Service]["Animation"] then
			Framework.Client.playAnim(source,false,{Products[Service]["Animation"]["Dict"],Products[Service]["Animation"]["Anim"]},true)
		end

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Player(source)["state"]["Buttons"] = false
				Active[Passport] = nil

				if Products[Service]["Animation"] then
					Framework.Client.Destroy(source)
				end

				if not Products[Service]["Item"] or (Products[Service]["Item"] and Framework.TakeItem(Passport,Products[Service]["Item"])) then
					local Result = Framework.RandPercentage(Products[Service]["Itens"])
					if not Framework.MaxItens(Passport,Result["Item"],Result["Valuation"]) and Framework.CheckWeight(Passport,Result["Item"],Result["Valuation"]) then
						Framework.GenerateItem(Passport,Result["Item"],Result["Valuation"],true)
					else
						TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","amarelo",5000)
						Framework.InventoryDrops(Passport,source,Result["Item"],Result["Valuation"])
					end

					if Products[Service]["Residual"] then
						TriggerClientEvent("player:Residual",source,Products[Service]["Residual"])
					end
				end
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVETYRES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:RemoveTyres")
AddEventHandler("inventory:RemoveTyres",function(Entity)
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] and Entity[2] ~= "veto" and Entity[2] ~= "veto2" and Framework.VehicleMode(Entity[2]) ~= "Work" then
		if not Framework.InventoryClient.CheckWeapon(source,Settings.Tyres.Weapon) then
			TriggerClientEvent("Notify",source,"Aviso","<b>"..Framework.ItemName(Settings.Tyres.Weapon).."</b> não encontrada.","amarelo",5000)

			return false
		end

		local Networked = NetworkGetEntityFromNetworkId(Entity[4])
		if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 2 then
			if Framework.InventoryClient.tyreHealth(source,Entity[4],Entity[6]) == 1000.0 then
				if Framework.MaxItens(Passport,Settings.Tyres.Item,1) then
					TriggerClientEvent("Notify",source,"Atenção","Limite atingido.","vermelho",5000)

					return false
				end

				if Framework.PassportPlate(Entity[1]) then
					Player(source)["state"]["Buttons"] = true
					Framework.Client.playAnim(source,false,{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"},true)

					if Framework.Task(source,Settings.Tyres.Task.Amount,Settings.Tyres.Task.Time) then
						Active[Passport] = os.time() + Settings.Tyres.Duration
						TriggerClientEvent("Progress",source,"Removendo",Settings.Tyres.Duration * 1000)

						CreateThread(function()
							while Active[Passport] and os.time() < Active[Passport] do
								Wait(100)
							end

							if Active[Passport] then
								Active[Passport] = nil

								local Networked = NetworkGetEntityFromNetworkId(Entity[4])
								if DoesEntityExist(Networked) and not IsPedAPlayer(Networked) and GetEntityType(Networked) == 2 then
									if Framework.InventoryClient.tyreHealth(source,Entity[4],Entity[6]) == 1000.0 then
										local Players = Framework.Client.Players(source)
										for _,v in pairs(Players) do
											Framework.async(function()
												TriggerClientEvent("inventory:explodeTyres",v,Entity[4],Entity[1],Entity[6])
											end)
										end

										Framework.GenerateItem(Passport,Settings.Tyres.Item,1,true)
									end
								end
							end
						end)
					end

					Player(source)["state"]["Buttons"] = false
					Framework.Client.Destroy(source)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMDATA:SAVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("itemdata:Save")
AddEventHandler("itemdata:Save",function(Item,Text)
	Framework.SetSrvData(Item,Text,true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER:ROLLVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("player:RollVehicle")
AddEventHandler("player:RollVehicle",function(Entity)
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] then
		Framework.Client.AnimActive(source)
		Active[Passport] = os.time() + Settings.RollVehicle.Duration
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Desvirando",Settings.RollVehicle.Duration * 1000)
		Framework.Client.playAnim(source,false,{"mini@repair","fixing_a_player"},true)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Framework.Client.Destroy(source)
				Active[Passport] = nil
				Player(source)["state"]["Buttons"] = false

				local Players = Framework.Client.Players(source)
				for _,v in pairs(Players) do
					Framework.async(function()
						TriggerClientEvent("target:RollVehicle",v,Entity[4])
					end)
				end
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:BUFFSERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:BuffServer",function(source,Passport,Name,Amount)
	if not Buffs[Name][Passport] then
		Buffs[Name][Passport] = 0
	end

	if os.time() >= Buffs[Name][Passport] then
		Buffs[Name][Passport] = os.time() + Amount
	else
		Buffs[Name][Passport] = Buffs[Name][Passport] + Amount

		if (Buffs[Name][Passport] - os.time()) >= Settings.Buffs.MaximumDuration then
			Buffs[Name][Passport] = os.time() + Settings.Buffs.MaximumDuration
		end
	end

	TriggerClientEvent("hud:"..Name,source,Buffs[Name][Passport] - os.time())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUFFS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Buffs",function(Mode,Passport)
	return Buffs[Mode] and Buffs[Mode][Passport] and Buffs[Mode][Passport] > os.time() and (Mode ~= "Luck" or (Mode == "Luck" and math.random(100) > (100 - Settings.Buffs.LuckChance))) and true or false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("CleanWeapons",function(Passport)
	Equipped[Passport] = nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STEALPEDS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.StealPeds()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport then
		local Result = Framework.RandPercentage(Framework.IlegalItens)
		if not Framework.MaxItens(Passport,Result["Item"],Result["Valuation"]) and Framework.CheckWeight(Passport,Result["Item"],Result["Valuation"]) then
			Framework.GenerateItem(Passport,Result["Item"],Result["Valuation"],true)
		else
			TriggerClientEvent("Notify",source,"Mochila Sobrecarregada","Sua recompensa caiu no chão.","amarelo",5000)
			Framework.InventoryDrops(Passport,source,Result["Item"],Result["Valuation"])
		end

		if math.random(100) <= Settings.StealPeds.PoliceChance and Framework.DoesEntityExist(source) then
			Framework.CallPolice({
				Source = source,
				Passport = Passport,
				Permission = Settings.StealPeds.Police.Permission,
				Name = Settings.StealPeds.Police.Name,
				Wanted = Settings.StealPeds.Police.Wanted,
				Code = Settings.StealPeds.Police.Code,
				Color = Settings.StealPeds.Police.Color
			})
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOTSFIRED
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ShotsFired(Vehicle)
	local source = source
	if Framework.IsInCoreGameMatch(source) then return false end
	local Passport = Framework.Passport(source)
	if Passport then
		if Vehicle then
			Vehicle = Settings.Shots.VehicleName
		else
			Vehicle = Settings.Shots.WeaponName
		end

		if Framework.DoesEntityExist(source) then
			Framework.CallPolice({
				Source = source,
				Passport = Passport,
				Permission = Settings.Shots.Permission,
				Name = Vehicle,
				Code = Settings.Shots.Code,
				Color = Settings.Shots.Color
			})
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:DRINK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Drink")
AddEventHandler("inventory:Drink",function()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] then
		Active[Passport] = os.time() + Settings.Drink.Duration
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Bebendo",Settings.Drink.Duration * 1000)
		Framework.Client.CreateObjects(source,"amb@world_human_drinking@coffee@male@idle_a","idle_c","prop_plastic_cup_02",49,28422)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Active[Passport] = nil
				Framework.Client.Destroy(source,"one")
				Framework.UpgradeThirst(Passport,Settings.Drink.Thirst)
				Player(source)["state"]["Buttons"] = false
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REFILLGALLON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:RefillGallon")
AddEventHandler("inventory:RefillGallon",function()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] then
		if not Framework.ConsultItem(Passport,Settings.RefillGallon.Input) then
			TriggerClientEvent("Notify",source,"Atenção","Você precisa de <b>1x "..Framework.ItemName(Settings.RefillGallon.Input).."</b>.","amarelo",5000)
			return
		end

		Active[Passport] = os.time() + Settings.RefillGallon.Duration
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Enchendo",Settings.RefillGallon.Duration * 1000)
		Framework.Client.playAnim(source,false,{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"},true)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Framework.Client.Destroy(source)
				Active[Passport] = nil
				Player(source)["state"]["Buttons"] = false

				if Framework.TakeItem(Passport,Settings.RefillGallon.Input) then
					Framework.GenerateItem(Passport,Settings.RefillGallon.Output,1)
				end
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REFILLBOTTLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:RefillBottle")
AddEventHandler("inventory:RefillBottle",function()
	local source = source
	local Passport = Framework.Passport(source)
	if Passport and not Active[Passport] then
		if not Framework.ConsultItem(Passport,Settings.RefillBottle.Input) then
			TriggerClientEvent("Notify",source,"Atenção","Você precisa de <b>1x "..Framework.ItemName(Settings.RefillBottle.Input).."</b>.","amarelo",5000)
			return
		end

		Active[Passport] = os.time() + Settings.RefillBottle.Duration
		Player(source)["state"]["Buttons"] = true
		TriggerClientEvent("Progress",source,"Enchendo",Settings.RefillBottle.Duration * 1000)
		Framework.Client.playAnim(source,false,{"amb@prop_human_parking_meter@female@idle_a","idle_a_female"},true)

		CreateThread(function()
			while Active[Passport] and os.time() < Active[Passport] do
				Wait(100)
			end

			if Active[Passport] then
				Framework.Client.Destroy(source)
				Active[Passport] = nil
				Player(source)["state"]["Buttons"] = false

				if Framework.TakeItem(Passport,Settings.RefillBottle.Input) then
					Framework.GenerateItem(Passport,Settings.RefillBottle.Output,1)
				end
			end
		end)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVESERVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SaveServer",function(Silenced)
	local List = Framework.Players()
	for Passport in pairs(List) do
		if Users.Skins and Users.Skins[Passport] then
			Framework.Query("playerdata/SetData",{ Passport = Passport, Name = "Skins", Information = json.encode(Users.Skins[Passport]) })
		end

		if Users.Blueprints and Users.Blueprints[Passport] then
			Framework.Query("playerdata/SetData",{ Passport = Passport, Name = "Blueprints", Information = json.encode(Users.Blueprints[Passport]) })
		end
	end

	Framework.Query("entitydata/SetData",{ Name = "SaveObjects", Information = json.encode(SaveObjects) })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	if Users.Skins and Users.Skins[Passport] then
		Framework.Query("playerdata/SetData",{ Passport = Passport, Name = "Skins", Information = json.encode(Users.Skins[Passport]) })
		Users.Skins[Passport] = nil
	end

	if Users.Blueprints and Users.Blueprints[Passport] then
		Framework.Query("playerdata/SetData",{ Passport = Passport, Name = "Blueprints", Information = json.encode(Users.Blueprints[Passport]) })
		Users.Blueprints[Passport] = nil
	end

	if Active[Passport] then
		Active[Passport] = nil
	end

	if Drugs[Passport] then
		Drugs[Passport] = nil
	end

	if Carry[Passport] then
		if Framework.Passport(Carry[Passport]) then
			TriggerClientEvent("inventory:Carry",Carry[Passport],nil,"Detach")
			Framework.Client.Destroy(Carry[Passport])

			if Player(Carry[Passport]).state.Carry then
				Player(Carry[Passport]).state.Carry = false
			end
		end

		Carry[Passport] = nil
	end

	if Robberys[Passport] then
		TriggerEvent("inventory:RobberyActive",Robberys[Passport].Mode,Robberys[Passport].Number)
		Robberys[Passport] = nil
	end

	if Attention[Passport] then
		Attention[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	if not Users.Skins[Passport] then
		Users.Skins[Passport] = Framework.UserData(Passport,"Skins")
	end

	if not Users.Blueprints[Passport] then
		Users.Blueprints[Passport] = Framework.UserData(Passport,"Blueprints")
	end

	MigrateWeaponPools(Passport)

	TriggerClientEvent("objects:Table",source,Objects)
	TriggerClientEvent("inventory:Drops",source,Drops)
	TriggerClientEvent("inventory:Skins",source,Users.Skins[Passport])

	for Name,_ in pairs(Buffs) do
		if Buffs[Name] and Buffs[Name][Passport] and os.time() < Buffs[Name][Passport] then
			TriggerClientEvent("hud:"..Name,source,Buffs[Name][Passport] - os.time())
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLUEPRINT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Blueprint",function(Passport,Item)
	return Users.Blueprints[Passport] and Users.Blueprints[Passport][Item]
end)
