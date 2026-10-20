-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp","lib/Tunnel")
Proxy  = module("vrp","lib/Proxy")
vRP    = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Functions = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.Passport(source)
	return vRP.Passport(source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HASPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.HasPermission(Passport,Permission)
	if not Passport then
		return false
	end

	if not Permission then
		return true
	end

	if type(Permission) == "table" then
		return vRP.HasTable(Passport,Permission) and true or false
	end

	local Group,Level = Permission:match("^(.+)@(%d+)$")
	if Group then
		return vRP.HasGroup(Passport,Group,tonumber(Level)) and true or false
	end

	return (vRP.HasPermission(Passport,Permission) or vRP.HasGroup(Passport,Permission,1)) and true or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FULLNAME
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.FullName(Passport)
	if not Passport then return "Desconhecido" end
	if vRP.FullName then
		local Name = vRP.FullName(Passport)
		if Name and Name ~= "" then return Name end
	end

	local Identity = vRP.Identity and vRP.Identity(Passport) or nil
	if Identity then
		local F = Identity.firstname or Identity.nome or ""
		local L = Identity.lastname  or Identity.sobrenome or ""
		if F ~= "" and L ~= "" then return F.." "..L end
		if F ~= "" then return F end
	end

	return "Passaporte "..Passport
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STAFFRANK
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.StaffRank(Passport)
	if not Passport then return "Staff" end

	local Level = vRP.HasPermission(Passport,Calls.StaffPermission)
	if not Level or type(Level) ~= "number" then return "Staff" end

	local Name = vRP.NameHierarchy(Calls.StaffPermission,Level)
	if not Name or Name == "" or Name == Calls.StaffPermission then
		return "Staff"
	end

	return (Calls.RankLabels and Calls.RankLabels[Name]) or Name
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.Notify(source,kind,message,duration)
	if not source or source <= 0 then return end
	TriggerClientEvent("Notify",source,"Chamados",tostring(message or ""),tostring(kind or "info"),duration or 6000)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
function Functions.Query(command,params)
	return MySQL.query.await(command,params or {})
end

function Functions.Execute(command,params)
	return MySQL.update.await(command,params or {})
end

function Functions.Insert(command,params)
	return MySQL.insert.await(command,params or {})
end
