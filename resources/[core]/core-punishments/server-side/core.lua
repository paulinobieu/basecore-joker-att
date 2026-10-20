-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
vKEYBOARD = Tunnel.getInterface("keyboard")
-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------
local function parseInt(v)
	return math.floor(tonumber(v) or 0)
end

local function FormatTime(s)
	if s <= 0 then
		return "Expirado"
	end

	return string.format("%02d dias, %02d horas, %02d minutos, %02d segundos",math.floor(s / 86400),math.floor((s % 86400) / 3600),math.floor((s % 3600) / 60),s % 60)
end

local function ParseDuration(text)
	text = tostring(text or ""):lower():gsub("%s","")
	local num,unit = text:match("^(%d+)([mhd]?)$")
	num = parseInt(num)
	if num <= 0 then
		return 0,nil
	end

	if unit == "h" then
		return num * 3600,num.." horas"
	elseif unit == "d" then
		return num * 86400,num.." dias"
	end

	return num * 60,num.." minutos"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATE
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = { block = {}, prison = {} }
-----------------------------------------------------------------------------------------------------------------------------------------
-- TABLE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Functions.DBExecute([[CREATE TABLE IF NOT EXISTS core_punishments (
		passport INT NOT NULL,
		type VARCHAR(20) NOT NULL,
		remaining INT NOT NULL DEFAULT 0,
		expires BIGINT NOT NULL DEFAULT 0,
		license VARCHAR(64) DEFAULT NULL,
		reason TEXT NOT NULL,
		admin VARCHAR(100) NOT NULL,
		created_at BIGINT NOT NULL,
		PRIMARY KEY (passport, type),
		KEY idx_tempban (type, license, expires)
	)]])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- IN-CITY HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function LoadPunishment(uid,ptype)
	return Functions.DBSingle("SELECT remaining, reason, admin FROM core_punishments WHERE passport = ? AND type = ?",{ uid,ptype })
end

local function SavePunishment(uid,ptype,remaining,reason,admin)
	Functions.DBExecute("INSERT INTO core_punishments (passport, type, remaining, expires, reason, admin, created_at) VALUES (?, ?, ?, 0, ?, ?, ?) ON DUPLICATE KEY UPDATE remaining = VALUES(remaining), reason = VALUES(reason), admin = VALUES(admin)",{ uid,ptype,remaining,reason,admin,os.time() })
end

local function DeletePunishment(uid,ptype)
	Functions.DBExecute("DELETE FROM core_punishments WHERE passport = ? AND type = ?",{ uid,ptype })
end

local function ApplyToClient(uid,ptype)
	local src = Functions.Source(uid)
	if not src then
		return
	end

	local data = Active[ptype][uid]
	if data then
		local rem = math.max(0,data.expires - os.time())
		TriggerClientEvent("core-punishments:Apply",src,ptype,data.expires,rem,data.reason)
	else
		TriggerClientEvent("core-punishments:Apply",src,ptype,0,0,nil)
	end
end

local function ActivatePunishment(uid,ptype,seconds,reason,admin)
	Active[ptype][uid] = { expires = os.time() + seconds, reason = reason, admin = admin }
	SavePunishment(uid,ptype,seconds,reason,admin)
	ApplyToClient(uid,ptype)
end

local function DeactivatePunishment(uid,ptype)
	Active[ptype][uid] = nil
	DeletePunishment(uid,ptype)
	ApplyToClient(uid,ptype)
end

local function SaveOnlineRemaining(uid,ptype)
	local data = Active[ptype][uid]
	if not data then
		return
	end

	local rem = math.max(0,data.expires - os.time())
	if rem > 0 then
		Functions.DBExecute("UPDATE core_punishments SET remaining = ? WHERE passport = ? AND type = ?",{ rem,uid,ptype })
	else
		DeletePunishment(uid,ptype)
	end

	Active[ptype][uid] = nil
end

local function RestoreFromDB(uid,ptype)
	local row = LoadPunishment(uid,ptype)
	if not row or parseInt(row.remaining) <= 0 then
		return
	end

	Active[ptype][uid] = { expires = os.time() + parseInt(row.remaining), reason = row.reason, admin = row.admin }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Connect",function(Passport,source)
	for _,ptype in ipairs({ "block","prison" }) do
		if not Active[ptype][Passport] then
			RestoreFromDB(Passport,ptype)
		end

		ApplyToClient(Passport,ptype)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REVIVE (ILHA)
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("core-punishments:Revive")
AddEventHandler("core-punishments:Revive",function()
	local src = source
	local uid = Functions.Passport(src)
	if not uid or not Active.prison[uid] then
		return
	end

	Functions.Revive(src,200)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect",function(Passport)
	for _,ptype in ipairs({ "block","prison" }) do
		SaveOnlineRemaining(Passport,ptype)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTING (TEMPBAN GATE)
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting",function(name,setKickReason,deferrals)
	local src = source
	deferrals.defer()
	Wait(0)

	local license = Functions.License(src)
	if not license then
		deferrals.done()
		return
	end

	local row = Functions.DBSingle("SELECT expires, reason FROM core_punishments WHERE type = 'tempban' AND license = ? AND expires > ? ORDER BY expires DESC LIMIT 1",{ license,os.time() })
	if row then
		local rem = math.max(0,parseInt(row.expires) - os.time())
		deferrals.done("\n\nVocê está banido temporariamente.\nMotivo: "..(row.reason or "Banimento temporário").."\nTempo restante: "..FormatTime(rem))
		return
	end

	deferrals.done()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANUP THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		Wait(Punishments.CleanupInterval)
		local now = os.time()

		for _,ptype in ipairs({ "block","prison" }) do
			for uid,data in pairs(Active[ptype]) do
				if data.expires <= now then
					Active[ptype][uid] = nil
					DeletePunishment(uid,ptype)
					local src = Functions.Source(uid)
					if src then
						TriggerClientEvent("core-punishments:Apply",src,ptype,0,0,nil)
					end
				end
			end
		end

		local rows = Functions.DBQuery("SELECT passport FROM core_punishments WHERE type = 'tempban' AND expires > 0 AND expires <= ?",{ now }) or {}
		for _,row in ipairs(rows) do
			local uid = parseInt(row.passport)
			Functions.DBExecute("DELETE FROM core_punishments WHERE passport = ? AND type = 'tempban'",{ uid })
			Functions.PLUnban(uid)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AMARRAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.Tie,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Tie) then
		return false
	end

	local Keyboard = vKEYBOARD.Codes(src,"Passaporte do jogador","Tempo (ex: 30m, 2h, 1d)","Motivo")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" or not Keyboard[3] or Keyboard[3] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local seconds,label = ParseDuration(Keyboard[2])
	local reason = tostring(Keyboard[3])

	if tid <= 0 or not Functions.Identity(tid) then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	if seconds <= 0 then
		Functions.Notify(src,"Erro","Tempo inválido.","vermelho")
		return false
	end

	local adminName = Functions.FullName(uid)
	ActivatePunishment(tid,"block",seconds,reason,adminName)

	local tsrc = Functions.Source(tid)
	if tsrc then
		Functions.Notify(tsrc,"Punição","Você foi amarrado por: "..reason,"vermelho",8000)
	end

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> amarrado por <b>"..label.."</b>.","verde")
	Functions.Log("PUN-AMARRAR",{
		message = adminName.." #"..uid.." amarrou "..Functions.FullName(tid).." #"..tid.." por "..label,
		adminName = adminName,
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Tempo = label,
		Motivo = reason
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESAMARRAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.Untie,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Tie) then
		return false
	end

	local Keyboard = vKEYBOARD.Secondary(src,"Passaporte do jogador","Motivo")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local reason = tostring(Keyboard[2])
	if tid <= 0 then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	DeactivatePunishment(tid,"block")

	local tsrc = Functions.Source(tid)
	if tsrc then
		Functions.Notify(tsrc,"Punição","Você foi desamarrado.","verde",6000)
	end

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> desamarrado.","verde")
	Functions.Log("PUN-DESAMARRAR",{
		message = Functions.FullName(uid).." #"..uid.." desamarrou "..Functions.FullName(tid).." #"..tid,
		adminName = Functions.FullName(uid),
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Motivo = reason
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VERIFICARAMARRAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.CheckTie,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Check) then
		return false
	end

	local Keyboard = vKEYBOARD.Primary(src,"Passaporte do jogador")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local data = Active.block[tid]
	if not data then
		Functions.Notify(src,"Punição","Passaporte não está amarrado.","amarelo")
		return false
	end

	local rem = math.max(0,data.expires - os.time())
	Functions.Notify(src,"Punição","Jogador: "..Functions.FullName(tid).." #"..tid.."<br>Motivo: "..data.reason.."<br>Staff: "..data.admin.."<br>Restante: "..FormatTime(rem),"azul",8000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRISAOADM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.Prison,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Prison) then
		return false
	end

	local Keyboard = vKEYBOARD.Codes(src,"Passaporte do jogador","Tempo (ex: 30m, 2h, 1d)","Motivo")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" or not Keyboard[3] or Keyboard[3] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local seconds,label = ParseDuration(Keyboard[2])
	local reason = tostring(Keyboard[3])

	if tid <= 0 or not Functions.Identity(tid) then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	if seconds <= 0 then
		Functions.Notify(src,"Erro","Tempo inválido.","vermelho")
		return false
	end

	local adminName = Functions.FullName(uid)
	ActivatePunishment(tid,"prison",seconds,reason,adminName)

	local tsrc = Functions.Source(tid)
	if tsrc then
		Functions.Notify(tsrc,"Punição","Você foi preso na ilha por: "..reason,"vermelho",8000)
	end

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> preso na ilha por <b>"..label.."</b>.","verde")
	Functions.Log("PUN-PRISAO",{
		message = adminName.." #"..uid.." prendeu "..Functions.FullName(tid).." #"..tid.." na ilha por "..label,
		adminName = adminName,
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Tempo = label,
		Motivo = reason
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMPRISAOADM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.UnPrison,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Prison) then
		return false
	end

	local Keyboard = vKEYBOARD.Secondary(src,"Passaporte do jogador","Motivo da liberação")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local reason = tostring(Keyboard[2])
	if tid <= 0 then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	DeactivatePunishment(tid,"prison")

	local tsrc = Functions.Source(tid)
	if tsrc then
		Functions.Notify(tsrc,"Punição","Você foi liberado da ilha.","verde",6000)
	end

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> liberado da ilha.","verde")
	Functions.Log("PUN-REMPRISAO",{
		message = Functions.FullName(uid).." #"..uid.." liberou "..Functions.FullName(tid).." #"..tid.." da ilha",
		adminName = Functions.FullName(uid),
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Motivo = reason
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VERIFICARPRISAO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.CheckPrison,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Check) then
		return false
	end

	local Keyboard = vKEYBOARD.Primary(src,"Passaporte do jogador")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local data = Active.prison[tid]
	if not data then
		Functions.Notify(src,"Punição","Passaporte não está preso.","amarelo")
		return false
	end

	local rem = math.max(0,data.expires - os.time())
	Functions.Notify(src,"Punição","Jogador: "..Functions.FullName(tid).." #"..tid.."<br>Motivo: "..data.reason.."<br>Staff: "..data.admin.."<br>Restante: "..FormatTime(rem),"azul",8000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLEAMARRAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.ToggleTie,function(src)
	local uid = Functions.Passport(src)
	if not uid then
		return false
	end

	TriggerClientEvent("core-punishments:ToggleNotify",src)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.Ban,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Ban) then
		return false
	end

	local Keyboard = vKEYBOARD.Secondary(src,"Passaporte do jogador","Motivo do banimento")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local reason = tostring(Keyboard[2])
	if tid <= 0 or not Functions.Identity(tid) then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	local adminName = Functions.FullName(uid)
	local tsrc = Functions.Source(tid)

	Functions.SetBanned(tid,-1,"Permanente",reason)
	Functions.PLBan(tsrc,tid,reason,adminName,0)
	if tsrc then
		Functions.Kick(tsrc,"Banido: "..reason)
	end

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> banido permanentemente.","verde",8000)
	Functions.Log("PUN-BAN",{
		message = adminName.." #"..uid.." baniu "..Functions.FullName(tid).." #"..tid,
		adminName = adminName,
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Tempo = "Permanente",
		Motivo = reason,
		Online = tsrc and "Sim" or "Não"
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEMPBAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.TempBan,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.TempBan) then
		return false
	end

	local Keyboard = vKEYBOARD.Codes(src,"Passaporte do jogador","Tempo (ex: 5h, 2d)","Motivo do banimento")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" or not Keyboard[3] or Keyboard[3] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local seconds,label = ParseDuration(Keyboard[2])
	local reason = tostring(Keyboard[3])
	local target = tid > 0 and Functions.Identity(tid)

	if not target then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	if seconds <= 0 then
		Functions.Notify(src,"Erro","Tempo inválido.","vermelho")
		return false
	end

	local adminName = Functions.FullName(uid)
	local tsrc = Functions.Source(tid)
	local expires = os.time() + seconds

	Functions.DBExecute("INSERT INTO core_punishments (passport, type, remaining, expires, license, reason, admin, created_at) VALUES (?, 'tempban', ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE remaining = VALUES(remaining), expires = VALUES(expires), license = VALUES(license), reason = VALUES(reason), admin = VALUES(admin)",{ tid,seconds,expires,target.License,reason,adminName,os.time() })
	Functions.PLBan(tsrc,tid,reason,adminName,0)
	if tsrc then
		Functions.Kick(tsrc,"Banido temporariamente ("..label.."): "..reason)
	end

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> banido por <b>"..label.."</b>.","verde",8000)
	Functions.Log("PUN-TEMPBAN",{
		message = adminName.." #"..uid.." baniu temporariamente "..Functions.FullName(tid).." #"..tid.." por "..label,
		adminName = adminName,
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Tempo = label,
		Motivo = reason,
		Online = tsrc and "Sim" or "Não"
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNBAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Punishments.Commands.Unban,function(src)
	local uid = Functions.Passport(src)
	if not Functions.HasPermission(uid,Punishments.Levels.Ban) then
		return false
	end

	local Keyboard = vKEYBOARD.Secondary(src,"Passaporte do jogador","Motivo do desbanimento")
	if not Keyboard or not Keyboard[1] or Keyboard[1] == "" or not Keyboard[2] or Keyboard[2] == "" then
		return false
	end

	local tid = parseInt(Keyboard[1])
	local reason = tostring(Keyboard[2])
	if tid <= 0 then
		Functions.Notify(src,"Erro","Passaporte inválido.","vermelho")
		return false
	end

	Functions.RemoveBanned(tid)
	Functions.PLUnban(tid)
	Functions.DBExecute("DELETE FROM core_punishments WHERE passport = ? AND type = 'tempban'",{ tid })

	Functions.Notify(src,"Sucesso","Passaporte <b>"..tid.."</b> desbanido.","verde")
	Functions.Log("PUN-UNBAN",{
		message = Functions.FullName(uid).." #"..uid.." desbaniu "..Functions.FullName(tid).." #"..tid,
		adminName = Functions.FullName(uid),
		adminId = uid,
		playerName = Functions.FullName(tid),
		playerId = tid,
		Motivo = reason
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("IsTied",function(uid)
	local data = Active.block[uid]
	if data then
		local rem = data.expires - os.time()
		if rem > 0 then
			return true,rem,data.reason
		end
	end

	return false,0,nil
end)

exports("IsPrisoned",function(uid)
	local data = Active.prison[uid]
	if data then
		local rem = data.expires - os.time()
		if rem > 0 then
			return true,rem,data.reason
		end
	end

	return false,0,nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
