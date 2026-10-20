-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUEST INTERFACE
-----------------------------------------------------------------------------------------------------------------------------------------
local Core = {}
Tunnel.bindInterface("request", Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Current = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseRequest(Result)
	if not Current then return end
	local cb = Current.cb
	Current = nil
	SendNUIMessage({ action = "notify:request", payload = nil })
	if cb then cb(Result and true or false) end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCEPT / REFUSE BINDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("AcceptRequest", function()
	if Current then CloseRequest(true) end
end)
RegisterKeyMapping("AcceptRequest", "Aceitar pedido.", "keyboard", "Y")

RegisterCommand("RefuseRequest", function()
	if Current then CloseRequest(false) end
end)
RegisterKeyMapping("RefuseRequest", "Recusar pedido.", "keyboard", "U")
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("request:accept", function(_, cb)
	CloseRequest(true)
	cb(true)
end)

RegisterNUICallback("request:refuse", function(_, cb)
	CloseRequest(false)
	cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE.FUNCTION
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Function(Title, Message, Timeout)
	if Current then return false end

	Timeout = tonumber(Timeout) or 15000
	local r = async()
	Current = { cb = r }

	SendNUIMessage({ action = "notify:request", payload = {
		title     = Title,
		message   = Message,
		acceptKey = "Y",
		refuseKey = "U",
		timeout   = Timeout,
	}})

	SetTimeout(Timeout, function()
		if Current and Current.cb == r then CloseRequest(false) end
	end)

	return r:wait()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEST
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:testRequest", function()
	CreateThread(function()
		Core.Function("Teste de Pedido","Fulano quer te dar R$ 500. Aceitar?")
	end)
end)
