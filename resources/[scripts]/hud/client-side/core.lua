-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONVERSÃO DE RUAS
-----------------------------------------------------------------------------------------------------------------------------------------
function ConvertStreet(raw)
	if not raw or raw == "" then return raw end
	if not hudConfig.modifyStreetNames then return raw end
	local streets = hudConfig.modifyStreets
	if streets[raw] then return streets[raw] end
	local name = raw
		:gsub("^N%. ", "North "):gsub("^S%. ", "South ")
		:gsub("^E%. ", "East ") :gsub("^W%. ", "West ")
		:gsub(" Ave$",  " Avenue")   :gsub(" Blvd$", " Boulevard")
		:gsub(" St$",   " Street")   :gsub(" Dr$",   " Drive")
		:gsub(" Rd$",   " Road")     :gsub(" Fwy$",  " Freeway")
		:gsub(" Hwy$",  " Highway")  :gsub(" Ln$",   " Lane")
		:gsub(" Pkwy$", " Parkway")  :gsub(" Pl$",   " Place")
	if streets[name] then return streets[name] end
	return name
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("hud",Core)
vSERVER = Tunnel.getInterface("hud")
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL
-----------------------------------------------------------------------------------------------------------------------------------------
Radar = false
HudActive = true
HudHidden = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function isPlayingEvent()
return LocalPlayer.state.inPvp or LocalPlayer.state.inLateGame
end

local function CompassHeading(heading)
local dirs = { "N","NW","W","SW","S","SE","E","NE" }
return dirs[math.floor((heading + 22.5) % 360 / 45) + 1]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MENU SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
local MenuSettings = {
velocimeter = "digital",
survival    = "lonzege",
chat        = true,
radar       = true,
hide        = false,
notify      = true,
survivalSettings = {
life = true, shield = true, hungry = true,
thirst = true, stamina = true, stress = true, oxygen = true,
},
}

local LastRadarVisible = nil
function ApplyMinimapVisibility()
local InVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
local hasRadarSource = hudConfig.pinTheMinimap or Radar or InVehicle
local shouldShow = HudActive ~= false and not HudHidden and hasRadarSource and MenuSettings.radar ~= false
if shouldShow then
if not IsMinimapRendering() then
SetBigmapActive(false, false)
DisplayRadar(true)
end
elseif IsMinimapRendering() then
DisplayRadar(false)
end
if shouldShow ~= LastRadarVisible then
LastRadarVisible = shouldShow
SendNUIMessage({ action = "set:radar:visible", payload = shouldShow })
end
end

CreateThread(function()
while not hudConfig do Wait(100) end
UnlockMinimapAngle()
if hudConfig.setMiniMapBelt then
while true do
LockMinimapAngle(0)
Wait(500)
end
end
end)

AddEventHandler("onResourceStop", function(name)
if name == GetCurrentResourceName() then
UnlockMinimapAngle()
end
end)

local RadarKvpLoad, RadarKvpSave
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Hood         = false
local HudStarted   = false
local Armour       = 0
local Health       = 200
local Thirst       = 100
local ThirstTimer  = 0
local ThirstAmount = 180000
local ThirstDelay  = GetGameTimer()
local Hunger       = 100
local HungerTimer  = 0
local HungerAmount = 180000
local HungerDelay  = GetGameTimer()
local Stress       = 0
local StressTimer  = GetGameTimer()
local Wanted       = 0
local WantedTimer  = GetGameTimer()
local Repose       = 0
local ReposeTimer  = GetGameTimer()
local Underwater   = false
local LastLocation = nil
local LastTime     = nil
local LastStamina  = nil
local LastStress   = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
LoadMovement("move_m@injured")

while true do
if LocalPlayer.state.Active then
local Pid = PlayerId()
local Ped = PlayerPedId()
local Coords = GetEntityCoords(Ped)

local Armouring = hudConfig.getPedArmour(Ped)
local Healing   = hudConfig.getLifeCalculate(Ped)
if Healing < 0   then Healing = 0   end
if Healing > 100 then Healing = 100 end

if not HudStarted then
	HudStarted = true
	SendNUIMessage({ action = "set:life",   payload = Healing })
	SendNUIMessage({ action = "set:shield", payload = Armouring })
	SendNUIMessage({ action = "set:hungry", payload = Hunger })
	SendNUIMessage({ action = "set:thirst", payload = Thirst })
	SendNUIMessage({ action = "set:oxygen", payload = 100 })
	SendNUIMessage({ action = "set:stress",  payload = Stress })
	SendNUIMessage({ action = "set:stamina", payload = hudConfig.getPlayerStamina(Pid) })
end

if Health ~= Healing then
SendNUIMessage({ action = "set:life", payload = Healing })
Health = Healing
end

if not IsPedSwimming(Ped) then
if Healing <= 30 and GetPedMovementClipset(Ped) ~= -650503762 then
LocalPlayer.state:set("Walk", false, false)
SetPedMovementClipset(Ped, "move_m@injured", 0.5)
elseif Healing > 30 and GetPedMovementClipset(Ped) == -650503762 then
LocalPlayer.state:set("Walk", false, false)
end
end

if Armour ~= Armouring then
SendNUIMessage({ action = "set:shield", payload = Armouring })
Armour = Armouring
end

local MinRoad  = GetStreetNameAtCoord(Coords.x, Coords.y, Coords.z)
local FullRoad = ConvertStreet(GetStreetNameFromHashKey(MinRoad) or "")
if FullRoad ~= "" then
	if FullRoad ~= LastLocation then
		SendNUIMessage({ action = "set:location", payload = {
			street         = FullRoad,
			compassHeading = CompassHeading(GetEntityHeading(Ped)),
		}})
		LastLocation = FullRoad
	end
elseif LastLocation ~= nil then
	SendNUIMessage({ action = "set:location", payload = nil })
	LastLocation = nil
end

local TimeText = string.format("%02d:%02d", GlobalState.Hours, GlobalState.Minutes)
if TimeText ~= LastTime then
LastTime = TimeText
SendNUIMessage({ action = "set:time", payload = TimeText })
end

if Wanted > 0 and WantedTimer <= GetGameTimer() then
Wanted = Wanted - 1
WantedTimer = GetGameTimer() + 1000
SendNUIMessage({ action = "set:wanted", payload = Wanted > 0 })
end

if Repose > 0 and ReposeTimer <= GetGameTimer() then
Repose = Repose - 1
ReposeTimer = GetGameTimer() + 1000
SendNUIMessage({ action = "set:rest", payload = Repose > 0 })
end

if not LocalPlayer.state.Banned and not LocalPlayer.state.Prison and GetEntityHealth(Ped) > 100 and not isPlayingEvent() then
if Hunger <= 10 and HungerTimer <= GetGameTimer() then
ApplyDamageToPed(Ped, 1, false)
HungerTimer = GetGameTimer() + 60000
TriggerEvent("Notify", "Alimentação", "Sofrendo com a <b>fome</b>.", "fome", 2500)
end

if Thirst <= 10 and ThirstTimer <= GetGameTimer() then
ApplyDamageToPed(Ped, 1, false)
ThirstTimer = GetGameTimer() + 60000
TriggerEvent("Notify", "Hidratação", "Sofrendo com a <b>sede</b>.", "sede", 2500)
end

if Stress ~= 999 and Stress >= 50 and StressTimer <= GetGameTimer() then
AnimpostfxPlay("MenuMGIn")
SetTimeout(1000, function() AnimpostfxStop("MenuMGIn") end)
StressTimer = GetGameTimer() + 30000
end

if Hunger > 0 and HungerDelay <= GetGameTimer() then
Hunger = Hunger - 1
vRPS.DowngradeHunger()
HungerDelay = GetGameTimer() + HungerAmount
SendNUIMessage({ action = "set:hungry", payload = Hunger })
end

if Thirst > 0 and ThirstDelay <= GetGameTimer() then
Thirst = Thirst - 1
vRPS.DowngradeThirst()
ThirstDelay = GetGameTimer() + ThirstAmount
SendNUIMessage({ action = "set:thirst", payload = Thirst })
end

local Stamina = hudConfig.getPlayerStamina(Pid)
if Stamina ~= LastStamina then
LastStamina = Stamina
SendNUIMessage({ action = "set:stamina", payload = Stamina })
end

if Stress ~= LastStress then
LastStress = Stress
SendNUIMessage({ action = "set:stress", payload = Stress })
end

if IsPedSwimmingUnderWater(Ped) then
local IsScuba    = GetPedConfigFlag(Ped, 135)
local Remaining  = GetPlayerUnderwaterTimeRemaining(Pid)
local Calculated = Remaining / (IsScuba and 10000 or 10) * 100
SendNUIMessage({ action = "set:oxygen", payload = Calculated })
Underwater = true
else
if Underwater then
SendNUIMessage({ action = "set:oxygen", payload = 100 })
Underwater = false
end
end
end
end

Wait(500)
end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTITYVELOCITY
-----------------------------------------------------------------------------------------------------------------------------------------
function EntityVelocity(Ped)
local Velocity = GetEntityVelocity(Ped)
return math.min(math.sqrt(Velocity.x^2 + Velocity.y^2 + Velocity.z^2), 10)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATE BAGS
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("Passport", ("player:%s"):format(LocalPlayer.state.Source), function(_, _, Value)
SendNUIMessage({ action = "set:passport", payload = Value })
end)

AddStateBagChangeHandler("Safezone", ("player:%s"):format(LocalPlayer.state.Source), function(_, _, Value)
SendNUIMessage({ action = "set:safezone", payload = Value and true or false })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ASSAULT ZONE
-----------------------------------------------------------------------------------------------------------------------------------------
local AssaultActive = false

CreateThread(function()
	while true do
		if LocalPlayer.state.Active and Assault then
			local hour   = GlobalState.Hours or 0
			local init   = AssaultInitTime
			local finish = AssaultEndTime

			local inTime
			if init <= finish then
				inTime = hour >= init and hour < finish
			else
				inTime = hour >= init or hour < finish
			end

			local inRegion = false
			if inTime then
				if AssaultRegion == "All" then
					inRegion = true
				else
					local Ped    = PlayerPedId()
					local Coords = GetEntityCoords(Ped)
					if AssaultRegion == "North" then
						inRegion = Coords.y > 1500
					elseif AssaultRegion == "South" then
						inRegion = Coords.y <= 1500
					end
				end
			end

			local nowActive = inTime and inRegion
			if nowActive ~= AssaultActive then
				AssaultActive = nowActive
				if AssaultActive then
					local regionLabel = AssaultRegion == "North" and "Norte" or AssaultRegion == "South" and "Sul" or "Todo Mapa"
					local label = string.format("%02dH-%02dH | %s", init, finish, regionLabel)
					SendNUIMessage({ action = "set:robbery", payload = label })
				else
					SendNUIMessage({ action = "set:robbery", payload = nil })
				end
			end

			if inTime and AssaultRegion ~= "All" then
				Wait(500)
			else
				Wait(10000)
			end
		else
			if AssaultActive then
				AssaultActive = false
				SendNUIMessage({ action = "set:robbery", payload = nil })
			end
			Wait(10000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOIP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Voip", function(Number)
SendNUIMessage({ action = "set:voice:level", payload = Number })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOICE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Voice", function(Status)
SendNUIMessage({ action = "set:voice:isTalking", payload = Status })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Wanted")
AddEventHandler("hud:Wanted", function(Seconds)
Wanted = Seconds
WantedTimer = GetGameTimer() + 1000
SendNUIMessage({ action = "set:wanted", payload = Seconds > 0 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED EXPORT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wanted", function()
if Wanted > 0 then
TriggerEvent("Notify", "Procurado", "Tempo restante: " .. CompleteTimers(Wanted, true), "vermelho", 5000)
return true
end
return false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REPOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Repose")
AddEventHandler("hud:Repose", function(Seconds)
Repose = Seconds
ReposeTimer = GetGameTimer() + 1000
SendNUIMessage({ action = "set:rest", payload = Seconds > 0 })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSE EXPORT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Repose", function()
if Repose > 0 then
TriggerEvent("Notify", "Repousando", "Tempo restante: " .. CompleteTimers(Repose, true), "amarelo", 5000)
return true
end
return false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Active", function(state)
local visible = state ~= false
HudActive = visible
SendNUIMessage({ action = "set:hud:visible", payload = visible })
ApplyMinimapVisibility()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD (opens settings menu)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud", function()
SendNUIMessage({ action = "set:menu:visible", payload = true })
SetNuiFocus(true, true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:MENU
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Menu", function()
SendNUIMessage({ action = "set:menu:visible", payload = true })
SetNuiFocus(true, true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:RADAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Radar")
AddEventHandler("hud:Radar", function()
Radar = not Radar
RadarKvpSave()
ApplyMinimapVisibility()
TriggerEvent("Notify", "Radar", "Mapa adaptativo " .. (Radar and "ativado" or "desativado") .. ".", "verde", 3000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:RADAROFF (mapgps item — ativa o minimapa)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Radaroff")
AddEventHandler("hud:Radaroff", function()
Radar = true
RadarKvpSave()
ApplyMinimapVisibility()
TriggerEvent("Notify", "Mapa Adaptativo", "Dispositivo ativado.", "verde", 3000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:RADAREXPIRE (durabilidade do mapgps zerou — desativa o minimapa)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:RadarExpire")
AddEventHandler("hud:RadarExpire", function()
Radar = false
RadarKvpSave()
ApplyMinimapVisibility()
TriggerEvent("Notify", "Mapa Adaptativo", "A bateria do dispositivo acabou.", "amarelo", 5000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROGRESS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Progress")
AddEventHandler("Progress", function(Message, Timer)
SendNUIMessage({ action = "set:progress", payload = { text = Message, time = Timer - 300 } })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:THIRST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Thirst")
AddEventHandler("hud:Thirst", function(Number)
if Thirst ~= Number then
SendNUIMessage({ action = "set:thirst", payload = Number })
Thirst = Number
end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:HUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Hunger")
AddEventHandler("hud:Hunger", function(Number)
if Hunger ~= Number then
SendNUIMessage({ action = "set:hungry", payload = Number })
Hunger = Number
end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Stress")
AddEventHandler("hud:Stress", function(Number)
if Stress ~= Number then
SendNUIMessage({ action = "set:stress", payload = Number })
Stress = Number
end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUNGER AMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Hunger", function(Value)
HungerAmount = Value
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THIRST AMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Thirst", function(Value)
ThirstAmount = Value
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:HOOD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Hood")
AddEventHandler("hud:Hood", function()
if Hood then
DoScreenFadeIn(2500)
Hood = false
else
DoScreenFadeOut(0)
Hood = true
end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOMINATION:UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("domination:Update")
AddEventHandler("domination:Update", function(Data, Max)
SendNUIMessage({ action = "domination:update", payload = { data = Data, max = Max } })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOMINATION:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("domination:Close", function()
SendNUIMessage({ action = "domination:close" })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DOMINATION:KILLFEED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("domination:KillFeed")
AddEventHandler("domination:KillFeed", function(Attacker, Victim)
SendNUIMessage({ action = "domination:killfeed", payload = { killer = Attacker, victim = Victim } })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:colors", function(_, cb)
cb({ primaryColor = Theme.main, secondaryColor = Theme.main, thirdyColor = Theme.main })
end)

RegisterNUICallback("get:logo:data", function(_, cb)
cb({
logo       = hudConfig.logoUrl or "",
dimensions = { width = "9.375rem", height = "9.375rem", top = "-1.1875rem" },
})
end)

RegisterNUICallback("fetchMapPosition", function(_, cb)
local DefaultAspect = 1920 / 1080
local ResX, ResY    = GetActiveScreenResolution()
local Aspect        = ResX / ResY
local XOffset       = 0
if Aspect > DefaultAspect then
XOffset = (DefaultAspect - Aspect) / 3.6
end
cb({ width = math.floor(0.175 * ResX), height = math.floor(0.225 * ResY), left = math.floor((0.005 + XOffset) * ResX), top = math.floor(ResY * 0.8) })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- KVP HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function KvpLoad()
	local raw = GetResourceKvpString("hud:settings")
	if not raw then return end
	local ok, decoded = pcall(json.decode, raw)
	if not ok or type(decoded) ~= "table" then return end
	for k, v in pairs(decoded) do
		if k == "survivalSettings" and type(v) == "table" then
			for sk, sv in pairs(v) do
				MenuSettings.survivalSettings[sk] = sv
			end
		else
			MenuSettings[k] = v
		end
	end
end

local function KvpSave()
	SetResourceKvp("hud:settings", json.encode(MenuSettings))
end

RadarKvpLoad = function()
local raw = GetResourceKvpString("hud:radar")
if raw == "1" then
Radar = true
CreateThread(function()
while not LocalPlayer.state.Active do Wait(1000) end
TriggerServerEvent("hud:RadarCheck")
end)
end
end

RadarKvpSave = function()
SetResourceKvp("hud:radar", Radar and "1" or "0")
end

KvpLoad()
RadarKvpLoad()
HudHidden = MenuSettings.hide == true
if hudConfig.pinTheMinimap then
CreateThread(function()
while not LocalPlayer.state.Active do Wait(1000) end
ApplyMinimapVisibility()
end)
end

RegisterNUICallback("hud:ready", function(_, cb)
local Pid = PlayerId()
local Ped = PlayerPedId()
local Healing   = hudConfig.getLifeCalculate(Ped)
if Healing < 0   then Healing = 0   end
if Healing > 100 then Healing = 100 end
SendNUIMessage({ action = "set:life",    payload = Healing })
SendNUIMessage({ action = "set:shield",  payload = hudConfig.getPedArmour(Ped) })
SendNUIMessage({ action = "set:hungry",  payload = Hunger })
SendNUIMessage({ action = "set:thirst",  payload = Thirst })
SendNUIMessage({ action = "set:oxygen",  payload = 100 })
SendNUIMessage({ action = "set:stress",  payload = Stress })
SendNUIMessage({ action = "set:stamina", payload = hudConfig.getPlayerStamina(Pid) })
cb(true)
end)

RegisterNUICallback("get:menu:savedSettings", function(_, cb)
cb(MenuSettings)
end)

RegisterNUICallback("post:menu:setVelocimeter", function(data, cb)
if data == "rounded" or data == "digital" then
MenuSettings.velocimeter = data
KvpSave()
end
cb(true)
end)

RegisterNUICallback("post:menu:setSurvival", function(data, cb)
if data == "rounded" or data == "lonzege" then
MenuSettings.survival = data
KvpSave()
end
cb(true)
end)

RegisterNUICallback("post:closeUi", function(_, cb)
SetNuiFocus(false, false)
SendNUIMessage({ action = "set:menu:visible", payload = false })
cb(true)
end)

RegisterNUICallback("get:police:expireHistoryTimeout", function(_, cb)
cb(120000)
end)

RegisterNUICallback("fetch:binds", function(_, cb)
cb({})
end)

do
local topItems      = { "notify", "radar", "chat", "hide" }
local survivalItems = { "life", "shield", "hungry", "thirst", "stamina", "stress", "oxygen" }

for _, opt in ipairs(topItems) do
RegisterNUICallback("post:menu:toggle:" .. opt, function(_, cb)
MenuSettings[opt] = not MenuSettings[opt]
if opt == "hide" then
HudHidden = MenuSettings.hide
ApplyMinimapVisibility()
elseif opt == "radar" then
ApplyMinimapVisibility()
end
KvpSave()
cb(true)
end)
end

for _, opt in ipairs(survivalItems) do
RegisterNUICallback("post:menu:toggle:" .. opt, function(_, cb)
MenuSettings.survivalSettings[opt] = not MenuSettings.survivalSettings[opt]
KvpSave()
cb(true)
end)
end
end
