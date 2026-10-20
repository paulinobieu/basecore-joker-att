-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("chat",Core)
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT:SERVERMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("chat:ServerMessage")
AddEventHandler("chat:ServerMessage",function(Mode,Message)
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport then
		return false
	end

	local Name = vRP.FullName(Passport)
	local Messenger = (Message or ""):gsub("[<>]","")

	if Groups[Mode] and Groups[Mode].Chat then
		if vRP.GetHealth(source) > 100 and vRP.HasService(Passport,Mode) then
			local DisplayName = Name .. " #" .. tostring(Passport)
			local Sent = {}
			local Service = vRP.NumPermission(Mode)
			for _,TargetSource in pairs(Service) do
				if not Sent[TargetSource] then
					Sent[TargetSource] = true
					async(function()
						TriggerClientEvent("chat:ClientMessage",TargetSource,DisplayName,Messenger,Mode)
					end)
				end
			end
			if not Sent[source] then
				TriggerClientEvent("chat:ClientMessage",source,DisplayName,Messenger,Mode)
			end
		end

		return false
	end

	if Mode == "OOC" then
		local DisplayName = Name .. " #" .. tostring(Passport)
		TriggerClientEvent("chat:ClientMessage",source,DisplayName,Messenger,Mode)

		local NearbyPlayers = vRPC.ClosestPeds(source,10)
		for _,TargetSource in pairs(NearbyPlayers) do
			async(function()
				TriggerClientEvent("chat:ClientMessage",TargetSource,DisplayName,Messenger,Mode)
			end)
		end

		return false
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("me",function(source,Message,History)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] then
		local Name = vRP.FullName(Passport)
		local Message = string.sub(History:sub(4),1,100)

		for _,v in pairs(vRPC.Players(source)) do
			async(function()
				TriggerClientEvent("chat:me_new",v,source,Name,Message,10)
			end)
		end
	end
end)
