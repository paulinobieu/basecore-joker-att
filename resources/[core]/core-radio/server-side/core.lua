-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ConnectedPlayers = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function NotifyFrequencyUsers(frequency, eventName, ...)
	local usersInFrequency = ConnectedPlayers[frequency]
	if not usersInFrequency then
		return
	end

	local args = {...}
	for _, playerSource in pairs(usersInFrequency) do
		TriggerClientEvent(eventName, playerSource, table.unpack(args))
	end
end

local function GetFrequencyPlayers(frequency)
	local players = {}
	local usersInFrequency = ConnectedPlayers[frequency]

	if usersInFrequency then
		for userId, _ in pairs(usersInFrequency) do
			local playerName = Functions.getUserName(userId)
			table.insert(players, { nome = playerName, id = userId })
		end
	end

	return players
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUEST OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-radio:requestOpen")
AddEventHandler("core-radio:requestOpen", function()
	local source = source
	local userId = Functions.getUserId(source)
	if not userId then return end

	if not Functions.hasItem(userId, Radio.RequiredItem) then
		Functions.notify(source, Functions.NotifyTypes.Warning, "Você não possui um rádio.", 5000)
		return
	end

	TriggerClientEvent("core-radio:open", source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT TO FREQUENCY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-radio:connect")
AddEventHandler("core-radio:connect", function(frequency)
	local source = source
	local userId = Functions.getUserId(source)
	if not userId then return end

	frequency = tonumber(frequency)
	if not frequency then return end

	local permissions = Radio.RestrictedFrequencies[frequency]
	if permissions and not Functions.hasPermission(userId, permissions) then
		Functions.notify(source, Functions.NotifyTypes.Denied, "Você não tem permissão para esta frequência.", 5000)
		TriggerClientEvent("core-radio:connectDenied", source, frequency)
		return
	end

	if not ConnectedPlayers[frequency] then
		ConnectedPlayers[frequency] = {}
	end

	ConnectedPlayers[frequency][userId] = source
	TriggerClientEvent("core-radio:frequencyJoined", source, frequency)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT FROM FREQUENCY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-radio:disconnect")
AddEventHandler("core-radio:disconnect", function(frequency)
	local source = source
	local userId = Functions.getUserId(source)
	if not userId then return end

	frequency = tonumber(frequency)
	if not frequency then return end

	if ConnectedPlayers[frequency] then
		ConnectedPlayers[frequency][userId] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GET FREQUENCY PLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-radio:getPlayers")
AddEventHandler("core-radio:getPlayers", function(callbackId, frequency)
	local source = source
	local userId = Functions.getUserId(source)

	if not userId then
		TriggerClientEvent("core-radio:callback", source, callbackId, { players = {} })
		return
	end

	frequency = tonumber(frequency)
	local players = frequency and GetFrequencyPlayers(frequency) or {}
	TriggerClientEvent("core-radio:callback", source, callbackId, { players = players })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER TALKING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-radio:playerTalking")
AddEventHandler("core-radio:playerTalking", function(status, frequency)
	local source = source
	local userId = Functions.getUserId(source)
	if not userId then return end

	local playerName = Functions.getUserName(userId)
	NotifyFrequencyUsers(frequency, "core-radio:updateTalkingStatus", status, frequency, userId, playerName)
	NotifyFrequencyUsers(frequency, "client:pessoafalando", status, frequency, userId, playerName)
end)

RegisterNetEvent("pessoafalando")
AddEventHandler("pessoafalando", function(status, freq)
	local source = source
	local userId = Functions.getUserId(source)
	if not userId then return end

	local playerName = Functions.getUserName(userId)
	NotifyFrequencyUsers(freq, "core-radio:updateTalkingStatus", status, freq, userId, playerName)
	NotifyFrequencyUsers(freq, "client:pessoafalando", status, freq, userId, playerName)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect", function(Passport)
	for frequency, users in pairs(ConnectedPlayers) do
		if users[Passport] then
			users[Passport] = nil
		end
	end
end)

AddEventHandler("playerDisconnect", function(Passport)
	for frequency, users in pairs(ConnectedPlayers) do
		if users[Passport] then
			users[Passport] = nil
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect", function(Passport, source)
	TriggerClientEvent("core-radio:syncRadioState", source)
end)

AddEventHandler("playerConnect", function(Passport, source)
	TriggerClientEvent("core-radio:syncRadioState", source)
end)
