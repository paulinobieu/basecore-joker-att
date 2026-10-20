-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
local AnnounceCount = 0

local function ColorToType(color)
	local map = {
		verde    = "success", vermelho = "error",  sangue  = "error",
		amarelo  = "warn",    fome     = "warn",   sede    = "warn",
	}
	return map[color] or "info"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY (client event)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify", function(Title, Message, Color, Timer)
	local cfg = hudConfig.anuncios and hudConfig.anuncios[Color]
	if cfg then
		AnnounceCount = AnnounceCount + 1
		SendNUIMessage({ action = "set:announces:add", payload = {
			id      = AnnounceCount,
			image   = { src = cfg.image },
			header  = { text = Title, icon = cfg.icon or "bell-ring" },
			text    = Message,
			timeout = Timer or cfg.time,
			color   = cfg.color,
		}})
	else
		SendNUIMessage({ action = "notify:message", payload = {
			type    = ColorToType(Color),
			title   = Title,
			message = Message,
			timeout = Timer or 5000,
		}})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:NOTIFY (alias)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Notify")
AddEventHandler("inventory:Notify", function(Title, Message, Color, Timer)
	TriggerEvent("Notify", Title, Message, Color, Timer)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:NOTIFYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:NotifyItem")
AddEventHandler("inventory:NotifyItem", function(data)
	local item     = data[1]
	local amount   = data[2]
	local baseItem = item:match("^([^%-:]+)") or item
	local weaponData = hudConfig.weapons and (hudConfig.weapons[baseItem] or hudConfig.weapons[baseItem:upper()])
	local image
	if weaponData then
		local idx = weaponData.index:match("(.-)%.[^%.]+$") or weaponData.index
		image = hudConfig.armoryUrl .. idx .. ".png"
	else
		local idx = (ItemIndex and ItemIndex(baseItem)) or baseItem
		image = hudConfig.itemsUrl .. idx .. ".png"
	end
	SendNUIMessage({ action = "notify:item", payload = {
		action = amount > 0 and "add" or "remove",
		image  = image,
		amount = math.abs(amount),
		name   = ItemName and ItemName(item) or (weaponData and weaponData.name or item),
	}})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEST COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("testnotify", function(_, args)
	local types = { "success", "error", "warn", "info" }
	local t     = args[1] and args[1] or "success"
	if not (t == "success" or t == "error" or t == "warn" or t == "info") then
		t = "success"
	end
	SendNUIMessage({ action = "notify:message", payload = {
		type    = t,
		title   = "Teste " .. t,
		message = "Notificação de <b>teste</b> do tipo " .. t .. ".",
		timeout = 5000,
	}})
end)

RegisterCommand("testnotifyitem", function(_, args)
	local action = (args[1] == "remove") and "remove" or "add"
	local amount = tonumber(args[2]) or 2
	SendNUIMessage({ action = "notify:item", payload = {
		action = action,
		image  = hudConfig.itemsUrl .. "bandagem.png",
		amount = amount,
		name   = "Bandagem",
	}})
end)

RegisterCommand("testnotifypolice", function(source, args)
	local codes = { "13", "20", "31", "99", "15" }
	local titles = { "Oficial desmaiado/ferido", "Localização", "Homicídio em andamento", "Situação crítica", "Perseguição" }
	local idx = math.random(1, #codes)
	local ped = PlayerPedId()
	local pos = GetEntityCoords(ped)
	TriggerEvent("NotifyPush", {
		code  = codes[idx],
		title = titles[idx],
		x     = pos.x,
		y     = pos.y,
		z     = pos.z,
		name  = "Officer Test",
	})
end)

RegisterCommand("testnotifyrequest", function()
	TriggerEvent("hud:testRequest")
end)
