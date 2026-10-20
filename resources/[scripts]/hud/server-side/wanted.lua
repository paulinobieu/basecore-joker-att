
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Lock = {}
local Wanted = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Wanted",function(source,Passport,Seconds)
	if not WantedSystem then
		return
	end

	Seconds = parseInt(Seconds)
	Passport = tostring(Passport)

	if Wanted[Passport] then
		if os.time() > Wanted[Passport] then
			Wanted[Passport] = os.time() + Seconds
		else
			Wanted[Passport] = Wanted[Passport] + Seconds
		end
	else
		Wanted[Passport] = os.time() + Seconds
	end

	TriggerClientEvent("hud:Wanted",source,Wanted[Passport] - os.time())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wanted",function(Passport)
	if not WantedSystem then
		return false
	end

	Passport = tostring(Passport)

	return Wanted[Passport] and Wanted[Passport] > os.time() and true or false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	Passport = tostring(Passport)

	if not WantedSystem then
		Wanted[Passport] = nil
		Lock[Passport] = nil
		return
	end

	if Lock[Passport] then
		TriggerEvent("Wanted",source,Passport,Lock[Passport])

		Lock[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	Passport = tostring(Passport)

	if not WantedSystem then
		Wanted[Passport] = nil
		Lock[Passport] = nil
		return
	end

	if Wanted[Passport] then
		if Wanted[Passport] > os.time() then
			Lock[Passport] = (Wanted[Passport] - os.time())
		end

		Wanted[Passport] = nil
	end
end)
