local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("core-weather")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local IsOpen = false
local UniqueState = false
local CurrentWeather = nil
local CurrentHour = nil
local CurrentMinute = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDNUI
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendNui(action,data)
	SendNUIMessage({ action = action, data = data or {} })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
local function SyncState()
	if UniqueState then
		LocalPlayer.state:set("cw_override",{
			weather = CurrentWeather,
			hour = CurrentHour,
			minute = CurrentMinute
		},false)
	else
		LocalPlayer.state:set("cw_override",false,false)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
local function OpenWeather()
	if IsOpen then
		return
	end

	if not vSERVER.CheckPermission() then
		TriggerEvent("Notify","Negado","Você não tem permissão.","vermelho",5000)
		return
	end

	IsOpen = true
	SetNuiFocus(true,true)
	SetCursorLocation(0.5,0.5)

	SendNui("openWeather",{
		weather = CurrentWeather or GlobalState.Weather or "EXTRASUNNY",
		hour = CurrentHour or GlobalState.Hours or 12,
		minute = CurrentMinute or GlobalState.Minutes or 0,
		themeColor = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or Weather.ThemeColor or "#dc1553"
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEWEATHER
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseWeather()
	if not IsOpen then
		return
	end

	IsOpen = false
	SetNuiFocus(false,false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Weather.Command,function()
	OpenWeather()
end,false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("core-weather",function(Data,Callback)
	local Action = Data.action

	if Action == "close" then
		CloseWeather()
	elseif Action == "setWeather" then
		local W = Data.weather
		if W and type(W) == "string" and W ~= "" then
			UniqueState = true
			CurrentWeather = W
			SyncState()
			TriggerEvent("Notify","Sucesso","Clima alterado com sucesso.","verde",5000)
		end
	elseif Action == "setTime" then
		local H = tonumber(Data.hour)
		local M = tonumber(Data.minute)
		if H and M then
			UniqueState = true
			CurrentHour = math.max(0,math.min(23,H))
			CurrentMinute = math.max(0,math.min(59,M))
			SyncState()
			TriggerEvent("Notify","Sucesso","Horário alterado com sucesso.","verde",5000)
		end
	elseif Action == "reset" then
		UniqueState = false
		CurrentWeather = nil
		CurrentHour = nil
		CurrentMinute = nil
		SyncState()

		SendNui("openWeather",{
			weather = GlobalState.Weather or "EXTRASUNNY",
			hour = GlobalState.Hours or 12,
			minute = GlobalState.Minutes or 0
		})

		TriggerEvent("Notify","Sucesso","Clima sincronizado com a cidade.","verde",5000)
	end

	Callback("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	SetNuiFocus(false,false)
	SyncState()
end)
