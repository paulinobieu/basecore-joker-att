-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-crash",Core)
vCLIENT = Tunnel.getInterface("core-crash")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = false
local Selected = 0
local CrashType = "heli"
local EndsAt = 0
local NextSpawn = os.time()
local PlayersInside = {}
local PendingRespawns = {}
local MaxChests = 6
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBALSTATE
-----------------------------------------------------------------------------------------------------------------------------------------
GlobalState.Helibox = 0
GlobalState.Helicrash = false
GlobalState["CoreCrash"] = { active = false, selected = 0, crashType = "heli" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORMATTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
local function FormatTimer()
	local Remaining = EndsAt - os.time()
	if Remaining < 0 then
		Remaining = 0
	end

	return string.format("%02d:%02d",math.floor(Remaining / 60),Remaining % 60)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATION
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetLocation(Index)
	if Index == -1 then
		return Crash.Special
	end

	return Crash.Locations[Index]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDLOOT
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildLoot(Special)
	local Table = Crash.LootTables[math.random(#Crash.LootTables)]
	local Multiplier = Special and Crash.Special.LootMultiplier or 1
	local Itens = {}

	for Slot,Entry in ipairs(Table) do
		Itens[tostring(Slot)] = { item = Entry.item, amount = Entry.amount * Multiplier }
	end

	if Special and Crash.Special.Bonus then
		Itens[tostring(#Table + 1)] = { item = Crash.Special.Bonus.item, amount = Crash.Special.Bonus.amount }
	end

	return Itens
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEARCONTAINERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function ClearContainers()
	for Index = 1,MaxChests do
		Functions.SetContainer(Crash.ChestPrefix..":"..Index,{})
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTCRASH
-----------------------------------------------------------------------------------------------------------------------------------------
local function StartCrash(Index,Type)
	if Active then
		return false
	end

	local Location = GetLocation(Index)
	if not Location or not Location.Vehicle or not Location.Chests then
		return false
	end

	local Special = Index == -1
	if Special then
		Type = Crash.Special.Type
	end

	ClearContainers()

	local Count = #Location.Chests
	for Chest = 1,Count do
		Functions.SetContainer(Crash.ChestPrefix..":"..Chest,BuildLoot(Special))
		Functions.ChestCooldown(Crash.ChestPrefix..":"..Chest)
	end

	Active = true
	Selected = Index
	CrashType = Type or "heli"
	EndsAt = os.time() + Crash.Times.Duration
	PlayersInside = {}
	PendingRespawns = {}

	GlobalState.Helibox = Count
	GlobalState.Helicrash = true
	GlobalState["CoreCrash"] = { active = true, selected = Selected, crashType = CrashType }

	TriggerClientEvent("core-crash:spawn",-1,Selected,CrashType)
	Wait(100)
	Functions.Announce(nil,"Atenção!",Crash.Messages[CrashType] or Crash.Messages.stock)

	Functions.Webhook(Crash.Logs.Started,{
		description = "# CRASH INICIADO",
		fields = {
			{ name = "TIPO", value = Crash.Names[CrashType] or CrashType },
			{ name = "LOCALIZAÇÃO", value = Special and "Especial" or ("#"..Selected) },
		},
		footer = { text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S") },
		color = 2829875,
	})

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISHCRASH
-----------------------------------------------------------------------------------------------------------------------------------------
local function FinishCrash()
	if not Active then
		return false
	end

	Active = false
	NextSpawn = os.time() + Crash.Times.SpawnCooldown

	ClearContainers()

	PlayersInside = {}
	PendingRespawns = {}

	GlobalState.Helibox = 0
	GlobalState.Helicrash = false
	GlobalState["CoreCrash"] = { active = false, selected = 0, crashType = "heli" }

	TriggerClientEvent("core-crash:finished",-1)

	Functions.Webhook(Crash.Logs.Finished,{
		description = "# CRASH FINALIZADO",
		footer = { text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S") },
		color = 2829875,
	})

	Selected = 0
	CrashType = "heli"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AUTO SPAWN THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Now = os.date("%H:%M")
		if Crash.Schedule[Now] and not Active and os.time() >= NextSpawn and Functions.Online() > Crash.MinPlayers then
			if Now == Crash.SpecialTime then
				StartCrash(-1)
			else
				StartCrash(math.random(#Crash.Locations),"heli")
			end
		end

		Wait(60000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMER THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Active then
			local Timer = FormatTimer()
			for Passport,Source in pairs(PlayersInside) do
				TriggerClientEvent("core-crash:timer",Source,Timer)
			end
		end

		Wait(999)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISH THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Active and ((GlobalState.Helibox or 0) <= 0 or os.time() >= EndsAt) then
			FinishCrash()
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Enter()
	local source = source
	local Passport = Functions.Passport(source)
	if not Passport or not Active or PlayersInside[Passport] then
		return false
	end

	PlayersInside[Passport] = source
	Player(source).state.inCrash = true

	TriggerClientEvent("core-crash:timer",source,FormatTimer())
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXIT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Exit()
	local source = source
	local Passport = Functions.Passport(source)
	if not Passport or not PlayersInside[Passport] then
		return false
	end

	PlayersInside[Passport] = nil
	Player(source).state.inCrash = false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEATHLOG
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.DeathLog(VictimSource,Weapon)
	local source = source
	local Passport = Functions.Passport(source)
	local VictimPassport = Functions.Passport(VictimSource)
	if not Passport or not VictimPassport or Passport == VictimPassport then
		return false
	end

	local Killer = Functions.FullName(Passport).." #"..Passport
	local Victim = Functions.FullName(VictimPassport).." #"..VictimPassport

	TriggerClientEvent("core-crash:newKill",-1,Killer,Victim,Weapon)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUEUERESPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.QueueRespawn()
	if not Crash.Respawn.Enable then
		return false
	end

	local source = source
	local Passport = Functions.Passport(source)
	if not Passport or not Active or not PlayersInside[Passport] or PendingRespawns[Passport] then
		return false
	end

	if Functions.ItemAmount(Passport,Crash.Respawn.Item) < 1 then
		return false
	end

	if not Functions.TakeItem(Passport,Crash.Respawn.Item,1) then
		return false
	end

	PendingRespawns[Passport] = true

	CreateThread(function()
		Wait(Crash.Respawn.Timer * 1000)

		PendingRespawns[Passport] = nil

		local Target = Functions.Source(Passport)
		if not Target then
			return false
		end

		local Coords = Crash.Respawn.Coords

		PlayersInside[Passport] = nil
		Player(Target).state.inCrash = false

		TriggerClientEvent("core-crash:prepareRespawn",Target)
		Wait(250)

		Functions.Teleport(Target,Coords.x,Coords.y,Coords.z)
		SetEntityHeading(GetPlayerPed(Target),Coords.h or 0.0)
		Functions.Revive(Target,Crash.Respawn.Health)
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- START COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Crash.Commands.Start,function(source,args)
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Crash.Permission) then
		return Functions.Notify(source,"Atenção","Você não tem permissão para usar este comando.","vermelho",5000)
	end

	if Active then
		return Functions.Notify(source,"Atenção","Já existe um crash em andamento. Use /"..Crash.Commands.End.." para finalizar.","amarelo",5000)
	end

	local Type = args[1] and string.lower(args[1])
	if not Type or not Crash.Props[Type] then
		return Functions.Notify(source,"Atenção","Use: /"..Crash.Commands.Start.." heli | truck | stock | stockade [número]","vermelho",5000)
	end

	local Index = args[2] and tonumber(args[2]) or math.random(#Crash.Locations)
	if not Crash.Locations[Index] then
		return Functions.Notify(source,"Atenção","Localização inválida. Use um número entre 1 e "..#Crash.Locations..".","vermelho",5000)
	end

	if StartCrash(Index,Type) then
		Functions.Notify(source,"Sucesso","Crash iniciado. Tipo: "..(Crash.Names[Type] or Type).." | Localização: #"..Index..".","verde",5000)
		Functions.Log("CRASH",{
			message = Functions.FullName(Passport).." #"..Passport.." iniciou o crash ("..(Crash.Names[Type] or Type)..") no local #"..Index,
			adminName = Functions.FullName(Passport),
			adminId = Passport,
			Tipo = Crash.Names[Type] or Type,
			Local = Index,
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANDOM COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Crash.Commands.Random,function(source)
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Crash.Permission) then
		return Functions.Notify(source,"Atenção","Você não tem permissão para usar este comando.","vermelho",5000)
	end

	if Active then
		return Functions.Notify(source,"Atenção","Já existe um crash em andamento.","amarelo",5000)
	end

	local Index = math.random(#Crash.Locations)
	if StartCrash(Index,"heli") then
		Functions.Notify(source,"Sucesso","Crash iniciado. Tipo: Helicóptero | Localização: #"..Index..".","verde",5000)
		Functions.Log("CRASH",{
			message = Functions.FullName(Passport).." #"..Passport.." iniciou um crash aleatório no local #"..Index,
			adminName = Functions.FullName(Passport),
			adminId = Passport,
			Local = Index,
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPECIAL COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Crash.Commands.Special,function(source)
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Crash.Permission) then
		return Functions.Notify(source,"Atenção","Você não tem permissão para usar este comando.","vermelho",5000)
	end

	if Active then
		return Functions.Notify(source,"Atenção","Já existe um crash em andamento.","amarelo",5000)
	end

	if StartCrash(-1) then
		Functions.Notify(source,"Sucesso","Crash especial iniciado com sucesso.","verde",5000)
		Functions.Log("CRASH",{
			message = Functions.FullName(Passport).." #"..Passport.." iniciou o crash especial",
			adminName = Functions.FullName(Passport),
			adminId = Passport,
			Tipo = "Especial",
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOP COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
local function StopCommand(source)
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Crash.Permission) then
		return Functions.Notify(source,"Atenção","Você não tem permissão para usar este comando.","vermelho",5000)
	end

	if not Active then
		return Functions.Notify(source,"Atenção","Não há crash em andamento.","amarelo",5000)
	end

	FinishCrash()
	Functions.Notify(source,"Sucesso","Crash finalizado com sucesso.","verde",5000)
	Functions.Log("CRASH",{
		message = Functions.FullName(Passport).." #"..Passport.." finalizou o crash",
		adminName = Functions.FullName(Passport),
		adminId = Passport,
	})
end

RegisterCommand(Crash.Commands.Stop,function(source) StopCommand(source) end)
RegisterCommand(Crash.Commands.End,function(source) StopCommand(source) end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FAST COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Crash.Commands.Fast,function(source)
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Crash.Permission) or not Active then
		return false
	end

	EndsAt = os.time() + 5
	Functions.Notify(source,"Atenção","O crash será finalizado em instantes.","amarelo",5000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEST COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Crash.Commands.Test,function(source,args)
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Crash.Permission) then
		return Functions.Notify(source,"Atenção","Você não tem permissão para usar este comando.","vermelho",5000)
	end

	local Type = args[1] and string.lower(args[1]) or "heli"
	if not Crash.Messages[Type] then
		return Functions.Notify(source,"Atenção","Use: /"..Crash.Commands.Test.." heli | truck | stock | stockade","vermelho",5000)
	end

	Functions.Announce(source,"Atenção!",Crash.Messages[Type])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport,source)
	if not Passport then
		return false
	end

	PendingRespawns[Passport] = nil

	if PlayersInside[Passport] then
		PlayersInside[Passport] = nil

		Functions.Webhook(Crash.Logs.CombatLog,{
			description = "# COMBAT LOG",
			fields = {
				{ name = "AUTOR", value = Functions.FullName(Passport).." #"..Passport },
			},
			footer = { text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S") },
			color = 2829875,
		})
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("IsActive",function()
	return Active
end)

exports("GetTimer",function()
	return FormatTimer()
end)

exports("InCrash",function(Coords)
	if not Active then
		return false
	end

	local Location = GetLocation(Selected)
	if not Location or not Location.Vehicle then
		return false
	end

	local Vehicle = Location.Vehicle
	return #(vector3(Coords.x,Coords.y,Coords.z) - vector3(Vehicle.x,Vehicle.y,Vehicle.z)) <= Crash.AreaSize
end)
