-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Aberto = false
local SelectedOutfit = nil
local PreviewPed = nil
local PreviewThread = false
local PlayerHiddenThread = false
local NUIOpen = false
local function ResolveThemeColor()
	if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
		return Theme.main
	end
	return Config.ThemeColor or "#dc1553"
end

local WardrobeCache = {
	maxSlots = Config.MaxSlots,
	unlockedSlots = Config.DefaultSlots,
	slotPrice = Config.SlotPriceGems,
	themeColor = ResolveThemeColor(),
	outfits = {},
	outfitMap = {},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CanOpenWardrobe()
	local Ped = PlayerPedId()
	if not DoesEntityExist(Ped) then return false end
	if not Config.AllowOpenWhenDead and GetEntityHealth(Ped) <= 101 then
		TriggerEvent("Notify", "Armário", "Você não pode abrir o armário agora.", "amarelo", 3000)
		return false
	end
	return true
end

local function NormalizeValue(value)
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

local function GetPedGender(ped)
	local Model = GetEntityModel(ped)
	if Model == GetHashKey("mp_m_freemode_01") then return "male"
	elseif Model == GetHashKey("mp_f_freemode_01") then return "female" end
	return IsPedMale(ped) and "male" or "female"
end

local function GetComponentData(ped, component)
	return { item = GetPedDrawableVariation(ped, component), texture = GetPedTextureVariation(ped, component) }
end

local function GetPropData(ped, prop)
	local item = GetPedPropIndex(ped, prop)
	local texture = GetPedPropTextureIndex(ped, prop)
	return { item = item >= 0 and item or -1, texture = texture >= 0 and texture or 0 }
end

local function CollectCurrentSkinData(ped)
	return {
		pants = GetComponentData(ped, 4), arms = GetComponentData(ped, 3),
		tshirt = GetComponentData(ped, 8), torso = GetComponentData(ped, 11),
		vest = GetComponentData(ped, 9), shoes = GetComponentData(ped, 6),
		mask = GetComponentData(ped, 1), accessory = GetComponentData(ped, 7),
		decals = GetComponentData(ped, 10), bag = GetComponentData(ped, 5),
		hat = GetPropData(ped, 0), glass = GetPropData(ped, 1),
		ear = GetPropData(ped, 2), watch = GetPropData(ped, 6), bracelet = GetPropData(ped, 7),
	}
end

local function ApplyComponent(ped, component, value)
	local Data = NormalizeValue(value)
	SetPedComponentVariation(ped, component, Data.item, Data.texture, 0)
end

local function ApplyProp(ped, prop, value)
	local Data = NormalizeValue(value)
	if Data.item == nil or Data.item < 0 then
		ClearPedProp(ped, prop)
	else
		SetPedPropIndex(ped, prop, Data.item, Data.texture, true)
	end
end

local function ApplySkinDataToPed(skinData, ped)
	if not skinData or not ped or not DoesEntityExist(ped) then return end
	ApplyComponent(ped, 4, skinData.pants)
	ApplyComponent(ped, 3, skinData.arms)
	ApplyComponent(ped, 8, skinData.tshirt)
	ApplyComponent(ped, 11, skinData.torso)
	ApplyComponent(ped, 9, skinData.vest)
	ApplyComponent(ped, 6, skinData.shoes)
	ApplyComponent(ped, 1, skinData.mask)
	ApplyComponent(ped, 7, skinData.accessory)
	ApplyComponent(ped, 10, skinData.decals)
	ApplyComponent(ped, 5, skinData.bag)
	ApplyProp(ped, 0, skinData.hat)
	ApplyProp(ped, 1, skinData.glass)
	ApplyProp(ped, 2, skinData.ear)
	ApplyProp(ped, 6, skinData.watch)
	ApplyProp(ped, 7, skinData.bracelet)
end

local function RebuildOutfitMap(outfits)
	local Map = {}
	for _,Outfit in ipairs(outfits or {}) do
		Map[tonumber(Outfit.id)] = Outfit
	end
	return Map
end

local function SetWardrobeCache(payload)
	if not payload then return end
	WardrobeCache.maxSlots = payload.maxSlots or WardrobeCache.maxSlots
	WardrobeCache.unlockedSlots = payload.unlockedSlots or WardrobeCache.unlockedSlots
	WardrobeCache.slotPrice = payload.slotPrice or WardrobeCache.slotPrice
	WardrobeCache.themeColor = payload.themeColor or WardrobeCache.themeColor
	WardrobeCache.outfits = payload.outfits or WardrobeCache.outfits
	WardrobeCache.outfitMap = RebuildOutfitMap(WardrobeCache.outfits)
end

local function SendWardrobeUpdate(payload)
	if not payload then return end
	SetWardrobeCache(payload)
	SendNUIMessage({
		action = "updateWardrobe",
		data = {
			maxSlots = WardrobeCache.maxSlots,
			unlockedSlots = WardrobeCache.unlockedSlots,
			outfits = WardrobeCache.outfits,
			themeColor = WardrobeCache.themeColor,
			slotPrice = WardrobeCache.slotPrice,
		},
	})
end

local function SendInterfaceMessage(action, data)
	SendNUIMessage({ action = action, data = data })
end

local function SetUiVisibility(status)
	NUIOpen = status
	SetNuiFocus(status, status)
	SendNUIMessage({ action = "setVisible", data = status })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEW
-----------------------------------------------------------------------------------------------------------------------------------------
local PositionBuffer = {}
local BufferSize = 5

local function EnsurePlayerHiddenThread()
	if PlayerHiddenThread then return end
	PlayerHiddenThread = true
	CreateThread(function()
		while Aberto do
			SetEntityLocallyInvisible(PlayerPedId())
			Wait(0)
		end
		PlayerHiddenThread = false
	end)
end

local function StartPreviewPositionThread()
	if PreviewThread then return end
	PreviewThread = true
	PositionBuffer = {}
	CreateThread(function()
		while Aberto and PreviewPed and DoesEntityExist(PreviewPed) do
			local World, Normal = GetWorldCoordFromScreenCoord(0.5, 0.77)
			local Target = World + Normal * 3.5
			local CamRot = GetGameplayCamRot(2)

			table.insert(PositionBuffer, Target)
			if #PositionBuffer > BufferSize then
				table.remove(PositionBuffer, 1)
			end

			local Averaged = vector3(0, 0, 0)
			for _,Pos in ipairs(PositionBuffer) do
				Averaged = Averaged + Pos
			end
			Averaged = Averaged / #PositionBuffer

			SetEntityCoords(PreviewPed, Averaged.x, Averaged.y, Averaged.z, false, false, false, true)
			SetEntityHeading(PreviewPed, CamRot.z + 190.0)
			SetEntityRotation(PreviewPed, CamRot.x * (-1), 0.0, CamRot.z + 170.0, 2, false)
			Wait(4)
		end
		PreviewThread = false
	end)
end

local function CreatePreviewPed()
	if PreviewPed and DoesEntityExist(PreviewPed) then
		DeleteEntity(PreviewPed)
		PreviewPed = nil
	end

	local PlayerPed = PlayerPedId()
	local Coords = GetEntityCoords(PlayerPed) - vector3(0.0, 0.0, 10.0)
	PreviewPed = CreatePed(26, GetEntityModel(PlayerPed), Coords.x, Coords.y, Coords.z, 0.0, false, false)
	ClonePedToTarget(PlayerPed, PreviewPed)

	SetEntityAsMissionEntity(PreviewPed, true, true)
	DecorSetBool(PreviewPed, "CREATIVE_PED", true)
	SetEntityInvincible(PreviewPed, true)
	SetEntityLocallyVisible(PreviewPed)
	NetworkSetEntityInvisibleToNetwork(PreviewPed, true)
	SetEntityCanBeDamaged(PreviewPed, false)
	SetBlockingOfNonTemporaryEvents(PreviewPed, true)
	SetEntityAlpha(PreviewPed, 254, false)
	SetEntityCollision(PreviewPed, false, false)

	Wait(100)
	StartPreviewPositionThread()
end

local function DestroyPreviewPed()
	if PreviewPed and DoesEntityExist(PreviewPed) then
		DeleteEntity(PreviewPed)
	end
	PreviewPed = nil
	PositionBuffer = {}
end

local function PreviewSelectedOutfit(outfitId)
	if not PreviewPed or not DoesEntityExist(PreviewPed) then return end
	local Outfit = WardrobeCache.outfitMap[tonumber(outfitId)]
	if not Outfit or not Outfit.clothingData then return end
	ApplySkinDataToPed(Outfit.clothingData, PreviewPed)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN / CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseWardrobe()
	if not Aberto then return end
	Aberto = false
	SelectedOutfit = nil
	SetUiVisibility(false)
	DestroyPreviewPed()
end

local function OpenWardrobe()
	if Aberto or not CanOpenWardrobe() then return end
	TriggerServerEvent("core-wardrobe:requestOpen")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-wardrobe:openPanel", function(payload)
	if Aberto then return end

	Aberto = true
	SelectedOutfit = nil
	SetWardrobeCache(payload)
	SetUiVisibility(true)
	CreatePreviewPed()
	EnsurePlayerHiddenThread()

	SendNUIMessage({
		action = "openWardrobe",
		data = {
			maxSlots = WardrobeCache.maxSlots,
			unlockedSlots = WardrobeCache.unlockedSlots,
			outfits = WardrobeCache.outfits,
			themeColor = WardrobeCache.themeColor,
			slotPrice = WardrobeCache.slotPrice,
		},
	})
end)

RegisterNetEvent("core-wardrobe:response", function(action, response)
	if not Aberto then return end

	if action == "wearOutfit" then
		if response and response.success then
			CloseWardrobe()
		end
		return
	end

	if action == "selectOutfit" then
		return
	end

	if response and response.success and response.wardrobe then
		SendWardrobeUpdate(response.wardrobe)
	end
end)

RegisterNetEvent("core-wardrobe:open", function()
	OpenWardrobe()
end)

AddEventHandler("onResourceStop", function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end
	CloseWardrobe()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("core-wardrobe", function(data, cb)
	local Action = data and data.action
	local Ped = PlayerPedId()
	local Response = { success = true }

	if Action == "close" then
		CloseWardrobe()
		cb(Response)
		return
	end

	if not Aberto then
		cb({ success = false })
		return
	end

	if Action == "selectOutfit" then
		SelectedOutfit = tonumber(data.id)
		PreviewSelectedOutfit(SelectedOutfit)
		TriggerServerEvent("core-wardrobe:handleAction", "selectOutfit", { id = data.id })
		cb(Response)
		return
	end

	if Action == "wearOutfit" then
		TriggerServerEvent("core-wardrobe:handleAction", "wearOutfit", { id = data.id })
		CloseWardrobe()
		cb(Response)
		return
	end

	if Action == "updateOutfit" then
		TriggerServerEvent("core-wardrobe:handleAction", "updateOutfit", {
			id = data.id,
			clothingData = CollectCurrentSkinData(Ped),
			gender = GetPedGender(Ped),
		})
		cb(Response)
		return
	end

	if Action == "addOutfit" then
		TriggerServerEvent("core-wardrobe:handleAction", "addOutfit", {
			name = tostring(data.name or ""),
			clothingData = CollectCurrentSkinData(Ped),
			gender = GetPedGender(Ped),
		})
		cb(Response)
		return
	end

	if Action == "importCode" then
		TriggerServerEvent("core-wardrobe:handleAction", "importCode", {
			code = tostring(data.code or ""),
			playerGender = GetPedGender(Ped),
		})
		cb(Response)
		return
	end

	if Action == "removeOutfit" then
		TriggerServerEvent("core-wardrobe:handleAction", "removeOutfit", { id = data.id })
		if SelectedOutfit == tonumber(data.id) then
			SelectedOutfit = nil
		end
		cb(Response)
		return
	end

	if Action == "unlockSlot" then
		TriggerServerEvent("core-wardrobe:handleAction", "unlockSlot", {})
		cb(Response)
		return
	end

	if Action == "shareOutfit" then
		TriggerServerEvent("core-wardrobe:handleAction", "shareOutfit", { id = data.id })
		cb(Response)
		return
	end

	if Action == "confirmShare" then
		TriggerServerEvent("core-wardrobe:handleAction", "confirmShare", { id = data.id })
		cb(Response)
		return
	end

	cb({ success = false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS / EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
if Config.AllowOpenCommand then
	RegisterCommand(Config.OpenCommand, function()
		OpenWardrobe()
	end)
end

exports("OpenWardrobe", function()
	OpenWardrobe()
end)
