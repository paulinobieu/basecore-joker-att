local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORELOGS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CoreLog(Category,Data)
	if GetResourceState("core_logs") == "started" then
		exports["core_logs"]:AddLog(Category,Data)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SALVARSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("salvarspawn",function(source,args,rawCommand)
	local Passport = vRP.Passport(source)

	if Passport and vRP.HasGroup(Passport,"Admin",1) then
		TriggerClientEvent("fuga:salvar",source)

		CoreLog("SALVARSPAWN",{
			message = vRP.FullName(Passport).." #"..Passport.." salvou o ponto de spawn do evento de fuga",
			adminName = vRP.FullName(Passport),
			adminId = Passport
		})
	else
		TriggerClientEvent("Notify",source,"Fuga","Você não tem permissão.","vermelho",5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VOLTARSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("voltarspawn",function(source,args,rawCommand)
	local Passport = vRP.Passport(source)

	if Passport and vRP.HasGroup(Passport,"Admin",1) then
		TriggerClientEvent("fuga:voltar",source)

		CoreLog("VOLTARSPAWN",{
			message = vRP.FullName(Passport).." #"..Passport.." voltou ao spawn salvo do evento de fuga",
			adminName = vRP.FullName(Passport),
			adminId = Passport
		})
	else
		TriggerClientEvent("Notify",source,"Fuga","Você não tem permissão.","vermelho",5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORRER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("correr",function(source,args,rawCommand)
	local Passport = vRP.Passport(source)

	if Passport and vRP.HasGroup(Passport,"Admin",1) then
		TriggerClientEvent("fuga:correr",source)

		CoreLog("CORRER",{
			message = vRP.FullName(Passport).." #"..Passport.." ativou a corrida do evento de fuga",
			adminName = vRP.FullName(Passport),
			adminId = Passport
		})
	else
		TriggerClientEvent("Notify",source,"Fuga","Você não tem permissão.","vermelho",5000)
	end
end)
