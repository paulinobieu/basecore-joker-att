-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CARRY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Carry")
AddEventHandler("inventory:Carry",function()
	local source = source
	local Passport = Framework.Passport(source)
	if not Passport then return end

	if not Carry[Passport] then
		local OtherSource = Framework.Client.ClosestPed(source)
		if OtherSource then
			local OtherPassport = Framework.Passport(OtherSource)
			if OtherPassport and not Carry[OtherPassport] and Framework.DoesEntityExist(OtherSource) and not Framework.Client.PlayingAnim(OtherSource,"amb@world_human_sunbathe@female@back@idle_a","idle_a") and not Framework.IsEntityVisible(OtherSource) then
				Carry[Passport] = OtherSource
				Player(source)["state"]["Carry"] = true
				Player(OtherSource)["state"]["Carry"] = true
				TriggerClientEvent("inventory:Carry",OtherSource,source,"Attach")
			end
		end
	else
		if Framework.DoesEntityExist(Carry[Passport]) then
			TriggerClientEvent("inventory:Carry",Carry[Passport],source,"Detach")
			Player(Carry[Passport])["state"]["Carry"] = false
		end

		Player(source)["state"]["Carry"] = false
		Carry[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:SERVERCARRY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:ServerCarry")
AddEventHandler("inventory:ServerCarry",function(source,Passport,OtherSource,Handcuff)
	if Carry[Passport] then
		if Framework.DoesEntityExist(Carry[Passport]) then
			TriggerClientEvent("inventory:Carry",Carry[Passport],source,"Detach")
			Player(Carry[Passport])["state"]["Carry"] = false
		end

		Player(source)["state"]["Carry"] = false
		Carry[Passport] = nil
	else
		local OtherPassport = Framework.Passport(OtherSource)
		if OtherPassport and not Carry[OtherPassport] and Framework.DoesEntityExist(OtherSource) then
			Carry[Passport] = OtherSource
			Player(source)["state"]["Carry"] = true
			Player(OtherSource)["state"]["Carry"] = true
			TriggerClientEvent("inventory:Carry",OtherSource,source,"Attach",Handcuff)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CARRY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:CarryDetach")
AddEventHandler("inventory:CarryDetach",function(source,Passport)
	if Carry[Passport] then
		if Framework.DoesEntityExist(Carry[Passport]) then
			TriggerClientEvent("inventory:Carry",Carry[Passport],source,"Detach")
			Player(Carry[Passport])["state"]["Carry"] = false
		end

		Player(source)["state"]["Carry"] = false
		Carry[Passport] = nil
	end
end)
