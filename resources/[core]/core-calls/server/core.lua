-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core  = {}
Tunnel.bindInterface("core-calls",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Wait(1500)
	Functions.Execute([[
		CREATE TABLE IF NOT EXISTS core_calls (
			id INT(11) NOT NULL AUTO_INCREMENT,
			staff INT(11) NOT NULL,
			fast TINYINT(1) DEFAULT 0,
			stars INT(11) DEFAULT 5,
			period VARCHAR(8) DEFAULT '',
			created_at INT(11) DEFAULT 0,
			PRIMARY KEY (id),
			KEY idx_staff (staff),
			KEY idx_period (period)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
	]])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------------------------------------------------------------------------
local Tickets    = {}
local Cooldown   = {}
local NotifyOff  = {}
local Watching   = {}
local Garages    = {}
local StaffCache = {}  -- { [Passport] = source } admins online
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGES
-----------------------------------------------------------------------------------------------------------------------------------------
local function LoadGarages()
	local Cfg = Calls.Garage or {}
	local Source = LoadResourceFile(Cfg.Resource or "core-vehicles",Cfg.ConfigFile or "config/garages.lua")
	if not Source then
		print(("[core-calls] nao foi possivel ler %s/%s"):format(Cfg.Resource or "?",Cfg.ConfigFile or "?"))
		return {}
	end

	local Env   = setmetatable({},{ __index = _G })
	local Chunk = load(Source,"@"..(Cfg.Resource or "?").."/"..(Cfg.ConfigFile or "?"),"t",Env)
	if not Chunk then return {} end

	local Ok,Err = pcall(Chunk)
	if not Ok then
		print(("[core-calls] erro carregando garagens: %s"):format(tostring(Err)))
		return {}
	end

	local Allowed = Cfg.AllowedTypes or { NORMAL = true }
	local Public  = Cfg.OnlyPublic
	local Raw     = Env.garages or {}
	local Out     = {}

	for _,Entry in ipairs(Raw) do
		local TypeOk = not next(Allowed) or Allowed[Entry.type or "NORMAL"]
		local PermOk = (not Public) or (Entry.permission == nil)
		if TypeOk and PermOk and Entry.open then
			Out[#Out + 1] = {
				name = Entry.name or "Garagem",
				type = Entry.type or "NORMAL",
				x    = Entry.open[1] or 0.0,
				y    = Entry.open[2] or 0.0,
				z    = Entry.open[3] or 0.0,
				h    = Entry.open[4] or 0.0,
			}
		end
	end

	return Out
end

CreateThread(function()
	Wait(2000)
	Garages = LoadGarages()
	print(("[core-calls] %d garagem(ns) publica(s) carregada(s)"):format(#Garages))
end)

AddEventHandler("onResourceStart",function(Resource)
	if Resource == GetCurrentResourceName() then
		CreateThread(function()
			Wait(2000)
			for _,RawSrc in ipairs(GetPlayers()) do
				local Src      = tonumber(RawSrc)
				local Passport = Functions.Passport(Src)
				if Passport and Functions.HasPermission(Passport,Calls.StaffPermission) then
					StaffCache[Passport] = Src
				end
			end
			print(("[core-calls] cache de staff inicializado: %d admin(s) online"):format(CountTable(StaffCache)))
		end)
	end
	if Resource ~= (Calls.Garage and Calls.Garage.Resource or "core-vehicles") then return end
	SetTimeout(2000,function() Garages = LoadGarages() end)
end)

local function NearestGarage(X,Y,Z)
	local Best,BestDist
	for _,G in ipairs(Garages) do
		local D = #(vector3(X,Y,Z) - vector3(G.x,G.y,G.z))
		if not BestDist or D < BestDist then
			BestDist = D
			Best     = G
		end
	end
	return Best
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CurrentPeriod()
	return os.date("%m-%y")
end

local function TrimText(Text)
	return (tostring(Text or "")):gsub("^%s+",""):gsub("%s+$","")
end

local function SnapshotTickets()
	local Out,Count = {},0
	for Id,T in pairs(Tickets) do
		if not T.response then
			Count = Count + 1
			Out[Count] = {
				id        = Id,
				name      = T.name,
				text      = T.text,
				hour      = T.hour,
				createdAt = T.initTime,
			}
		end
	end
	table.sort(Out,function(A,B) return A.createdAt < B.createdAt end)
	return Out
end

local function BroadcastUpdate()
	local Snapshot = SnapshotTickets()
	for Passport in pairs(Watching) do
		local Src = vRP.Source(Passport)
		if Src then
			TriggerClientEvent("core-calls:Update",Src,Snapshot)
		else
			Watching[Passport] = nil
		end
	end
end

local function OnlineStaff()
	local Out = {}
	for Passport,Src in pairs(StaffCache) do
		Out[#Out + 1] = { passport = Passport, source = Src }
	end
	return #Out,Out
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROFILE / RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildProfile(Passport)
	local Rows = Functions.Query("SELECT * FROM core_calls WHERE staff = ?",{ Passport }) or {}
	local Positives,Negatives,Fast = 0,0,0
	for _,Row in ipairs(Rows) do
		local Stars = tonumber(Row.stars) or 0
		if Stars >= 4 then Positives = Positives + 1
		elseif Stars <= 2 then Negatives = Negatives + 1 end
		if tonumber(Row.fast) == 1 then Fast = Fast + 1 end
	end
	return {
		id        = Passport,
		name      = Functions.FullName(Passport),
		role      = Functions.StaffRank(Passport),
		total     = #Rows,
		positives = Positives,
		negatives = Negatives,
		fast      = Fast,
	}
end

local function BuildRanking(Period)
	local Rows = Functions.Query([[
		SELECT staff,
		       COUNT(*) AS total,
		       SUM(CASE WHEN stars >= 4 THEN 1 ELSE 0 END) AS positives,
		       SUM(CASE WHEN stars <= 2 THEN 1 ELSE 0 END) AS negatives,
		       SUM(CASE WHEN fast = 1 THEN 1 ELSE 0 END)  AS fast
		FROM core_calls
		WHERE (? = '' OR period = ?)
		GROUP BY staff
		ORDER BY total DESC
		LIMIT 15
	]],{ Period or "", Period or "" }) or {}

	local Out = {}
	for _,Row in ipairs(Rows) do
		local Passport = tonumber(Row.staff)
		Out[#Out + 1] = {
			staff     = Passport,
			name      = Functions.FullName(Passport),
			role      = Functions.StaffRank(Passport),
			total     = tonumber(Row.total) or 0,
			positives = tonumber(Row.positives) or 0,
			negatives = tonumber(Row.negatives) or 0,
			fast      = tonumber(Row.fast) or 0,
		}
	end
	return Out
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TICKETS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CreateTicket(source,Passport,RawText)
	local Text = TrimText(RawText)
	if Text == "" then
		Functions.Notify(source,"vermelho","Mensagem vazia.")
		return false
	end

	local Now = os.time()
	if Cooldown[Passport] and Cooldown[Passport] > Now then
		Functions.Notify(source,"amarelo","Aguarde <b>"..(Cooldown[Passport] - Now).."s</b> antes de abrir outro chamado.")
		return false
	end
	if Tickets[Passport] then
		Functions.Notify(source,"amarelo","Voce ja tem um chamado em aberto.")
		return false
	end

	local Online,Staff = OnlineStaff()
	if Online == 0 then
		Functions.Notify(source,"vermelho","Nenhum staff em servico no momento.")
		return false
	end

	Cooldown[Passport] = Now + Calls.PlayerCooldown
	Tickets[Passport] = {
		id       = Passport,
		source   = source,
		name     = Functions.FullName(Passport),
		text     = Text,
		hour     = os.date("%H:%M:%S"),
		initTime = Now,
		response = nil,
	}

	local Snapshot = SnapshotTickets()
	for _,Entry in ipairs(Staff) do
		if not NotifyOff[Entry.passport] and Entry.source ~= source then
			TriggerClientEvent("core-calls:Incoming",Entry.source,{
				id   = Passport,
				name = Tickets[Passport].name,
				text = Text,
				time = Calls.AcceptTimeout,
			})
			if Watching[Entry.passport] then
				TriggerClientEvent("core-calls:Update",Entry.source,Snapshot)
			end
		end
	end

	Functions.Notify(source,"verde","Chamado enviado para <b>"..Online.."</b> staff(s).")
	return true
end

local function AcceptTicket(StaffSrc,StaffPassport,TicketId)
	local T = Tickets[TicketId]
	if not T then return false,"Chamado nao existe mais." end
	if T.response then return false,"Outro staff ja atendeu." end

	local PlayerSrc = vRP.Source(TicketId)
	if not PlayerSrc then
		Tickets[TicketId] = nil
		BroadcastUpdate()
		return false,"O jogador saiu da cidade."
	end

	T.response       = StaffPassport
	T.responseAt     = os.time()
	T.responseSource = StaffSrc

	local Coords = GetEntityCoords(GetPlayerPed(PlayerSrc))
	TriggerClientEvent("core-calls:Accepted",StaffSrc,{
		id     = TicketId,
		name   = T.name,
		text   = T.text,
		coords = { x = Coords.x, y = Coords.y, z = Coords.z },
		target = PlayerSrc,
	})

	Functions.Notify(PlayerSrc,"verde","Seu chamado foi aceito. Aguarde no local.")
	Functions.Notify(StaffSrc,"verde","Chamado de <b>"..T.name.."</b> aceito.")

	BroadcastUpdate()
	return true
end

local function DeclineTicket(StaffPassport,TicketId)
	local T = Tickets[TicketId]
	if not T then return false end
	if T.response and T.response ~= StaffPassport then return false end

	local PlayerSrc = vRP.Source(TicketId)
	if PlayerSrc then
		Functions.Notify(PlayerSrc,"vermelho","Seu chamado foi recusado.")
	end
	Tickets[TicketId] = nil
	BroadcastUpdate()
	return true
end

local function FinishTicket(StaffSrc,StaffPassport,TicketId)
	local T = Tickets[TicketId]
	if not T or T.response ~= StaffPassport then return false end

	local Elapsed = os.time() - T.initTime
	T.fast       = (Elapsed <= Calls.FastThreshold) and 1 or 0
	T.finishedAt = os.time()

	local PlayerSrc = vRP.Source(TicketId)
	if PlayerSrc then
		TriggerClientEvent("core-calls:Feedback",PlayerSrc,{
			name = Functions.FullName(StaffPassport),
			role = Functions.StaffRank(StaffPassport),
		})
	else
		Functions.Insert("INSERT INTO core_calls (staff,fast,stars,period,created_at) VALUES (?,?,?,?,?)",{
			StaffPassport, T.fast, 5, CurrentPeriod(), os.time(),
		})
		Tickets[TicketId] = nil
		BroadcastUpdate()
	end

	TriggerClientEvent("core-calls:Finished",StaffSrc)
	Functions.Notify(StaffSrc,"verde","Chamado finalizado.")
	return true
end

local function SubmitFeedback(PlayerSrc,Passport,Stars)
	Stars = math.max(1,math.min(5,tonumber(Stars) or 5))
	local T = Tickets[Passport]
	if not T or not T.response then return false end

	local StaffPassport = T.response
	local StaffSrc      = vRP.Source(StaffPassport)
	if StaffSrc then
		Functions.Notify(StaffSrc,"verde","Voce recebeu <b>"..Stars.."</b> estrela(s).")
	end

	Functions.Insert("INSERT INTO core_calls (staff,fast,stars,period,created_at) VALUES (?,?,?,?,?)",{
		StaffPassport, T.fast or 0, Stars, CurrentPeriod(), os.time(),
	})

	Tickets[Passport] = nil
	BroadcastUpdate()
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATTENDING TARGET
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResolveAttending(StaffPassport)
	for TicketId,T in pairs(Tickets) do
		if T.response == StaffPassport then
			return TicketId,vRP.Source(TicketId)
		end
	end
	return nil,nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNNEL (NUI)
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.OpenTicket(Text)
	local source   = source
	local Passport = Functions.Passport(source)
	if not Passport then return { ok = false } end
	return { ok = CreateTicket(source,Passport,Text) }
end

function Core.GetInitial()
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return nil end
	Watching[Passport] = true
	return {
		tickets = SnapshotTickets(),
		profile = BuildProfile(Passport),
		ranking = { allTime = BuildRanking(""), monthly = BuildRanking(CurrentPeriod()) },
	}
end

function Core.ClosePanel()
	local source   = source
	local Passport = Functions.Passport(source)
	if Passport then Watching[Passport] = nil end
end

function Core.AcceptTicket(TicketId)
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end
	local Ok,Err = AcceptTicket(source,Passport,tonumber(TicketId))
	if not Ok and Err then Functions.Notify(source,"amarelo",Err) end
	return { ok = Ok }
end

function Core.DeclineTicket(TicketId)
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end
	return { ok = DeclineTicket(Passport,tonumber(TicketId)) }
end

function Core.SubmitFeedback(Stars)
	local source   = source
	local Passport = Functions.Passport(source)
	if not Passport then return { ok = false } end
	return { ok = SubmitFeedback(source,Passport,Stars) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STAFF ACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.StaffRevive()
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end

	local TicketId,TargetSrc = ResolveAttending(Passport)
	if not TicketId or not TargetSrc then
		Functions.Notify(source,"vermelho","Sem chamado em atendimento.")
		return { ok = false }
	end

	vRP.Revive(TargetSrc,300)
	vRP.UpgradeThirst(TicketId,100)
	vRP.UpgradeHunger(TicketId,100)
	vRP.DowngradeStress(TicketId,100)

	Functions.Notify(source,"verde","Jogador <b>#"..TicketId.."</b> revivido.")
	Functions.Notify(TargetSrc,"amarelo","Voce foi revivido pela staff.")
	return { ok = true }
end

function Core.StaffTpTo()
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end

	local TicketId,TargetSrc = ResolveAttending(Passport)
	if not TicketId or not TargetSrc then
		Functions.Notify(source,"vermelho","Sem chamado em atendimento.")
		return { ok = false }
	end

	local Coords = GetEntityCoords(GetPlayerPed(TargetSrc))
	SetEntityCoords(GetPlayerPed(source),Coords.x + 0.5,Coords.y + 0.5,Coords.z,false,false,false,false)
	Functions.Notify(source,"verde","Teleportado ate o jogador <b>#"..TicketId.."</b>.")
	return { ok = true }
end

function Core.StaffPullPlayer()
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end

	local TicketId,TargetSrc = ResolveAttending(Passport)
	if not TicketId or not TargetSrc then
		Functions.Notify(source,"vermelho","Sem chamado em atendimento.")
		return { ok = false }
	end

	local Coords = GetEntityCoords(GetPlayerPed(source))
	SetEntityCoords(GetPlayerPed(TargetSrc),Coords.x + 0.5,Coords.y + 0.5,Coords.z,false,false,false,false)
	Functions.Notify(source,"verde","Jogador <b>#"..TicketId.."</b> puxado.")
	Functions.Notify(TargetSrc,"amarelo","Voce foi puxado pela staff.")
	return { ok = true }
end

function Core.StaffSendToGarage()
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end

	local TicketId,TargetSrc = ResolveAttending(Passport)
	if not TicketId or not TargetSrc then
		Functions.Notify(source,"vermelho","Sem chamado em atendimento.")
		return { ok = false }
	end

	if #Garages == 0 then
		Garages = LoadGarages()
		if #Garages == 0 then
			Functions.Notify(source,"vermelho","Nenhuma garagem publica carregada.")
			return { ok = false }
		end
	end

	local TPed   = GetPlayerPed(TargetSrc)
	local TCoord = GetEntityCoords(TPed)
	local Nearest = NearestGarage(TCoord.x,TCoord.y,TCoord.z)
	if not Nearest then
		Functions.Notify(source,"vermelho","Nenhuma garagem publica encontrada.")
		return { ok = false }
	end

	if GetEntityHealth(TPed) <= 100 then
		vRP.Revive(TargetSrc,300)
		vRP.UpgradeThirst(TicketId,100)
		vRP.UpgradeHunger(TicketId,100)
		vRP.DowngradeStress(TicketId,100)
	end

	SetEntityCoords(TPed,Nearest.x + 0.0,Nearest.y + 0.0,Nearest.z + 0.0,false,false,false,false)
	SetEntityHeading(TPed,Nearest.h + 0.0)

	Functions.Notify(source,"verde","Jogador <b>#"..TicketId.."</b> enviado para <b>"..Nearest.name.."</b>.")
	Functions.Notify(TargetSrc,"amarelo","Voce foi movido para a garagem mais proxima.")
	return { ok = true }
end

function Core.StaffFinish()
	local source   = source
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return { ok = false } end

	local TicketId = ResolveAttending(Passport)
	if not TicketId then
		Functions.Notify(source,"amarelo","Nenhum chamado em atendimento.")
		return { ok = false }
	end
	FinishTicket(source,Passport,TicketId)
	return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Calls.PlayerCommand,function(source)
	if source <= 0 then return end
	if not Functions.Passport(source) then return end
	TriggerClientEvent("core-calls:OpenPrompt",source)
end,false)

RegisterCommand(Calls.StaffCommand,function(source)
	if source <= 0 then return end
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then
		Functions.Notify(source,"vermelho","Apenas staff pode usar.")
		return
	end
	TriggerClientEvent("core-calls:OpenPanel",source)
end,false)

RegisterCommand(Calls.ToggleCommand,function(source)
	if source <= 0 then return end
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return end
	NotifyOff[Passport] = not NotifyOff[Passport] or nil
	if NotifyOff[Passport] then
		Functions.Notify(source,"amarelo","Notificacoes de chamado <b>desativadas</b>.")
	else
		Functions.Notify(source,"verde","Notificacoes de chamado <b>ativadas</b>.")
	end
end,false)

RegisterCommand(Calls.FinishCommand,function(source)
	if source <= 0 then return end
	local Passport = Functions.Passport(source)
	if not Functions.HasPermission(Passport,Calls.StaffPermission) then return end
	for TicketId,T in pairs(Tickets) do
		if T.response == Passport then
			FinishTicket(source,Passport,TicketId)

			if GetResourceState("core_logs") == "started" then
				exports["core_logs"]:AddLog("FINALIZOU-CHAMADO",{
					message = Functions.FullName(Passport).." #"..Passport.." finalizou o chamado #"..TicketId,
					adminName = Functions.FullName(Passport),
					adminId = Passport,
					Chamado = TicketId,
					Autor = T.author and (Functions.FullName(T.author).." #"..T.author) or nil
				})
			end

			return
		end
	end
	Functions.Notify(source,"amarelo","Nenhum chamado ativo em atendimento.")
end,false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER DROP / CLEANUP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	if not Passport then return end
	if Functions.HasPermission(Passport,Calls.StaffPermission) then
		StaffCache[Passport] = source
	end
end)

AddEventHandler("vRP:playerLeave",function(_,Passport)
	if not Passport then return end
	StaffCache[Passport] = nil
	Watching[Passport]  = nil

	local T = Tickets[Passport]
	if not T then return end

	if T.response then
		Functions.Insert("INSERT INTO core_calls (staff,fast,stars,period,created_at) VALUES (?,?,?,?,?)",{
			T.response, T.fast or 0, 5, CurrentPeriod(), os.time(),
		})
		local StaffSrc = vRP.Source(T.response)
		if StaffSrc then
			TriggerClientEvent("core-calls:Finished",StaffSrc)
			Functions.Notify(StaffSrc,"amarelo","O jogador saiu da cidade. Chamado finalizado automaticamente.")
		end
	end
	Tickets[Passport] = nil
	BroadcastUpdate()
end)

AddEventHandler("playerDropped",function()
	local source = source
	local Passport = Functions.Passport(source)
	if not Passport then return end
	Watching[Passport] = nil
end)
