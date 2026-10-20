-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("core-skins")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local nUIOpen = false
local inventoryCategory = ""
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cálculos de cor puros (não dependem de framework), usados só aqui pra montar a paleta do
-- tema a partir da cor base (globalConfig.themeColor).
local function hexToRgb(hex)
	if type(hex) ~= "string" then return 0,149,243 end
	hex = hex:gsub("#","")
	if #hex ~= 6 then return 0,149,243 end
	local r = tonumber(hex:sub(1,2),16) or 0
	local g = tonumber(hex:sub(3,4),16) or 149
	local b = tonumber(hex:sub(5,6),16) or 243
	return r,g,b
end

local function rgbToHsl(r,g,b)
	r,g,b = r / 255,g / 255,b / 255
	local max = math.max(r,g,b)
	local min = math.min(r,g,b)
	local l = (max + min) / 2
	local h,s = 0,0
	if max ~= min then
		local d = max - min
		s = (l > 0.5) and (d / (2 - max - min)) or (d / (max + min))
		if max == r then
			h = (g - b) / d + ((g < b) and 6 or 0)
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
		h = h / 6
	end
	return h * 360,s,l
end

local function hueToRgb(p,q,t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1 / 6 then return p + (q - p) * 6 * t end
	if t < 1 / 2 then return q end
	if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
	return p
end

local function hslToRgb(h,s,l)
	h = (h % 360) / 360
	if s == 0 then
		local v = math.floor(l * 255 + 0.5)
		return v,v,v
	end
	local q = (l < 0.5) and (l * (1 + s)) or (l + s - l * s)
	local p = 2 * l - q
	local r = hueToRgb(p,q,h + 1 / 3)
	local g = hueToRgb(p,q,h)
	local b = hueToRgb(p,q,h - 1 / 3)
	return math.floor(r * 255 + 0.5),math.floor(g * 255 + 0.5),math.floor(b * 255 + 0.5)
end

local function paletteFromHex(hex)
	local r,g,b = hexToRgb(hex)
	local h,s,l = rgbToHsl(r,g,b)

	local sr,sg,sb = hslToRgb(h + 120,s,l)
	local tr,tg,tb = hslToRgb(h + 60,s,l)

	return {
		primaryColor   = string.format("%d, %d, %d",r,g,b),
		secondaryColor = string.format("%d, %d, %d",sr,sg,sb),
		thirdColor     = string.format("%d, %d, %d",tr,tg,tb),
	}
end

local function resolveTheme()
	return paletteFromHex((Theme and Theme.main) or globalConfig.themeColor or "#0095f3")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
local function openPanel()
	if nUIOpen then return end

	nUIOpen = true
	SetNuiFocus(true,true)
	SendNUIMessage({ action = "setAdmin", payload = false })
	SendNUIMessage({ action = "setVisible", payload = true })
end

local function openAdmin()
	if nUIOpen then return end

	nUIOpen = true
	SetNuiFocus(true,true)
	SendNUIMessage({ action = "setAdmin", payload = true })
	SendNUIMessage({ action = "setVisible", payload = true })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function closePanel()
	if not nUIOpen then return end

	nUIOpen = false
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "setVisible", payload = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEW 3D
-----------------------------------------------------------------------------------------------------------------------------------------
local previewCoords = vec3(235.86,-977.57,-98.80)
local previewCamPos = vec3(234.86,-977.57,-98.65)
local previewCamRot = vec3(0.0,0.0,-90.0)
local previewDefaultRot = vec3(0.0,0.0,90.0)
local previewDefaultFov = 60.0
local previewMinFov = 25.0
local previewMaxFov = 90.0

local previewCam = nil
local previewObject = nil
local previewComponent = nil
local previewRotation = nil
local previewFov = previewDefaultFov
local previewActive = false
local previewModelHash = nil
local previewComponentHash = nil
local previewWeaponMap = nil

local alternativeBaseMap = nil

local function buildPreviewMap()
	previewWeaponMap = {}
	alternativeBaseMap = {}

	for _,weapon in ipairs(globalConfig.weapons or {}) do
		for _,skin in ipairs(weapon.skins or {}) do
			if skin.data then
				previewWeaponMap[skin.id] = {
					weapon    = skin.data.weapon,
					component = skin.data.component,
				}

				if skin.data.weapon then
					alternativeBaseMap[skin.data.weapon] = weapon.id
				end
			end
		end
	end
end

local function getBaseWeapon(weaponName)
	if not weaponName then return weaponName end
	if not alternativeBaseMap then buildPreviewMap() end
	return alternativeBaseMap[weaponName] or weaponName
end

exports("GetBaseWeapon",getBaseWeapon)

local function resolveSkinModels(modelName)
	if not previewWeaponMap then buildPreviewMap() end

	local entry = previewWeaponMap[modelName]
	if not entry then return nil,nil end

	local weaponModel = nil
	if entry.weapon then
		local hash = GetWeapontypeModel(GetHashKey(entry.weapon))
		if hash and hash ~= 0 and IsModelValid(hash) then
			weaponModel = hash
		end
	end

	local componentModel = nil
	if entry.component then
		local hash = GetWeaponComponentTypeModel(GetHashKey(entry.component))
		if hash and hash ~= 0 and IsModelValid(hash) then
			componentModel = hash
		end
	end

	return weaponModel,componentModel
end

local function loadModel(hash)
	if not hash then return false end
	RequestModel(hash)
	local tries = 0
	while not HasModelLoaded(hash) and tries < 100 do
		Wait(10)
		RequestModel(hash)
		tries = tries + 1
	end
	return HasModelLoaded(hash)
end

local function releasePreviewModels()
	if previewModelHash then
		SetModelAsNoLongerNeeded(previewModelHash)
		previewModelHash = nil
	end
	if previewComponentHash then
		SetModelAsNoLongerNeeded(previewComponentHash)
		previewComponentHash = nil
	end
end

local function cleanupPreview()
	if previewComponent and DoesEntityExist(previewComponent) then
		DeleteEntity(previewComponent)
	end
	previewComponent = nil

	if previewObject and DoesEntityExist(previewObject) then
		DeleteEntity(previewObject)
	end
	previewObject = nil

	if previewCam and DoesCamExist(previewCam) then
		RenderScriptCams(false,false,0,false,false)
		SetCamActive(previewCam,false)
		DestroyCam(previewCam,false)
	end
	previewCam = nil

	releasePreviewModels()

	previewActive = false
	previewFov = previewDefaultFov
	previewRotation = nil
	NewLoadSceneStop()
end

local function spawnPreviewObject(modelName)
	local weaponModel,componentModel = resolveSkinModels(modelName)
	local primaryModel = weaponModel or componentModel
	if not primaryModel then return false end

	if not loadModel(primaryModel) then return false end

	if previewComponent and DoesEntityExist(previewComponent) then
		DeleteEntity(previewComponent)
	end
	previewComponent = nil

	if previewObject and DoesEntityExist(previewObject) then
		DeleteEntity(previewObject)
	end
	previewObject = nil

	releasePreviewModels()
	previewModelHash = primaryModel

	previewObject = CreateObject(primaryModel,previewCoords,false,false,false)
	if not previewObject or previewObject == 0 then
		previewObject = nil
		releasePreviewModels()
		return false
	end

	SetEntityRotation(previewObject,previewDefaultRot.x,previewDefaultRot.y,previewDefaultRot.z,2,true)
	FreezeEntityPosition(previewObject,true)
	previewRotation = GetEntityRotation(previewObject,2)

	if weaponModel and componentModel and componentModel ~= primaryModel then
		if loadModel(componentModel) then
			previewComponentHash = componentModel
			previewComponent = CreateObject(componentModel,previewCoords,false,false,false)
			if previewComponent and previewComponent ~= 0 then
				AttachEntityToEntity(previewComponent,previewObject,0,0.0,0.0,0.0,0.0,0.0,0.0,true,true,false,false,2,true)
			else
				previewComponent = nil
				SetModelAsNoLongerNeeded(componentModel)
				previewComponentHash = nil
			end
		end
	end

	return true
end

local function openPreview(modelName)
	if previewActive then
		return spawnPreviewObject(modelName)
	end

	NewLoadSceneStartSphere(previewCoords.x,previewCoords.y,previewCoords.z,100.0,0)

	previewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
	SetCamCoord(previewCam,previewCamPos.x,previewCamPos.y,previewCamPos.z)
	SetCamRot(previewCam,previewCamRot.x,previewCamRot.y,previewCamRot.z,2)
	SetCamFov(previewCam,previewDefaultFov)
	SetCamActive(previewCam,true)
	RenderScriptCams(true,false,0,false,false)

	previewFov = previewDefaultFov
	previewActive = true

	local ok = spawnPreviewObject(modelName)
	if not ok then
		cleanupPreview()
		return false
	end

	return true
end

local function closePreview()
	if not previewActive then return end
	cleanupPreview()
end

local function rotatePreview(x,y)
	if not previewActive or not previewObject or not DoesEntityExist(previewObject) then return end
	if not previewRotation then return end

	local speed = (globalConfig.preview and globalConfig.preview.rotationSpeed) or 0.35
	local newPitch = previewRotation.x + (y * speed)
	local newYaw = previewRotation.z - (x * speed)

	SetEntityRotation(previewObject,newPitch,previewRotation.y,newYaw,2,true)
	previewRotation = GetEntityRotation(previewObject,2)
end

local function zoomPreview(delta)
	if not previewActive or not previewCam or not DoesCamExist(previewCam) then return end

	delta = tonumber(delta) or 0
	previewFov = math.max(previewMinFov,math.min(previewMaxFov,previewFov + delta))
	SetCamFov(previewCam,previewFov)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPON TEST
-----------------------------------------------------------------------------------------------------------------------------------------
local weaponTestActive = false
local weaponTestWeaponHash = nil
local weaponTestRestoreCoords = nil
local weaponTestRestoreHeading = nil
local weaponTestRestoreInvincible = false
local weaponTestSquaredRadius = 0.0
local weaponTestExpireAt = 0

local function stopWeaponTest()
	if not weaponTestActive then return end
	weaponTestActive = false

	local ped = PlayerPedId()

	if DoesEntityExist(ped) then
		RemoveAllPedWeapons(ped,true)

		if weaponTestRestoreCoords then
			SetEntityCoords(ped,weaponTestRestoreCoords.x,weaponTestRestoreCoords.y,weaponTestRestoreCoords.z,false,false,false,false)
		end
		if weaponTestRestoreHeading then
			SetEntityHeading(ped,weaponTestRestoreHeading)
		end

		SetEntityInvincible(ped,weaponTestRestoreInvincible)
	end

	weaponTestWeaponHash = nil
	weaponTestRestoreCoords = nil
	weaponTestRestoreHeading = nil
	weaponTestRestoreInvincible = false
	weaponTestSquaredRadius = 0.0
	weaponTestExpireAt = 0

	TriggerServerEvent("core-skins:WeaponTestEnded")
end

local function startWeaponTest(payload)
	if globalConfig.weaponTest.enabled == false then return false end
	if weaponTestActive then return false end
	if type(payload) ~= "table" or not payload.weapon then return false end

	local ped = PlayerPedId()
	if not DoesEntityExist(ped) then return false end

	local cfg = globalConfig.weaponTest
	local target = cfg.coords
	local weaponHash = GetHashKey(payload.weapon)

	closePreview()
	closePanel()

	weaponTestActive = true
	weaponTestWeaponHash = weaponHash
	weaponTestRestoreInvincible = GetPlayerInvincible(PlayerId()) and true or false
	weaponTestSquaredRadius = (cfg.maxRadius or 30.0) * (cfg.maxRadius or 30.0)
	weaponTestExpireAt = GetGameTimer() + ((cfg.maxSeconds or 600) * 1000)

	local coords = GetEntityCoords(ped)
	weaponTestRestoreCoords = vector3(coords.x,coords.y,coords.z)
	weaponTestRestoreHeading = GetEntityHeading(ped)

	TriggerEvent("inventory:CleanWeapons")
	RemoveAllPedWeapons(ped,true)

	RequestCollisionAtCoord(target.x,target.y,target.z)
	SetEntityCoords(ped,target.x,target.y,target.z,false,false,false,false)
	SetEntityHeading(ped,target.w)
	SetEntityInvincible(ped,true)

	TriggerServerEvent("core-skins:WeaponTestGive")

	CreateThread(function()
		local tries = 0
		while weaponTestActive and not HasPedGotWeapon(PlayerPedId(),weaponHash,false) and tries < 100 do
			Wait(50)
			tries = tries + 1
		end

		if not weaponTestActive then return end

		local self = PlayerPedId()
		if payload.component then
			GiveWeaponComponentToPed(self,weaponHash,GetHashKey(payload.component))
		end
		if payload.clip then
			GiveWeaponComponentToPed(self,weaponHash,GetHashKey(payload.clip))
		end

		SetCurrentPedWeapon(self,weaponHash,true)
	end)

	CreateThread(function()
		local nextAmmoRefill = 0

		while weaponTestActive do
			Wait(0)

			if IsControlJustReleased(0,cfg.exitKey or 177) then
				stopWeaponTest()
				return
			end

			BeginTextCommandDisplayHelp("STRING")
			AddTextComponentSubstringPlayerName("Pressione ~INPUT_FRONTEND_DELETE~ para encerrar o teste.")
			EndTextCommandDisplayHelp(0,false,true,-1)

			local self = PlayerPedId()
			local pos = GetEntityCoords(self)
			local dx = pos.x - target.x
			local dy = pos.y - target.y
			local dz = pos.z - target.z
			if (dx * dx + dy * dy + dz * dz) > weaponTestSquaredRadius then
				stopWeaponTest()
				return
			end

			if GetGameTimer() >= weaponTestExpireAt then
				stopWeaponTest()
				return
			end

			if GetAmmoInPedWeapon(self,weaponHash) < 30 and GetGameTimer() >= nextAmmoRefill then
				nextAmmoRefill = GetGameTimer() + 1000
				TriggerServerEvent("core-skins:WeaponTestAmmo")
			end
		end
	end)

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function route(path,handler)
	RegisterNUICallback(path,function(data,callback)
		local ok,result = pcall(handler,data)
		if not ok then
			print("[core-skins][NUI][ERRO]",path,result)
			callback(false)
			return
		end
		callback(result)
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTES - GETTERS
-----------------------------------------------------------------------------------------------------------------------------------------
route("get:playerData",function()              return vSERVER.playerData() end)
route("get:cases",function()                   return vSERVER.cases() end)
route("get:caseContents",function(data)        return vSERVER.caseContents(data) end)
route("get:lastWins",function()                return vSERVER.lastWins() end)
route("get:inventory",function()               return vSERVER.inventory() end)
route("get:colors",function()                  return resolveTheme() end)
route("get:banner",function()                  return vSERVER.banner() end)
route("get:logo",function()                    return vSERVER.logo() end)
route("get:skinCoinsShopUrl",function()        return vSERVER.skinCoinsShopUrl() end)
route("get:inventoryWeaponCategory",function() return inventoryCategory end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTES - TRADES
-----------------------------------------------------------------------------------------------------------------------------------------
route("get:trades:list",function()            return vSERVER.tradesList() end)
route("get:trades:playersById",function(data) return vSERVER.tradesPlayersById(data) end)
route("get:playersData",function(data)        return vSERVER.tradesPlayersData(data) end)
route("post:trades:sendTrade",function(data)    return vSERVER.tradesSend(data) end)
route("post:trades:acceptTrade",function(data)  return vSERVER.tradesAccept(data) end)
route("post:trades:declineTrade",function(data) return vSERVER.tradesDecline(data) end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTES - IMPROVEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
route("get:improvement:data",function()           return vSERVER.improvementData() end)
route("get:improvement:skinChance",function(data) return vSERVER.improvementSkinChance(data) end)
route("post:improvement:improve",function(data)   return vSERVER.improvementImprove(data) end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTES - RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
route("get:ranking:byPeriod",function(data) return vSERVER.rankingByPeriod(data) end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTES - ACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
route("post:openCase",function(data) return vSERVER.openCase(data) end)
route("post:equip",function(data)    return vSERVER.equip(data) end)
route("post:unequip",function(data)  return vSERVER.unequip(data) end)
route("post:sell",function(data)     return vSERVER.sell(data) end)
route("post:purchaseSkin",function(data) return vSERVER.purchase(data) end)

route("get:admin:search",function(data)     return vSERVER.adminSearch(data) end)
route("get:admin:player",function(data)      return vSERVER.adminPlayer(data) end)
route("get:admin:catalogue",function()       return vSERVER.adminCatalogue() end)
route("post:admin:currency",function(data)   return vSERVER.adminCurrency(data) end)
route("post:admin:giveSkin",function(data)   return vSERVER.adminGiveSkin(data) end)
route("post:admin:removeSkin",function(data) return vSERVER.adminRemoveSkin(data) end)
route("post:admin:wipeSkins",function(data)  return vSERVER.adminWipeSkins(data) end)
route("post:admin:giveAll",function(data)    return vSERVER.adminGiveSkinAllOnline(data) end)
route("post:admin:giveAllSkins",function(data) return vSERVER.adminGiveAllSkins(data) end)

route("post:closeUi",function()
	closePreview()
	closePanel()
	return true
end)

route("setInventoryWeaponCategory",function(data)
	inventoryCategory = data and data.category or ""
	return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROUTES - PREVIEW
-----------------------------------------------------------------------------------------------------------------------------------------
route("post:preview3D",function(data)
	local modelName = data and data.modelName
	if not modelName then return false end
	return openPreview(modelName)
end)

route("post:stopPreview3D",function()
	closePreview()
	return true
end)

route("post:rotatePreview",function(data)
	rotatePreview(tonumber(data and data.x) or 0,tonumber(data and data.y) or 0)
	return true
end)

route("post:zoomPreview",function(data)
	zoomPreview(tonumber(data and data.delta) or 0)
	return true
end)

route("get:weaponTestEnabled",function() return globalConfig.weaponTest.enabled ~= false end)
route("post:startWeaponTest",function(data) return vSERVER.weaponTestStart(data) end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-skins:Open")
AddEventHandler("core-skins:Open",function()
	openPanel()
end)

RegisterNetEvent("core-skins:OpenAdmin")
AddEventHandler("core-skins:OpenAdmin",function()
	openAdmin()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS:NEWWIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-skins:NewWin")
AddEventHandler("core-skins:NewWin",function(win)
	if not nUIOpen or not win then return end
	SendNUIMessage({ action = "newWin", payload = win })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS:TRADEUPDATED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-skins:TradeUpdated")
AddEventHandler("core-skins:TradeUpdated",function(trade)
	if not trade then return end
	SendNUIMessage({ action = "tradeUpdated", payload = trade })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS:TRADEPROPOSALRECEIVED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-skins:TradeProposalReceived")
AddEventHandler("core-skins:TradeProposalReceived",function(trade)
	if not trade then return end

	if not nUIOpen then
		openPanel()
	end

	SendNUIMessage({ action = "tradeProposalReceived", payload = trade })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS:STARTWEAPONTEST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-skins:StartWeaponTest")
AddEventHandler("core-skins:StartWeaponTest",function(payload)
	startWeaponTest(payload)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLY COMPONENT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-skins:ApplyComponent")
AddEventHandler("core-skins:ApplyComponent",function(weaponName,weaponComponent)
	if not weaponName or not weaponComponent then return end

	local ped = PlayerPedId()
	GiveWeaponComponentToPed(ped,GetHashKey(weaponName),GetHashKey(weaponComponent))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(resource)
	if resource ~= GetCurrentResourceName() then return end
	SetNuiFocus(false,false)
	cleanupPreview()
	stopWeaponTest()
end)
