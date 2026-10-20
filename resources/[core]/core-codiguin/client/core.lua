-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp","lib/Tunnel")
Proxy  = module("vrp","lib/Proxy")
vRP    = Proxy.getInterface("vRP")
vSERVER = Tunnel.getInterface("core-codiguin")
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------------------------------------------------------------------------
local NUIOpen = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
local function HexToRGB(Hex)
	if type(Hex) ~= "string" then return 1,67,187 end
	Hex = Hex:gsub("#","")
	if #Hex ~= 6 then return 1,67,187 end
	return tonumber(Hex:sub(1,2),16) or 1,tonumber(Hex:sub(3,4),16) or 67,tonumber(Hex:sub(5,6),16) or 187
end

local function ResolveTheme()
	local Color = (Theme and Theme.main) or Codiguin.ThemeColor or "#dc1553"
	local R,G,B = HexToRGB(Color)
	return { hex = Color, rgb = string.format("%d,%d,%d",R,G,B) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendNui(Action,Payload)
	SendNUIMessage({ action = Action, payload = Payload })
end

local function OpenPanel()
	if NUIOpen then return end
	NUIOpen = true
	SetNuiFocus(true,true)
	SendNui("setConfig",{ theme = ResolveTheme() })
	SendNui("setVisible",true)
end

local function ClosePanel()
	if not NUIOpen then return end
	NUIOpen = false
	SetNuiFocus(false,false)
	SendNui("setVisible",false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CODIGUIN:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-codiguin:Open")
AddEventHandler("core-codiguin:Open",function()
	OpenPanel()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:REDEEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("redeem",function(Data,Callback)
	local Code = Data and Data.code or ""
	local Result = vSERVER.Redeem(Code)
	Callback(Result or { ok = false, message = "Erro inesperado." })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close",function(_,Callback)
	ClosePanel()
	Callback({ ok = true })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(Resource)
	if Resource ~= GetCurrentResourceName() then return end
	SetNuiFocus(false,false)
end)
