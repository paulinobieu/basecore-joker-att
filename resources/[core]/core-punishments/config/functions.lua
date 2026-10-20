-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Functions = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.Passport(source)
	return vRP.Passport(source)
end

function Functions.Source(Passport)
	return vRP.Source(Passport)
end

function Functions.Identity(Passport)
	return vRP.Identity(Passport)
end

function Functions.FullName(Passport)
	return vRP.FullName(Passport)
end

function Functions.License(source)
	return vRP.Identities(source)
end

function Functions.HasPermission(Passport,Level)
	return Passport and vRP.HasGroup(Passport,Punishments.Permission,Level or 1)
end

function Functions.Kick(source,Reason)
	vRP.Kick(source,Reason)
end

function Functions.Revive(source,Health)
	vRP.Revive(source,Health or 200)
end

function Functions.SetBanned(Passport,Amount,Mode,Reason)
	local Minutes = parseInt(Amount)
	if Mode == "Permanente" then
		Minutes = -1
	elseif Mode == "Horas" then
		Minutes = Minutes * 60
	elseif Mode == "Dias" then
		Minutes = Minutes * 1440
	end

	vRP.SetBanned(Passport,Minutes,Reason)
end

function Functions.RemoveBanned(Passport)
	vRP.RemoveBanned(Passport)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.Notify(source,Title,Message,Type,Time)
	TriggerClientEvent("Notify",source,Title,Message,Type or "amarelo",Time or 5000)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.DBQuery(Query,Params)
	return exports.oxmysql:query_async(Query,Params or {})
end

function Functions.DBSingle(Query,Params)
	return exports.oxmysql:single_async(Query,Params or {})
end

function Functions.DBExecute(Query,Params)
	return exports.oxmysql:execute_async(Query,Params or {})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOG
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.Log(Category,Data)
	if GetResourceState("core_logs") == "started" then
		exports["core_logs"]:AddLog(Category,Data)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PL_PROTECT
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.PLActive()
	return GetResourceState("PL_PROTECT") == "started"
end

function Functions.PLBan(source,Passport,Reason,Admin,Days)
	if not Functions.PLActive() then
		return
	end

	if source then
		exports["PL_PROTECT"]:BanPlayer(source,Reason,Admin or "Staff",Days or 0)
	elseif Passport then
		exports["PL_PROTECT"]:BanPlayerByUserId(Passport,Reason,Admin or "Staff",Days or 0)
	end
end

function Functions.PLUnban(Passport)
	if not Functions.PLActive() then
		return
	end

	exports["PL_PROTECT"]:UnbanPlayerByUserId(Passport)
end
-----------------------------------------------------------------------------------------------------------------------------------------
