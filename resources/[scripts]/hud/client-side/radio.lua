-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
local RadioUsers = {}

AddEventHandler("radio:Connect",function(Frequency)
	SendNUIMessage({ action = "set:radio", payload = Frequency })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADIO:DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("radio:Disconnect")
AddEventHandler("radio:Disconnect",function()
	RadioUsers = {}
	SendNUIMessage({ action = "set:radio",  payload = nil })
	SendNUIMessage({ action = "radio:users", payload = {} })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLIENT:PESSOAFALANDO (core-radio talking indicator)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("client:pessoafalando")
AddEventHandler("client:pessoafalando", function(status, frequency, userId, playerName)
	if status then
		RadioUsers[tostring(userId)] = { id = userId, name = playerName or "Desconhecido" }
	else
		RadioUsers[tostring(userId)] = nil
	end

	local list = {}
	for _, v in pairs(RadioUsers) do list[#list + 1] = v end
	SendNUIMessage({ action = "radio:users", payload = list })
end)
