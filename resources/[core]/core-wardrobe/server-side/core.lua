local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SelectedOutfits = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------
local function Notify(source, Color, Message, Duration)
	TriggerClientEvent("Notify", source, "Armário", Message, Color, Duration or 3000)
end

local function SanitizeName(name)
	name = tostring(name or "")
	name = name:gsub("[^%w%sáàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ%-%_%(%)%[%]]", "")
	name = name:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	return name
end

local function SanitizeCode(code)
	code = tostring(code or ""):upper():gsub("%s+", "")
	return code:gsub("[^%w]", "")
end

local function GetPlayerGender(source)
	local Ped = GetPlayerPed(source)
	local Model = GetEntityModel(Ped)
	if Model == GetHashKey("mp_m_freemode_01") then
		return "male"
	elseif Model == GetHashKey("mp_f_freemode_01") then
		return "female"
	end
	return "male"
end

local function GetVipExtraSlots(Passport)
	local Extra = 0
	if Config.Cargos then
		for _,CargoData in pairs(Config.Cargos) do
			if CargoData.grupo and CargoData.quantidade_de_roupas and vRP.HasGroup(Passport, CargoData.grupo) then
				if CargoData.quantidade_de_roupas > Extra then
					Extra = CargoData.quantidade_de_roupas
				end
			end
		end
	end
	return Extra
end

local function GetPurchasedSlots(Passport)
	local Result = vRP.Query("coreWardrobe/getSlots", { Passport = Passport })
	if Result and Result[1] and Result[1].extra_slots then
		return tonumber(Result[1].extra_slots) or 0
	end
	return 0
end

local function GetUnlockedSlots(Passport)
	local Unlocked = Config.DefaultSlots + GetVipExtraSlots(Passport) + GetPurchasedSlots(Passport)
	return math.min(Config.MaxSlots, Unlocked)
end

local function ParsePiece(value)
	if type(value) == "table" then
		return {
			item = tonumber(value.item) or tonumber(value.drawable) or tonumber(value[1]) or 0,
			texture = tonumber(value.texture) or tonumber(value[2]) or 0,
		}
	elseif type(value) == "string" then
		local item, texture = string.match(value, "(-?%d+)%s+(-?%d+)")
		return { item = tonumber(item) or 0, texture = tonumber(texture) or 0 }
	end
	return { item = 0, texture = 0 }
end

local function NormalizeClothingData(clothingData)
	clothingData = clothingData or {}
	return {
		pants     = ParsePiece(clothingData.pants or clothingData.calca),
		arms      = ParsePiece(clothingData.arms or clothingData.maos),
		tshirt    = ParsePiece(clothingData.tshirt or clothingData.blusa),
		torso     = ParsePiece(clothingData.torso or clothingData.jaqueta),
		vest      = ParsePiece(clothingData.vest or clothingData.colete),
		shoes     = ParsePiece(clothingData.shoes or clothingData.sapatos),
		mask      = ParsePiece(clothingData.mask or clothingData.mascara),
		accessory = ParsePiece(clothingData.accessory or clothingData.acessorios),
		decals    = ParsePiece(clothingData.decals),
		backpack  = ParsePiece(clothingData.backpack or clothingData.bag or clothingData.mochila),
		hat       = ParsePiece(clothingData.hat or clothingData.chapeu or { item = -1, texture = 0 }),
		glass     = ParsePiece(clothingData.glass or clothingData.oculos or { item = -1, texture = 0 }),
		ear       = ParsePiece(clothingData.ear or { item = -1, texture = 0 }),
		watch     = ParsePiece(clothingData.watch or { item = -1, texture = 0 }),
		bracelet  = ParsePiece(clothingData.bracelet or { item = -1, texture = 0 }),
	}
end

local function GetUserOutfits(Passport)
	local Outfits = vRP.Query("coreWardrobe/getOutfitsByUser", { Passport = Passport }) or {}
	for _,Outfit in ipairs(Outfits) do
		if type(Outfit.clothing_data) == "string" then
			Outfit.clothing_data = json.decode(Outfit.clothing_data) or {}
		end
	end
	return Outfits
end

local function FindUserOutfit(Passport, OutfitId)
	local Result = vRP.Query("coreWardrobe/getOutfitById", {
		id = tonumber(OutfitId),
		Passport = Passport,
	})
	if not Result or not Result[1] then
		return nil
	end
	local Outfit = Result[1]
	if type(Outfit.clothing_data) == "string" then
		Outfit.clothing_data = json.decode(Outfit.clothing_data) or {}
	end
	return Outfit
end

local function BuildWardrobePayload(Passport)
	local Outfits = GetUserOutfits(Passport)
	local PayloadOutfits = {}
	for Index,Outfit in ipairs(Outfits) do
		table.insert(PayloadOutfits, {
			id = tonumber(Outfit.id),
			name = Outfit.name or "Sem Nome",
			slotLabel = "Slot "..Index,
			shareCode = Outfit.share_code,
			clothingData = NormalizeClothingData(Outfit.clothing_data),
			gender = Outfit.gender or "male",
		})
	end
	return {
		maxSlots = Config.MaxSlots,
		unlockedSlots = GetUnlockedSlots(Passport),
		outfits = PayloadOutfits,
		themeColor = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or Config.ThemeColor or "#dc1553",
		slotPrice = Config.SlotPriceGems,
	}
end

local function BuildSuccess(Passport, Extra)
	local Response = {
		success = true,
		wardrobe = BuildWardrobePayload(Passport),
	}
	if Extra then
		for Key,Value in pairs(Extra) do
			Response[Key] = Value
		end
	end
	return Response
end

local function BuildFailure(Message)
	return { success = false, message = Message }
end

local function GenerateShareCode()
	local Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local Code = ""
	for _ = 1,10 do
		local Index = math.random(#Chars)
		Code = Code..Chars:sub(Index, Index)
	end
	return Code
end

local function GetUniqueShareCode()
	for _ = 1,30 do
		local Code = GenerateShareCode()
		local Result = vRP.Query("coreWardrobe/getOutfitByShareCode", { share_code = Code })
		if not Result or not Result[1] then
			return Code
		end
	end
	return tostring(os.time()):sub(-10)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.Prepare("coreWardrobe/createTable", [[
	CREATE TABLE IF NOT EXISTS core_wardrobe (
		id INT NOT NULL AUTO_INCREMENT,
		Passport INT NOT NULL,
		name VARCHAR(60) NOT NULL,
		clothing_data LONGTEXT,
		gender VARCHAR(10) DEFAULT 'male',
		share_code VARCHAR(10) DEFAULT NULL,
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (id),
		UNIQUE KEY unique_share_code (share_code),
		INDEX idx_passport (Passport)
	)
]])

vRP.Prepare("coreWardrobe/createSlotsTable", [[
	CREATE TABLE IF NOT EXISTS core_wardrobe_slots (
		Passport INT NOT NULL,
		extra_slots INT DEFAULT 0,
		PRIMARY KEY (Passport)
	)
]])

vRP.Prepare("coreWardrobe/getSlots", "SELECT extra_slots FROM core_wardrobe_slots WHERE Passport = @Passport")
vRP.Prepare("coreWardrobe/addSlot", "INSERT INTO core_wardrobe_slots(Passport, extra_slots) VALUES(@Passport, 1) ON DUPLICATE KEY UPDATE extra_slots = extra_slots + 1")
vRP.Prepare("coreWardrobe/getOutfitsByUser", "SELECT * FROM core_wardrobe WHERE Passport = @Passport ORDER BY id ASC")
vRP.Prepare("coreWardrobe/getOutfitById", "SELECT * FROM core_wardrobe WHERE id = @id AND Passport = @Passport LIMIT 1")
vRP.Prepare("coreWardrobe/getOutfitByShareCode", "SELECT * FROM core_wardrobe WHERE share_code = @share_code LIMIT 1")
vRP.Prepare("coreWardrobe/insertOutfit", "INSERT INTO core_wardrobe(Passport, name, clothing_data, gender, share_code) VALUES(@Passport, @name, @clothing_data, @gender, @share_code)")
vRP.Prepare("coreWardrobe/updateOutfit", "UPDATE core_wardrobe SET clothing_data = @clothing_data, gender = @gender, updated_at = CURRENT_TIMESTAMP WHERE id = @id AND Passport = @Passport")
vRP.Prepare("coreWardrobe/updateShareCode", "UPDATE core_wardrobe SET share_code = @share_code WHERE id = @id AND Passport = @Passport")
vRP.Prepare("coreWardrobe/deleteOutfit", "DELETE FROM core_wardrobe WHERE id = @id AND Passport = @Passport")

CreateThread(function()
	vRP.Query("coreWardrobe/createTable", {})
	vRP.Query("coreWardrobe/createSlotsTable", {})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-wardrobe:requestOpen", function()
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport then return end

	local Payload = BuildWardrobePayload(Passport)
	TriggerClientEvent("core-wardrobe:openPanel", source, Payload)
end)

RegisterNetEvent("core-wardrobe:handleAction", function(action, data)
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport then return end

	if action == "selectOutfit" then
		local OutfitId = tonumber(data.id)
		local Outfit = FindUserOutfit(Passport, OutfitId)
		if not Outfit then
			TriggerClientEvent("core-wardrobe:response", source, "selectOutfit", BuildFailure("Roupa não encontrada."))
			return
		end
		SelectedOutfits[Passport] = OutfitId
		TriggerClientEvent("core-wardrobe:response", source, "selectOutfit", { success = true })
		return
	end

	if action == "wearOutfit" then
		local OutfitId = tonumber(data.id)
		local Outfit = FindUserOutfit(Passport, OutfitId)
		if not Outfit then
			Notify(source, "vermelho", "Roupa não encontrada.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "wearOutfit", BuildFailure("Roupa não encontrada."))
			return
		end

		local PlayerGender = GetPlayerGender(source)
		local OutfitGender = Outfit.gender or "male"
		if OutfitGender ~= PlayerGender then
			Notify(source, "vermelho", "Essa roupa pertence a outro gênero de personagem.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "wearOutfit", BuildFailure("Gênero incompatível."))
			return
		end

		local SkinData = NormalizeClothingData(Outfit.clothing_data)

		exports["core-customization"]:SetOutfit(Passport, SkinData, nil)

		TriggerClientEvent("core-wardrobe:response", source, "wearOutfit", { success = true })
		return
	end

	if action == "addOutfit" then
		local Name = SanitizeName(data.name)
		if Name == "" then
			Notify(source, "vermelho", "Digite um nome válido para a roupa.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "addOutfit", BuildFailure("Nome inválido."))
			return
		end

		local Outfits = GetUserOutfits(Passport)
		local UnlockedSlots = GetUnlockedSlots(Passport)
		if #Outfits >= UnlockedSlots then
			Notify(source, "vermelho", "Você não possui slots livres para salvar uma nova roupa.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "addOutfit", BuildFailure("Sem slots disponíveis."))
			return
		end

		local ClothingData = NormalizeClothingData(data.clothingData)
		local Gender = data.gender or GetPlayerGender(source)
		vRP.Update("coreWardrobe/insertOutfit", {
			Passport = Passport,
			name = Name,
			clothing_data = json.encode(ClothingData),
			gender = Gender,
			share_code = nil,
		})

		Notify(source, "sucesso", "Roupa salva com sucesso.", 3000)
		TriggerClientEvent("core-wardrobe:response", source, "addOutfit", BuildSuccess(Passport))
		return
	end

	if action == "updateOutfit" then
		local OutfitId = tonumber(data.id)
		local Outfit = FindUserOutfit(Passport, OutfitId)
		if not Outfit then
			Notify(source, "vermelho", "Roupa não encontrada.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "updateOutfit", BuildFailure("Roupa não encontrada."))
			return
		end

		local ClothingData = NormalizeClothingData(data.clothingData)
		local Gender = data.gender or GetPlayerGender(source)
		vRP.Update("coreWardrobe/updateOutfit", {
			id = OutfitId,
			Passport = Passport,
			clothing_data = json.encode(ClothingData),
			gender = Gender,
		})

		Notify(source, "sucesso", "Roupa atualizada com sucesso.", 3000)
		TriggerClientEvent("core-wardrobe:response", source, "updateOutfit", BuildSuccess(Passport))
		return
	end

	if action == "removeOutfit" then
		local OutfitId = tonumber(data.id)
		local Outfit = FindUserOutfit(Passport, OutfitId)
		if not Outfit then
			Notify(source, "vermelho", "Roupa não encontrada.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "removeOutfit", BuildFailure("Roupa não encontrada."))
			return
		end

		vRP.Update("coreWardrobe/deleteOutfit", {
			id = OutfitId,
			Passport = Passport,
		})

		if SelectedOutfits[Passport] == OutfitId then
			SelectedOutfits[Passport] = nil
		end

		Notify(source, "sucesso", "Roupa removida com sucesso.", 3000)
		TriggerClientEvent("core-wardrobe:response", source, "removeOutfit", BuildSuccess(Passport))
		return
	end

	if action == "unlockSlot" then
		local Unlocked = GetUnlockedSlots(Passport)
		if Unlocked >= Config.MaxSlots then
			Notify(source, "amarelo", "Você já desbloqueou todos os slots disponíveis.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "unlockSlot", BuildFailure("Limite máximo atingido."))
			return
		end

		if not vRP.PaymentGems(Passport, Config.SlotPriceGems) then
			Notify(source, "vermelho", "Você não possui gemas suficientes.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "unlockSlot", BuildFailure("Gemas insuficientes."))
			return
		end

		vRP.Update("coreWardrobe/addSlot", { Passport = Passport })
		Notify(source, "sucesso", "Slot desbloqueado com sucesso.", 3000)
		TriggerClientEvent("core-wardrobe:response", source, "unlockSlot", BuildSuccess(Passport))
		return
	end

	if action == "shareOutfit" then
		local OutfitId = tonumber(data.id)
		local Outfit = FindUserOutfit(Passport, OutfitId)
		if not Outfit then
			Notify(source, "vermelho", "Roupa não encontrada.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "shareOutfit", BuildFailure("Roupa não encontrada."))
			return
		end

		local ShareCode = Outfit.share_code
		if not ShareCode or ShareCode == "" then
			ShareCode = GetUniqueShareCode()
			vRP.Update("coreWardrobe/updateShareCode", {
				id = OutfitId,
				Passport = Passport,
				share_code = ShareCode,
			})
		end

		TriggerClientEvent("core-wardrobe:response", source, "shareOutfit", BuildSuccess(Passport, { shareCode = ShareCode }))
		return
	end

	if action == "confirmShare" then
		local OutfitId = tonumber(data.id)
		local Outfit = FindUserOutfit(Passport, OutfitId)
		if not Outfit then
			TriggerClientEvent("core-wardrobe:response", source, "confirmShare", BuildFailure("Roupa não encontrada."))
			return
		end

		local ShareCode = Outfit.share_code
		if not ShareCode or ShareCode == "" then
			ShareCode = GetUniqueShareCode()
			vRP.Update("coreWardrobe/updateShareCode", {
				id = OutfitId,
				Passport = Passport,
				share_code = ShareCode,
			})
		end

		Notify(source, "sucesso", "Código de compartilhamento gerado com sucesso.", 3000)
		TriggerClientEvent("core-wardrobe:response", source, "confirmShare", BuildSuccess(Passport, { shareCode = ShareCode }))
		return
	end

	if action == "importCode" then
		local Code = SanitizeCode(data.code)
		if Code == "" or #Code < 10 then
			Notify(source, "vermelho", "Código inválido.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "importCode", BuildFailure("Código inválido."))
			return
		end

		local Imported = vRP.Query("coreWardrobe/getOutfitByShareCode", { share_code = Code })
		if not Imported or not Imported[1] then
			Notify(source, "vermelho", "Nenhuma roupa foi encontrada com este código.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "importCode", BuildFailure("Código não encontrado."))
			return
		end

		local ImportedOutfit = Imported[1]
		local OutfitGender = ImportedOutfit.gender or "male"
		local PlayerGender = data.playerGender or GetPlayerGender(source)
		if OutfitGender ~= PlayerGender then
			Notify(source, "vermelho", "Essa roupa pertence a outro gênero de personagem.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "importCode", BuildFailure("Gênero incompatível."))
			return
		end

		local Outfits = GetUserOutfits(Passport)
		local UnlockedSlots = GetUnlockedSlots(Passport)
		if #Outfits >= UnlockedSlots then
			Notify(source, "vermelho", "Você não possui slots livres para importar esta roupa.", 3000)
			TriggerClientEvent("core-wardrobe:response", source, "importCode", BuildFailure("Sem slots disponíveis."))
			return
		end

		local ClothingData = ImportedOutfit.clothing_data
		if type(ClothingData) == "string" then
			ClothingData = json.decode(ClothingData) or {}
		end

		vRP.Update("coreWardrobe/insertOutfit", {
			Passport = Passport,
			name = SanitizeName(ImportedOutfit.name or "Roupa Importada"),
			clothing_data = json.encode(NormalizeClothingData(ClothingData)),
			gender = OutfitGender,
			share_code = nil,
		})

		Notify(source, "sucesso", "Roupa importada com sucesso.", 3000)
		TriggerClientEvent("core-wardrobe:response", source, "importCode", BuildSuccess(Passport))
		return
	end
end)

---------------------------------------------------------------------------------------------------------------------------------------
-- AUTH / WEBHOOK
---------------------------------------------------------------------------------------------------------------------------------------
