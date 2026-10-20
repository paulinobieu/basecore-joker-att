-- Declaração antecipada dos helpers de log (o corpo deles fica na seção LOGS mais abaixo).
-- Isso permite que funções definidas antes dela — como a expiração de skins — também logem.
local coreLog, logPlayerName, logStaffInfo
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
core = {}
Tunnel.bindInterface("core-skins",core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCALS (cache de funções quentes — acesso a upvalue é mais barato que lookup global)
-----------------------------------------------------------------------------------------------------------------------------------------
local type, tostring, tonumber, pairs, ipairs = type, tostring, tonumber, pairs, ipairs
local math, string, table, os, json = math, string, table, os, json
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local skinsCache = {}
local userSkins = {}
local dirtySkins = {}
local casesData = {}
local lastWins = {}
local skinsCoinsCache = {}
local vouchersCache = {}
local avatarCache = {}
local dailyOpensCache = {}
local tradeStore = {}
local tradeHistoryLimit = 50
-- Índices derivados de UserSkins (mesma vida útil; mantidos em sync nas mutações).
local equippedSkins = {}   -- [Passport][SkinId] = true  (só skins equipadas)
local tempSkins = {}       -- [Passport][SkinId] = expiresAt  (só skins temporárias)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
framework.databaseReady(function()
	framework.query([[
		CREATE TABLE IF NOT EXISTS `core_skins_inventory` (
			`passport` INT NOT NULL,
			`skinId` VARCHAR(64) NOT NULL,
			`weaponId` VARCHAR(64) NOT NULL,
			`equipped` TINYINT(1) NOT NULL DEFAULT 0,
			`amount` INT NOT NULL DEFAULT 1,
			`expires_at` BIGINT NULL DEFAULT NULL,
			PRIMARY KEY (`passport`,`skinId`),
			INDEX `idx_passport` (`passport`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	]])

	framework.query([[
		ALTER TABLE `core_skins_inventory`
		ADD COLUMN IF NOT EXISTS `expires_at` BIGINT NULL DEFAULT NULL
	]])

	framework.query([[
		CREATE TABLE IF NOT EXISTS `core_skins_wins` (
			`id` INT NOT NULL AUTO_INCREMENT,
			`passport` INT NOT NULL,
			`skinId` VARCHAR(64) NOT NULL,
			`caseId` VARCHAR(64) DEFAULT NULL,
			`rarity` VARCHAR(32) DEFAULT NULL,
			`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			PRIMARY KEY (`id`),
			INDEX `idx_passport` (`passport`),
			INDEX `idx_created` (`created_at`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	]])

	framework.query([[
		CREATE TABLE IF NOT EXISTS `core_skins_trades` (
			`id` VARCHAR(96) NOT NULL,
			`proposer_id` INT NOT NULL,
			`other_id` INT NOT NULL,
			`proposer_items` LONGTEXT NOT NULL,
			`other_items` LONGTEXT NOT NULL,
			`status` VARCHAR(16) NOT NULL DEFAULT 'pending',
			`created_at` BIGINT NOT NULL,
			`expires_at` BIGINT NOT NULL,
			PRIMARY KEY (`id`),
			INDEX `idx_proposer` (`proposer_id`),
			INDEX `idx_other` (`other_id`),
			INDEX `idx_status` (`status`),
			INDEX `idx_expires` (`expires_at`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	]])
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function hashSize(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

local function nowMs()
	return math.floor(os.time() * 1000)
end

local function notify(source,kind,message)
	if not source or source <= 0 then return end
	TriggerClientEvent("Notify",source,"Skins",message,kind or "amarelo",5000)
end

local function notifyOrPrint(source,kind,message)
	if source and source > 0 then
		TriggerClientEvent("Notify",source,"Skins",message,kind or "amarelo",5000)
	else
		print("[core-skins] "..message)
	end
end

local function expiryFromDays(days)
	days = tonumber(days) or 0
	if days <= 0 then return nil end
	return nowMs() + math.floor(days * 86400000)
end

local function isExpired(entry,now)
	if not entry or not entry.expiresAt then return false end
	return entry.expiresAt <= (now or nowMs())
end

local function daysLeft(entry,now)
	if not entry or not entry.expiresAt then return nil end
	local diff = entry.expiresAt - (now or nowMs())
	if diff <= 0 then return 0 end
	return math.ceil(diff / 86400000)
end

-- Agendador de expiração (timer único global, definido após RemoveSkin).
local scheduleExpiry

local function resolveRarity(rarity)
	return globalConfig.rarityMap[rarity] or rarity or "comum"
end

local function playerName(passport)
	local identity = framework.identity(passport)
	if not identity then return "Cidadão #"..tostring(passport) end
	return (identity.Name or "") .. " " .. (identity.Lastname or "") .. " #" .. tostring(passport)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- AVATAR
-----------------------------------------------------------------------------------------------------------------------------------------
local function resolveAvatar(passport)
	passport = tonumber(passport)
	if not passport then return "" end

	if avatarCache[passport] ~= nil then
		return avatarCache[passport]
	end

	local url = framework.avatar(passport) or ""
	avatarCache[passport] = url
	return url
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER CARD
-----------------------------------------------------------------------------------------------------------------------------------------
local function playerCard(passport)
	local identity = framework.identity(passport)
	local name = "Cidadão"
	if identity then
		name = (identity.Name or "") .. " " .. (identity.Lastname or "")
	end
	return { id = passport, name = name, avatar = resolveAvatar(passport) }
end

local function checkStaff(source)
	if source == 0 then return true end

	local passport = framework.passport(source)
	if not passport then return false end

	if not framework.hasPermission(passport,globalConfig.staffPermission) then
		notify(source,"vermelho","Você não tem permissão para isso.")
		return false
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CURRENCY HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function readCurrency(passport,key)
	local data = framework.userData(passport,key)
	if type(data) == "table" then
		return tonumber(data.amount) or 0
	end
	return tonumber(data) or 0
end

local function writeCurrency(passport,key,amount)
	framework.setUserData(passport,key,{ amount = amount })
end

local function getCurrency(cache,key,passport)
	passport = tonumber(passport)
	if not passport then return 0 end

	if cache[passport] ~= nil then
		return cache[passport]
	end

	local value = readCurrency(passport,key)
	cache[passport] = value
	return value
end

local function setCurrency(cache,key,passport,amount)
	passport = tonumber(passport)
	amount = math.floor(tonumber(amount) or 0)
	if not passport or amount < 0 then return false end

	cache[passport] = amount
	writeCurrency(passport,key,amount)
	return true
end

local function giveCurrency(cache,key,passport,amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end
	return setCurrency(cache,key,passport,getCurrency(cache,key,passport) + amount)
end

local function removeCurrency(cache,key,passport,amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount <= 0 then return false end

	local current = getCurrency(cache,key,passport)
	if current < amount then return false end

	return setCurrency(cache,key,passport,current - amount)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKINSCOINS
-----------------------------------------------------------------------------------------------------------------------------------------
local function getSkinsCoins(passport)
	if globalConfig.useFrameworkCoins then return framework.frameworkCoins.get(passport) end
	return getCurrency(skinsCoinsCache,globalConfig.skinsCoinsUDataKey,passport)
end

local function setSkinsCoins(passport,a)
	if globalConfig.useFrameworkCoins then return framework.frameworkCoins.set(passport,a) end
	return setCurrency(skinsCoinsCache,globalConfig.skinsCoinsUDataKey,passport,a)
end

local function giveSkinsCoins(passport,a)
	if globalConfig.useFrameworkCoins then return framework.frameworkCoins.give(passport,a) end
	return giveCurrency(skinsCoinsCache,globalConfig.skinsCoinsUDataKey,passport,a)
end

local function removeSkinsCoins(passport,a)
	if globalConfig.useFrameworkCoins then return framework.frameworkCoins.remove(passport,a) end
	return removeCurrency(skinsCoinsCache,globalConfig.skinsCoinsUDataKey,passport,a)
end

exports("GetSkinsCoins",getSkinsCoins)
exports("SetSkinsCoins",setSkinsCoins)
exports("GiveSkinsCoins",giveSkinsCoins)
exports("RemoveSkinsCoins",removeSkinsCoins)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VOUCHERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function getVouchers(passport)    return getCurrency(vouchersCache,globalConfig.vouchersUDataKey,passport) end
local function setVouchers(passport,a)  return setCurrency(vouchersCache,globalConfig.vouchersUDataKey,passport,a) end
local function giveVouchers(passport,a) return giveCurrency(vouchersCache,globalConfig.vouchersUDataKey,passport,a) end
local function removeVouchers(passport,a) return removeCurrency(vouchersCache,globalConfig.vouchersUDataKey,passport,a) end

exports("GetVouchers",getVouchers)
exports("SetVouchers",setVouchers)
exports("GiveVouchers",giveVouchers)
exports("RemoveVouchers",removeVouchers)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DAILY COOLDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
local function loadDailyOpens(passport)
	passport = tonumber(passport)
	if not passport then return {} end

	if dailyOpensCache[passport] then
		return dailyOpensCache[passport]
	end

	local data = framework.userData(passport,globalConfig.dailyUDataKey)
	local map = (type(data) == "table" and not data.amount) and data or {}
	dailyOpensCache[passport] = map
	return map
end

local function lastDailyOpen(passport,caseId)
	local map = loadDailyOpens(passport)
	return tonumber(map[caseId]) or 0
end

local function setLastDailyOpen(passport,caseId,ts)
	passport = tonumber(passport)
	if not passport or not caseId then return end

	local map = loadDailyOpens(passport)
	map[caseId] = ts
	framework.setUserData(passport,globalConfig.dailyUDataKey,map)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKINS CRUD
-----------------------------------------------------------------------------------------------------------------------------------------
local function ensureUser(passport)
	if not userSkins[passport] then
		userSkins[passport] = {}
	end
end

local function indexEquip(passport,skinId,on)
	if on then
		equippedSkins[passport] = equippedSkins[passport] or {}
		equippedSkins[passport][skinId] = true
	elseif equippedSkins[passport] then
		equippedSkins[passport][skinId] = nil
	end
end

local function indexTemp(passport,skinId,expiresAt)
	if expiresAt then
		tempSkins[passport] = tempSkins[passport] or {}
		tempSkins[passport][skinId] = expiresAt
	elseif tempSkins[passport] then
		tempSkins[passport][skinId] = nil
	end
end

local function markDirty(passport,skinId,flag)
	passport = tonumber(passport)
	skinId = tostring(skinId)
	if not passport or skinId == "" or not flag then return end

	dirtySkins[passport] = dirtySkins[passport] or {}
	local prev = dirtySkins[passport][skinId]

	if flag == "delete" then
		dirtySkins[passport][skinId] = "delete"
		return
	end

	if prev == "insert" and flag == "update" then
		return
	end

	if prev == "delete" and flag == "insert" then
		dirtySkins[passport][skinId] = "insert"
		return
	end

	dirtySkins[passport][skinId] = flag
end

local function addSkin(passport,skinId,amount,days)
	amount = tonumber(amount) or 1
	if not passport or not skinId or amount <= 0 then return false end

	ensureUser(passport)

	local owned = userSkins[passport][skinId]
	local skin = skinsCache[skinId]
	if not skin then return false end

	local newExpiry = expiryFromDays(days)

	if owned then
		owned.amount = (tonumber(owned.amount) or 1) + amount

		if newExpiry == nil then
			owned.expiresAt = nil
		elseif owned.expiresAt ~= nil then
			owned.expiresAt = math.max(owned.expiresAt,newExpiry)
		end

		indexTemp(passport,skinId,owned.expiresAt)
		markDirty(passport,skinId,"update")
		if scheduleExpiry then scheduleExpiry(owned.expiresAt) end
		return true
	end

	userSkins[passport][skinId] = {
		weaponId = skin.weaponId,
		equipped = false,
		amount = amount,
		expiresAt = newExpiry,
	}

	indexTemp(passport,skinId,newExpiry)
	markDirty(passport,skinId,"insert")
	if scheduleExpiry then scheduleExpiry(newExpiry) end
	return true
end

local function removeSkin(passport,skinId,amount)
	if not passport or not skinId then return false end

	ensureUser(passport)

	local owned = userSkins[passport] and userSkins[passport][skinId]
	if not owned then return false end

	amount = tonumber(amount) or 1
	if amount <= 0 then return false end

	local current = tonumber(owned.amount) or 1
	local new = current - amount

	if new <= 0 then
		userSkins[passport][skinId] = nil
		indexEquip(passport,skinId,false)
		indexTemp(passport,skinId,nil)
		markDirty(passport,skinId,"delete")
	else
		owned.amount = new
		markDirty(passport,skinId,"update")
	end

	return true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPIRY SCHEDULER (timer único global, sem polling)
-----------------------------------------------------------------------------------------------------------------------------------------
local nextExpiryAt = nil
local expireGen = 0

-- Remove as skins vencidas (notifica online, limpa offline) e reagenda para a próxima.
local function expireDue()
	local now = nowMs()
	local soonest = nil

	for passport,entries in pairs(tempSkins) do
		local src

		for skinId,expiresAt in pairs(entries) do
			if expiresAt <= now then
				local skin = skinsCache[skinId]
				removeSkin(passport,skinId,1000000000)
				if src == nil then src = framework.source(passport) or false end
				if src and skin then
					notify(src,"vermelho",string.format(globalConfig.language.skinExpired,skin.name))
				end

				coreLog("SKIN_EXPIRED",{
					message    = logPlayerName(passport).." #"..passport.." teve a skin "..((skin and skin.name) or skinId).." expirada e removida do inventário",
					playerName = logPlayerName(passport),
					playerId   = passport,
					skin       = (skin and skin.name) or skinId,
					skinId     = skinId,
				})
			elseif not soonest or expiresAt < soonest then
				soonest = expiresAt
			end
		end
	end

	nextExpiryAt = nil
	if soonest then scheduleExpiry(soonest) end
end

-- Agenda o timer para `At` (epoch ms) se for mais cedo que o já agendado.
function scheduleExpiry(at)
	if not at then return end
	if nextExpiryAt and at >= nextExpiryAt then return end

	nextExpiryAt = at
	expireGen = expireGen + 1
	local gen = expireGen

	local wait = at - nowMs()
	if wait < 0 then wait = 0 end

	local maxWait = globalConfig.expireMaxScheduleMs or 86400000
	if wait > maxWait then wait = maxWait end

	SetTimeout(wait,function()
		if gen ~= expireGen then return end
		expireDue()
	end)
end

local function unequipWeapon(passport,weaponId)
	if not passport or not weaponId then return false end

	ensureUser(passport)

	for skinId,data in pairs(userSkins[passport]) do
		if data and data.weaponId == weaponId and data.equipped then
			data.equipped = false
			indexEquip(passport,skinId,false)
			markDirty(passport,skinId,"update")
		end
	end

	return true
end

local function equipSkin(passport,skinId)
	if not passport or not skinId then return false end

	ensureUser(passport)

	local owned = userSkins[passport] and userSkins[passport][skinId]
	if not owned then return false end

	if owned.equipped then
		owned.equipped = false
		indexEquip(passport,skinId,false)
		markDirty(passport,skinId,"update")
		return "unequipped"
	end

	unequipWeapon(passport,owned.weaponId)
	owned.equipped = true
	indexEquip(passport,skinId,true)
	markDirty(passport,skinId,"update")
	return "equipped"
end

local function findCase(id)
	for _,case in ipairs(casesData) do
		if case.id == id then
			return case
		end
	end
end

local function rollItem(items)
	local total = 0

	for _,item in ipairs(items or {}) do
		local chance = tonumber(item.chance) or 0
		if chance > 0 then
			total = total + chance
		end
	end

	if total <= 0 then return nil end

	local pick = math.random() * total
	local acc = 0

	for _,item in ipairs(items) do
		local chance = tonumber(item.chance) or 0
		if chance > 0 then
			acc = acc + chance
			if pick <= acc then
				return item
			end
		end
	end

	return items[#items]
end

-- Resolve as opções de duração de uma skin.
-- `SkinCfg.durations` (opcional) pode conter:
--   • string  → id de uma opção global (Skins.TemporaryDurations)
--   • table   → opção inline com dias/preço arbitrários { id?, label?, days, price? }
-- Sem o campo, usa a lista global. `days = 0` é permanente; `price = nil` usa o preço base.
local function resolveSkinDurations(skinCfg)
	local raw = (skinCfg and skinCfg.durations) or globalConfig.temporaryDurations or {}
	local out = {}

	for _,item in ipairs(raw) do
		if type(item) == "string" then
			for _,g in ipairs(globalConfig.temporaryDurations or {}) do
				if g.id == item then
					out[#out + 1] = { id = g.id, label = g.label, days = tonumber(g.days) or 0, price = g.price }
					break
				end
			end
		elseif type(item) == "table" then
			local daysVal = tonumber(item.days) or 0
			out[#out + 1] = {
				id    = item.id or ((daysVal > 0) and (daysVal .. "d") or "perm"),
				label = item.label or ((daysVal > 0) and (daysVal .. " Dias") or "Permanente"),
				days  = daysVal,
				price = item.price,
			}
		end
	end

	return out
end

local function buildInventory(passport)
	local result = {}

	for _,weapon in ipairs(globalConfig.weapons or {}) do
		local category = {
			id = weapon.id,
			name = weapon.name,
			image = weapon.image or "",
			skinsCount = 0,
			skins = {},
		}

		local now = nowMs()

		for _,skin in ipairs(weapon.skins or {}) do
			ensureUser(passport)
			local owned = userSkins[passport][skin.id]
			local quantity = owned and (tonumber(owned.amount) or 1) or 0
			local isOwned = quantity > 0 and not isExpired(owned,now)

			local days = isOwned and daysLeft(owned,now) or nil

			category.skins[#category.skins + 1] = {
				model_name  = skin.id,
				weapon_hash = weapon.id,
				name        = skin.name,
				rarity      = resolveRarity(skin.rarity),
				equipped    = (isOwned and owned.equipped) or false,
				owned       = isOwned,
				image       = skin.image,
				quantity    = quantity,
				price       = tonumber(skin.price) or 0,
				temporary   = (days ~= nil),
				daysLeft    = days,
				expiresAt   = (isOwned and owned.expiresAt) or nil,
				durations   = skin.durations and resolveSkinDurations(skin) or nil,
			}

			if isOwned then
				category.skinsCount = category.skinsCount + 1
			end
		end

		result[#result + 1] = category
	end

	return result
end

local function buildCasesList(passport)
	local result = {}
	local now = nowMs()

	for _,case in ipairs(casesData) do
		local cooldownSeconds = tonumber(case.cooldownSeconds) or 0
		local availableIn = tonumber(case.availableIn) or 0

		if case.free and passport and cooldownSeconds > 0 then
			local last = lastDailyOpen(passport,case.id)
			if last > 0 then
				local remaining = (last + (cooldownSeconds * 1000)) - now
				if remaining > 0 then
					availableIn = math.ceil(remaining / 1000)
				else
					availableIn = 0
				end
			end
		end

		result[#result + 1] = {
			id              = case.id,
			name            = case.name,
			price           = case.price or 0,
			originalPrice   = case.originalPrice,
			image           = case.image or "",
			skinsCount      = #(case.items or {}),
			badge           = case.badge,
			free            = case.free or false,
			availableIn     = availableIn,
			cooldownSeconds = cooldownSeconds,
		}
	end

	return result
end

local function buildCaseContents(id)
	local case = findCase(id)
	if not case then return {} end

	local result = {}
	for _,item in ipairs(case.items or {}) do
		result[#result + 1] = {
			model_name   = item.id,
			name         = item.name,
			rarity       = resolveRarity(item.rarity),
			value        = tonumber(item.price) or 0,
			chance       = tonumber(item.chance) or 0,
			image        = item.image,
			durationDays = item.durationDays,
		}
	end

	return result
end

local function pushWin(win)
	table.insert(lastWins,1,win)
	while #lastWins > (globalConfig.lastWinsSize or 20) do
		table.remove(lastWins)
	end
end

local function findEquippedByWeapon(passport,weaponName)
	local data = userSkins[passport]
	local equipped = equippedSkins[passport]
	if not data or not equipped then return false end

	local now = nowMs()

	for skinId in pairs(equipped) do
		local skin = data[skinId]
		if skin and skin.weaponId == weaponName and skin.equipped and (tonumber(skin.amount) or 1) > 0 and not isExpired(skin,now) then
			return skinId
		end
	end

	for skinId in pairs(equipped) do
		local skin = data[skinId]
		if skin and skin.equipped and (tonumber(skin.amount) or 1) > 0 and not isExpired(skin,now) then
			local cache = skinsCache[skinId]
			if cache and cache.cfg and cache.cfg.data and cache.cfg.data.weapon == weaponName then
				return skinId
			end
		end
	end

	return false
end

local function getWeaponSkin(passport,weaponName)
	if not passport or not weaponName then return false end

	local equipped = findEquippedByWeapon(passport,weaponName)
	if not equipped then return false end

	local skin = skinsCache[equipped]
	if not skin or not skin.cfg or not skin.cfg.data then return false end

	if skin.cfg.modType == "modWeapon" or skin.cfg.modType == "alternativeWeapon" then
		return skin.cfg.data.weapon or weaponName
	end

	return false
end

local function getBaseWeapon(weaponName)
	if not weaponName then return weaponName end

	for _,skin in pairs(skinsCache) do
		if skin.cfg and skin.cfg.data and skin.cfg.data.weapon == weaponName then
			return skin.weaponId or weaponName
		end
	end

	return weaponName
end

exports("GetWeaponSkin",getWeaponSkin)
exports("GetBaseWeapon",getBaseWeapon)

-- GiveSkin(passport, skinId, days, amount) — days nil/0 = permanente. Funciona offline (cache + sync).
local function giveSkinExport(passport,skinId,days,amount)
	passport = tonumber(passport)
	if not passport or not skinId or not skinsCache[skinId] then return false end
	return addSkin(passport,skinId,tonumber(amount) or 1,days)
end

-- RemoveSkinExport(passport, skinId, amount) — amount nil = remove tudo.
local function removeSkinExport(passport,skinId,amount)
	passport = tonumber(passport)
	if not passport or not skinId then return false end
	return removeSkin(passport,skinId,tonumber(amount) or 1000000000)
end

-- HasSkin(passport, skinId) -> false ou { owned, permanent, expiresAt, daysLeft }
local function hasSkinExport(passport,skinId)
	passport = tonumber(passport)
	local entry = passport and skinId and userSkins[passport] and userSkins[passport][skinId]
	if not entry or (tonumber(entry.amount) or 1) <= 0 or isExpired(entry) then return false end
	return {
		owned     = true,
		permanent = (entry.expiresAt == nil),
		expiresAt = entry.expiresAt,
		daysLeft  = daysLeft(entry),
	}
end

exports("GiveSkin",giveSkinExport)
exports("RemoveSkin",removeSkinExport)
exports("HasSkin",hasSkinExport)
-----------------------------------------------------------------------------------------------------------------------------------------
-- IMPROVEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
local function improvementEnabled()
	return globalConfig.improvement.enabled ~= false
end

local function targetMarkupOk(inputTotal,targetValue)
	local cfg = globalConfig.improvement
	if inputTotal <= 0 or targetValue <= 0 then return false end

	if cfg.minTargetMarkup and targetValue < (inputTotal * cfg.minTargetMarkup) then
		return false
	end
	if cfg.maxTargetMarkup and targetValue > (inputTotal * cfg.maxTargetMarkup) then
		return false
	end

	return true
end

local function improvementChance(inputValue,targetValue)
	local cfg = globalConfig.improvement
	if inputValue <= 0 or targetValue <= 0 then
		return cfg.minChance
	end

	local ratio = math.min(1.0,inputValue / targetValue)
	local chance = math.floor((ratio ^ cfg.chanceExponent) * 100 + 0.5)
	return math.max(cfg.minChance,math.min(cfg.maxChance,chance))
end

local function buildImprovementSkin(skinId)
	local skin = skinsCache[skinId]
	if not skin then return nil end

	return {
		model_name = skinId,
		name       = skin.name,
		rarity     = resolveRarity(skin.rarity),
		image      = skin.image or "",
		value      = tonumber(skin.price) or 0,
	}
end

local function buildImprovementPlayerInventory(passport)
	local out = {}
	if not passport or not userSkins[passport] then return out end

	for skinId,owned in pairs(userSkins[passport]) do
		local qty = tonumber(owned.amount) or 0
		if qty > 0 then
			local item = buildImprovementSkin(skinId)
			if item then
				item.quantity = qty
				out[#out + 1] = item
			end
		end
	end

	table.sort(out,function(a,b) return (a.value or 0) < (b.value or 0) end)
	return out
end

local function buildImprovementServerCatalog()
	local out = {}

	for skinId in pairs(skinsCache) do
		local item = buildImprovementSkin(skinId)
		if item then
			out[#out + 1] = item
		end
	end

	table.sort(out,function(a,b) return (a.value or 0) < (b.value or 0) end)
	return out
end

local function validateImprovementSelection(passport,selected)
	if type(selected) ~= "table" then return false,0 end
	if not userSkins[passport] then return false,0 end
	if globalConfig.improvement.requirePlayerSkin and #selected < 1 then return false,0 end

	local counts = {}
	local total = 0

	for _,entry in ipairs(selected) do
		local skinId = entry and entry.model_name
		if not skinId then return false,0 end

		local cache = skinsCache[skinId]
		if not cache then return false,0 end

		counts[skinId] = (counts[skinId] or 0) + 1
		total = total + (tonumber(cache.price) or 0)
	end

	for skinId,count in pairs(counts) do
		local owned = userSkins[passport][skinId]
		if not owned or (tonumber(owned.amount) or 0) < count then
			return false,0
		end
	end

	return true,total
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
local rankingLimit = 20

local rankingPeriodFilter = {
	["all"]     = "",
	["weekly"]  = "WHERE w.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)",
	["montlhy"] = "WHERE w.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)",
	["monthly"] = "WHERE w.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)",
}

local function buildRanking(period)
	local where = rankingPeriodFilter[period or "all"] or ""

	local sql = ([[
		SELECT
			w.passport AS id,
			COUNT(*) AS boxsBuyed,
			COALESCE(c.Name, 'Cidadão') AS firstname,
			COALESCE(c.Lastname, '') AS lastname
		FROM core_skins_wins w
		LEFT JOIN characters c ON c.id = w.passport
		%s
		GROUP BY w.passport, c.Name, c.Lastname
		ORDER BY boxsBuyed DESC
		LIMIT %d
	]]):format(where,rankingLimit)

	local rows = framework.query(sql) or {}
	local out = {}

	for index,row in ipairs(rows) do
		local id = tonumber(row.id) or 0
		local firstName = tostring(row.firstname or "Cidadão")
		local lastName = tostring(row.lastname or "")
		local name = (lastName ~= "") and (firstName.." "..lastName) or firstName

		out[index] = {
			id        = id,
			name      = name,
			avatar    = "",
			boxsBuyed = tonumber(row.boxsBuyed) or 0,
			rank      = index,
		}
	end

	return out
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRADES
-----------------------------------------------------------------------------------------------------------------------------------------
local function voucherCost(skinId)
	local skin = skinsCache[skinId]
	if not skin then return 0 end

	local price = tonumber(skin.price) or 0
	if price <= 0 then return 0 end

	return math.max(0,math.floor(price * (globalConfig.tradeVoucherRate or 0)))
end

local function sumVoucherCost(items)
	local total = 0
	if type(items) ~= "table" then return 0 end

	for _,item in ipairs(items) do
		total = total + voucherCost(item.id)
	end

	return total
end

local function buildSkinItem(skinId)
	local skin = skinsCache[skinId]
	if not skin then return nil end

	return {
		id               = skinId,
		name             = skin.name,
		image            = skin.image or "",
		rarity           = resolveRarity(skin.rarity),
		vouchersRequired = voucherCost(skinId),
	}
end

local function ownsAll(passport,items)
	if not passport or not items then return false end

	for _,item in ipairs(items) do
		local owned = userSkins[passport] and userSkins[passport][item.id]
		if not owned or (tonumber(owned.amount) or 0) < 1 then
			return false
		end
	end

	return true
end

local function inventoryFlat(passport)
	local out = {}
	if not passport or not userSkins[passport] then return out end

	for skinId,owned in pairs(userSkins[passport]) do
		if (tonumber(owned.amount) or 0) > 0 then
			local item = buildSkinItem(skinId)
			if item then
				item.selected = false
				out[#out + 1] = item
			end
		end
	end

	return out
end

local function listTradesFor(passport)
	local out = {}

	for _,trade in pairs(tradeStore) do
		if trade.proposer.id == passport or trade.otherPlayer.id == passport then
			out[#out + 1] = trade
		end
	end

	table.sort(out,function(a,b) return (a.timestamp or 0) > (b.timestamp or 0) end)
	return out
end

local function normalizeSelected(items)
	local out = {}
	if type(items) ~= "table" then return out end

	for _,item in ipairs(items) do
		if item and item.selected and item.id and skinsCache[item.id] then
			out[#out + 1] = buildSkinItem(item.id)
		end
	end

	return out
end

local function pruneTrades()
	local all = {}
	for id,trade in pairs(tradeStore) do
		all[#all + 1] = { id = id, ts = trade.timestamp or 0 }
	end

	if #all <= tradeHistoryLimit then return end

	table.sort(all,function(a,b) return a.ts < b.ts end)

	local excess = #all - tradeHistoryLimit
	for i = 1,excess do
		tradeStore[all[i].id] = nil
	end
end

local function persistTrade(trade)
	if not trade then return end

	pcall(function()
		framework.query([[
			INSERT INTO core_skins_trades
				(id, proposer_id, other_id, proposer_items, other_items, status, created_at, expires_at)
			VALUES (@id, @proposer, @other, @pitems, @oitems, @status, @created, @expires)
			ON DUPLICATE KEY UPDATE
				status = VALUES(status),
				proposer_items = VALUES(proposer_items),
				other_items = VALUES(other_items),
				expires_at = VALUES(expires_at)
		]],{
			id       = tostring(trade.id),
			proposer = tonumber(trade.proposer.id),
			other    = tonumber(trade.otherPlayer.id),
			pitems   = json.encode(trade.proposerItems or {}),
			oitems   = json.encode(trade.otherPlayerItems or {}),
			status   = tostring(trade.status or "pending"),
			created  = tonumber(trade.timestamp) or 0,
			expires  = tonumber(trade.expiresAt) or 0,
		})
	end)
end

local function broadcastTrade(trade)
	local proposerSource = framework.source(trade.proposer.id)
	local otherSource = framework.source(trade.otherPlayer.id)

	if proposerSource then
		TriggerClientEvent("core-skins:TradeUpdated",proposerSource,trade)
	end
	if otherSource then
		TriggerClientEvent("core-skins:TradeUpdated",otherSource,trade)
	end
end

local function commitTradeChange(trade)
	persistTrade(trade)
	broadcastTrade(trade)
end

local function sendTrade(proposerPassport,data)
	if not proposerPassport or type(data) ~= "table" then return nil end

	local newTrade = data.newTrade or data
	if type(newTrade) ~= "table" then return nil end

	local otherPassport = tonumber(newTrade.otherPlayer and newTrade.otherPlayer.id)
	if not otherPassport or otherPassport == proposerPassport then return nil end

	local proposerItems = normalizeSelected(newTrade.player)
	local otherItems = normalizeSelected(newTrade.otherPlayerItems)

	if #proposerItems == 0 and #otherItems == 0 then return nil end

	if not ownsAll(proposerPassport,proposerItems) then return nil end
	if not ownsAll(otherPassport,otherItems) then return nil end

	local now = nowMs()
	local id = string.format("trade-%d-%d-%d-%d",proposerPassport,otherPassport,os.time(),math.random(1000,9999))
	local trade = {
		id               = id,
		proposer         = playerCard(proposerPassport),
		otherPlayer      = playerCard(otherPassport),
		proposerItems    = proposerItems,
		otherPlayerItems = otherItems,
		status           = "pending",
		timestamp        = now,
		expiresAt        = now + (globalConfig.tradeExpireMs or 86400000),
	}

	tradeStore[id] = trade
	pruneTrades()
	persistTrade(trade)

	local proposerSource = framework.source(proposerPassport)
	local otherSource = framework.source(otherPassport)

	if proposerSource then
		TriggerClientEvent("core-skins:TradeUpdated",proposerSource,trade)
	end
	if otherSource then
		TriggerClientEvent("core-skins:TradeUpdated",otherSource,trade)
		TriggerClientEvent("core-skins:TradeProposalReceived",otherSource,trade)
	end

	return trade
end

local function acceptTrade(accepterPassport,tradeId)
	local trade = tradeStore[tradeId]
	if not trade then return nil,"trade_not_found" end
	if trade.status ~= "pending" then return nil,"trade_not_pending" end
	if trade.otherPlayer.id ~= accepterPassport then return nil,"not_accepter" end

	if trade.expiresAt and nowMs() >= trade.expiresAt then
		trade.status = "declined"
		commitTradeChange(trade)
		return nil,"trade_expired"
	end

	if not ownsAll(trade.proposer.id,trade.proposerItems) then
		trade.status = "declined"
		commitTradeChange(trade)
		return nil,"missing_skins"
	end
	if not ownsAll(trade.otherPlayer.id,trade.otherPlayerItems) then
		trade.status = "declined"
		commitTradeChange(trade)
		return nil,"missing_skins"
	end

	local proposerVoucherCost = sumVoucherCost(trade.otherPlayerItems)
	local otherVoucherCost = sumVoucherCost(trade.proposerItems)

	if getVouchers(trade.proposer.id) < proposerVoucherCost then
		trade.status = "declined"
		commitTradeChange(trade)
		return nil,"missing_vouchers"
	end
	if getVouchers(trade.otherPlayer.id) < otherVoucherCost then
		trade.status = "declined"
		commitTradeChange(trade)
		return nil,"missing_vouchers"
	end

	if proposerVoucherCost > 0 then
		removeVouchers(trade.proposer.id,proposerVoucherCost)
	end
	if otherVoucherCost > 0 then
		removeVouchers(trade.otherPlayer.id,otherVoucherCost)
	end

	for _,item in ipairs(trade.proposerItems) do
		removeSkin(trade.proposer.id,item.id,1)
		addSkin(trade.otherPlayer.id,item.id,1)
	end
	for _,item in ipairs(trade.otherPlayerItems) do
		removeSkin(trade.otherPlayer.id,item.id,1)
		addSkin(trade.proposer.id,item.id,1)
	end

	trade.status = "accepted"
	commitTradeChange(trade)
	return trade
end

local function declineTrade(declinerPassport,tradeId)
	local trade = tradeStore[tradeId]
	if not trade then return nil end
	if trade.status ~= "pending" then return nil end
	if trade.proposer.id ~= declinerPassport and trade.otherPlayer.id ~= declinerPassport then return nil end

	trade.status = "declined"
	commitTradeChange(trade)
	return trade
end

local function expireStaleTrades()
	local now = nowMs()
	local expired = {}

	for _,trade in pairs(tradeStore) do
		if trade.status == "pending" and (trade.expiresAt or 0) > 0 and now >= trade.expiresAt then
			trade.status = "declined"
			expired[#expired + 1] = trade
		end
	end

	for _,trade in ipairs(expired) do
		commitTradeChange(trade)
	end
end

local function resolveTradeId(data)
	local newTrade = data and data.newTrade
	if type(newTrade) ~= "table" then return nil end
	if newTrade.tradeId then return tostring(newTrade.tradeId) end
	if newTrade.id then return tostring(newTrade.id) end
	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(globalConfig.command,function(source)
	if source == 0 then return end

	local passport = framework.passport(source)
	if not passport then return end

	TriggerClientEvent("core-skins:Open",source)
end,false)

RegisterCommand(globalConfig.adminCommand,function(source)
	if source == 0 then return end
	if not checkStaff(source) then return end

	TriggerClientEvent("core-skins:OpenAdmin",source)
end,false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOGS
-----------------------------------------------------------------------------------------------------------------------------------------
-- coreLog manda o log pro core_logs se ele estiver rodando; senão, cai no webhook do Discord
-- (config/webhook.lua). TODAS as ações (compra, venda, caixa, aprimoramento, troca, equipar,
-- teste de arma e ações de admin) passam por aqui, então é só um ponto pra controlar tudo.
coreLog = function(category,data)
	if GetResourceState("core_logs") == "started" then
		exports["core_logs"]:AddLog(category,data)
	else
		webhooks.log(category,data)
	end
end

-- Nome completo do jogador (Nome Sobrenome) a partir do passport, ou "Desconhecido".
logPlayerName = function(passport)
	local identity = framework.identity(passport)
	return identity and (identity.Name.." "..identity.Lastname) or "Desconhecido"
end

-- Descobre quem executou uma ação de staff (nome e passport), tratando o console (source 0).
logStaffInfo = function(source)
	if source == 0 then
		return "Console",nil
	end

	local passport = framework.passport(source)
	return passport and logPlayerName(passport) or "Desconhecido",passport
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER DATA
-----------------------------------------------------------------------------------------------------------------------------------------
local function buildDurations()
	return resolveSkinDurations(nil)
end

function core.playerData()
	local source = source
	local passport = framework.passport(source)
	if not passport then return false end

	local identity = framework.identity(passport)
	local name = "Cidadão"
	if identity then
		name = (identity.Name or "") .. " " .. (identity.Lastname or "")
	end

	return {
		id                 = passport,
		name               = name,
		skinsCoins         = getSkinsCoins(passport),
		vouchers           = getVouchers(passport),
		avatar             = resolveAvatar(passport),
		improvementEnabled = improvementEnabled(),
		durations          = buildDurations(),
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CASES
-----------------------------------------------------------------------------------------------------------------------------------------
function core.cases()
	local source = source
	local passport = framework.passport(source)
	return buildCasesList(passport)
end

function core.caseContents(data)
	local id = data and data.caseId
	if not id then return {} end
	return buildCaseContents(id)
end

function core.openCase(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return false end

	local caseId = data and data.caseId
	local case = findCase(caseId)
	if not case then return false end

	if case.permission and not framework.hasPermission(passport,case.permission) then
		notify(source,"vermelho",globalConfig.language.noPermission)
		return false
	end

	local cooldownSeconds = tonumber(case.cooldownSeconds) or 0
	if case.free and cooldownSeconds > 0 then
		local last = lastDailyOpen(passport,case.id)
		if last > 0 and (nowMs() - last) < (cooldownSeconds * 1000) then
			notify(source,"vermelho",globalConfig.language.cooldownActive)
			return false
		end
	end

	local price = tonumber(case.price) or 0
	if price > 0 then
		if not removeSkinsCoins(passport,price) then
			notify(source,"vermelho",globalConfig.language.insufficientSkinsCoins)
			return false
		end
	end

	local reward = rollItem(case.items)
	if not reward then
		if price > 0 then giveSkinsCoins(passport,price) end
		return false
	end

	addSkin(passport,reward.id,1,reward.durationDays)

	if case.free and cooldownSeconds > 0 then
		setLastDailyOpen(passport,case.id,nowMs())
	end

	pcall(function()
		framework.query([[
			INSERT INTO core_skins_wins (passport, skinId, caseId, rarity)
			VALUES (@passport, @skinId, @caseId, @rarity)
		]],{
			passport = passport,
			skinId   = tostring(reward.id),
			caseId   = tostring(case.id),
			rarity   = tostring(reward.rarity or ""),
		})
	end)

	local win = {
		id     = tostring(passport).."-"..tostring(reward.id).."-"..tostring(os.time()),
		name   = reward.name,
		player = playerName(passport),
		image  = reward.image,
		rarity = resolveRarity(reward.rarity),
		source = "case",
	}
	pushWin(win)
	TriggerClientEvent("core-skins:NewWin",-1,win)

	coreLog("CASE_WIN",{
		message    = logPlayerName(passport).." #"..passport.." ganhou "..reward.name.." ("..resolveRarity(reward.rarity)..") na caixa "..case.name..((price > 0) and (" (custo "..price.." SkinsCoins)") or " (grátis)"),
		playerName = logPlayerName(passport),
		playerId   = passport,
		caseName   = case.name,
		caseId     = case.id,
		skin       = reward.name,
		skinId     = reward.id,
		rarity     = resolveRarity(reward.rarity),
		price      = price,
	})

	return {
		skin = {
			model_name   = reward.id,
			name         = reward.name,
			rarity       = resolveRarity(reward.rarity),
			value        = tonumber(reward.price) or 0,
			image        = reward.image,
			durationDays = reward.durationDays,
		},
		skinsCoins = getSkinsCoins(passport),
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function core.inventory()
	local source = source
	local passport = framework.passport(source)
	if not passport then return {} end
	return buildInventory(passport)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LAST WINS
-----------------------------------------------------------------------------------------------------------------------------------------
function core.lastWins()
	local out = {}
	for i,win in ipairs(lastWins) do out[i] = win end
	return out
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EQUIP / UNEQUIP
-----------------------------------------------------------------------------------------------------------------------------------------
function core.equip(data)
	local source = source
	local passport = framework.passport(source)
	local skinId = data and data.modelName
	if not passport or not skinId then return false end

	local skin = skinsCache[skinId]
	if not skin then return false end

	local owned = userSkins[passport] and userSkins[passport][skinId]
	if not owned then return false end

	if not owned.equipped then
		equipSkin(passport,skinId)
	end

	notify(source,"verde",string.format(globalConfig.language.equippedSuccess,skin.name))

	coreLog("SKIN_EQUIP",{
		message    = logPlayerName(passport).." #"..passport.." equipou "..skin.name,
		playerName = logPlayerName(passport),
		playerId   = passport,
		skin       = skin.name,
		skinId     = skinId,
		action     = "equip",
	})

	return true
end

function core.unequip(data)
	local source = source
	local passport = framework.passport(source)
	local skinId = data and data.modelName
	if not passport or not skinId then return false end

	local skin = skinsCache[skinId]
	if not skin then return false end

	local owned = userSkins[passport] and userSkins[passport][skinId]
	if not owned or not owned.equipped then return false end

	equipSkin(passport,skinId)
	notify(source,"verde",string.format(globalConfig.language.unequippedSuccess,skin.name))

	coreLog("SKIN_EQUIP",{
		message    = logPlayerName(passport).." #"..passport.." desequipou "..skin.name,
		playerName = logPlayerName(passport),
		playerId   = passport,
		skin       = skin.name,
		skinId     = skinId,
		action     = "unequip",
	})

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SELL
-----------------------------------------------------------------------------------------------------------------------------------------
function core.sell(data)
	local source = source
	local passport = framework.passport(source)
	local skinId = data and data.modelName
	if not passport or not skinId then return false end

	local skin = skinsCache[skinId]
	if not skin then return false end

	if (tonumber(skin.price) or 0) <= 0 then
		notify(source,"vermelho",globalConfig.language.noPriceForSell)
		return false
	end

	local sellValue = math.floor((tonumber(skin.price) or 0) / 2)

	if not removeSkin(passport,skinId,1) then return false end

	giveSkinsCoins(passport,sellValue)
	notify(source,"verde",string.format(globalConfig.language.sellSuccess,skin.name,sellValue))

	coreLog("SKIN_SELL",{
		message    = logPlayerName(passport).." #"..passport.." vendeu "..skin.name.." por "..sellValue.." SkinsCoins",
		playerName = logPlayerName(passport),
		playerId   = passport,
		skin       = skin.name,
		skinId     = skinId,
		value      = sellValue,
	})

	return { skinsCoins = getSkinsCoins(passport) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PURCHASE
-----------------------------------------------------------------------------------------------------------------------------------------
function core.purchase(data)
	local source = source
	local passport = framework.passport(source)
	local skinId = data and data.modelName
	if not passport or not skinId then return false end

	local skin = skinsCache[skinId]
	if not skin then return false end

	local basePrice = tonumber(skin.price) or 0
	if basePrice <= 0 then
		notify(source,"vermelho",globalConfig.language.noPriceForBuy)
		return false
	end

	local options = resolveSkinDurations(skin.cfg)
	local durationId = data and data.durationId
	local option

	if durationId == nil then
		for _,o in ipairs(options) do
			if (tonumber(o.days) or 0) <= 0 then option = o break end
		end
	else
		for _,o in ipairs(options) do
			if o.id == durationId then option = o break end
		end
	end

	if not option then
		notify(source,"vermelho",globalConfig.language.invalidDuration)
		return false
	end

	local days  = tonumber(option.days) or 0
	local price = (option.price ~= nil) and (tonumber(option.price) or 0) or basePrice

	if price <= 0 then
		notify(source,"vermelho",globalConfig.language.noPriceForBuy)
		return false
	end

	if getSkinsCoins(passport) < price then
		notify(source,"vermelho",globalConfig.language.insufficientSkinsCoinsBuy)
		return false
	end

	if not removeSkinsCoins(passport,price) then
		notify(source,"vermelho",globalConfig.language.insufficientSkinsCoinsBuy)
		return false
	end

	addSkin(passport,skinId,1,days)

	if days > 0 then
		notify(source,"verde",string.format(globalConfig.language.buyTempSuccess,skin.name,days,price))
	else
		notify(source,"verde",string.format(globalConfig.language.buySuccess,skin.name,price))
	end

	coreLog("SKIN_PURCHASE",{
		message    = logPlayerName(passport).." #"..passport.." comprou "..skin.name..((days > 0) and (" por "..days.." dias") or " (permanente)").." por "..price.." SkinsCoins",
		playerName = logPlayerName(passport),
		playerId   = passport,
		skin       = skin.name,
		skinId     = skinId,
		days       = days,
		price      = price,
	})

	return { skinsCoins = getSkinsCoins(passport) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COSMETIC
-----------------------------------------------------------------------------------------------------------------------------------------
function core.logo()
	return globalConfig.logoUrl or ""
end

function core.banner()
	return globalConfig.bannerUrl or ""
end

function core.skinCoinsShopUrl()
	return globalConfig.skinCoinsShopUrl or ""
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRADES
-----------------------------------------------------------------------------------------------------------------------------------------
function core.tradesList()
	local source = source
	local passport = framework.passport(source)
	if not passport then return {} end
	return listTradesFor(passport)
end

function core.tradesPlayersById(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return {} end

	local target = tonumber(data and data.id)
	if not target or target == passport then return {} end

	local targetSource = framework.source(target)
	if not targetSource then return {} end

	return { playerCard(target) }
end

function core.tradesPlayersData(data)
	local source = source
	local passport = framework.passport(source)
	local target = tonumber(data and data.id)
	if not passport or not target or target == passport then return false end

	local targetSource = framework.source(target)
	if not targetSource then return false end

	return {
		player           = inventoryFlat(passport),
		otherPlayerItems = inventoryFlat(target),
		otherPlayer      = playerCard(target),
		playerData       = playerCard(passport),
	}
end

function core.tradesSend(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return { success = false, vouchers = 0 } end

	local trade = sendTrade(passport,data)
	if not trade then return { success = false, vouchers = getVouchers(passport) } end

	coreLog("TRADE_SENT",{
		message  = trade.proposer.name.." #"..trade.proposer.id.." enviou uma proposta de troca para "..trade.otherPlayer.name.." #"..trade.otherPlayer.id,
		fromName = trade.proposer.name,
		fromId   = trade.proposer.id,
		toName   = trade.otherPlayer.name,
		toId     = trade.otherPlayer.id,
		tradeId  = trade.id,
	})

	notify(source,"verde",globalConfig.language.tradeProposalSent)
	return { success = true, vouchers = getVouchers(passport) }
end

function core.tradesAccept(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return { success = false, vouchers = 0 } end

	local tradeId = resolveTradeId(data)
	if not tradeId then return { success = false, vouchers = getVouchers(passport) } end

	local trade,reason = acceptTrade(passport,tradeId)
	if not trade then
		if reason == "trade_expired" then
			notify(source,"vermelho",globalConfig.language.tradeExpired)
		elseif reason == "missing_skins" then
			notify(source,"vermelho",globalConfig.language.tradeMissingSkins)
		elseif reason == "missing_vouchers" then
			notify(source,"vermelho",globalConfig.language.tradeMissingVouchers)
		end
		return { success = false, vouchers = getVouchers(passport) }
	end

	coreLog("TRADE_ACCEPTED",{
		message  = trade.otherPlayer.name.." #"..trade.otherPlayer.id.." aceitou a troca de "..trade.proposer.name.." #"..trade.proposer.id,
		fromName = trade.proposer.name,
		fromId   = trade.proposer.id,
		toName   = trade.otherPlayer.name,
		toId     = trade.otherPlayer.id,
		tradeId  = trade.id,
	})

	notify(source,"verde",globalConfig.language.tradeAccepted)
	return { success = true, vouchers = getVouchers(passport) }
end

function core.tradesDecline(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return { success = false, vouchers = 0 } end

	local tradeId = resolveTradeId(data)
	if not tradeId then return { success = false, vouchers = getVouchers(passport) } end

	local trade = declineTrade(passport,tradeId)
	if not trade then return { success = false, vouchers = getVouchers(passport) } end

	coreLog("TRADE_DECLINED",{
		message  = logPlayerName(passport).." #"..passport.." recusou a troca entre "..trade.proposer.name.." #"..trade.proposer.id.." e "..trade.otherPlayer.name.." #"..trade.otherPlayer.id,
		fromName = trade.proposer.name,
		fromId   = trade.proposer.id,
		toName   = trade.otherPlayer.name,
		toId     = trade.otherPlayer.id,
		tradeId  = trade.id,
	})

	notify(source,"amarelo",globalConfig.language.tradeDeclined)
	return { success = true, vouchers = getVouchers(passport) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- IMPROVEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function core.improvementData()
	local source = source
	local passport = framework.passport(source)
	if not passport then return false end
	if not improvementEnabled() then return false end

	return {
		playerSkins = buildImprovementPlayerInventory(passport),
		serverSkins = buildImprovementServerCatalog(),
		config = {
			chanceExponent    = globalConfig.improvement.chanceExponent,
			minChance         = globalConfig.improvement.minChance,
			minTargetMarkup   = globalConfig.improvement.minTargetMarkup,
			maxTargetMarkup   = globalConfig.improvement.maxTargetMarkup,
			requirePlayerSkin = globalConfig.improvement.requirePlayerSkin or false,
		},
	}
end

function core.improvementSkinChance(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return globalConfig.improvement.minChance end
	if not improvementEnabled() then return globalConfig.improvement.minChance end
	if type(data) ~= "table" then return globalConfig.improvement.minChance end

	local target = data.skin
	local targetId = target and target.model_name
	local targetSkin = targetId and skinsCache[targetId]
	if not targetSkin then return globalConfig.improvement.minChance end

	local ok,inputValue = validateImprovementSelection(passport,data.selectedPlayerSkins or {})
	if not ok then return globalConfig.improvement.minChance end

	local balance = math.max(0,math.floor(tonumber(data.balance) or 0))
	local targetValue = tonumber(targetSkin.price) or 0
	local total = inputValue + balance

	if not targetMarkupOk(total,targetValue) then return globalConfig.improvement.minChance end

	return improvementChance(total,targetValue)
end

function core.rankingByPeriod(data)
	local period = (data and tostring(data.period or "all")) or "all"
	if not rankingPeriodFilter[period] then period = "all" end
	return buildRanking(period)
end

local activeWeaponTests = {}

local function weaponTestBucketFor(source)
	return source + (globalConfig.weaponTest.bucketOffset or 75000)
end

function core.weaponTestStart(data)
	if globalConfig.weaponTest.enabled == false then return false end
	local source = source
	local passport = framework.passport(source)
	if not passport then return false end
	if type(data) ~= "table" then return false end

	local skinId = data.modelName
	local skin = skinId and skinsCache[skinId]
	if not skin or not skin.cfg or not skin.cfg.data or not skin.cfg.data.weapon then
		notify(source,"vermelho",globalConfig.language.weaponTestInvalid)
		return false
	end

	activeWeaponTests[source] = skin.cfg.data.weapon
	SetPlayerRoutingBucket(source,weaponTestBucketFor(source))

	TriggerClientEvent("core-skins:StartWeaponTest",source,{
		weapon    = skin.cfg.data.weapon,
		component = skin.cfg.data.component,
		clip      = skin.cfg.data.clip,
	})

	coreLog("WEAPON_TEST",{
		message    = logPlayerName(passport).." #"..passport.." iniciou o teste da skin "..skin.name,
		playerName = logPlayerName(passport),
		playerId   = passport,
		skin       = skin.name,
		skinId     = skinId,
	})

	return true
end

function core.improvementImprove(data)
	local source = source
	local passport = framework.passport(source)
	if not passport then return { success = false } end
	if type(data) ~= "table" then return { success = false } end
	if not improvementEnabled() then
		notify(source,"vermelho",globalConfig.language.improvementDisabled)
		return { success = false }
	end

	local target = data.selectedServerSkin
	local targetId = target and target.model_name
	local targetSkin = targetId and skinsCache[targetId]
	if not targetSkin then
		notify(source,"vermelho",globalConfig.language.improvementNoTarget)
		return { success = false }
	end

	local selected = data.selectedPlayerSkins or {}

	if globalConfig.improvement.requirePlayerSkin and #selected < 1 then
		notify(source,"vermelho",globalConfig.language.improvementNoPlayerSkin)
		return { success = false }
	end

	local ok,inputValue = validateImprovementSelection(passport,selected)
	if not ok then
		notify(source,"vermelho",globalConfig.language.improvementInvalid)
		return { success = false }
	end

	local balance = math.max(0,math.floor(tonumber(data.balance) or 0))
	local targetValue = tonumber(targetSkin.price) or 0
	local total = inputValue + balance

	if not targetMarkupOk(total,targetValue) then
		notify(source,"vermelho",globalConfig.language.improvementInvalidTarget)
		return { success = false }
	end

	if balance > 0 then
		if not removeSkinsCoins(passport,balance) then
			notify(source,"vermelho",globalConfig.language.improvementInsufficientSkinsCoins)
			return { success = false }
		end
	end

	for _,entry in ipairs(selected) do
		removeSkin(passport,entry.model_name,1)
	end

	local chance = improvementChance(total,targetValue)
	local roll = math.random() * 100
	local success = roll <= chance

	if success then
		addSkin(passport,targetId,1)
		notify(source,"verde",string.format(globalConfig.language.improvementSuccess,targetSkin.name))
	else
		notify(source,"amarelo",globalConfig.language.improvementFailed)
	end

	coreLog("IMPROVEMENT",{
		message    = logPlayerName(passport).." #"..passport..(success and " APRIMOROU com sucesso e recebeu " or " FALHOU o aprimoramento mirando ")..targetSkin.name.." (chance "..chance.."%, "..#selected.." skin(s)"..((balance > 0) and (" + "..balance.." SkinsCoins") or "")..")",
		playerName = logPlayerName(passport),
		playerId   = passport,
		result     = success and "sucesso" or "falha",
		target     = targetSkin.name,
		targetId   = targetId,
		chance     = chance,
		inputSkins = #selected,
		balance    = balance,
	})

	return {
		success     = success,
		chance      = chance,
		playerSkins = buildImprovementPlayerInventory(passport),
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CURRENCY COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
local function registerCurrencyCommands(label,suffix,get,set,give,remove)
	RegisterCommand("addskin"..suffix,function(source,args)
		if not checkStaff(source) then return end

		local target = tonumber(args and args[1])
		local amount = tonumber(args and args[2])
		if not target or not amount or amount <= 0 then
			notifyOrPrint(source,"vermelho","Uso: /addskin"..suffix.." <passport> <amount>")
			return
		end

		if give(target,amount) then
			notifyOrPrint(source,"verde","Adicionado <b>"..amount.."</b> "..label.." ao passport <b>"..target.."</b>. Total: "..get(target))

			local adminName,adminPassport = logStaffInfo(source)
			coreLog(string.upper("addskin"..suffix),{
				message = adminName..(adminPassport and " #"..adminPassport or "").." adicionou "..amount.."x "..label.." para "..logPlayerName(target).." #"..target,
				adminName = adminName,
				adminId = adminPassport,
				playerName = logPlayerName(target),
				playerId = target,
				quantidade = amount,
				saldoNovo = get(target),
				moeda = label
			})
		else
			notifyOrPrint(source,"vermelho","Falha ao adicionar "..label..".")
		end
	end,false)

	RegisterCommand("remskin"..suffix,function(source,args)
		if not checkStaff(source) then return end

		local target = tonumber(args and args[1])
		local amount = tonumber(args and args[2])
		if not target or not amount or amount <= 0 then
			notifyOrPrint(source,"vermelho","Uso: /remskin"..suffix.." <passport> <amount>")
			return
		end

		if remove(target,amount) then
			notifyOrPrint(source,"verde","Removido <b>"..amount.."</b> "..label.." do passport <b>"..target.."</b>. Total: "..get(target))

			local adminName,adminPassport = logStaffInfo(source)
			coreLog(string.upper("remskin"..suffix),{
				message = adminName..(adminPassport and " #"..adminPassport or "").." removeu "..amount.."x "..label.." de "..logPlayerName(target).." #"..target,
				adminName = adminName,
				adminId = adminPassport,
				playerName = logPlayerName(target),
				playerId = target,
				quantidade = amount,
				saldoNovo = get(target),
				moeda = label
			})
		else
			notifyOrPrint(source,"vermelho","Passport sem saldo suficiente de "..label..".")
		end
	end,false)

	RegisterCommand("setskin"..suffix,function(source,args)
		if not checkStaff(source) then return end

		local target = tonumber(args and args[1])
		local amount = tonumber(args and args[2])
		if not target or amount == nil or amount < 0 then
			notifyOrPrint(source,"vermelho","Uso: /setskin"..suffix.." <passport> <amount>")
			return
		end

		if set(target,amount) then
			notifyOrPrint(source,"verde","Saldo de "..label.." do passport <b>"..target.."</b> definido em <b>"..amount.."</b>.")

			local adminName,adminPassport = logStaffInfo(source)
			coreLog(string.upper("setskin"..suffix),{
				message = adminName..(adminPassport and " #"..adminPassport or "").." definiu o saldo de "..label.." de "..logPlayerName(target).." #"..target.." para "..amount,
				adminName = adminName,
				adminId = adminPassport,
				playerName = logPlayerName(target),
				playerId = target,
				quantidade = amount,
				moeda = label
			})
		end
	end,false)

	RegisterCommand("checkskin"..suffix,function(source,args)
		if not checkStaff(source) then return end

		local target = tonumber(args and args[1])
		if not target then
			notifyOrPrint(source,"vermelho","Uso: /checkskin"..suffix.." <passport>")
			return
		end

		notifyOrPrint(source,"amarelo","Passport <b>"..target.."</b> possui <b>"..get(target).."</b> "..label..".")
	end,false)
end

if not globalConfig.useFrameworkCoins then
	registerCurrencyCommands("SkinsCoins","scoin",getSkinsCoins,setSkinsCoins,giveSkinsCoins,removeSkinsCoins)
end

registerCurrencyCommands("Vouchers","voucher",getVouchers,setVouchers,giveVouchers,removeVouchers)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN PANEL
-----------------------------------------------------------------------------------------------------------------------------------------
local function adminOnline(passport)
	return framework.source(passport) and true or false
end

local function buildAdminSkins(passport)
	local out = {}
	local data = userSkins[passport]
	if not data then return out end

	for skinId,owned in pairs(data) do
		local skin = skinsCache[skinId]
		if skin and (tonumber(owned.amount) or 0) > 0 then
			out[#out + 1] = {
				model_name = skinId,
				name       = skin.name,
				image      = skin.image,
				rarity     = resolveRarity(skin.rarity),
				weapon     = skin.weaponId,
				quantity   = tonumber(owned.amount) or 1,
				equipped   = owned.equipped or false,
				price      = tonumber(skin.price) or 0,
			}
		end
	end

	return out
end

local function buildAdminPlayer(passport)
	local identity = framework.identity(passport)
	if not identity then return false end

	local skins_ = buildAdminSkins(passport)
	local quantity,value = 0,0
	for _,skin in ipairs(skins_) do
		quantity = quantity + skin.quantity
		value = value + (skin.price * skin.quantity)
	end

	local boxes = 0
	local ok,rows = pcall(function()
		return framework.query("SELECT COUNT(*) AS total FROM core_skins_wins WHERE passport = ?",{ passport })
	end)
	if ok and type(rows) == "table" and rows[1] then
		boxes = tonumber(rows[1].total) or 0
	end

	return {
		id                = passport,
		name              = (identity.Name or "").." "..(identity.Lastname or ""),
		avatar            = framework.avatar(passport),
		online            = adminOnline(passport),
		useFrameworkCoins = globalConfig.useFrameworkCoins and true or false,
		skinsCoins        = globalConfig.useFrameworkCoins and 0 or getSkinsCoins(passport),
		vouchers          = getVouchers(passport),
		skins             = skins_,
		stats             = {
			skinsDistinct   = #skins_,
			skinsTotal      = quantity,
			boxesOpened     = boxes,
			collectionValue = value,
		},
	}
end

local function adminLog(source,category,passport,message,extra)
	local adminName,adminPassport = logStaffInfo(source)
	local data = {
		message    = adminName..(adminPassport and " #"..adminPassport or "").." "..message,
		adminName  = adminName,
		adminId    = adminPassport,
		playerName = passport and logPlayerName(passport) or nil,
		playerId   = passport,
	}
	if type(extra) == "table" then
		for key,val in pairs(extra) do data[key] = val end
	end
	coreLog(category,data)
end

function core.adminSearch(data)
	local source = source
	if not checkStaff(source) then return false end

	local term = data and data.term
	term = type(term) == "string" and term:gsub("^%s+",""):gsub("%s+$","") or ""
	local out = {}

	if term == "" then
		for _,src in ipairs(GetPlayers()) do
			local passport = framework.passport(tonumber(src))
			if passport then
				local identity = framework.identity(passport)
				out[#out + 1] = {
					id     = passport,
					name   = identity and ((identity.Name or "").." "..(identity.Lastname or "")) or ("Cidadão #"..passport),
					avatar = framework.avatar(passport),
					online = true,
				}
			end
		end
		return out
	end

	local rows
	local asId = tonumber(term)
	if asId then
		rows = framework.query("SELECT id, Name, Lastname FROM characters WHERE Deleted = 0 AND id = ? LIMIT 30",{ asId })
	else
		rows = framework.query("SELECT id, Name, Lastname FROM characters WHERE Deleted = 0 AND CONCAT(Name,' ',Lastname) LIKE ? ORDER BY Name LIMIT 30",{ "%"..term.."%" })
	end

	for _,row in ipairs(rows or {}) do
		local passport = tonumber(row.id)
		out[#out + 1] = {
			id     = passport,
			name   = (row.Name or "").." "..(row.Lastname or ""),
			avatar = framework.avatar(passport),
			online = adminOnline(passport),
		}
	end

	return out
end

function core.adminPlayer(data)
	local source = source
	if not checkStaff(source) then return false end

	local passport = tonumber(data and data.passport)
	if not passport then return false end

	return buildAdminPlayer(passport)
end

function core.adminCatalogue()
	local source = source
	if not checkStaff(source) then return false end

	local out = {}
	for _,weapon in ipairs(globalConfig.weapons or {}) do
		local category = { id = weapon.id, name = weapon.name, skins = {} }
		for _,skin in ipairs(weapon.skins or {}) do
			category.skins[#category.skins + 1] = {
				model_name = skin.id,
				name       = skin.name,
				image      = skin.image,
				rarity     = resolveRarity(skin.rarity),
				price      = tonumber(skin.price) or 0,
			}
		end
		out[#out + 1] = category
	end

	return out
end

function core.adminCurrency(data)
	local source = source
	if not checkStaff(source) then return false end

	local passport = tonumber(data and data.passport)
	local currency = data and data.currency
	local op = data and data.op
	local amount = math.floor(tonumber(data and data.amount) or 0)
	if not passport or amount < 0 then return false end
	if not framework.identity(passport) then return false end

	local isCoins = currency == "coins"
	if isCoins and globalConfig.useFrameworkCoins then return false end

	local get    = isCoins and getSkinsCoins or getVouchers
	local set    = isCoins and setSkinsCoins or setVouchers
	local give   = isCoins and giveSkinsCoins or giveVouchers
	local remove = isCoins and removeSkinsCoins or removeVouchers
	local label  = isCoins and "SkinsCoins" or "Vouchers"

	local ok = false
	if op == "give" then ok = give(passport,amount)
	elseif op == "remove" then ok = remove(passport,amount)
	elseif op == "set" then ok = set(passport,amount) end
	if not ok then return false end

	local targetSource = framework.source(passport)
	if targetSource then notify(targetSource,"verde","Um administrador ajustou seu saldo de "..label..".") end

	adminLog(source,"SKINSADM_CURRENCY",passport,tostring(op).." "..amount.." "..label.." -> "..logPlayerName(passport).." #"..passport,{
		moeda = label, operacao = op, quantidade = amount, saldoNovo = get(passport),
	})

	return buildAdminPlayer(passport)
end

function core.adminGiveSkin(data)
	local source = source
	if not checkStaff(source) then return false end

	local passport = tonumber(data and data.passport)
	local skinId = data and data.skinId
	local amount = math.floor(tonumber(data and data.amount) or 1)
	local days = math.floor(tonumber(data and data.days) or 0)
	if not passport or not skinId or amount <= 0 then return false end
	if not framework.identity(passport) then return false end

	local skin = skinsCache[skinId]
	if not skin then return false end
	if not addSkin(passport,skinId,amount,days) then return false end

	local targetSource = framework.source(passport)
	if targetSource then notify(targetSource,"verde","Você recebeu a skin "..skin.name..((days > 0) and (" por "..days.." dias") or "")..".") end

	adminLog(source,"SKINSADM_GIVESKIN",passport,"deu "..amount.."x "..skin.name..((days > 0) and (" ("..days.."d)") or "").." -> "..logPlayerName(passport).." #"..passport,{
		skin = skin.name, skinId = skinId, quantidade = amount, dias = (days > 0) and days or nil,
	})

	return buildAdminPlayer(passport)
end

function core.adminRemoveSkin(data)
	local source = source
	if not checkStaff(source) then return false end

	local passport = tonumber(data and data.passport)
	local skinId = data and data.skinId
	if not passport or not skinId then return false end

	local owned = userSkins[passport] and userSkins[passport][skinId]
	if not owned then return false end

	local amount = math.floor(tonumber(data and data.amount) or 0)
	if amount <= 0 then amount = tonumber(owned.amount) or 1 end

	local skin = skinsCache[skinId]
	if not removeSkin(passport,skinId,amount) then return false end

	adminLog(source,"SKINSADM_REMOVESKIN",passport,"removeu "..amount.."x "..((skin and skin.name) or skinId).." de "..logPlayerName(passport).." #"..passport,{
		skin = (skin and skin.name) or skinId, skinId = skinId, quantidade = amount,
	})

	return buildAdminPlayer(passport)
end

function core.adminWipeSkins(data)
	local source = source
	if not checkStaff(source) then return false end

	local passport = tonumber(data and data.passport)
	if not passport then return false end

	ensureUser(passport)
	local ids = {}
	for skinId in pairs(userSkins[passport] or {}) do ids[#ids + 1] = skinId end
	for _,skinId in ipairs(ids) do removeSkin(passport,skinId,1000000000) end

	adminLog(source,"SKINSADM_WIPE",passport,"zerou as skins de "..logPlayerName(passport).." #"..passport,{
		removidas = #ids,
	})

	return buildAdminPlayer(passport)
end

function core.adminGiveSkinAllOnline(data)
	local source = source
	if not checkStaff(source) then return false end

	local skinId = data and data.skinId
	local amount = math.floor(tonumber(data and data.amount) or 1)
	if not skinId or amount <= 0 then return false end

	local skin = skinsCache[skinId]
	if not skin then return false end

	local count = 0
	for _,src in ipairs(GetPlayers()) do
		local target = tonumber(src)
		local passport = framework.passport(target)
		if passport and addSkin(passport,skinId,amount) then
			count = count + 1
			notify(target,"verde","Você recebeu a skin "..skin.name..".")
		end
	end

	adminLog(source,"SKINSADM_GIVEALL",nil,"deu "..amount.."x "..skin.name.." para "..count.." jogador(es) online",{
		skin = skin.name, skinId = skinId, quantidade = amount, jogadores = count,
	})

	return { count = count }
end

function core.adminGiveAllSkins(data)
	local source = source
	if not checkStaff(source) then return false end

	local passport = tonumber(data and data.passport)
	if not passport then return false end
	if not framework.identity(passport) then return false end

	local count = 0
	for skinId in pairs(skinsCache) do
		if addSkin(passport,skinId,1) then count = count + 1 end
	end

	local targetSource = framework.source(passport)
	if targetSource then notify(targetSource,"verde","Você recebeu todas as skins disponíveis.") end

	adminLog(source,"SKINSADM_GIVEALLSKINS",passport,"entregou todas as skins ("..count..") para "..logPlayerName(passport).." #"..passport,{
		quantidade = count,
	})

	return { count = count, player = buildAdminPlayer(passport) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVEALL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("giveallskins",function(source,args)
	if not checkStaff(source) then return end

	local target = tonumber(args and args[1])
	if not target then
		notifyOrPrint(source,"vermelho","Uso: /giveallskins <passport>")
		return
	end

	local count = 0
	for skinId in pairs(skinsCache) do
		if addSkin(target,skinId,1) then
			count = count + 1
		end
	end

	notifyOrPrint(source,"verde","Foram entregues <b>"..count.."</b> skins ao passport <b>"..target.."</b>.")

	local adminName,adminPassport = logStaffInfo(source)
	coreLog("GIVEALLSKINS",{
		message = adminName..(adminPassport and " #"..adminPassport or "").." entregou todas as skins ("..count..") para "..logPlayerName(target).." #"..target,
		adminName = adminName,
		adminId = adminPassport,
		playerName = logPlayerName(target),
		playerId = target,
		quantidade = count
	})
end,false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPON TEST END
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("core-skins:WeaponTestEnded")
AddEventHandler("core-skins:WeaponTestEnded",function()
	local source = source
	local passport = framework.passport(source)
	if not passport then return end

	if activeWeaponTests[source] then
		if GetResourceState("PL_PROTECT") == "started" then exports['PL_PROTECT']:removeWeapons(source) end
		SetPlayerRoutingBucket(source,0)
		activeWeaponTests[source] = nil
	end

	TriggerEvent("vRP:ReloadWeapons",source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPON TEST GIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("core-skins:WeaponTestGive")
AddEventHandler("core-skins:WeaponTestGive",function()
	local source = source
	local weapon = activeWeaponTests[source]
	if not weapon then return end

	if GetResourceState("PL_PROTECT") == "started" then exports['PL_PROTECT']:giveWeapons(source,{ [weapon] = { ammo = globalConfig.weaponTest.ammo or 250, isHidden = false, bForceInHand = true } }) end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPON TEST AMMO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("core-skins:WeaponTestAmmo")
AddEventHandler("core-skins:WeaponTestAmmo",function()
	local source = source
	local weapon = activeWeaponTests[source]
	if not weapon then return end

	if GetResourceState("PL_PROTECT") == "started" then exports['PL_PROTECT']:addAmmo(source,"SetPedAmmo",weapon,globalConfig.weaponTest.ammo or 250) end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLY COMPONENT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("core-skins:TryApplyComponent")
AddEventHandler("core-skins:TryApplyComponent",function(weaponName)
	local source = source
	local passport = framework.passport(source)
	if not passport or not weaponName then return end

	local equipped = findEquippedByWeapon(passport,weaponName)
	if not equipped then return end

	local skin = skinsCache[equipped]
	if not skin or not skin.cfg or not skin.cfg.data then return end
	if skin.cfg.modType == "modWeapon" then return end

	local real = skin.cfg.data.weapon
	if skin.cfg.data.component then
		TriggerClientEvent("core-skins:ApplyComponent",source,real,skin.cfg.data.component)
	end
	if skin.cfg.data.clip then
		TriggerClientEvent("core-skins:ApplyComponent",source,real,skin.cfg.data.clip)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function()
	local source = source
	local passport = framework.passport(source)
	if passport then
		skinsCoinsCache[passport] = nil
		vouchersCache[passport] = nil
		avatarCache[passport] = nil
		dailyOpensCache[passport] = nil
	end
	activeWeaponTests[source] = nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(resource)
	if resource ~= GetCurrentResourceName() then return end

	for src in pairs(activeWeaponTests) do
		pcall(SetPlayerRoutingBucket,src,0)
	end
	activeWeaponTests = {}
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CACHE
-----------------------------------------------------------------------------------------------------------------------------------------
local function initializeCache()
	print("\27[33m[core-skins]\27[0m Iniciando cache de skins...")

	local rows = framework.query("SELECT passport, skinId, weaponId, equipped, amount, expires_at FROM core_skins_inventory") or {}

	local now = nowMs()

	for _,row in ipairs(rows) do
		local passport = tonumber(row.passport)
		local skinId   = tostring(row.skinId or "")
		local weaponId = tostring(row.weaponId or "")
		local amount   = tonumber(row.amount) or 1
		local expiry   = tonumber(row.expires_at)

		if amount < 1 then amount = 1 end

		if passport and skinId ~= "" and weaponId ~= "" then
			if expiry and expiry <= now then
				pcall(Query,"DELETE FROM core_skins_inventory WHERE passport = ? AND skinId = ?",{ passport,skinId })
			else
				userSkins[passport] = userSkins[passport] or {}
				local isEquipped = (tonumber(row.equipped) == 1)
				userSkins[passport][skinId] = {
					weaponId = weaponId,
					equipped = isEquipped,
					amount   = amount,
					expiresAt = expiry,
				}
				if isEquipped then indexEquip(passport,skinId,true) end
				if expiry then indexTemp(passport,skinId,expiry) end
			end
		end
	end

	for _,weapon in ipairs(globalConfig.weapons or {}) do
		for _,skin in ipairs(weapon.skins or {}) do
			skinsCache[skin.id] = {
				id       = skin.id,
				index    = skin.id,
				name     = skin.name,
				image    = skin.image,
				chance   = skin.chance,
				rarity   = skin.rarity,
				weaponId = weapon.id,
				price    = skin.price,
				cfg      = skin,
			}
		end
	end

	for _,case in ipairs(globalConfig.cases or {}) do
		local built = {
			id              = case.id,
			name            = case.name,
			price           = case.price or 0,
			originalPrice   = case.originalPrice,
			image           = case.image,
			badge           = case.badge,
			free            = case.free or false,
			availableIn     = case.availableIn or 0,
			cooldownSeconds = case.cooldownSeconds or 0,
			permission      = case.permission,
			items           = {},
		}

		for _,item in ipairs(case.skins or {}) do
			local skin = skinsCache[item.id]
			if skin then
				local entry = skin
				if item.durationDays then
					entry = {}
					for k,v in pairs(skin) do entry[k] = v end
					entry.durationDays = tonumber(item.durationDays)
				end
				built.items[#built.items + 1] = entry
			end
		end

		casesData[#casesData + 1] = built
	end

	print("\27[32m[core-skins]\27[0m Cache de skins finalizado. "..(#casesData).." caixas, "..hashSize(skinsCache).." skins.")
end

local function initializeTrades()
	local now = nowMs()

	pcall(Query,"UPDATE core_skins_trades SET status = 'declined' WHERE status = 'pending' AND expires_at <= ?",{ now })

	local rows = framework.query("SELECT id, proposer_id, other_id, proposer_items, other_items, status, created_at, expires_at FROM core_skins_trades WHERE status = 'pending'") or {}

	local loaded = 0
	for _,row in ipairs(rows) do
		local proposerId = tonumber(row.proposer_id)
		local otherId = tonumber(row.other_id)
		if proposerId and otherId then
			local pItems = (type(row.proposer_items) == "string") and json.decode(row.proposer_items) or row.proposer_items
			local oItems = (type(row.other_items) == "string") and json.decode(row.other_items) or row.other_items

			tradeStore[row.id] = {
				id               = row.id,
				proposer         = playerCard(proposerId),
				otherPlayer      = playerCard(otherId),
				proposerItems    = pItems or {},
				otherPlayerItems = oItems or {},
				status           = row.status or "pending",
				timestamp        = tonumber(row.created_at) or 0,
				expiresAt        = tonumber(row.expires_at) or 0,
			}
			loaded = loaded + 1
		end
	end

	print("\27[32m[core-skins]\27[0m "..loaded.." propostas de troca pendentes carregadas.")
end

framework.databaseReady(function()
	Wait(500)
	initializeCache()
	initializeTrades()
	expireDue()
end)

CreateThread(function()
	while true do
		Wait(globalConfig.tradeSweepMs or 60000)
		expireStaleTrades()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		Wait(globalConfig.syncInterval or 60000 * 5)

		for passport,rows in pairs(dirtySkins or {}) do
			for skinId,flag in pairs(rows or {}) do
				local data = userSkins[passport] and userSkins[passport][skinId]

				if flag == "insert" and data then
					local ok,err = pcall(function()
						framework.query([[
							INSERT INTO core_skins_inventory (passport, skinId, weaponId, equipped, amount, expires_at)
							VALUES (@passport, @skinId, @weaponId, @equipped, @amount, @expires_at)
							ON DUPLICATE KEY UPDATE
								weaponId = VALUES(weaponId),
								equipped = VALUES(equipped),
								amount = amount + VALUES(amount),
								expires_at = VALUES(expires_at)
						]],{
							passport = tonumber(passport),
							skinId   = tostring(skinId),
							weaponId = tostring(data.weaponId),
							equipped = data.equipped and 1 or 0,
							amount   = tonumber(data.amount) or 0,
							expires_at = data.expiresAt or nil,
						})
					end)
					if not ok then
						print("[core-skins][DB][INSERT][ERRO]",passport,skinId,err)
					end
				elseif flag == "update" and data then
					local ok,err = pcall(function()
						framework.query([[
							UPDATE core_skins_inventory
							SET equipped = @equipped, amount = @amount, expires_at = @expires_at
							WHERE passport = @passport AND skinId = @skinId
						]],{
							passport = tonumber(passport),
							skinId   = tostring(skinId),
							equipped = data.equipped and 1 or 0,
							amount   = tonumber(data.amount) or 0,
							expires_at = data.expiresAt or nil,
						})
					end)
					if not ok then
						print("[core-skins][DB][UPDATE][ERRO]",passport,skinId,err)
					end
				elseif flag == "delete" then
					local ok,err = pcall(function()
						framework.query("DELETE FROM core_skins_inventory WHERE passport = @passport AND skinId = @skinId",{
							passport = tonumber(passport),
							skinId   = tostring(skinId),
						})
					end)
					if not ok then
						print("[core-skins][DB][DELETE][ERRO]",passport,skinId,err)
					end
				end
			end
		end

		dirtySkins = {}
	end
end)

-- =============================================================================
-- AUTH / WEBHOOK
-- =============================================================================
