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
Tunnel.bindInterface("admin",Core)
vKEYBOARD = Tunnel.getInterface("keyboard")
vCLIENT = Tunnel.getInterface("admin")
vHUD = Tunnel.getInterface("hud")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORELOGS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CoreLog(Category,Data)
	if GetResourceState("core_logs") == "started" then
		exports["core_logs"]:AddLog(Category,Data)
	end
end

local function LogName(Passport)
	return vRP.FullName(Passport).." #"..Passport
end

local function LogCoords(source)
	local Coords = vRP.GetEntityCoords(source)
	return ("%.1f, %.1f, %.1f"):format(Coords.x,Coords.y,Coords.z)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSAPORTE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("passaporte",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport then
		local Allowed = {}
		local Consult = exports.oxmysql:query_async("SELECT n.id AS missing_id FROM (SELECT n1.n + n10.n * 10 + n100.n * 100 + 1 AS id FROM (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n1, (SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) n10, (SELECT 0 AS n UNION ALL SELECT 1) n100) n LEFT JOIN characters c ON c.id = n.id WHERE n.id BETWEEN 1 AND 200 AND c.id IS NULL ORDER BY n.id")
		for _,v in ipairs(Consult) do
			Allowed[#Allowed + 1] = tostring(v.missing_id)
		end

		local Keyboard = vKEYBOARD.Instagram(source,Allowed)
		if Keyboard then
			local Price = 20000
			local OtherPassport = Passport
			local NewPassport = parseInt(Keyboard[1])

			if not vRP.Request(source,"Deseja efetuar o número do passaporte para <b>"..NewPassport.."</b>? A mudança tem o custo de <b>"..Dotted(Price).." Diamantes</b>.") then
				return false
			end

			if not vRP.PaymentGems(Passport,Price) then
				TriggerClientEvent("Notify",source,"Aviso","Diamantes insuficientes.","amarelo",5000)
				return false
			end

			if vRP.Identity(NewPassport) then
				TriggerClientEvent("Notify",source,"Aviso","Passaporte escolhido já existe.","amarelo",5000)
				return false
			end

			vRP.Kick(source,"Desconectado para mudança de passaporte, aguarde 60 segundos e tente conectar novamente.")

			while vRP.Source(Passport) do
				Wait(100)
			end

			local Vehicles = exports['core-vehicles']:getCharacterVehicles(OtherPassport)
			if Vehicles then
				for plate,v in pairs(Vehicles) do
					exports['core-vehicles']:transferVehicle(plate, NewPassport)
					local Trunkchest = vRP.GetSrvData("Trunkchest:"..OtherPassport..":"..v.index,true)
					vRP.SetSrvData("Trunkchest:"..NewPassport..":"..v.index,Trunkchest,true)
					vRP.RemSrvData("Trunkchest:"..OtherPassport..":"..v.index)
				end
			end

			local NewEntitydata = "Personal:"..NewPassport
			local ActualEntitydata = "Personal:"..OtherPassport
			local Entitydata = exports.oxmysql:query_async("SELECT * FROM entitydata WHERE Name = ?",{ ActualEntitydata })
			if Entitydata and #Entitydata > 0 then
				exports.oxmysql:update_async("UPDATE entitydata SET Name = ? WHERE Name = ?",{ NewEntitydata,ActualEntitydata })
			end

			local Character = exports.oxmysql:query_async("SELECT * FROM characters WHERE id = ?",{ OtherPassport })
			if Character and #Character > 0 then
				exports.oxmysql:update_async("UPDATE characters SET id = ? WHERE id = ?",{ NewPassport,OtherPassport })
			end

			exports["core-bank"]:MigratePassport(OtherPassport,NewPassport)

			local Races = exports.oxmysql:query_async("SELECT * FROM races WHERE Passport = ?",{ OtherPassport })
			if Races and #Races > 0 then
				exports.oxmysql:update_async("UPDATE races SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local Propertys = exports.oxmysql:query_async("SELECT * FROM propertys WHERE Passport = ?",{ OtherPassport })
			if Propertys and #Propertys > 0 then
				exports.oxmysql:update_async("UPDATE propertys SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local Playerdata = exports.oxmysql:query_async("SELECT * FROM playerdata WHERE Passport = ?",{ OtherPassport })
			if Playerdata and #Playerdata > 0 then
				exports.oxmysql:update_async("UPDATE playerdata SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local Painel_Transactions = exports.oxmysql:query_async("SELECT * FROM painel_creative_transactions WHERE Passport = ?",{ OtherPassport })
			if Painel_Transactions and #Painel_Transactions > 0 then
				exports.oxmysql:update_async("UPDATE painel_creative_transactions SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local Painel_Transactions_Transfer = exports.oxmysql:query_async("SELECT * FROM painel_creative_transactions WHERE Transfer = ?",{ OtherPassport })
			if Painel_Transactions_Transfer and #Painel_Transactions_Transfer > 0 then
				exports.oxmysql:update_async("UPDATE painel_creative_transactions SET Transfer = ? WHERE Transfer = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Arrest = exports.oxmysql:query_async("SELECT * FROM mdt_creative_arrest WHERE Passport = ?",{ OtherPassport })
			if MDT_Arrest and #MDT_Arrest > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_arrest SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Arrest_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_arrest WHERE Officer = ?",{ OtherPassport })
			if MDT_Arrest_Officer and #MDT_Arrest_Officer > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_arrest SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Medals_Officers = exports.oxmysql:query_async("SELECT * FROM mdt_creative_medals")
			if MDT_Medals_Officers and #MDT_Medals_Officers > 0 then
				for _,v in pairs(MDT_Medals_Officers) do
					local Updated = false
					local Officers = json.decode(v.Officers)
					for Index,Number in pairs(Officers) do
						if OtherPassport == Number then
							Officers[Index] = NewPassport
							Updated = true

							break
						end
					end

					if Updated then
						exports.oxmysql:update_async("UPDATE mdt_creative_medals SET Officers = ? WHERE id = ?",{ json.encode(Officers),v.id })
					end
				end
			end

			local MDT_Reports = exports.oxmysql:query_async("SELECT * FROM mdt_creative_reports WHERE Passport = ?",{ OtherPassport })
			if MDT_Reports and #MDT_Reports > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_reports SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Reports_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_reports WHERE Officer = ?",{ OtherPassport })
			if MDT_Reports_Officer and #MDT_Reports_Officer > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_reports SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Units_Officers = exports.oxmysql:query_async("SELECT * FROM mdt_creative_units")
			if MDT_Units_Officers and #MDT_Units_Officers > 0 then
				for _,v in pairs(MDT_Units_Officers) do
					local Updated = false
					local Officers = json.decode(v.Officers)
					for Index,Number in pairs(Officers) do
						if OtherPassport == Number then
							Officers[Index] = NewPassport
							Updated = true

							break
						end
					end

					if Updated then
						exports.oxmysql:update_async("UPDATE mdt_creative_units SET Officers = ? WHERE id = ?",{ json.encode(Officers),v.id })
					end
				end
			end

			local MDT_Vehicles = exports.oxmysql:query_async("SELECT * FROM mdt_creative_vehicles WHERE Passport = ?",{ OtherPassport })
			if MDT_Vehicles and #MDT_Vehicles > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_vehicles SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Vehicles_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_vehicles WHERE Officer = ?",{ OtherPassport })
			if MDT_Vehicles_Officer and #MDT_Vehicles_Officer > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_vehicles SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Wanted = exports.oxmysql:query_async("SELECT * FROM mdt_creative_wanted WHERE Passport = ?",{ OtherPassport })
			if MDT_Wanted and #MDT_Wanted > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_wanted SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Wanted_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_wanted WHERE Officer = ?",{ OtherPassport })
			if MDT_Wanted_Officer and #MDT_Wanted_Officer > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_wanted SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Warning = exports.oxmysql:query_async("SELECT * FROM mdt_creative_warning WHERE Passport = ?",{ OtherPassport })
			if MDT_Warning and #MDT_Warning > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_warning SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
			end

			local MDT_Warning_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_warning WHERE Officer = ?",{ OtherPassport })
			if MDT_Warning_Officer and #MDT_Warning_Officer > 0 then
				exports.oxmysql:update_async("UPDATE mdt_creative_warning SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
			end

			local Phone = exports.oxmysql:query_async("SELECT * FROM phone_phones WHERE owner_id = ?",{ OtherPassport })
			if Phone and #Phone > 0 then
				exports.oxmysql:update_async("UPDATE phone_phones SET owner_id = ?, id = ? WHERE owner_id = ?",{ NewPassport,NewPassport,OtherPassport })
			end

			local Permissions = vRP.UserGroups(OtherPassport)
			for Permission,Level in pairs(Permissions) do
				vRP.RemovePermission(OtherPassport,Permission)
				vRP.SetPermission(NewPassport,Permission,Level)
			end

			exports.oxmysql:update_async("UPDATE tickets_creative SET Author = ? WHERE Author = ?",{ NewPassport,OtherPassport })
			exports.oxmysql:update_async("UPDATE tickets_creative SET Assumed = ? WHERE Assumed = ?",{ NewPassport,OtherPassport })
			exports.oxmysql:update_async("UPDATE tickets_creative_messages SET Staff = ? WHERE Staff = ?",{ NewPassport,OtherPassport })
			exports.oxmysql:update_async("UPDATE tickets_creative_messages SET Author = ? WHERE Author = ?",{ NewPassport,OtherPassport })

			exports.crons:Swap(OtherPassport,NewPassport)

			local Playing = vRP.GetSrvData("Playing:"..OtherPassport,true)
			vRP.SetSrvData("Playing:"..NewPassport,Playing,true)
			vRP.RemSrvData("Playing:"..OtherPassport)

			CoreLog("TROCA-PASSAPORTE",{
				message = vRP.FullName(NewPassport).." #"..OtherPassport.." trocou o passaporte para #"..NewPassport,
				playerName = vRP.FullName(NewPassport),
				playerId = NewPassport,
				PassaporteAntigo = OtherPassport,
				Custo = "20.000 Diamantes"
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("passport",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",1) then
		local Keyboard = vKEYBOARD.Secondary(source,"Atual","Novo")
		if Keyboard then
			local NewPassport = parseInt(Keyboard[2])
			local OtherPassport = parseInt(Keyboard[1])
			if NewPassport > 0 and OtherPassport > 0 then
				if vRP.Source(OtherPassport) then
					return TriggerClientEvent("Notify",source,"Atenção","O passaporte "..OtherPassport.." precisa estar desconectado.","amarelo",5000)
				end

				if not vRP.Identity(OtherPassport) then
					return TriggerClientEvent("Notify",source,"Atenção","O passaporte "..OtherPassport.." não existe.","amarelo",5000)
				end

				if vRP.Identity(NewPassport) then
					return TriggerClientEvent("Notify",source,"Atenção","O passaporte "..NewPassport.." já existe.","amarelo",5000)
				end

				local Vehicles = exports['core-vehicles']:getCharacterVehicles(OtherPassport)
				if Vehicles then
					for plate,v in pairs(Vehicles) do
						exports['core-vehicles']:transferVehicle(plate, NewPassport)
						local Trunkchest = vRP.GetSrvData("Trunkchest:"..OtherPassport..":"..v.index,true)
						vRP.SetSrvData("Trunkchest:"..NewPassport..":"..v.index,Trunkchest,true)
						vRP.RemSrvData("Trunkchest:"..OtherPassport..":"..v.index)
					end
				end

				local NewEntitydata = "Personal:"..NewPassport
				local ActualEntitydata = "Personal:"..OtherPassport
				local Entitydata = exports.oxmysql:query_async("SELECT * FROM entitydata WHERE Name = ?",{ ActualEntitydata })
				if Entitydata and #Entitydata > 0 then
					exports.oxmysql:update_async("UPDATE entitydata SET Name = ? WHERE Name = ?",{ NewEntitydata,ActualEntitydata })
				end

				local Character = exports.oxmysql:query_async("SELECT * FROM characters WHERE id = ?",{ OtherPassport })
				if Character and #Character > 0 then
					exports.oxmysql:update_async("UPDATE characters SET id = ? WHERE id = ?",{ NewPassport,OtherPassport })
				end

				exports["core-bank"]:MigratePassport(OtherPassport,NewPassport)

				local Races = exports.oxmysql:query_async("SELECT * FROM races WHERE Passport = ?",{ OtherPassport })
				if Races and #Races > 0 then
					exports.oxmysql:update_async("UPDATE races SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local Propertys = exports.oxmysql:query_async("SELECT * FROM propertys WHERE Passport = ?",{ OtherPassport })
				if Propertys and #Propertys > 0 then
					exports.oxmysql:update_async("UPDATE propertys SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local Playerdata = exports.oxmysql:query_async("SELECT * FROM playerdata WHERE Passport = ?",{ OtherPassport })
				if Playerdata and #Playerdata > 0 then
					exports.oxmysql:update_async("UPDATE playerdata SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local Painel_Transactions = exports.oxmysql:query_async("SELECT * FROM painel_creative_transactions WHERE Passport = ?",{ OtherPassport })
				if Painel_Transactions and #Painel_Transactions > 0 then
					exports.oxmysql:update_async("UPDATE painel_creative_transactions SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local Painel_Transactions_Transfer = exports.oxmysql:query_async("SELECT * FROM painel_creative_transactions WHERE Transfer = ?",{ OtherPassport })
				if Painel_Transactions_Transfer and #Painel_Transactions_Transfer > 0 then
					exports.oxmysql:update_async("UPDATE painel_creative_transactions SET Transfer = ? WHERE Transfer = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Arrest = exports.oxmysql:query_async("SELECT * FROM mdt_creative_arrest WHERE Passport = ?",{ OtherPassport })
				if MDT_Arrest and #MDT_Arrest > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_arrest SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Arrest_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_arrest WHERE Officer = ?",{ OtherPassport })
				if MDT_Arrest_Officer and #MDT_Arrest_Officer > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_arrest SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Medals_Officers = exports.oxmysql:query_async("SELECT * FROM mdt_creative_medals")
				if MDT_Medals_Officers and #MDT_Medals_Officers > 0 then
					for _,v in pairs(MDT_Medals_Officers) do
						local Updated = false
						local Officers = json.decode(v.Officers)
						for Index,Number in pairs(Officers) do
							if OtherPassport == Number then
								Officers[Index] = NewPassport
								Updated = true

								break
							end
						end

						if Updated then
							exports.oxmysql:update_async("UPDATE mdt_creative_medals SET Officers = ? WHERE id = ?",{ json.encode(Officers),v.id })
						end
					end
				end

				local MDT_Reports = exports.oxmysql:query_async("SELECT * FROM mdt_creative_reports WHERE Passport = ?",{ OtherPassport })
				if MDT_Reports and #MDT_Reports > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_reports SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Reports_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_reports WHERE Officer = ?",{ OtherPassport })
				if MDT_Reports_Officer and #MDT_Reports_Officer > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_reports SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Units_Officers = exports.oxmysql:query_async("SELECT * FROM mdt_creative_units")
				if MDT_Units_Officers and #MDT_Units_Officers > 0 then
					for _,v in pairs(MDT_Units_Officers) do
						local Updated = false
						local Officers = json.decode(v.Officers)
						for Index,Number in pairs(Officers) do
							if OtherPassport == Number then
								Officers[Index] = NewPassport
								Updated = true

								break
							end
						end

						if Updated then
							exports.oxmysql:update_async("UPDATE mdt_creative_units SET Officers = ? WHERE id = ?",{ json.encode(Officers),v.id })
						end
					end
				end

				local MDT_Vehicles = exports.oxmysql:query_async("SELECT * FROM mdt_creative_vehicles WHERE Passport = ?",{ OtherPassport })
				if MDT_Vehicles and #MDT_Vehicles > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_vehicles SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Vehicles_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_vehicles WHERE Officer = ?",{ OtherPassport })
				if MDT_Vehicles_Officer and #MDT_Vehicles_Officer > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_vehicles SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Wanted = exports.oxmysql:query_async("SELECT * FROM mdt_creative_wanted WHERE Passport = ?",{ OtherPassport })
				if MDT_Wanted and #MDT_Wanted > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_wanted SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Wanted_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_wanted WHERE Officer = ?",{ OtherPassport })
				if MDT_Wanted_Officer and #MDT_Wanted_Officer > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_wanted SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Warning = exports.oxmysql:query_async("SELECT * FROM mdt_creative_warning WHERE Passport = ?",{ OtherPassport })
				if MDT_Warning and #MDT_Warning > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_warning SET Passport = ? WHERE Passport = ?",{ NewPassport,OtherPassport })
				end

				local MDT_Warning_Officer = exports.oxmysql:query_async("SELECT * FROM mdt_creative_warning WHERE Officer = ?",{ OtherPassport })
				if MDT_Warning_Officer and #MDT_Warning_Officer > 0 then
					exports.oxmysql:update_async("UPDATE mdt_creative_warning SET Officer = ? WHERE Officer = ?",{ NewPassport,OtherPassport })
				end

				local Phone = exports.oxmysql:query_async("SELECT * FROM phone_phones WHERE owner_id = ?",{ OtherPassport })
				if Phone and #Phone > 0 then
					exports.oxmysql:update_async("UPDATE phone_phones SET owner_id = ?, id = ? WHERE owner_id = ?",{ NewPassport,NewPassport,OtherPassport })
				end

				local Permissions = vRP.UserGroups(OtherPassport)
				for Permission,Level in pairs(Permissions) do
					vRP.RemovePermission(OtherPassport,Permission)
					vRP.SetPermission(NewPassport,Permission,Level)
				end

				exports.crons:Swap(OtherPassport,NewPassport)

				local Playing = vRP.GetSrvData("Playing:"..OtherPassport,true)
				vRP.SetSrvData("Playing:"..NewPassport,Playing,true)
				vRP.RemSrvData("Playing:"..OtherPassport)

				TriggerClientEvent("Notify",source,"Sucesso","Atualização de passaporte concluída.","verde",5000)

				CoreLog("PASSPORT",{
					message = LogName(Passport).." transferiu os dados do passaporte #"..OtherPassport.." para #"..NewPassport,
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					playerName = vRP.FullName(NewPassport),
					playerId = NewPassport,
					PassaporteAntigo = OtherPassport,
					Coords = LogCoords(source)
				})
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("players",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Number = 0
		local Message = ""
		local Players = vRP.Players()
		local Amounts = CountTable(Players)
		for OtherPassport in pairs(Players) do
			Number = Number + 1
			Message = Message..OtherPassport..(Number < Amounts and ", " or "")
		end

		TriggerClientEvent("chat:ClientMessage",source,"JOGADORES CONECTADOS",Message,"OOC")
		TriggerClientEvent("Notify",source,"Listagem","<b>Jogadores Conectados:</b> "..GetNumPlayerIndices(),"verde",5000)

		CoreLog("PLAYERS",{
			message = LogName(Passport).." listou os jogadores conectados",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Conectados = GetNumPlayerIndices(),
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLONE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("clone",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",3) and Message[1] and parseInt(Message[1]) > 0 then
		local OtherPassport = parseInt(Message[1])
		local Identity = vRP.Identity(OtherPassport)
		if Identity then
			vRPC.Skin(source,Identity.Skin)

			local Outfit = exports["core-customization"]:GetOutfit(OtherPassport)
			if Outfit then
				TriggerClientEvent("core-customization:applyTemporary",source,Outfit.clothes)
				TriggerClientEvent("core-customization:wearTattoos",source,Outfit.tattoos)
			end

			local Appearance = exports["core-character"]:GetAppearance(OtherPassport)
			if Appearance then
				TriggerClientEvent("core-character:applyAppearance",source,Appearance)
			end

			TriggerClientEvent("Notify",source,"Clonagem","Alterações conclúidas.","verde",5000)

			CoreLog("CLONE",{
				message = LogName(Passport).." clonou a aparência de "..LogName(OtherPassport),
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(OtherPassport),
				playerId = OtherPassport,
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRINT
-----------------------------------------------------------------------------------------------------------------------------------------
-- POSTIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("postit",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		TriggerClientEvent("chat:postit_new",source,true)

		CoreLog("POSTIT",{
			message = LogName(Passport).." criou um post-it no chat",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- USOURCE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("usource",function(source,Message)
	local Passport = vRP.Passport(source)
	local OtherSource = parseInt(Message[1])
	if Passport and OtherSource and OtherSource > 0 and vRP.Passport(OtherSource) and vRP.HasGroup(Passport,"Admin") then
		TriggerClientEvent("Notify",source,"Informações","<b>Passaporte:</b> "..vRP.Passport(OtherSource),"default",5000)

		CoreLog("USOURCE",{
			message = LogName(Passport).." consultou o source "..OtherSource.." ("..LogName(vRP.Passport(OtherSource))..")",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(vRP.Passport(OtherSource)),
			playerId = vRP.Passport(OtherSource),
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FREECAM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("freecam",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Freecam") then
		TriggerClientEvent("freecam:Active",source,Message)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ID
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("id",function(source,Message)
	local OtherPassport = Message[1]
	local Passport = vRP.Passport(source)
	if Passport and OtherPassport and vRP.Identity(OtherPassport) and vRP.HasGroup(Passport,"Admin") then
		local CountGroups = 0
		local Radio = "Desligado"
		local Message = "<br><br>"
		local Groups = vRP.UserGroups(OtherPassport)
		local OtherSource = vRP.Source(OtherPassport)
		for Permission,Level in pairs(Groups) do
			CountGroups = CountGroups + 1
			Message = Message.."[ <warning>"..Permission.."</warning> ] "..vRP.NameHierarchy(Permission,Level).." ( "..Level.." )<br>"
		end

		if OtherSource then
			Radio = vHUD.Radio(OtherSource) or "Desligado"
		end

		TriggerClientEvent("Notify",source,"Informações","<b>Passaporte:</b> "..OtherPassport.."<br><b>Nome:</b> "..vRP.FullName(OtherPassport).."<br><b>Banco:</b> "..Currency..Dotted(vRP.GetBank(OtherPassport)).."<br><b>Radio:</b> "..(Radio ~= ("Desligado" or 0) and Radio.."Mhz" or "Desligado").."<br><b>Telefone:</b> "..vRP.Phone(OtherPassport).."<br><b>Grupos Participantes:</b> "..CountGroups..(CountGroups >= 1 and Message or ""),(OtherSource and "verde" or "vermelho"),10000)

		CoreLog("ID",{
			message = LogName(Passport).." consultou as informações de "..LogName(parseInt(OtherPassport)),
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(parseInt(OtherPassport)),
			playerId = parseInt(OtherPassport),
			Banco = vRP.GetBank(OtherPassport),
			Telefone = vRP.Phone(OtherPassport),
			Radio = Radio,
			Grupos = CountGroups,
			Online = vRP.Source(OtherPassport) and "Sim" or "Não",
			Coords = LogCoords(source)
		})
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------
-- WIPEPERMISSIONS
------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("wipepermissions",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Permissions = {}
		for Permission in pairs(Groups) do
			Permissions[#Permissions + 1] = Permission
		end

		table.sort(Permissions,function(a,b) return a < b end)

		local Keyboard = vKEYBOARD.Instagram(source,Permissions)
		if Keyboard then
			local Permission = Keyboard[1]
			local Consult = exports.oxmysql:query_async("SELECT * FROM chests WHERE Permission LIKE ?",{ Permission.."%" })
			for _,v in pairs(Consult) do
				if v.Permission and SplitOne(v.Permission) == Permission and vRP.GetSrvData("Chest:"..v.Name,true) then
					vRP.RemSrvData("Chest:"..v.Name)
				end

				if v.id then
					exports.oxmysql:query_async("DELETE FROM chests WHERE id = ?",{ v.id })
				end
			end

			local Data = vRP.GetSrvData("Permissions:"..Permission,true)
			if Data then
				for OtherPassport in pairs(Data) do
					local OtherSource = vRP.Source(OtherPassport)
					if OtherSource then
						vRP.ServiceLeave(OtherSource,OtherPassport,Permission,true)
					end
				end

				vRP.RemSrvData("Permissions:"..Permission)
			end

			exports.oxmysql:query_async("DELETE FROM permissions WHERE Permission = ?",{ Permission })

			CoreLog("WIPEPERMISSIONS",{
				message = LogName(Passport).." limpou a permissão "..Permission.." de todos os jogadores e removeu os baús relacionados",
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				Permissao = Permission
			})
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------
-- CLEARPERMISSION
------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("clearpermission",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Keyboard = vKEYBOARD.Primary(source,"Passaporte")
		if Keyboard then
			local OtherPassport = parseInt(Keyboard[1])
			if vRP.Identity(OtherPassport) then
				local Removed = ""
				local Permissions = vRP.UserGroups(OtherPassport)
				for Permission,Level in pairs(Permissions) do
					vRP.RemovePermission(OtherPassport,Permission)
					Removed = Removed..(Removed ~= "" and ", " or "")..Permission.." ("..Level..")"
				end

				TriggerClientEvent("Notify",source,"Sucesso","Limpeza concluída.","verde",5000)

				CoreLog("CLEARPERMISSION",{
					message = LogName(Passport).." removeu todas as permissões de "..LogName(OtherPassport),
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Permissoes = Removed ~= "" and Removed or "Nenhuma",
					Online = vRP.Source(OtherPassport) and "Sim" or "Não",
					Coords = LogCoords(source)
				})
			end
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------
-- STATUS
------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("status",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Permissions = {}
		for Permission in pairs(Groups) do
			table.insert(Permissions,Permission)
		end

		table.sort(Permissions,function(a,b) return a < b end)

		local Keyboard = vKEYBOARD.Instagram(source,Permissions)
		if Keyboard then
			local Online = ""
			local Offline = ""
			local Permission = Keyboard[1]
			local Consult,Amount = vRP.DataGroups(Permission)
			local Table,Connects = vRP.NumPermission(Permission)

			local Message = "<warning>Jogadores Conectados:</warning> "..Connects.."<br><warning>Jogadores Participantes:</warning> "..Amount..(Amount >= 1 and "<br><br>" or "")

			for OtherPassport in pairs(Consult) do
				if Table[OtherPassport] then
					Online = Online.."<online>•</online> "..vRP.FullName(OtherPassport).." ( "..OtherPassport.." )<br>"
				else
					Offline = Offline.."<offline>•</offline> "..vRP.FullName(OtherPassport).." ( "..OtherPassport.." )<br>"
				end
			end

			TriggerClientEvent("Notify",source,Permission,Message..Online..Offline,"default",15000)

			CoreLog("STATUS",{
				message = LogName(Passport).." consultou os membros do grupo "..Permission,
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				Permissao = Permission,
				Conectados = Connects,
				Participantes = Amount,
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STAFF
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("staff",function(source)
	local Passport = vRP.Passport(source)
	if not Passport then return end

	local Level = vRP.HasPermission(Passport,"Admin")
	if not Level then
		return TriggerClientEvent("Notify",source,"Staff","Você não faz parte da equipe administrativa.","vermelho",5000)
	end

	if Level == 1 then
		return TriggerClientEvent("Notify",source,"Staff","Como <b>C-Level</b> você está sempre em serviço.","amarelo",5000)
	end

	local Entered = not vRP.HasService(Passport,"Admin")
	vRP.ServiceToggle(source,Passport,"Admin",true)

	TriggerClientEvent("Notify",source,"Staff",Entered and "Você <b>entrou</b> em serviço administrativo. Seus poderes estão ativos." or "Você <b>saiu</b> de serviço administrativo. Seus poderes foram desativados.",Entered and "verde" or "vermelho",5000)

	CoreLog("STAFF",{
		message = LogName(Passport)..(Entered and " entrou em" or " saiu de").." serviço administrativo",
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		Cargo = Groups.Admin.Hierarchy[Level] or "Staff",
		Servico = Entered and "Em serviço" or "Fora de serviço",
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STAFFS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("staffs",function(source)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasPermission(Passport,"Admin") then return end

	local OnDuty = ""
	local OffDuty = ""

	for OtherPassport in pairs(vRP.Players()) do
		local Level = vRP.HasPermission(OtherPassport,"Admin")
		if Level then
			local Cargo = Groups.Admin.Hierarchy[Level] or "Staff"
			local Line = "<b>"..vRP.FullName(OtherPassport).."</b> #"..OtherPassport.." — "..Cargo.."<br>"
			if Level == 1 or vRP.HasService(OtherPassport,"Admin") then
				OnDuty = OnDuty.."<online>•</online> "..Line
			else
				OffDuty = OffDuty.."<offline>•</offline> "..Line
			end
		end
	end

	local Message = "<warning>Em Serviço:</warning><br>"..(OnDuty ~= "" and OnDuty or "Ninguém<br>").."<br><warning>Fora de Serviço:</warning><br>"..(OffDuty ~= "" and OffDuty or "Ninguém")
	TriggerClientEvent("Notify",source,"Staffs Online",Message,"default",15000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("skin",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin",5) then
		return false
	end

	local Keyboard = vKEYBOARD.Tertiary(source,"Passaporte","Modelo","Dias")
	if not Keyboard then
		return false
	end

	local Model = Keyboard[2]
	if not vRPC.ModelExist(source,Model) then
		TriggerClientEvent("Notify",source,"Aviso","Modelo inválido.","amarelo",5000)
		return false
	end

	local Days = parseInt(Keyboard[3],true)
	local OtherPassport = parseInt(Keyboard[1])
	if OtherSource then
		vRPC.Skin(OtherSource,Model)
	end

	if Days > 0 then
		local CurrentTimer = os.time()
		local ExpireTime = Days * 86400
		local Consult = exports.oxmysql:single_async("SELECT SkinMontly FROM characters WHERE id = ? LIMIT 1",{ OtherPassport })
		if Consult then
			local NewExpire = (Consult.SkinMontly or 0) > CurrentTimer and Consult.SkinMontly + ExpireTime or CurrentTimer + ExpireTime
			exports.oxmysql:update_async("UPDATE characters SET SkinMontly = ? WHERE id = ?",{ NewExpire,OtherPassport })
		end
	end

	vRP.SkinCharacter(OtherPassport,Model)
	TriggerClientEvent("Notify",source,"Sucesso","Aplicação concluída.","verde",5000)
	exports.discord:Embed("Skin","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport.."\n**[MODEL]:** "..Model.."\n**[DIAS]:** "..Days)

	CoreLog("SKIN",{
		message = LogName(Passport).." aplicou a skin "..Model.." em "..LogName(OtherPassport),
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Modelo = Model,
		Dias = Days,
		Online = OtherSource and "Sim" or "Não",
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARINV
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("clearinv",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and parseInt(Message[1]) > 0 and vRP.HasGroup(Passport,"Admin",2) then
		vRP.ClearInventory(Message[1],true)
		TriggerClientEvent("Notify",source,"Sucesso","Limpeza concluída.","verde",5000)
		exports.discord:Embed("ClearInv","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..Message[1])

		CoreLog("CLEARINV",{
			message = LogName(Passport).." limpou o inventário de "..LogName(parseInt(Message[1])),
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(parseInt(Message[1])),
			playerId = parseInt(Message[1]),
			Online = vRP.Source(parseInt(Message[1])) and "Sim" or "Não",
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DIMA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("dima",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin",1) then
		return false
	end

	local Keyboard = vKEYBOARD.Secondary(source,"Passaporte","Quantidade")
	if not Keyboard then
		return false
	end

	local Amount = Keyboard[2]
	local OtherPassport = Keyboard[1]
	if not vRP.Identity(OtherPassport) then
		TriggerClientEvent("Notify",source,"Aviso","Passaporte inválido.","vermelho",5000)
		return false
	end

	vRP.UpgradeGemstone(OtherPassport,Amount,true)
	TriggerClientEvent("Notify",source,"Sucesso","Diamantes entregues.","verde",5000)
	exports.discord:Embed("Dima",("**[ADMIN]:** %s\n**[PASSAPORTE]:** %s\n**[QUANTIDADE]:** %sx"):format(Passport,OtherPassport,Amount))

	CoreLog("DIMA",{
		message = LogName(Passport).." adicionou "..Amount.."x diamantes para "..LogName(parseInt(OtherPassport)),
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(parseInt(OtherPassport)),
		playerId = parseInt(OtherPassport),
		Quantidade = parseInt(Amount),
		Online = vRP.Source(parseInt(OtherPassport)) and "Sim" or "Não",
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MONEY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("money",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin",1) then
		return false
	end

	local Keyboard = vKEYBOARD.Secondary(source,"Passaporte","Quantidade")
	if not Keyboard then
		return false
	end

	local Amount = Keyboard[2]
	local OtherPassport = Keyboard[1]
	if not vRP.Identity(OtherPassport) then
		TriggerClientEvent("Notify",source,"Aviso","Passaporte inválido.","vermelho",5000)
		return false
	end

	vRP.GiveBank(OtherPassport,Amount,true)
	TriggerClientEvent("Notify",source,"Sucesso","Dinheiros entregues.","verde",5000)
	exports.discord:Embed("Money",("**[ADMIN]:** %s\n**[PASSAPORTE]:** %s\n**[QUANTIDADE]:** %sx"):format(Passport,OtherPassport,Amount))

	CoreLog("MONEY",{
		message = LogName(Passport).." adicionou R$ "..Dotted(parseInt(Amount)).." no banco de "..LogName(parseInt(OtherPassport)),
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(parseInt(OtherPassport)),
		playerId = parseInt(OtherPassport),
		Valor = parseInt(Amount),
		SaldoNovo = vRP.GetBank(OtherPassport),
		Online = vRP.Source(parseInt(OtherPassport)) and "Sim" or "Não",
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("blips",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		vRPC.BlipAdmin(source)

		CoreLog("BLIPS",{
			message = LogName(Passport).." alternou os blips de admin no mapa",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GOD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("god",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		if Message[1] then
			local OtherPassport = parseInt(Message[1])
			local OtherSource = vRP.Source(OtherPassport)
			if OtherSource then
				vRP.Revive(OtherSource,300)
				vRP.UpgradeThirst(OtherPassport,10)
				vRP.UpgradeHunger(OtherPassport,10)
				vRP.DowngradeStress(OtherPassport,100)
				TriggerClientEvent("paramedic:Reset",OtherSource)

				exports.discord:Embed("God","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport)

				CoreLog("GOD",{
					message = LogName(Passport).." aplicou god em "..LogName(OtherPassport),
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Coords = LogCoords(source),
					CoordsAlvo = LogCoords(OtherSource)
				})
			end
		else
			vRP.Revive(source,300)
			vRP.Armour(source,100)
			vRP.UpgradeThirst(Passport,100)
			vRP.UpgradeHunger(Passport,100)
			vRP.DowngradeStress(Passport,100)
			TriggerClientEvent("paramedic:Reset",source)

			exports.discord:Embed("God","**[ADMIN]:** "..Passport)

			CoreLog("GOD",{
				message = LogName(Passport).." aplicou god em si mesmo",
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(Passport),
				playerId = Passport,
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("item",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",3) then
		if not Message[1] then
			local Keyboard = vKEYBOARD.Item(source,"Passaporte","Item","Quantidade",{ "Jogador","Todos","Area" },"Distância")
			if Keyboard and ItemExist(Keyboard[2]) then
				local Item = Keyboard[2]
				local Action = Keyboard[4]
				local OtherPassport = Keyboard[1]
				local Amount = parseInt(Keyboard[3],true)
				local Distance = parseInt(Keyboard[5],true)

				if Action == "Jogador" then
					if vRP.Source(OtherPassport) then
						vRP.GenerateItem(OtherPassport,Item,Amount,true)
						TriggerClientEvent("Notify",source,"Sucesso","Entregue ao destinatário.","verde",5000)
					else
						local Selected = GenerateString("DDLLDDLL")
						local Consult = vRP.GetSrvData("Offline:"..OtherPassport,true)

						repeat
							Selected = GenerateString("DDLLDDLL")
						until Selected and not Consult[Selected]

						TriggerClientEvent("Notify",source,"Sucesso","Adicionado a lista de entregas.","verde",5000)
						Consult[Selected] = { Item = Item, Amount = Amount }
						vRP.SetSrvData("Offline:"..OtherPassport,Consult,true)
					end
				elseif Action == "Todos" then
					local List = vRP.Players()
					for OtherPlayer in pairs(List) do
						async(function()
							vRP.GenerateItem(OtherPlayer,Item,Amount,true)
						end)
					end
				elseif Action == "Area" then
					local PlayerList = GetPlayers()
					local Coords = vRP.GetEntityCoords(source)

					for _,OtherSource in ipairs(PlayerList) do
						async(function()
							local OtherSource = parseInt(OtherSource)
							local OtherPassport = vRP.Passport(OtherSource)
							local OtherCoords = vRP.GetEntityCoords(OtherSource)

							if OtherCoords and OtherPassport and #(Coords - OtherCoords) <= Distance then
								vRP.GenerateItem(OtherPassport,Item,Amount,true)
							end
						end)
					end
				end

				exports.discord:Embed("Item","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport.."\n**[ITEM]:** "..Item.."\n**[QUANTIDADE]:** "..Amount.."x")

				local LogTarget = Action == "Jogador" and LogName(parseInt(OtherPassport)) or Action == "Todos" and "todos os jogadores" or "os jogadores da área"
				CoreLog("ITEM",{
					message = LogName(Passport).." entregou "..Amount.."x "..(ItemName(Item) or Item).." para "..LogTarget,
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					playerName = Action == "Jogador" and vRP.FullName(parseInt(OtherPassport)) or nil,
					playerId = Action == "Jogador" and parseInt(OtherPassport) or nil,
					Item = (ItemName(Item) or Item).." ("..Item..")",
					Quantidade = Amount,
					Modo = Action,
					Distancia = Action == "Area" and Distance or nil,
					Coords = LogCoords(source)
				})
			end
		elseif Message[1] and Message[2] then
			vRP.GenerateItem(Passport,Message[1],Message[2],true)
			exports.discord:Embed("Item","**[ADMIN]:** "..Passport.."\n**[ITEM]:** "..Message[1].."\n**[QUANTIDADE]:** "..Message[2].."x")

			CoreLog("ITEM",{
				message = LogName(Passport).." gerou "..Message[2].."x "..(ItemName(Message[1]) or Message[1]).." para si mesmo",
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(Passport),
				playerId = Passport,
				Item = (ItemName(Message[1]) or Message[1]).." ("..Message[1]..")",
				Quantidade = parseInt(Message[2]),
				Modo = "Próprio",
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("delete",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] and vRP.HasGroup(Passport,"Admin",1) then
		local DeletedName = vRP.FullName(Message[1])
		vRP.Update("characters/Delete",{ Passport = Message[1] })
		TriggerClientEvent("Notify",source,"Sucesso","Personagem <b>"..Message[1].."</b> deletado.","verde",5000)
		exports.discord:Embed("Delete","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..Message[1])

		CoreLog("DELETE",{
			message = LogName(Passport).." deletou o personagem "..DeletedName.." #"..Message[1],
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = DeletedName,
			playerId = parseInt(Message[1]),
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("nc",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		TriggerClientEvent("core:NoClip",source)

		CoreLog("NOCLIP",{
			message = LogName(Passport).." alternou o no-clip",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("kick",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",5) and parseInt(Message[1]) > 0 then
		local OtherPassport = Message[1]
		local OtherSource = vRP.Source(OtherPassport)
		if OtherSource then
			local TargetCoords = LogCoords(OtherSource)
			vRP.Kick(OtherSource,"Expulso da cidade")
			TriggerClientEvent("Notify",source,"Sucesso","Passaporte <b>"..OtherPassport.."</b> expulso.","verde",5000)
			exports.discord:Embed("Kick","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport)

			CoreLog("KICK",{
				message = LogName(Passport).." expulsou "..LogName(parseInt(OtherPassport)).." do servidor",
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(parseInt(OtherPassport)),
				playerId = parseInt(OtherPassport),
				Motivo = "Expulso da cidade",
				Coords = LogCoords(source),
				CoordsAlvo = TargetCoords
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INSERTCRON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("insertcron",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Keyboard = vKEYBOARD.Skins(source,"Passaporte","Permissão","Hierarquia","Quantidade",{ "Horas","Dias" })
		if Keyboard then
			local Timer = 0
			local Mode = Keyboard[5]
			local Permission = Keyboard[2]
			local OtherPassport = Keyboard[1]
			local Amount = parseInt(Keyboard[4],true)
			local Hierarchy = parseInt(Keyboard[3],true)

			if not vRP.HasPermission(OtherPassport,Permission) then
				vRP.SetPermission(OtherPassport,Permission)
			end

			if Mode == "Horas" then
				Timer = Amount * 3600
			elseif Mode == "Dias" then
				Timer = Amount * 86400
			end

			exports.crons:Insert(OtherPassport,"RemovePermission",Timer,{ Permission = Permission, Level = Hierarchy })
			TriggerClientEvent("Notify",source,"Sucesso","Adição efetuada.","verde",5000)

			CoreLog("INSERTCRON",{
				message = LogName(Passport).." adicionou a permissão temporária "..Permission.." para "..LogName(parseInt(OtherPassport)),
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(parseInt(OtherPassport)),
				playerId = parseInt(OtherPassport),
				Permissao = Permission,
				Hierarquia = Hierarchy,
				Tempo = Amount.." "..string.lower(Mode),
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVECRON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("removecron",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Keyboard = vKEYBOARD.Secondary(source,"Passaporte","Permissão")
		if Keyboard then
			exports.crons:Remove(Keyboard[1],"RemovePermission",Keyboard[2])
			TriggerClientEvent("Notify",source,"Sucesso","Remoção efetuada.","verde",5000)

			CoreLog("REMOVECRON",{
				message = LogName(Passport).." removeu a permissão temporária "..Keyboard[2].." de "..LogName(parseInt(Keyboard[1])),
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(parseInt(Keyboard[1])),
				playerId = parseInt(Keyboard[1]),
				Permissao = Keyboard[2],
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPCDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tpcds",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Keyboard = vKEYBOARD.Primary(source,"Cordenadas")
		if Keyboard then
			local Split = splitString(Keyboard[1],",")
			if Split[1] and Split[2] and Split[3] then
				local OriginCoords = LogCoords(source)
				vRP.Teleport(source,Split[1],Split[2],Split[3])

				CoreLog("TPCDS",{
					message = LogName(Passport).." teleportou para as coordenadas "..Keyboard[1],
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					CoordsOrigem = OriginCoords,
					CoordsDestino = Keyboard[1]
				})
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUCKET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("bucket",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",5) then
		exports.vrp:Bucket(source,"Enter",Message[1])

		CoreLog("BUCKET",{
			message = LogName(Passport).." entrou no bucket "..(Message[1] or "0"),
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Bucket = Message[1],
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("cds",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.DoesEntityExist(source) and vRP.HasGroup(Passport,"Admin") then
		local Ped = GetPlayerPed(source)
		local Coords = GetEntityCoords(Ped)
		local Heading = GetEntityHeading(Ped)

		vKEYBOARD.Copy(source,"Cordenadas",Optimize(Coords.x)..","..Optimize(Coords.y)..","..Optimize(Coords.z)..","..Optimize(Heading))

		CoreLog("CDS",{
			message = LogName(Passport).." copiou as coordenadas atuais",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = Optimize(Coords.x)..","..Optimize(Coords.y)..","..Optimize(Coords.z),
			Heading = Optimize(Heading)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("group",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] and Message[2] and vRP.HasGroup(Passport,"Admin",4) then
		local Permission = Message[2]
		local OtherPassport = Message[1]
		if Permission == "Admin" and vRP.HasPermission(Passport,Permission) >= 2 then
			return false
		end

		vRP.SetPermission(OtherPassport,Permission,Message[3])
		TriggerClientEvent("Notify",source,"Sucesso","Adicionado <b>"..Permission.."</b> ao passaporte <b>"..OtherPassport.."</b>.","verde",5000)
		exports.discord:Embed("Group","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport.."\n**[GRUPO]:** "..Permission.."\n**[Modo]:** Adicionou")

		CoreLog("GROUP",{
			message = LogName(Passport).." adicionou a permissão "..Permission.." para "..LogName(parseInt(OtherPassport)),
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(parseInt(OtherPassport)),
			playerId = parseInt(OtherPassport),
			Permissao = Permission,
			Hierarquia = Message[3] or 1,
			Online = vRP.Source(parseInt(OtherPassport)) and "Sim" or "Não",
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUPC
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("groupc",function(source,Message)
	if source ~= 0 then
		return false
	end

	local Permission = Message[2]
	local OtherPassport = parseInt(Message[1])
	if OtherPassport <= 0 or not Permission or Permission == "" then
		print("Use: groupc [passaporte] [permissao] [hierarquia]")
		return false
	end

	if not vRP.Identity(OtherPassport) then
		print(("Passaporte %s inválido."):format(OtherPassport))
		return false
	end

	vRP.SetPermission(OtherPassport,Permission,Message[3])
	print(("Permissão %s adicionada ao passaporte %s."):format(Permission,OtherPassport))
	exports.discord:Embed("Group","**[ADMIN]:** Console\n**[PASSAPORTE]:** "..OtherPassport.."\n**[GRUPO]:** "..Permission.."\n**[Modo]:** Adicionou")

	CoreLog("GROUP",{
		message = "Console adicionou a permissão "..Permission.." para "..LogName(OtherPassport),
		adminName = "Console",
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Permissao = Permission,
		Hierarquia = Message[3] or 1,
		Origem = "Console"
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNGROUP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("ungroup",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] and Message[2] and vRP.HasGroup(Passport,"Admin",2) then
		local Permission = Message[2]
		local OtherPassport = Message[1]
		if Permission == "Admin" and vRP.HasPermission(Passport,Permission) >= 2 then
			return false
		end

		vRP.RemovePermission(OtherPassport,Permission)
		TriggerClientEvent("Notify",source,"Sucesso","Removido <b>"..Permission.."</b> ao passaporte <b>"..OtherPassport.."</b>.","verde",5000)
		exports.discord:Embed("Group","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport.."\n**[GRUPO]:** "..Permission.."\n**[Modo]:** Removeu")

		CoreLog("UNGROUP",{
			message = LogName(Passport).." removeu a permissão "..Permission.." de "..LogName(parseInt(OtherPassport)),
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(parseInt(OtherPassport)),
			playerId = parseInt(OtherPassport),
			Permissao = Permission,
			Online = vRP.Source(parseInt(OtherPassport)) and "Sim" or "Não",
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPTOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tptome",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] and vRP.HasGroup(Passport,"Admin") then
		local OtherPassport = parseInt(Message[1])
		local OtherSource = vRP.Source(OtherPassport)
		if OtherSource and vRP.DoesEntityExist(OtherSource) then
			local TargetCoords = LogCoords(OtherSource)
			local Ped = GetPlayerPed(source)
			local Coords = GetEntityCoords(Ped)

			vRP.Teleport(OtherSource,Coords.x,Coords.y,Coords.z)

			CoreLog("TPTOME",{
				message = LogName(Passport).." puxou "..LogName(OtherPassport).." até si",
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(OtherPassport),
				playerId = OtherPassport,
				CoordsOrigem = TargetCoords,
				CoordsDestino = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPTO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tpto",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and Message[1] and vRP.HasGroup(Passport,"Admin") then
		local OtherPassport = parseInt(Message[1])
		local OtherSource = vRP.Source(OtherPassport)
		if OtherSource and vRP.DoesEntityExist(OtherSource) then
			local OriginCoords = LogCoords(source)
			local Ped = GetPlayerPed(OtherSource)
			local Coords = GetEntityCoords(Ped)

			vRP.Teleport(source,Coords.x,Coords.y,Coords.z)

			CoreLog("TPTO",{
				message = LogName(Passport).." teleportou até "..LogName(OtherPassport),
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(OtherPassport),
				playerId = OtherPassport,
				CoordsOrigem = OriginCoords,
				CoordsDestino = LogCoords(OtherSource)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPWAY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tpway",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local OriginCoords = LogCoords(source)
		vCLIENT.teleportWay(source)

		CoreLog("TPWAY",{
			message = LogName(Passport).." teleportou para o waypoint do mapa",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			CoordsOrigem = OriginCoords,
			CoordsDestino = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tuning",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",1) then
		TriggerClientEvent("admin:Tuning",source)

		CoreLog("TUNING",{
			message = LogName(Passport).." abriu o menu de tuning de veículos",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FIX
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fix",function(source)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",5) then
		local Vehicle,Network,Plate = vRPC.VehicleList(source)
		if Vehicle then
			local Players = vRPC.Players(source)
			for _,OtherSource in pairs(Players) do
				async(function()
					TriggerClientEvent("inventory:RepairAdmin",OtherSource,Network,Plate)
				end)
			end

			CoreLog("FIX",{
				message = LogName(Passport).." reparou o veículo de placa "..(Plate or "Desconhecida"),
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				Placa = Plate,
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN:DOORS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("admin:Doords")
AddEventHandler("admin:Doords",function(Coords,Model,Heading)
	vRP.Archive("coordenadas.txt","Coords = "..Coords..", Heading = "..Heading..", Hash = "..Model..", Disabled = false, Lock = true, Distance = 1.75")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CDS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.buttonTxt()
	local source = source
	local Passport = vRP.Passport(source)
	if Passport and vRP.DoesEntityExist(source) and vRP.HasGroup(Passport,"Admin") then
		local Ped = GetPlayerPed(source)
		local Coords = GetEntityCoords(Ped)
		local Heading = GetEntityHeading(Ped)

		vRP.Archive(Passport..".txt",Optimize(Coords.x)..","..Optimize(Coords.y)..","..Optimize(Coords.z)..","..Optimize(Heading))
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANNOUNCE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("announce",function(source,Message,History)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Keyboard = vKEYBOARD.Announce(source,"Título","Mensagem","Segundos",{ "amarelo","verde","vermelho","fome","sede","default","sangue","policia" },{ "middle-left","middle-right","top-left","top-center","top-right","bottom-left","bottom-center","bottom-right" })
		if Keyboard then
			local Title = Keyboard[1]
			local Colors = Keyboard[4]
			local Message = Keyboard[2]
			local Direction = Keyboard[5]
			local Seconds = parseInt(Keyboard[3],true) * 1000

			TriggerClientEvent("Notify",-1,Title,Message,Colors,Seconds,Direction)

			CoreLog("ANNOUNCE",{
				message = LogName(Passport).." enviou o anúncio global: "..Title,
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				Titulo = Title,
				Mensagem = Message,
				Segundos = Seconds / 1000,
				Cor = Colors,
				Posicao = Direction,
				Coords = LogCoords(source)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NAMEDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("nameds",function(source)
	if source ~= 0 then
		return false
	end

	local Consult = exports.oxmysql:query_async("SELECT id,Name,Lastname FROM characters")
	for _,v in ipairs(Consult) do
		local Name = v.Name ~= "" and FirstName(v.Name) or "Indivíduo"
		local Lastname = v.Lastname ~= "" and FirstName(v.Lastname) or "Indigente"

		exports.oxmysql:update_async("UPDATE characters SET Name = ?, Lastname = ? WHERE id = ?",{ Name,Lastname,v.id })

		Wait(100)
	end

	print(("Nomes ajustados para %d personagens."):format(#Consult))

	CoreLog("NAMEDS",{
		message = "Console ajustou os nomes de "..#Consult.." personagens",
		adminName = "Console",
		Personagens = #Consult
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONSOLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("console",function(source,Message,History)
	if source == 0 then
		TriggerClientEvent("Notify",-1,"Prefeitura",History:sub(8),"default",60000,"bottom-center")

		CoreLog("CONSOLE",{
			message = "Console enviou a mensagem global: "..History:sub(8),
			adminName = "Console",
			Mensagem = History:sub(8)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICKALL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("kickall",function(source)
	if source ~= 0 then
		local Passport = vRP.Passport(source)
		if not vRP.HasGroup(Passport,"Admin",1) then
			return
		end
	end

	local KickAdmin = source ~= 0 and vRP.Passport(source) or nil
	CoreLog("KICKALL",{
		message = (KickAdmin and LogName(KickAdmin) or "Console").." iniciou a expulsão de todos os jogadores (terremoto)",
		adminName = KickAdmin and vRP.FullName(KickAdmin) or "Console",
		adminId = KickAdmin,
		Jogadores = GetNumPlayerIndices(),
		Modo = "Gradual"
	})

	TriggerClientEvent("Notify",-1,"Prefeitura","Terremoto se aproxima em 3 minutos.","default",60000,"bottom-center")
	GlobalState.Weather = "RAIN"
	Wait(60000)

	TriggerClientEvent("Notify",-1,"Prefeitura","Terremoto se aproxima em 2 minutos.","default",60000,"bottom-center")
	Wait(60000)

	TriggerClientEvent("Notify",-1,"Prefeitura","Terremoto se aproxima em 1 minuto.","default",60000,"bottom-center")
	GlobalState.Weather = "THUNDER"
	Wait(60000)

	local List = vRP.Players()
	for _,OtherSource in pairs(List) do
		vRP.Kick(OtherSource,"Desconectado, a cidade reiniciou")
		Wait(100)
	end

	TriggerEvent("SaveServer",false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICKALL2
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("kickall2",function(source)
	if source ~= 0 then
		local Passport = vRP.Passport(source)
		if not vRP.HasGroup(Passport,"Admin",1) then
			return
		end
	end

	local KickAdmin = source ~= 0 and vRP.Passport(source) or nil
	CoreLog("KICKALL2",{
		message = (KickAdmin and LogName(KickAdmin) or "Console").." expulsou todos os jogadores imediatamente",
		adminName = KickAdmin and vRP.FullName(KickAdmin) or "Console",
		adminId = KickAdmin,
		Jogadores = GetNumPlayerIndices(),
		Modo = "Imediato"
	})

	local List = vRP.Players()
	for _,OtherSource in pairs(List) do
		vRP.Kick(OtherSource,"Desconectado, a cidade reiniciou")
		Wait(100)
	end

	TriggerEvent("SaveServer",false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("save",function(source)
	if source ~= 0 then
		local Passport = vRP.Passport(source)
		if not vRP.HasGroup(Passport,"Admin",1) then
			return
		end
	end

	local SaveAdmin = source ~= 0 and vRP.Passport(source) or nil
	CoreLog("SAVE",{
		message = (SaveAdmin and LogName(SaveAdmin) or "Console").." salvou o servidor",
		adminName = SaveAdmin and vRP.FullName(SaveAdmin) or "Console",
		adminId = SaveAdmin
	})

	TriggerEvent("SaveServer",false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOGSERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		Wait(10 * 60000)

		local Message = "**LISTAGEM DE JOGADORES**\n\n**[ PLAYERS ]:** "..GetNumPlayerIndices().."\n"
		for Permission in pairs(Groups) do
			Message = Message.."**[ "..string.upper(Permission).." ]:** "..vRP.AmountService(Permission).."\n"

			Wait(1000)
		end

		exports.discord:Embed("Permissions",Message)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RACECONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.RaceConfig(Left,Center,Right,Distance,Name)
	vRP.Archive(Name..".txt","{")

	vRP.Archive(Name..".txt","['Left'] = vec3("..Optimize(Left.x)..","..Optimize(Left.y)..","..Optimize(Left.z).."),")
	vRP.Archive(Name..".txt","['Center'] = vec3("..Optimize(Center.x)..","..Optimize(Center.y)..","..Optimize(Center.z).."),")
	vRP.Archive(Name..".txt","['Right'] = vec3("..Optimize(Right.x)..","..Optimize(Right.y)..","..Optimize(Right.z).."),")
	vRP.Archive(Name..".txt","['Distance'] = "..Distance)

	vRP.Archive(Name..".txt","},")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPECTATE
-----------------------------------------------------------------------------------------------------------------------------------------
local Spectate = {}
RegisterCommand("spectate",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin") then
		return false
	end

	if Spectate[Passport] then
		local Ped = GetPlayerPed(Spectate[Passport])
		if DoesEntityExist(Ped) then
			SetEntityDistanceCullingRadius(Ped,0.0)
		end

		TriggerClientEvent("admin:resetSpectate",source)
		Spectate[Passport] = nil

		CoreLog("SPECTATE",{
			message = LogName(Passport).." parou de espectar",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Modo = "Parou",
			Coords = LogCoords(source)
		})

		return false
	end

	local OtherPassport = parseInt(Message[1])
	if OtherSource then
		local Ped = GetPlayerPed(OtherSource)
		if DoesEntityExist(Ped) then
			Spectate[Passport] = OtherSource
			SetEntityDistanceCullingRadius(Ped,999999.0)

			SetTimeout(1000,function()
				TriggerClientEvent("admin:initSpectate",source,OtherSource)
			end)

			CoreLog("SPECTATE",{
				message = LogName(Passport).." começou a espectar "..LogName(OtherPassport),
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(OtherPassport),
				playerId = OtherPassport,
				Modo = "Iniciou",
				Coords = LogCoords(source),
				CoordsAlvo = LogCoords(OtherSource)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUAKE
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState.Quake = false
RegisterCommand("quake",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",1) then
		TriggerClientEvent("Notify",-1,"Terromoto","Os geólogos informaram para nossa unidade governamental que foi encontrado um abalo de magnitude <b>60</b> na <b>Escala Richter</b>, encontrem abrigo até que o mesmo passe.","amarelo",60000)
		GlobalState.Quake = true

		CoreLog("QUAKE",{
			message = LogName(Passport).." ativou o terremoto no servidor",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIMPAREA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("limparea",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin") then
		local Ped = GetPlayerPed(source)
		local Coords = GetEntityCoords(Ped)
		local Players = vRPC.Players(source)
		for _,Sources in pairs(Players) do
			async(function()
				vCLIENT.Limparea(Sources,Coords)
			end)
		end

		CoreLog("LIMPAREA",{
			message = LogName(Passport).." limpou os objetos da área",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VIDEO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("video",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		local Keyboard = vKEYBOARD.Instagram(source,{ "Passporte","Permissão","Area","Global","Fechar" })
		if Keyboard then
			if Keyboard[1] == "Passporte" then
				local Keyboard = vKEYBOARD.Secondary(source,"Passaporte","Código Vimeo")
				if Keyboard then
					local OtherPassport = parseInt(Keyboard[1])
					local OtherSource = vRP.Source(OtherPassport)
					if OtherSource then
						TriggerClientEvent("hud:Video",OtherSource,Keyboard[2])
						TriggerClientEvent("Notify",source,"Sucesso","Vídeo executado com sucesso.","verde",5000)

						CoreLog("VIDEO",{
							message = LogName(Passport).." reproduziu um vídeo para "..LogName(OtherPassport),
							adminName = vRP.FullName(Passport),
							adminId = Passport,
							playerName = vRP.FullName(OtherPassport),
							playerId = OtherPassport,
							Modo = "Passaporte",
							Codigo = Keyboard[2],
							Coords = LogCoords(source)
						})
					end
				end
			elseif Keyboard[1] == "Global" then
				local Keyboard = vKEYBOARD.Primary(source,"Código Vimeo")
				if Keyboard then
					TriggerClientEvent("hud:Video",-1,Keyboard[1])

					CoreLog("VIDEO",{
						message = LogName(Passport).." reproduziu um vídeo global",
						adminName = vRP.FullName(Passport),
						adminId = Passport,
						Modo = "Global",
						Codigo = Keyboard[1],
						Coords = LogCoords(source)
					})
				end
			elseif Keyboard[1] == "Permissão" then
				local Permissions = {}
				for Permission in pairs(Groups) do
					table.insert(Permissions,Permission)
				end

				table.sort(Permissions,function(a,b) return a < b end)
				local Keyboard = vKEYBOARD.Options(source,"Código Vimeo",Permissions)
				if Keyboard then
					local Service = vRP.NumPermission(Keyboard[2])
					for Passports,Sources in pairs(Service) do
						async(function()
							TriggerClientEvent("hud:Video",Sources,Keyboard[1])
						end)
					end

					TriggerClientEvent("Notify",source,"Sucesso","Vídeo executado com sucesso.","verde",5000)

					CoreLog("VIDEO",{
						message = LogName(Passport).." reproduziu um vídeo para o grupo "..Keyboard[2],
						adminName = vRP.FullName(Passport),
						adminId = Passport,
						Modo = "Permissão",
						Permissao = Keyboard[2],
						Codigo = Keyboard[1],
						Coords = LogCoords(source)
					})
				end
			elseif Keyboard[1] == "Area" then
				local Keyboard = vKEYBOARD.Secondary(source,"Distância","Código Vimeo")
				if Keyboard then
					local PlayerList = GetPlayers()
					local Coords = vRP.GetEntityCoords(source)

					for _,OtherSource in ipairs(PlayerList) do
						async(function()
							local OtherSource = parseInt(OtherSource)
							local OtherCoords = vRP.GetEntityCoords(OtherSource)

							if OtherCoords and #(Coords - OtherCoords) <= parseInt(Keyboard[1]) then
								TriggerClientEvent("hud:Video",OtherSource,Keyboard[2])
							end
						end)
					end

					TriggerClientEvent("Notify",source,"Sucesso","Vídeo executado com sucesso.","verde",5000)

					CoreLog("VIDEO",{
						message = LogName(Passport).." reproduziu um vídeo para os jogadores da área",
						adminName = vRP.FullName(Passport),
						adminId = Passport,
						Modo = "Area",
						Distancia = parseInt(Keyboard[1]),
						Codigo = Keyboard[2],
						Coords = LogCoords(source)
					})
				end
			elseif Keyboard[1] == "Fechar" then
				TriggerClientEvent("hud:Video",-1)

				CoreLog("VIDEO",{
					message = LogName(Passport).." encerrou os vídeos em reprodução",
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					Modo = "Fechar",
					Coords = LogCoords(source)
				})
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RENAME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("rename",function(source)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin",3) then
		return false
	end

	local Keyboard = vKEYBOARD.Tertiary(source,"Passaporte","Nome","Sobrenome")
	if not Keyboard then
		return false
	end

	local Name = Keyboard[2]
	local Lastname = Keyboard[3]
	local OtherPassport = parseInt(Keyboard[1])

	local Identity = vRP.Identity(OtherPassport)
	if not Identity then
		TriggerClientEvent("Notify",source,"Erro","Passaporte inválido.","vermelho",5000)
		return false
	end

	vRP.UpgradeNames(OtherPassport,Name,Lastname)
	TriggerClientEvent("Notify",source,"Sucesso","Nome atualizado.","verde",5000)

	CoreLog("RENAME",{
		message = LogName(Passport).." renomeou #"..OtherPassport.." de "..Identity.Name.." "..Identity.Lastname.." para "..Name.." "..Lastname,
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = Name.." "..Lastname,
		playerId = OtherPassport,
		NomeAntigo = Identity.Name.." "..Identity.Lastname,
		NomeNovo = Name.." "..Lastname,
		Coords = LogCoords(source)
	})

	local Account = vRP.Account(Identity.License)
	if Account and Account.Discord then
		exports.discord:Content("Rename",Account.Discord.." #"..OtherPassport.." "..Name.." "..Lastname)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDCAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("addcar",function(source)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin",1) then
		return false
	end

	local Keyboard = vKEYBOARD.Vehicle(source,"Passaporte","Modelo",{ "Mensal","Permanente","Dias" },"Dias",{ "Sim","Não" })
	if not Keyboard then return end

	local Mode = Keyboard[3]
	local Model = Keyboard[2]
	local Days = parseInt(Keyboard[4],true)
	local OtherPassport = parseInt(Keyboard[1],true)

	if not VehicleExist(Model) then
		TriggerClientEvent("Notify",source,"Erro","Modelo de veículo inválido.","vermelho",5000)
		return false
	end

	local Rental = nil
	local CurrentTimer = os.time()

	if Mode == "Mensal" then
		Rental = CurrentTimer + 30 * 24 * 60 * 60
	elseif Mode == "Dias" then
		Rental = CurrentTimer + (86400 * Days)
	end

	local Result = exports["core-vehicles"]:giveVehicle(OtherPassport,Model)
	if not Result or not Result.ok then
		TriggerClientEvent("Notify",source,"Erro","Não foi possível entregar o veículo.","vermelho",5000)
		return false
	end
	if Rental then
		exports.oxmysql:update_async("UPDATE core_characters_vehicles SET expire_time = ?, expired = 0 WHERE plate = ?",{ Rental, Result.plate })
	end
	exports.discord:Embed("AddCar","**[ADMIN]:** "..Passport.."\n**[PASSAPORTE]:** "..OtherPassport.."\n**[MODEL]:** "..Model.."\n**[TIPO]:** "..Mode)
	TriggerClientEvent("Notify",source,"Sucesso","Veículo <b>"..VehicleName(Model).."</b> entregue.","verde",5000)

	CoreLog("ADDCAR",{
		message = LogName(Passport).." adicionou o veículo "..VehicleName(Model).." para "..LogName(OtherPassport),
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Veiculo = VehicleName(Model).." ("..Model..")",
		Placa = Result.plate,
		Tipo = Mode,
		Dias = Mode == "Dias" and Days or nil,
		Online = vRP.Source(OtherPassport) and "Sim" or "Não",
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMCAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("remcar",function(source)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin",1) then
		return false
	end

	local Keyboard = vKEYBOARD.Primary(source,"Passaporte")
	if not Keyboard then
		return false
	end

	local OtherPassport = parseInt(Keyboard[1])
	local UserVehicles = exports['core-vehicles']:getCharacterVehicles(OtherPassport)
	if not UserVehicles or not next(UserVehicles) then
		TriggerClientEvent("Notify",source,"Erro","Este usuário não possui veículos.","vermelho",5000)
		return false
	end

	local VehicleList = {}
	local PlateMap = {}
	for plate,v in pairs(UserVehicles) do
		local label = v.name.." ["..plate.."]"
		VehicleList[#VehicleList + 1] = label
		PlateMap[label] = { plate = plate, index = v.index }
	end

	local Keyboard = vKEYBOARD.Instagram(source,VehicleList)
	if not Keyboard then
		return false
	end

	local Selected = Keyboard[1]
	local info = PlateMap[Selected]
	if info then
		vRP.RemSrvData("Trunkchest:"..OtherPassport..":"..info.index)
		exports['core-vehicles']:deleteVehicle(info.plate)
		TriggerClientEvent("Notify",source,"Sucesso","Veículo <b>"..Selected.."</b> removido.","verde",5000)

		CoreLog("REMCAR",{
			message = LogName(Passport).." removeu o veículo "..Selected.." de "..LogName(OtherPassport),
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(OtherPassport),
			playerId = OtherPassport,
			Veiculo = info.index,
			Placa = info.plate,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NITRO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("nitro",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",5) and vRP.InsideVehicle(source) then
		local Vehicle,Network,Plate = vRPC.VehicleList(source)
		if Vehicle then
			local Networked = NetworkGetEntityFromNetworkId(Network)
			if DoesEntityExist(Networked) then
				Entity(Networked).state:set("Nitro",2000,true)

				CoreLog("NITRO",{
					message = LogName(Passport).." adicionou nitro ao veículo de placa "..(Plate or "Desconhecida"),
					adminName = vRP.FullName(Passport),
					adminId = Passport,
					Placa = Plate,
					Quantidade = 2000,
					Coords = LogCoords(source)
				})
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fuel",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",5) and vRP.InsideVehicle(source) then
		TriggerClientEvent("engine:FuelAdmin",source)

		CoreLog("FUEL",{
			message = LogName(Passport).." abriu o menu de controle de combustível",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KILL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("kill",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) and Message[1] and parseInt(Message[1]) > 0 then
		local ClosestPed = vRP.Source(Message[1])
		if ClosestPed then
			vRPC.SetHealth(ClosestPed,100)

			CoreLog("KILL",{
				message = LogName(Passport).." matou "..LogName(parseInt(Message[1])).." via comando",
				adminName = vRP.FullName(Passport),
				adminId = Passport,
				playerName = vRP.FullName(parseInt(Message[1])),
				playerId = parseInt(Message[1]),
				Coords = LogCoords(source),
				CoordsAlvo = LogCoords(ClosestPed)
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	local Consult = vRP.GetSrvData("Offline:"..Passport,true)
	if Consult and next(Consult) then
		for _,v in ipairs(Consult) do
			vRP.GenerateItem(Passport,v.Item,v.Amount,true)
		end

		vRP.RemSrvData("Offline:"..Passport)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if Spectate[Passport] then
		local Ped = GetPlayerPed(Spectate[Passport])
		if Ped and DoesEntityExist(Ped) then
			SetEntityDistanceCullingRadius(Ped,0.0)
		end

		Spectate[Passport] = nil
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETHTTPHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
SetHttpHandler(function(Request,Result)
	if Request.headers.Auth ~= "SuaAuthCode" then
		return SendMessageDiscord(Result,400,"Falha na autenticação.")
	end

	local Commands = {
		["/god"] = function(Data)
			local v = json.decode(Data)
			local OtherPassport = parseInt(v.Passport)
			local OtherSource = vRP.Source(OtherPassport)

			if OtherPassport and OtherSource then
				vRP.Revive(OtherSource,300)
				vRP.UpgradeThirst(OtherPassport,100)
				vRP.UpgradeHunger(OtherPassport,100)
				TriggerClientEvent("paramedic:Reset",OtherSource)

				CoreLog("GOD",{
					message = "Webhook aplicou god em "..LogName(OtherPassport),
					adminName = "Webhook",
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Origem = "Webhook",
					CoordsAlvo = LogCoords(OtherSource)
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Personagem indisponível no momento.")
			end
		end,

		["/dima"] = function(Data)
			local v = json.decode(Data)
			local Amount = parseInt(v.Amount)
			local OtherPassport = parseInt(v.Passport)

			if OtherPassport and Amount > 0 then
				vRP.UpgradeGemstone(OtherPassport,Amount,true)

				CoreLog("DIMA",{
					message = "Webhook adicionou "..Amount.."x diamantes para "..LogName(OtherPassport),
					adminName = "Webhook",
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Quantidade = Amount,
					Origem = "Webhook",
					Online = vRP.Source(OtherPassport) and "Sim" or "Não"
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Personagem não encontrado.")
			end
		end,

		["/print"] = function(Data)
			local v = json.decode(Data)
			local OtherPassport = parseInt(v.Passport)
			local OtherSource = vRP.Source(OtherPassport)
			local Webhook = exports.discord:Webhook("Print")

			if OtherPassport and OtherSource and Webhook ~= "" then
				TriggerClientEvent("megazord:Screenshot",OtherSource,Webhook)

				CoreLog("PRINT",{
					message = "Webhook tirou print da tela de "..LogName(OtherPassport),
					adminName = "Webhook",
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Origem = "Webhook",
					CoordsAlvo = LogCoords(OtherSource)
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Personagem indisponível no momento.")
			end
		end,

		["/tdiscord"] = function(Data)
			local v = json.decode(Data)
			local NewDiscord = parseInt(v.NewDiscord)
			local OtherPassport = parseInt(v.Passport)
			local CurrentDiscord = parseInt(v.CurrentDiscord)

			if NewDiscord and OtherPassport and CurrentDiscord then
				local Account = vRP.AccountInformation(OtherPassport,"Discord")
				if Account and parseInt(Account) == CurrentDiscord then
					exports.oxmysql:update_async("UPDATE accounts SET Discord = ? WHERE Discord = ?",{ NewDiscord,Account })

					CoreLog("TDISCORD",{
						message = "Webhook alterou o Discord de "..LogName(OtherPassport),
						adminName = "Webhook",
						playerName = vRP.FullName(OtherPassport),
						playerId = OtherPassport,
						DiscordAntigo = CurrentDiscord,
						DiscordNovo = NewDiscord,
						Origem = "Webhook"
					})

					SendMessageDiscord(Result,200,"Comando executado com sucesso.")
				else
					SendMessageDiscord(Result,404,"Discord atual é diferente do enviado.")
				end
			else
				SendMessageDiscord(Result,404,"Personagem indisponível no momento.")
			end
		end,

		["/thex"] = function(Data)
			local v = json.decode(Data)
			local NewHexPlayer = v.NewHex
			local ActualHexPlayer = v.NewHex

			if NewHexPlayer and ActualHexPlayer then
				exports.oxmysql:query_async("DELETE FROM accounts WHERE License = ?",{ NewHexPlayer })
				exports.oxmysql:query_async("DELETE FROM characters WHERE License = ?",{ NewHexPlayer })
				exports.oxmysql:update_async("UPDATE accounts SET License = ? WHERE License = ?",{ NewHexPlayer,ActualHexPlayer })
				exports.oxmysql:update_async("UPDATE characters SET License = ? WHERE License = ?",{ NewHexPlayer,ActualHexPlayer })

				CoreLog("THEX",{
					message = "Webhook trocou a license "..ActualHexPlayer.." para "..NewHexPlayer,
					adminName = "Webhook",
					LicenseAntiga = ActualHexPlayer,
					LicenseNova = NewHexPlayer,
					Origem = "Webhook"
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Troca indisponível no momento.")
			end
		end,

		["/banned"] = function(Data)
			local v = json.decode(Data)
			local Duration = parseInt(v.Duration)
			local OtherPassport = parseInt(v.Passport)

			if OtherPassport and vRP.Identity(OtherPassport) then
				vRP.SetBanned(OtherPassport,Duration,v.Reason)

				CoreLog("BAN",{
					message = "Webhook baniu "..LogName(OtherPassport),
					adminName = "Webhook",
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Tempo = Duration.." minutos",
					Motivo = v.Reason,
					Origem = "Webhook",
					Online = vRP.Source(OtherPassport) and "Sim" or "Não"
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Personagem indisponível no momento.")
			end
		end,

		["/unbanned"] = function(Data)
			local v = json.decode(Data)
			local OtherPassport = parseInt(v.Passport)

			if OtherPassport and vRP.Identity(OtherPassport) then
				vRP.RemoveBanned(OtherPassport)

				CoreLog("UNBAN",{
					message = "Webhook removeu o banimento de "..LogName(OtherPassport),
					adminName = "Webhook",
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					Origem = "Webhook"
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Personagem indisponível no momento.")
			end
		end,

		["/limbo"] = function(Data)
			local v = json.decode(Data)
			local OtherPassport = parseInt(v.Passport)
			local OtherSource = vRP.Source(OtherPassport)

			if OtherPassport and OtherSource then
				local OriginCoords = LogCoords(OtherSource)
				vRP.Teleport(OtherSource,164.3,-998.45,29.35)

				CoreLog("LIMBO",{
					message = "Webhook enviou "..LogName(OtherPassport).." para o limbo",
					adminName = "Webhook",
					playerName = vRP.FullName(OtherPassport),
					playerId = OtherPassport,
					CoordsOrigem = OriginCoords,
					CoordsDestino = "164.3, -998.45, 29.35",
					Origem = "Webhook"
				})

				SendMessageDiscord(Result,200,"Comando executado com sucesso.")
			else
				SendMessageDiscord(Result,404,"Personagem indisponível no momento.")
			end
		end
	}

	if Commands[Request.path] then
		Request.setDataHandler(function(Table)
			Commands[Request.path](Table)
		end)
	else
		SendMessageDiscord(Result,404,"Comando indisponível no momento.")
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDMESSAGEDISCORD
-----------------------------------------------------------------------------------------------------------------------------------------
function SendMessageDiscord(Result,Code,Message)
	Result.writeHead(Code,{ ["Content-Type"] = "application/json" })
	Result.send(json.encode({ message = Message }))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIBERAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("liberar",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",5) and Message[1] and parseInt(Message[1]) > 0 then
		local OtherPassport = parseInt(Message[1])
		local Identity = vRP.Identity(OtherPassport)
		if not Identity then
			TriggerClientEvent("Notify",source,"Aviso","Passaporte inexistente.","amarelo",5000)
			return
		end

		local Amount = parseInt(Identity.Prison)
		if Amount <= 0 then
			TriggerClientEvent("Notify",source,"Aviso","O passaporte <b>"..OtherPassport.."</b> não está preso.","amarelo",5000)
			return
		end

		vRP.RemovePrison(OtherPassport)

		TriggerClientEvent("Notify",source,"Liberação","Passaporte <b>"..OtherPassport.."</b> liberado da prisão.","verde",5000)

		CoreLog("LIBERAR",{
			message = LogName(Passport).." liberou "..LogName(OtherPassport).." da prisão",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			playerName = vRP.FullName(OtherPassport),
			playerId = OtherPassport,
			TempoRestante = Amount.." minutos",
			Online = vRP.Source(OtherPassport) and "Sim" or "Não",
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACKOUT
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState.Blackout = false
RegisterCommand("blackout",function(source,Message)
	local Passport = vRP.Passport(source)
	if Passport and vRP.HasGroup(Passport,"Admin",2) then
		GlobalState.Blackout = not GlobalState.Blackout

		CoreLog("BLACKOUT",{
			message = LogName(Passport).." "..(GlobalState.Blackout and "ativou" or "desativou").." o apagão",
			adminName = vRP.FullName(Passport),
			adminId = Passport,
			Estado = GlobalState.Blackout and "Ativado" or "Desativado",
			Coords = LogCoords(source)
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POINTEXPERIENCE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("pointexperience",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasPermission(Passport,"Admin",1) then
		return false
	end

	local Keyboard = vKEYBOARD.Tertiary(source,"Passaporte","Trabalho","Quantidade")
	if not Keyboard then
		return false
	end

	local Work = Keyboard[2]
	local Amount = parseInt(Keyboard[3])
	local OtherPassport = parseInt(Keyboard[1])
	if OtherPassport <= 0 or not vRP.Identity(OtherPassport) then
		TriggerClientEvent("Notify",source,"Aviso","Passaporte inválido.","amarelo",5000)
		return false
	end

	if Amount <= 0 then
		TriggerClientEvent("Notify",source,"Aviso","Quantidade inválida.","amarelo",5000)
		return false
	end

	vRP.PutExperience(OtherPassport,Work,Amount)
	TriggerClientEvent("Notify",source,"Sucesso","Pontos enviados com sucesso.","verde",5000)

	CoreLog("EXPERIENCIA",{
		message = LogName(Passport).." deu "..Amount.." de experiência ("..tostring(Work)..") para "..LogName(OtherPassport),
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Trabalho = tostring(Work),
		Quantidade = Amount,
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LEADERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("leaders",function(source)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasPermission(Passport,"Admin") then
		return false
	end

	local Message = {}
	local HasLeaders = false
	for Permission,v in pairs(Groups) do
		if not v.Block then
			local PermissionData = vRP.GetSrvData("Permissions:"..Permission,true)
			for OtherPassport,Level in pairs(PermissionData) do
				if Level <= 1 and vRP.Source(OtherPassport) then
					HasLeaders = true
					Message[#Message + 1] = string.format("%s - %s ( %s )<br>",Permission,vRP.FullName(OtherPassport),OtherPassport)
				end
			end
		end
	end

	if HasLeaders then
		TriggerClientEvent("Notify",source,"Líderes de Grupo",table.concat(Message),"verde",30000)
	else
		TriggerClientEvent("Notify",source,"Líderes de Grupo","Nenhum líder online no momento.","amarelo",5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("addback",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin") then
		return
	end

	local OtherPassport = parseInt(Message[1])
	local Amount = parseInt(Message[2])
	if OtherPassport <= 0 or Amount <= 0 then
		TriggerClientEvent("Notify",source,"Mochila","Use <b>/addback passaporte quantidade</b>.","amarelo",5000)
		return
	end

	local OtherSource = vRP.Source(OtherPassport)
	if not OtherSource then
		TriggerClientEvent("Notify",source,"Mochila","O jogador precisa estar online.","vermelho",5000)
		return
	end

	local Weight = vRP.SetWeight(OtherPassport,vRP.GetWeight(OtherPassport) + Amount)
	TriggerClientEvent("Notify",source,"Mochila","Capacidade de <b>"..OtherPassport.."</b> agora é <b>"..Weight.."kg</b>.","verde",5000)

	TriggerClientEvent("Notify",OtherSource,"Mochila","Sua capacidade agora é <b>"..Weight.."kg</b>.","verde",5000)

	CoreLog("ADDBACK",{
		message = LogName(Passport).." adicionou "..Amount.."kg na mochila de "..LogName(OtherPassport).." (total "..Weight.."kg)",
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("remback",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin") then
		return
	end

	local OtherPassport = parseInt(Message[1])
	local Amount = parseInt(Message[2])
	if OtherPassport <= 0 or Amount <= 0 then
		TriggerClientEvent("Notify",source,"Mochila","Use <b>/remback passaporte quantidade</b>.","amarelo",5000)
		return
	end

	local OtherSource = vRP.Source(OtherPassport)
	if not OtherSource then
		TriggerClientEvent("Notify",source,"Mochila","O jogador precisa estar online.","vermelho",5000)
		return
	end

	local Weight = vRP.SetWeight(OtherPassport,vRP.GetWeight(OtherPassport) - Amount)
	TriggerClientEvent("Notify",source,"Mochila","Capacidade de <b>"..OtherPassport.."</b> agora é <b>"..Weight.."kg</b>.","verde",5000)

	TriggerClientEvent("Notify",OtherSource,"Mochila","Sua capacidade agora é <b>"..Weight.."kg</b>.","amarelo",5000)

	CoreLog("REMBACK",{
		message = LogName(Passport).." removeu "..Amount.."kg da mochila de "..LogName(OtherPassport).." (total "..Weight.."kg)",
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Coords = LogCoords(source)
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESETBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("resetback",function(source,Message)
	local Passport = vRP.Passport(source)
	if not Passport or not vRP.HasGroup(Passport,"Admin") then
		return
	end

	local OtherPassport = parseInt(Message[1])
	if OtherPassport <= 0 then
		TriggerClientEvent("Notify",source,"Mochila","Use <b>/resetback passaporte</b>.","amarelo",5000)
		return
	end

	local OtherSource = vRP.Source(OtherPassport)
	if not OtherSource then
		TriggerClientEvent("Notify",source,"Mochila","O jogador precisa estar online.","vermelho",5000)
		return
	end

	vRP.ResetBackpack(OtherPassport)

	TriggerClientEvent("Notify",source,"Mochila","Mochila de <b>"..OtherPassport.."</b> voltou ao padrão (<b>"..MinimumWeight.."kg</b> e <b>"..MinimumSlots.." espaços</b>).","verde",5000)

	TriggerClientEvent("Notify",OtherSource,"Mochila","Sua mochila voltou ao padrão.","amarelo",5000)
	TriggerClientEvent("inventory:Update",OtherSource)

	CoreLog("RESETBACK",{
		message = LogName(Passport).." resetou a mochila de "..LogName(OtherPassport),
		adminName = vRP.FullName(Passport),
		adminId = Passport,
		playerName = vRP.FullName(OtherPassport),
		playerId = OtherPassport,
		Coords = LogCoords(source)
	})
end)
