local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-weather",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckPermission()
	local source = source
	local Passport = vRP.Passport(source)
	if not Passport then
		return false
	end

	if Weather.Public then
		return true
	end

	for _,Permission in ipairs(Weather.Permissions) do
		local Name,Level = Permission,nil
		if type(Permission) == "table" then
			Name,Level = Permission[1],Permission[2]
		end

		if vRP.HasGroup(Passport,Name,Level) then
			return true
		end
	end

	return false
end

---------------------------------------------------------------------------------------------------------------------------------------
-- AUTH / WEBHOOK
---------------------------------------------------------------------------------------------------------------------------------------
