--[[
    core-roubos :: server/functions.lua
    Núcleo do sistema de roubos: estado, presets, pontos, fluxo da ação,
    killfeed, persistência e webhook.

    Globais expostas (consumidas por server/server.lua):
        RobberyCache, ActualRobberies, RequestRobberies, selectMenu,
        lotusRoubos, IsInRobbery, GetPlayerTable, GetGiveUpMembers,
        GetRobberySources, ActualRobberies (read), etc.
--]]

-----------------------------------------------------------------------------
-- CONSTANTES INTERNAS
-----------------------------------------------------------------------------
local PLAYER_DEAD_HEALTH       = 101    -- vRP: <= 101 indica morto/down
local ROB_RADIUS               = 50     -- raio para listar bandidos próximos
local ROB_PERIMETER            = 68     -- raio do perímetro do roubo
local START_TIME_LIMIT         = 15 * 60      -- segundos para policiais entrarem
local SELECT_TEAM_TIMEOUT      = 15 * 60 * 1000 -- ms para escolher policiais
local POLICE_REQUEST_TIMEOUT_S = 15     -- segundos para algum policial aceitar
local POLICE_SERVICE           = 'Policia'

-----------------------------------------------------------------------------
-- ESTADO COMPARTILHADO (globais por necessidade cross-file)
-----------------------------------------------------------------------------
RobberyCache     = setmetatable({}, { __index = table })
ActualRobberies  = setmetatable({}, { __index = table })
RequestRobberies = {}
selectMenu       = {}

lotusRoubos = {}
lotusRoubos.__index = lotusRoubos
function lotusRoubos.new()
    return setmetatable({}, lotusRoubos)
end

-----------------------------------------------------------------------------
-- HELPERS GERAIS
-----------------------------------------------------------------------------
local function fullName(passport)
    local identity = vRP.Identity(passport) or {}
    local nome     = identity.Name     or identity.nome      or ''
    local sobre    = identity.Lastname or identity.sobrenome or ''
    return nome .. ' ' .. sobre
end

local function isAlive(source)
    return GetEntityHealth(GetPlayerPed(source)) > PLAYER_DEAD_HEALTH
end

local function chatRoubo(target, message)
    TriggerClientEvent('chatMessage', target, {
        type        = 'default',
        prefixColor = '#ff0000',
        title       = 'Roubo',
        message     = message,
    })
end

-- Toast genérico (vRP / sistema de notify do core)
local function notify(target, style, msg, time)
    TriggerClientEvent('Notify', target, style, msg, time)
end

-- Toast da UI React do core-roubos (escutado por client/events.lua → NotifyMessage)
local function robnotify(target, style, msg, time)
    TriggerClientEvent('core-roubos:robnotify', target, style, msg, time)
end

-----------------------------------------------------------------------------
-- POLICIAIS / PERMISSÕES
-----------------------------------------------------------------------------
function GetPoliceUsers()
    local result = {}
    local perm   = Config.Permissions.Police
    if not perm or not perm.Groups then return result end

    for passport in pairs(vRP.Players() or {}) do
        if passport then
            for _, group in ipairs(perm.Groups) do
                if vRP.HasGroup(passport, group) then
                    result[#result + 1] = passport
                    break
                end
            end
        end
    end
    return result
end

local function getHierarquiaCargo(passport)
    for _, cargo in ipairs(Config.Hierarquia) do
        if vRP.HasGroup(passport, cargo) then
            return cargo
        end
    end
    return '?'
end

-----------------------------------------------------------------------------
-- CACHE DE POINTS
-----------------------------------------------------------------------------
function UpdateRobberyPoints()
    local update = setmetatable({}, { __index = table })
    local result = vRP.Query('lotusRoubos/getPoint')
    for _, v in ipairs(result) do
        update:insert({
            preset = v.preset,
            cds    = json.decode(v.cds),
            count  = v.id,
        })
    end
    RobberyCache = update
    vCLIENT._updateRobberyPoints(-1, RobberyCache)
end

function IsPointInCache(count)
    if not count or type(RobberyCache) ~= 'table' then return false end
    for _, v in pairs(RobberyCache) do
        if tonumber(v.count) == tonumber(count) then return true end
    end
    return false
end

function DeleteRobberyInCache(count)
    if not count or type(RobberyCache) ~= 'table' then return end
    for k, v in pairs(RobberyCache) do
        if v.count == count then
            RobberyCache[k] = nil
            return
        end
    end
end

CreateThread(function()
    Wait(3000)
    UpdateRobberyPoints()
end)

-----------------------------------------------------------------------------
-- CHAVE DE ROUBO
-----------------------------------------------------------------------------
function GenerateRobKey(name, point)
    ActualRobberies:insert({ name = name, point_key = point })
    return #ActualRobberies
end

-----------------------------------------------------------------------------
-- LOOKUP DE PARTICIPANTES
-----------------------------------------------------------------------------
function IsInRobbery(source, user)
    if not tonumber(source) then return end
    local user_id = user or vRP.Passport(source)
    if not user_id then return false end

    for robberyKey, robberyData in pairs(ActualRobberies) do
        for teamKey, teamData in pairs(robberyData) do
            if type(teamData) == 'table' then
                for index = 1, #teamData do
                    if tonumber(teamData[index].id) == user_id then
                        return true,
                            tostring(robberyData.name),
                            tonumber(robberyKey),
                            tostring(teamKey),
                            tonumber(index)
                    end
                end
            end
        end
    end
    return false
end

function GetPlayerTable(source)
    source = tonumber(source)
    if not source then return end

    local _, _, key, team, index = IsInRobbery(source)
    if key and team and index and ActualRobberies[key] and ActualRobberies[key][team] then
        return ActualRobberies[key][team][index]
    end
end

function GetRobberySources(key, team)
    key = tonumber(key)
    if not key or type(ActualRobberies[key]) ~= 'table' then
        return false, 'Algo deu errado! (ERROR: 438)'
    end

    local sources = {}
    local function append(t)
        for _, p in ipairs(t) do
            if type(p) == 'table' and p.source then
                sources[#sources + 1] = p.source
            end
        end
    end

    if not team then
        for _, t in pairs(ActualRobberies[key]) do
            if type(t) == 'table' then append(t) end
        end
        return sources
    end

    local t = ActualRobberies[key][team]
    if type(t) ~= 'table' then
        return false, 'Algo deu errado! (ERROR: 457)'
    end
    append(t)
    return sources
end

function GetGiveUpMembers(key, team)
    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table'
            or type(ActualRobberies[k][team]) ~= 'table' then
        return false, 'Algo deu errado! (ERROR: 412)'
    end

    local list = {}
    for _, v in pairs(ActualRobberies[k][team]) do
        if v.giveup then
            list[#list + 1] = { name = v.name, id = v.id }
        end
    end
    return list
end

-----------------------------------------------------------------------------
-- PROJEÇÃO DE BANDIDOS x POLICIAIS
-----------------------------------------------------------------------------
function GetMinCopsFromProjection(obj)
    local min
    for _, v in pairs(obj) do
        local cops = tonumber(v.cops)
        if cops and not v.disable then
            min = (not min or cops < min) and cops or min
        end
    end
    return min or 0
end

function GetMaxBanditsRobbery(projection, cops)
    if type(projection) ~= 'table' then return 0 end

    local numCops = 0
    if type(cops) == 'table' then
        for _ in pairs(cops) do numCops = numCops + 1 end
    end

    local bandits = 0
    for k, v in pairs(projection) do
        if type(v) == 'table' and not v.disable then
            local req  = tonumber(v.cops)
            local maxB = tonumber(k)
            if req and maxB and req <= numCops and maxB > bandits then
                bandits = maxB
            end
        end
    end
    return bandits
end

function GetCopsNeedRobbery(projection, bandits)
    if type(projection) ~= 'table' then return end
    local sit = projection[parseInt(bandits)]
    if type(sit) == 'table' and not sit.disable then
        return parseInt(sit.cops)
    end
    return 0
end

-----------------------------------------------------------------------------
-- LISTAS DE PARTICIPANTES (cops/bandits)
-----------------------------------------------------------------------------
function GetRobberyCops(passports)
    if type(passports) ~= 'table' then return end

    local cops = {}
    for _, passport in ipairs(passports) do
        local source = vRP.Source(passport)
        if source and not IsInRobbery(source) then
            cops[#cops + 1] = {
                name  = fullName(passport),
                id    = parseInt(passport),
                cargo = getHierarquiaCargo(passport),
            }
        end
    end

    table.sort(cops, function(a, b) return a.id < b.id end)
    return cops
end

function GetRobberyBandits(source, radius)
    if not source then return false end

    local bandits = setmetatable({}, { __index = table })
    local nearby  = vCLIENT.getNearestPlayers(source, radius) or {}
    nearby[source] = { 0.0, source }

    for ply in pairs(nearby) do
        local nsource   = parseInt(ply)
        local npassport = vRP.Passport(nsource)
        if npassport
                and not IsInRobbery(nsource, npassport)
                and not Config.IsPolice(npassport) then
            bandits:insert({
                name  = fullName(npassport),
                id    = parseInt(npassport),
                fixed = (nsource == source),
            })
        end
    end
    return bandits
end

-----------------------------------------------------------------------------
-- SOLICITAÇÃO AO MELHOR POLICIAL DISPONÍVEL
-----------------------------------------------------------------------------
local pickLock = false

function GetBestCop(name, Rkey)
    local oficiais = GetPoliceUsers()
    if #oficiais < 1 then return false end

    local accepted

    for _, passport in ipairs(oficiais) do
        local sourceOficial = vRP.Source(tonumber(passport))
        if sourceOficial and vRP.HasService(passport, POLICE_SERVICE) then
            CreateThread(function()
                local accept = vRP.Request(
                    sourceOficial,
                    'Deseja escolher o time do roubo ' .. tostring(name) .. '?',
                    'Aceitar', 'Recusar'
                )
                if not accept then return end

                if pickLock then
                    notify(sourceOficial, 'negado',
                        'Já existe um policial montando o time do roubo.')
                    return
                end

                pickLock  = true
                accepted  = passport
                local nome = fullName(tonumber(passport))

                local rob = ActualRobberies[tonumber(Rkey)]
                if rob then
                    rob.policeaccept = tonumber(accepted) or passport
                    chatRoubo(rob.pusher,
                        'Policial ' .. nome .. ' aceitou montar o time do roubo ' .. name)
                end
                chatRoubo(sourceOficial,
                    'Policial ' .. nome .. ' aceitou montar o time do roubo ' .. name)
            end)
        end
    end

    local deadline = os.time() + POLICE_REQUEST_TIMEOUT_S
    while not accepted and os.time() < deadline do
        Wait(100)
    end

    pickLock = false

    if accepted then
        return tonumber(accepted), tonumber(vRP.Source(tonumber(accepted)))
    end
    return false
end

-----------------------------------------------------------------------------
-- ESTADO DA AÇÃO (vivo / vencedor)
-----------------------------------------------------------------------------
function IsInAndamentRobbery(key)
    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then return end

    for team, players in pairs(ActualRobberies[k]) do
        if type(players) == 'table' and (team == 'bandits' or team == 'cops') then
            local algumVivo = false
            for _, p in ipairs(players) do
                if p.isvivo then algumVivo = true break end
            end
            if not algumVivo then
                local winner = (team == 'bandits') and 'cops' or 'bandits'
                return false, winner
            end
        end
    end
    return true
end

-----------------------------------------------------------------------------
-- WINNERS / DISTRIBUIÇÃO
-----------------------------------------------------------------------------
function GetWinners(winner, key)
    local r = {}
    for _, p in ipairs(ActualRobberies[key][winner]) do
        r[#r + 1] = p
    end
    return r
end

function DistributeMoneyToWinners(winner, key)
    local rob = ActualRobberies[key]
    if not rob then return end

    local total = tonumber(rob.estimatedValue) or 0
    if total <= 0 then
        print(('^3[core-roubos] Roubo "%s" sem recompensa configurada (estimatedValue=%s)^0')
            :format(tostring(rob.name), tostring(rob.estimatedValue)))
        return
    end

    local winners = GetWinners(winner, key)
    if #winners == 0 then
        print(('^3[core-roubos] Nenhum vencedor para distribuir recompensa do roubo "%s"^0')
            :format(tostring(rob.name)))
        return
    end

    -- 🔧 vRP.GiveItem exige inteiro. Antes era `share = total / #winners`
    -- que podia gerar fração (ex: 10000/3 = 3333.33) — e silenciosamente
    -- não dava nada. math.floor garante valor inteiro.
    local share = math.floor(total / #winners)
    if share <= 0 then share = 1 end

    -- Bandits ganham dirtydollar, cops ganham dollar (clean).
    local item = (winner == 'cops') and 'dollar' or 'dirtydollar'

    for _, player in ipairs(winners) do
        local passport = tonumber(player.id)
        if passport then
            local ok = vRP.GiveItem(passport, item, share, true)
            print(('^2[core-roubos] [%s] %s × %d → %s%s^0'):format(
                rob.name or '?', item, share, tostring(passport),
                ok == false and ' (falhou)' or ''))

            if ok ~= false and GetResourceState("core_logs") == "started" then
                exports["core_logs"]:AddLog("ROUBO", {
                    message = vRP.FullName(passport).." #"..passport.." recebeu R$ "..share.." pelo roubo "..tostring(rob.name).." ("..(winner == 'cops' and "polícia venceu" or "bandidos venceram")..")",
                    playerName = vRP.FullName(passport),
                    playerId = passport,
                    Roubo = rob.name,
                    Valor = share,
                    ValorTotal = total,
                    Vencedor = winner == 'cops' and "Polícia" or "Bandidos",
                    Moeda = item
                })
            end
        end
    end
end

-----------------------------------------------------------------------------
-- HISTÓRICO + WEBHOOK
-----------------------------------------------------------------------------
local function killfeedString(players)
    table.sort(players, function(a, b) return a.kills > b.kills end)

    local parts = {}
    for _, p in ipairs(players) do
        local status = p.isvivo and 'Vivo' or 'Morto'
        parts[#parts + 1] = string.format(
            '[%d] %s \n[💀]: %d kills | [❤️]: %s',
            p.id, p.name, p.kills, status
        )
    end
    if #parts == 0 then return '' end
    return '```ini\n' .. table.concat(parts, '\n\n') .. '```\n'
end

-----------------------------------------------------------------------------
-- WEBHOOK / LOG DISCORD
--
--   Logs disparados via PerformHttpRequest. Suporta dois webhooks separados
--   (Config.Roubos.LogWebhook para eventos de roubo e Config.Roubos.AdminWebhook
--   para auditoria de ações administrativas). Se AdminWebhook for vazio, cai
--   no LogWebhook automaticamente.
-----------------------------------------------------------------------------
local WEBHOOK_USERNAME = 'core-roubos'
local WEBHOOK_AVATAR   = 'https://i.imgur.com/8gKnEoP.png'

-- Cores Discord (decimal) — escolhidas para refletir o tipo do evento
local WEBHOOK_COLORS = {
    start    = 0x3DD598,   -- verde
    end_cops = 0x3B82F6,   -- azul (policiais vencem)
    end_band = 0xDC153A,   -- vermelho (bandidos vencem)
    cancel   = 0xEAB308,   -- amarelo
    info     = 0x6B7280,   -- cinza
    admin    = 0xA855F7,   -- roxo
    create   = 0x10B981,   -- verde-claro
    delete   = 0xEF4444,   -- vermelho-claro
}

local function webhookURL(channel)
    local cfg = Config.Roubos or {}
    if channel == 'admin' then
        return (cfg.AdminWebhook ~= '' and cfg.AdminWebhook) or cfg.LogWebhook or ''
    end
    return cfg.LogWebhook or ''
end

--- Envia um embed para o Discord.
--  @param channel "log" | "admin"
--  @param embed { title, description, color, fields, footer, timestamp }
local function webhookEmbed(channel, embed)
    local url = webhookURL(channel)
    if url == '' then return end

    embed.timestamp = embed.timestamp or os.date('!%Y-%m-%dT%H:%M:%SZ')
    if not embed.footer then
        embed.footer = { text = 'core-roubos' }
    end

    PerformHttpRequest(url, function() end, 'POST', json.encode({
        username   = WEBHOOK_USERNAME,
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { embed },
    }), { ['Content-Type'] = 'application/json' })
end

-- Mantém o helper antigo para compatibilidade (envia content text simples)
local function postWebhook(content)
    local url = webhookURL('log')
    if url == '' then return end
    PerformHttpRequest(url, function() end, 'POST', json.encode({
        username   = WEBHOOK_USERNAME,
        avatar_url = WEBHOOK_AVATAR,
        content    = content,
    }), { ['Content-Type'] = 'application/json' })
end

--- Resolve nome legível de um passport (para logs).
local function describePlayer(passport)
    if not passport then return 'sistema' end
    local id = tonumber(passport)
    if not id then return tostring(passport) end
    local identity = vRP.Identity(id) or {}
    local nome  = identity.Name     or identity.nome      or '?'
    local sobre = identity.Lastname or identity.sobrenome or ''
    return string.format('%s %s [%d]', nome, sobre, id)
end

function InsertRobberyData(key, winner)
    key = tonumber(key)
    if not key or type(ActualRobberies[key]) ~= 'table' then return end

    local data     = ActualRobberies[key]
    local killfeed = {
        cops     = data.cops     or {},
        bandits  = data.bandits  or {},
        hostages = data.hostages or {},
    }
    ActualRobberies[key] = nil

    local name     = tostring(data.name)
    local time     = tonumber(data.init)
    local duration = os.time() - time

    CreateThread(function()
        vRP.Query('lotusRoubos/addHistoric', {
            name     = name,
            winner   = tostring(winner),
            duration = duration,
            killfeed = json.encode(killfeed),
            time     = time,
        })

        -- Embed do relatório final
        local copsStr     = killfeedString(killfeed.cops)
        local banditsStr  = killfeedString(killfeed.bandits)
        local hostagesStr = killfeedString(killfeed.hostages)
        if hostagesStr == '' then
            hostagesStr = '_(sem reféns)_'
        end

        local isCops    = winner:lower() == 'cops'
        local winnerLbl = isCops and 'Policiais' or 'Bandidos'

        local mm = string.format('%02d:%02d', math.floor(duration / 60), duration % 60)

        webhookEmbed('log', {
            title       = '🏁 Roubo finalizado · ' .. name,
            color       = isCops and WEBHOOK_COLORS.end_cops or WEBHOOK_COLORS.end_band,
            description = string.format('**Vencedor:** %s · **Duração:** %s', winnerLbl, mm),
            fields = {
                { name = '📅 Início', value = os.date('%d/%m/%Y %H:%M:%S', time),     inline = true },
                { name = '🏁 Fim',    value = os.date('%d/%m/%Y %H:%M:%S', os.time()), inline = true },
                { name = '⏱ Duração', value = mm .. ' (' .. duration .. 's)',          inline = true },
                { name = '🔫 Bandidos',  value = banditsStr:sub(1, 1024)  ~= '' and banditsStr:sub(1, 1024)  or '_(vazio)_', inline = false },
                { name = '👮 Policiais', value = copsStr:sub(1, 1024)     ~= '' and copsStr:sub(1, 1024)     or '_(vazio)_', inline = false },
                { name = '🙇 Reféns',    value = hostagesStr:sub(1, 1024) ~= '' and hostagesStr:sub(1, 1024) or '_(vazio)_', inline = false },
            },
        })
    end)
end

-----------------------------------------------------------------------------
-- KILLFEED EM AÇÃO
-----------------------------------------------------------------------------
function AnyKillInRobbery(key, victim, reason, killer)
    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then return end
    if type(victim) ~= 'table' then return end

    local victim_id, team = victim[1], victim[2]
    local killer_id, team2, kil, vic

    if killer and type(killer) == 'table' then
        killer_id, team2 = killer[1], killer[2]
        local data_killer = GetPlayerTable(killer_id)
        if type(data_killer) == 'table' then
            data_killer.kills = (tonumber(data_killer.kills) or 0) + 1
            kil = data_killer.name
            if type(kil) ~= 'string' then
                kil = fullName(tonumber(data_killer.id) or vRP.Passport(killer_id))
            end
        end
    end

    local data_victim = GetPlayerTable(victim_id)
    if type(data_victim) == 'table' then
        data_victim.isvivo = false
        vic = data_victim.name
        if type(vic) ~= 'string' then
            vic = fullName(tonumber(data_victim.id) or vRP.Passport(victim_id))
        end
    end

    local hasRobbery, winner = IsInAndamentRobbery(k)
    local sources = GetRobberySources(k)
    if type(sources) ~= 'table' then return end

    if hasRobbery then
        for _, p in ipairs(sources) do
            TriggerClientEvent('killfeed', p, vic, reason, kil,
                tostring(team):lower(), tostring(team2):lower())
            vCLIENT._updateActualRobbery(p, ActualRobberies[k])
        end
        return
    end

    -- Roubo terminou: notifica vencedor e finaliza
    for _, p in ipairs(sources) do
        TriggerClientEvent('killfeed', p, vic, reason, kil, team, team2)
        TriggerClientEvent('winnernotify', p, tostring(winner))
        vCLIENT._updateActualRobbery(p, false)
    end

    DistributeMoneyToWinners(winner, k)
    lotusRoubos:removeDrawmarker(k)
    InsertRobberyData(k, tostring(winner))
end

-----------------------------------------------------------------------------
-- PRESETS (CRUD)
-----------------------------------------------------------------------------
function lotusRoubos:createPreset(preset)
    local passport = vRP.Passport(source)
    if not passport then
        return { status = false, msg = 'Erro ao criar preset.' }
    end
    if not Config.HasPermission(passport, 'ManagePresets') then
        return { status = false, msg = 'Erro ao criar preset.' }
    end

    local data = preset.data
    if not data.name or not data.last_name then
        return { status = false, msg = 'Houve algum problema na troca de informação, notifique o dono da cidade!' }
    end

    -- Normalização de campos antes de persistir
    data.projection      = json.encode(data.projection or {})
    data.items           = type(data.items) == 'table' and json.encode(data.items) or '[]'
    data.isminigame      = nil
    data.minigame        = data.minigame and tonumber(data.minigame) or 0
    data.ispermission    = nil
    data.permission      = data.permission or ''
    data.needmakinganim  = nil
    data.animation       = data.animation or ''
    data.animationtime   = data.animationTime or 0
    data.iswanted        = not not data.iswanted
    data.awarddarkmoney  = data.awarddarkmoney or '0'
    data.awardmax        = data.awardmax or 0
    data.awardmin        = data.awardmin or 0
    data.cooldown        = data.cooldown or 0

    local check = vRP.Query('lotusRoubos/checkPreset', { name = data.last_name })
    local isUpdate = check[1] ~= nil

    if isUpdate then
        for _, v in pairs(ActualRobberies) do
            if v.name == data.last_name then
                return { status = false, msg = 'Existe um roubo em andamento com esse preset, portanto ele não pode ser editado!' }
            end
        end
        vRP.Query('lotusRoubos/updatePreset', data)
        UpdateRobberyPoints()
    else
        vRP.Query('lotusRoubos/createPreset', data)
    end

    -- 📡 Discord audit
    webhookEmbed('admin', {
        title       = isUpdate and '✏️ Preset editado · ' .. data.name or '➕ Preset criado · ' .. data.name,
        color       = isUpdate and WEBHOOK_COLORS.admin or WEBHOOK_COLORS.create,
        fields = {
            { name = '👤 Admin',         value = describePlayer(vRP.Passport(source) or source), inline = false },
            { name = 'Recompensa',       value = string.format('R$ %d–%d (%s)',
                tonumber(data.awardmin) or 0, tonumber(data.awardmax) or 0,
                (tonumber(data.awarddarkmoney) or 0) > 0 and 'sujo' or 'limpo'), inline = true },
            { name = 'Cooldown',         value = (tonumber(data.cooldown) or 0) .. 's', inline = true },
            { name = 'Wanted',           value = (tonumber(data.iswanted) or 0) > 0 and 'sim' or 'não', inline = true },
            { name = 'Permissão',        value = (data.permission ~= '' and data.permission) or '_(livre)_', inline = true },
        },
    })

    return { status = true, msg = 'O preset foi criado com sucesso!' }
end

function lotusRoubos:deletePreset(name)
    local src      = source
    local passport = vRP.Passport(src)
    if not passport then
        return { status = false, msg = 'Erro ao deletar preset' }
    end
    if not Config.HasPermission(passport, 'ManagePresets') then
        return { status = false, msg = 'Erro ao deletar preset' }
    end

    -- Bloqueia delete se algum roubo está em execução com esse preset
    for _, v in pairs(ActualRobberies) do
        if tonumber(v.point_key) then
            local consult = vRP.Query('lotusRoubos/getPointCount', { count = v.point_key })
            if consult.preset == tostring(name) then
                robnotify(src, 'negado', 'Existe um roubo em execução com esse preset!', 8000)
                return { status = false, msg = 'Existe um roubo em execução com esse preset!' }
            end
        end
    end

    -- Confirmação pelo popup nativo do vRP (sem window.confirm)
    local ok = vRP.Request(src,
        'Deletar o preset "' .. tostring(name) .. '"? Essa ação não pode ser desfeita.',
        'Confirmar', 'Cancelar')
    if not ok then
        return { status = false, msg = 'Cancelado pelo usuário.' }
    end

    vRP.Query('lotusRoubos/deletePreset', { name = tostring(name) })
    UpdateRobberyPoints()
    robnotify(src, 'sucesso', 'Preset "' .. tostring(name) .. '" deletado.', 6000)

    -- 📡 Discord audit
    webhookEmbed('admin', {
        title  = '🗑️ Preset deletado · ' .. tostring(name),
        color  = WEBHOOK_COLORS.delete,
        fields = {
            { name = '👤 Admin', value = describePlayer(passport), inline = false },
        },
    })

    return { status = true, msg = 'Preset de roubo deletado com sucesso!' }
end

function lotusRoubos:getDataPresets()
    local presets = vRP.Query('lotusRoubos/getAllPresets') or {}
    if type(presets) ~= 'table' then return {} end

    for _, v in ipairs(presets) do
        if type(v) == 'table' then
            if v.projection then
                v.projection = json.decode(v.projection)
            end
            v.permission = v.permission or ''
            v.minigame   = v.minigame   or ''
            v.animation  = v.animation  or ''

            v.needmakinganim = type(v.animation) == 'string' and v.animation:len() > 0
            v.animationTime  = parseInt(v.animationtime) or 0
            v.ispermission   = v.permission ~= ''
            v.isminigame     =
                (type(v.minigame) == 'number' and v.minigame > 0)
                or (type(v.minigame) == 'string' and v.minigame ~= '' and v.minigame ~= '0')

            if not v.isminigame then
                v.minigame = 1
            end

            if v.items then
                if type(v.items) == 'string' then
                    v.items = json.decode(v.items)
                end
                if type(v.items) ~= 'table' then
                    v.items = {}
                end
            end
        end
    end
    return presets
end

-----------------------------------------------------------------------------
-- POINTS (CRUD)
-----------------------------------------------------------------------------
function lotusRoubos:getDataRobberies()
    local consult = vRP.Query('lotusRoubos/getPoint')
    if #consult <= 0 then return consult end

    local px, py, pz = table.unpack(GetEntityCoords(GetPlayerPed(source)))
    local origin = vec3(px, py, pz)

    for k, v in ipairs(consult) do
        consult[k].count = v.id
        if type(v.cds) ~= 'table' then
            consult[k].cds = json.decode(v.cds)
        end
    end

    table.sort(consult, function(a, b)
        return #(origin - vec3(a.cds.x, a.cds.y, a.cds.z))
             < #(origin - vec3(b.cds.x, b.cds.y, b.cds.z))
    end)
    return consult
end

function lotusRoubos:addRobbery(data)
    local src = source
    local x = tonumber(data.cds.x)
    local y = tonumber(data.cds.y)
    local z = tonumber(data.cds.z)
    if not x or not y or not z then
        return { status = false, msg = 'As informações de coordenadas não chegaram como deveriam!' }
    end

    local check = vRP.Query('lotusRoubos/getPreset', { name = data.preset or '' })
    if #check < 1 then
        return { status = false, msg = 'O preset especificado não foi encontrado!' }
    end

    local result = vRP.Query('lotusRoubos/addPoint', {
        preset = tostring(data.preset),
        cds    = json.encode({ x = x, y = y, z = z }),
    })
    local newId = result and result.insertId
    if not newId or newId == 0 then
        local count = vRP.Query('lotusRoubos/getLastCount')
        newId = count and count[1] and (count[1].id or count[1].count)
    end

    if not newId then
        return { status = false, msg = 'CRITICAL: Erro ao obter ID do novo roubo!' }
    end

    RobberyCache:insert({
        preset = data.preset,
        cds    = { x = x, y = y, z = z },
        count  = tonumber(newId),
    })
    vCLIENT._updateRobberyPoints(-1, RobberyCache)

    -- 📡 Discord audit
    webhookEmbed('admin', {
        title  = '📍 Ponto adicionado · #' .. tostring(newId),
        color  = WEBHOOK_COLORS.create,
        fields = {
            { name = '👤 Admin',  value = describePlayer(vRP.Passport(src) or src), inline = false },
            { name = 'Preset',    value = tostring(data.preset), inline = true },
            { name = 'Coords',    value = string.format('`%.2f, %.2f, %.2f`', x, y, z), inline = true },
        },
    })

    return { status = true, msg = 'Roubo criado com sucesso!' }
end

function lotusRoubos:remRobbery(count)
    local src = source
    local id  = tonumber(count)
    if not IsPointInCache(id) then
        return { status = false, msg = 'O roubo selecionado não existe' }
    end

    for _, v in pairs(ActualRobberies) do
        if v.point_key and v.point_key == id then
            robnotify(src, 'negado', 'O roubo selecionado tem uma ação em execução!', 8000)
            return { status = false, msg = 'O roubo selecionado tem uma ação em execução!' }
        end
    end

    -- Confirmação via popup nativo do vRP (sem window.confirm)
    local ok = vRP.Request(src,
        'Remover o ponto de roubo #' .. tostring(id) .. ' do mapa?',
        'Confirmar', 'Cancelar')
    if not ok then
        return { status = false, msg = 'Cancelado pelo usuário.' }
    end

    DeleteRobberyInCache(id)
    vRP.Query('lotusRoubos/removePointv2', { id = id })
    vCLIENT._updateRobberyPoints(-1, RobberyCache)
    robnotify(src, 'sucesso', 'Ponto #' .. tostring(id) .. ' removido do mapa.', 6000)

    -- 📡 Discord audit
    webhookEmbed('admin', {
        title  = '🗑️ Ponto removido · #' .. tostring(id),
        color  = WEBHOOK_COLORS.delete,
        fields = {
            { name = '👤 Admin', value = describePlayer(vRP.Passport(src) or src), inline = false },
        },
    })

    return { status = true, msg = 'O roubo selecionado foi deletado!' }
end

-----------------------------------------------------------------------------
-- HISTÓRICO (em memória + banco)
-----------------------------------------------------------------------------
function lotusRoubos:getHistoricRobberys(offset, limit)
    local winnerBeautifier = { cops = 'Policiais', bandits = 'Bandidos' }

    offset = tonumber(offset) or 0
    limit  = tonumber(limit) or 1000

    local r, p = {}, 0
    local now  = table.clone(ActualRobberies)

    if offset < #now then
        table.sort(now, function(a, b)
            return tonumber(a.init) > tonumber(b.init)
        end)
        for _, v in ipairs(now) do
            if p < limit and v.name and type(v.bandits) == 'table' and type(v.cops) == 'table' then
                p = p + 1
                if p > offset then
                    r[#r + 1] = {
                        status   = true,
                        name     = tostring(v.name),
                        bandits  = #v.bandits,
                        cops     = #v.cops,
                        hostages = #(v.hostages or {}),
                        winner   = 'Não Definido',
                        players  = { bandits = v.bandits or {}, cops = v.cops or {} },
                    }
                end
            end
        end
    end

    if p >= limit then return r end

    offset = math.max(offset - p, 0)
    local occurred = vRP.Query('lotusRoubos/getHistoric',
        { limit = parseInt(limit), offset = parseInt(offset) }) or {}

    for _, v in ipairs(occurred) do
        local kf = json.decode(v.killfeed)
        if p < limit and v.name and v.winner and type(kf) == 'table' then
            p = p + 1
            r[#r + 1] = {
                status   = false,
                name     = tostring(v.name),
                bandits  = #(kf.bandits or {}),
                cops     = #(kf.cops or {}),
                hostages = #(kf.hostages or {}),
                winner   = winnerBeautifier[tostring(v.winner):lower()] or 'Indefinido',
                players  = { bandits = kf.bandits or {}, cops = kf.cops or {} },
            }
        end
    end
    return r, p
end

-----------------------------------------------------------------------------
-- TENTATIVA DE ROUBO (validação completa)
-----------------------------------------------------------------------------
function lotusRoubos:tryRobbery(user_id, point)
    local pusherSource = source
    local passport     = vRP.Passport(pusherSource)
    if not passport or not point then
        return false, 'Informações de usuário ou ponto estão faltando!'
    end

    local consult = vRP.Query('lotusRoubos/getPreset', { name = point.preset })
    local obj     = consult[1]
    if not obj then
        return false, 'Algo deu errado! (ERROR: 122)'
    end

    -- Já está em andamento?
    for _, v in pairs(ActualRobberies) do
        if v.name == tostring(obj.name) then
            return false, 'Aguarde o roubo em andamento acabar!'
        end
    end

    -- Permissão extra do preset
    if type(obj.permission) == 'string' and obj.permission:len() > 0
            and not vRP.HasPermission(passport, tostring(obj.permission)) then
        return false, 'Você não possui permissão para fazer esse roubo!'
    end

    -- Coordenadas válidas
    local x = tonumber(point.cds.x)
    local y = tonumber(point.cds.y)
    local z = tonumber(point.cds.z)
    if not x or not y or not z then
        return false, 'Coordenadas inválidas!'
    end

    -- Projeção
    local proj = json.decode(obj.projection)
    if type(proj) ~= 'table' then
        return false, 'Projeção inválida!'
    end

    -- Mínimo de policiais
    local cops = GetPoliceUsers()
    if #cops < GetMinCopsFromProjection(proj) then
        return false, 'Policiais insuficientes em serviço!'
    end

    -- Cooldown
    local consult_ts = vRP.Query('lotusRoubos/getHistoricWithName', { name = obj.name })
    local lastrob    = tonumber(consult_ts[1] and consult_ts[1].time)
    if not Config.Roubos.disableCooldown and lastrob then
        local elapsed = os.time() - lastrob
        local cd      = tonumber(obj.cooldown)
        if cd and elapsed < cd then
            local rem = cd - elapsed
            return false, 'Os cofres do local estão vazios, aguarde ' .. rem ..
                's para roubá-los novamente!'
        end
    end

    -- Itens necessários
    local needItens
    if type(obj.items) == 'string' and obj.items:len() > 0 then
        needItens = json.decode(obj.items)
        if type(needItens) ~= 'table' then
            return false, 'Ocorreu um erro inesperado! (E20)'
        end
        for _, v in pairs(needItens) do
            local nm  = tostring(v.name)
            local amt = parseInt(v.amount)
            if vRP.ItemAmount(passport, nm) < amt then
                return false, 'Você não possui ' .. amt .. 'x do item ' .. nm ..
                    ' na sua mochila!'
            end
        end
        for _, v in pairs(needItens) do
            vRP.TakeItem(passport, tostring(v.name), parseInt(v.amount), true)
        end
    end

    -- Coerções herdadas (compat)
    if obj.awarddarkmoney and not tonumber(obj.awarddarkmoney) then
        obj.awarddarkmoney = 1
    end
    if obj.iswanted and not tonumber(obj.iswanted) then
        obj.iswanted = 1
    end

    local Rkey = GenerateRobKey(tostring(obj.name), tonumber(point.count))
    local rob  = ActualRobberies[Rkey]
    rob.cds            = vec3(x, y, z)
    rob.pusher         = pusherSource
    rob.iswanted       = parseInt(obj.iswanted) > 0
    rob.needItens      = needItens
    rob.estimatedValue = math.random(parseInt(obj.awardmin),
                            math.max(parseInt(obj.awardmax), parseInt(obj.awardmin)))
    rob.isDarkMoney    = parseInt(obj.awarddarkmoney) > 0
    rob.animationTime  = parseInt(obj.animationtime)
    rob.animation      = tostring(obj.animation)

    selectMenu[pusherSource] = Rkey
    return tostring(obj.name),
           GetRobberyBandits(pusherSource, ROB_RADIUS),
           {
               key       = Rkey,
               proj      = proj,
               bandlimit = GetMaxBanditsRobbery(proj, cops),
           }
end

-----------------------------------------------------------------------------
-- INICIO DA SELEÇÃO DE TIME (após o pusher escolher bandidos/reféns)
-----------------------------------------------------------------------------
function lotusRoubos:tryStartRobbery(key, bandits, hostages)
    local pusherSource = source
    selectMenu[pusherSource] = nil

    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then
        return { status = false, msg = 'Algo deu errado! (ERROR: 150)' }
    end
    if type(bandits) ~= 'table' or type(hostages) ~= 'table' then
        return { status = false, msg = 'Os dados do alerta sofreram problemas no meio do envio!' }
    end

    local name = ActualRobberies[k].name

    -- Hidrata bandidos/reféns com source / vivo / kills
    CreateThread(function()
        for _, list in ipairs({ bandits, hostages }) do
            for i, v in ipairs(list) do
                if v.id then
                    local s = vRP.Source(parseInt(v.id))
                    if s then
                        list[i].source = s
                        list[i].isvivo = isAlive(s)
                        list[i].kills  = 0
                    end
                end
            end
        end
    end)

    ActualRobberies[k].bandits  = bandits
    ActualRobberies[k].hostages = hostages

    local nBandits, nHostages = #bandits, #hostages

    local consult = vRP.Query('lotusRoubos/getPreset', { name = name })
    if not consult then
        return { status = false, msg = 'Algo deu errado! (ERROR: 181)' }
    end
    local obj = consult[1]
    if not obj then
        return { status = false, msg = 'Algo deu errado! (ERROR: 184)' }
    end

    local policial_id, policial_source = GetBestCop(name, k)
    if not policial_id and not policial_source then
        lotusRoubos:cancelRobbery(k)
        return { status = false, msg = 'Nenhum policial aceitou montar um time para sua ação!' }
    end
    policial_id     = policial_id     or vRP.Passport(policial_source)
    policial_source = policial_source or vRP.Source(policial_id)

    local needcops  = GetCopsNeedRobbery(json.decode(obj.projection), nBandits) or 0
    local cops      = GetRobberyCops(GetPoliceUsers() or {}) or {}

    selectMenu[policial_source] = k
    vCLIENT.SelectCops(policial_source, k, cops, needcops, nBandits, nHostages, name)

    SetTimeout(SELECT_TEAM_TIMEOUT, function()
        if selectMenu[policial_source] then
            selectMenu[policial_source] = nil
            lotusRoubos:cancelRobbery(k)
            notify(policial_source, 'negado',
                'O tempo para escolher os policiais acabou!')
        end
    end)

    return { status = true,
        msg = 'Os policiais já receberam o alerta do roubo, e estão montando um time para a ação!' }
end

-----------------------------------------------------------------------------
-- CANCELAMENTO DE ROUBO
-----------------------------------------------------------------------------
function lotusRoubos:cancelRobbery(key, reason)
    local k = tonumber(key)
    if not k or not ActualRobberies[k] then return end

    local rob = ActualRobberies[k]

    -- Devolve itens consumidos para o pusher
    if type(rob.needItens) == 'table' and rob.pusher then
        local passport = vRP.Passport(rob.pusher)
        if passport then
            for _, item in pairs(rob.needItens) do
                vRP.GiveItem(passport, tostring(item.name), tonumber(item.amount), true)
            end
            vCLIENT._cancelRobbery(rob.pusher)
        end
    end

    local sources = GetRobberySources(k)
    if type(sources) == 'table' then
        for _, ps in ipairs(sources) do
            vCLIENT._updateActualRobbery(ps, false)
        end
    end

    -- 📡 Discord log: roubo cancelado
    local pusher = rob.pusher and vRP.Passport(rob.pusher) or nil
    webhookEmbed('log', {
        title       = '⚠️ Roubo cancelado · ' .. tostring(rob.name or 'desconhecido'),
        color       = WEBHOOK_COLORS.cancel,
        description = tostring(reason or 'Sem motivo especificado.'),
        fields = {
            { name = '👤 Pusher',   value = describePlayer(pusher),                     inline = true },
            { name = '🔫 Bandidos', value = tostring(#(rob.bandits  or {})),            inline = true },
            { name = '👮 Policiais',value = tostring(#(rob.cops     or {})),            inline = true },
            { name = '🙇 Reféns',   value = tostring(#(rob.hostages or {})),            inline = true },
        },
    })

    ActualRobberies[k] = nil
end

-----------------------------------------------------------------------------
-- APROVAÇÃO DOS POLICIAIS ESCOLHIDOS PELO POLICIAL "MONTADOR"
-----------------------------------------------------------------------------
function lotusRoubos:approveRobbery(key, rcops)
    local actorSource = source
    selectMenu[actorSource] = nil

    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then
        return false, 'Algo deu errado! (ERROR: 197)'
    end

    local rob = ActualRobberies[k]
    local name, bandits, hostages = rob.name, rob.bandits, rob.hostages
    if type(rcops) ~= 'table' then
        return false, 'Os dados do roubo sofreram problemas no meio do envio!'
    end

    local consult = vRP.Query('lotusRoubos/getPreset', { name = name })
    local obj     = consult[1]
    if not obj then
        return false, 'Algo deu errado! (ERROR: 122)'
    end

    local proj = json.decode(obj.projection)
    if type(proj) ~= 'table' then
        return false, 'Projeção inválida!'
    end

    local min = GetMinCopsFromProjection(proj)
    if #rcops <= 0 or #rcops < min then
        local accepterSrc = vRP.Source(rob.policeaccept)
        notify(accepterSrc, 'negado',
            'O policial destinado à escolha, não escolheu oficiais suficientes para o roubo!', 5000)
        return false,
            'O policial destinado à escolha, não escolheu oficiais suficientes para o roubo!'
    end

    -- Hidrata cops + notifica cada um
    for i, v in ipairs(rcops) do
        if v.id then
            local s = vRP.Source(parseInt(v.id))
            if s then
                rcops[i].source = s
                rcops[i].isvivo = isAlive(s)
                rcops[i].kills  = 0
                notify(s, 'sucesso',
                    'Você foi escalado para o roubo ' .. name ..
                    ' dirija-se até o local.', 30000)
            end
        end
    end

    rob.cops = rcops
    rob.auth = nil

    local err, msg
    if Config.Roubos.NeedAdminAuthorization then
        -- TODO: fluxo de aprovação por staff (mantido como antes: indefinido)
    else
        err, msg = 'true', 'Não foi necessário a aprovação de um staff!'
    end

    if err == 'true' then
        lotusRoubos:StartRobbery(k, bandits, rob.cops, hostages)

        if GetResourceState("core_logs") == "started" then
            local banditList = ""
            for _, b in ipairs(bandits or {}) do
                if b.id then
                    banditList = banditList .. (banditList ~= "" and ", " or "") .. vRP.FullName(b.id) .. " #" .. b.id
                end
            end

            exports["core_logs"]:AddLog("ROUBO-INICIOU", {
                message = "Roubo " .. tostring(name) .. " iniciado com " .. #bandits .. " bandidos e " .. #rcops .. " policiais",
                Roubo = name,
                Bandidos = banditList,
                Policiais = #rcops,
                Refens = hostages and #hostages or 0
            })
        end

        return true, tostring(msg)
    end
    return false, tostring(msg)
end

-----------------------------------------------------------------------------
-- DRAWMARKER NO SOURCE DE BANDIDOS / POLICIAIS
-----------------------------------------------------------------------------
local function notifyParticipants(team, fn)
    if type(team) ~= 'table' then return end
    for _, v in pairs(team) do
        if v.id then
            local s = vRP.Source(parseInt(v.id))
            if s then fn(s) end
        end
    end
end

function lotusRoubos:createDrawmarker(coords, key)
    local data = ActualRobberies[key]
    if not data then return end

    notifyParticipants(data.bandits, function(s) vCLIENT._createDrawmarker(s, coords, key) end)
    notifyParticipants(data.cops,    function(s) vCLIENT._createDrawmarker(s, coords, key) end)
end

function lotusRoubos:removeDrawmarker(key)
    local data = ActualRobberies[key]
    if not data then return end

    notifyParticipants(data.bandits, function(s) vCLIENT._removeDrawmarker(s, key) end)
    notifyParticipants(data.cops,    function(s) vCLIENT._removeDrawmarker(s, key) end)
end

-----------------------------------------------------------------------------
-- VALIDAÇÃO DE PERÍMETRO DOS BANDIDOS (cancela se saírem)
-----------------------------------------------------------------------------
function lotusRoubos:checkBanditInZone(key, bandits)
    local k = tonumber(key)
    CreateThread(function()
        local coords = ActualRobberies[k].cds
        while ActualRobberies[k] do
            Wait(1000)

            local todosDentro = true
            for _, v in pairs(bandits) do
                local s = vRP.Source(tonumber(v.id))
                if s then
                    local dist = #(GetEntityCoords(GetPlayerPed(s))
                                 - vector3(coords.x, coords.y, coords.z))
                    if dist > ROB_PERIMETER then
                        todosDentro = false
                    end
                end
            end

            if not todosDentro and ActualRobberies[k] then
                lotusRoubos:removeDrawmarker(k)
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo foi cancelado porque um dos bandidos sairam da área do roubo.', 15000, 'bandits')
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo foi cancelado porque os bandidos sairam da área do roubo.', 15000, 'cops')
                lotusRoubos:cancelRobbery(k)
                break
            end
        end
    end)
end

-----------------------------------------------------------------------------
-- INÍCIO EFETIVO DO ROUBO
-----------------------------------------------------------------------------
local function sendHudToParticipants(participants, robberyData, role)
    for _, p in pairs(participants) do
        local s = vRP.Source(tonumber(p.id))
        if s then
            vCLIENT._hudRobbery(s, robberyData, role)
        end
    end
end

function lotusRoubos:StartRobbery(key, bandits, cops, hostages)
    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then
        return false, 'Algo deu errado! (ERROR: 276)'
    end
    if type(bandits) ~= 'table' or type(cops) ~= 'table' or type(hostages) ~= 'table' then
        return
    end

    local rob    = ActualRobberies[k]
    local name   = tostring(rob.name)
    local coords = rob.cds

    lotusRoubos:createDrawmarker(coords, k)

    local nome = fullName(tonumber(rob.policeaccept))
    TriggerClientEvent('chatMessage', -1, {
        type        = 'default',
        prefixColor = '#ff0000',
        title       = 'Roubo',
        message     = 'O policial ' .. nome .. ' montou o time do roubo ' ..
                      name .. ' e está a caminho do local.',
    })

    -- Loop de monitoramento da entrada dos cops no perímetro
    CreateThread(function()
        lotusRoubos:checkBanditInZone(k, bandits)

        local startTime      = os.time()
        local robberyStarted = false

        while not robberyStarted and ActualRobberies[k] do
            Wait(1000)
            if not ActualRobberies[k] then break end

            local allCopsInZone = true
            local anyCopsAlive  = true

            for _, v in pairs(cops) do
                local s = vRP.Source(tonumber(v.id))
                if s then
                    local dist = #(GetEntityCoords(GetPlayerPed(s))
                                 - vector3(coords.x, coords.y, coords.z))
                    if dist > ROB_PERIMETER then allCopsInZone = false end
                    if GetEntityHealth(GetPlayerPed(s)) <= PLAYER_DEAD_HEALTH then
                        anyCopsAlive = false
                    end
                end
            end

            if allCopsInZone then
                robberyStarted = true
                lotusRoubos:removeDrawmarker(k)
                rob.init = os.time()

                sendHudToParticipants(cops,     rob, 'cops')
                sendHudToParticipants(bandits,  rob, 'bandits')
                sendHudToParticipants(hostages, rob, 'hostages')

                -- 📢 Broadcast pra toda a cidade: roubo começou de verdade
                TriggerClientEvent('chatMessage', -1, {
                    type        = 'default',
                    prefixColor = '#ff0000',
                    title       = 'Roubo',
                    message     = '🚨 ATENÇÃO: o roubo "' .. name .. '" foi INICIADO!',
                })

                -- Toast específico para os participantes
                TriggerEvent('core-roubos:tryrobnotify', k, 'sucesso',
                    'Roubo iniciado! Boa sorte.', 8000, 'bandits')
                TriggerEvent('core-roubos:tryrobnotify', k, 'sucesso',
                    'Roubo iniciado! Os bandidos estão na área.', 8000, 'cops')
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo começou. Coopere para sobreviver.', 8000, 'hostages')

                -- 📡 Discord log: roubo iniciado
                local pusher = rob.pusher and vRP.Passport(rob.pusher) or nil
                webhookEmbed('log', {
                    title       = '🚨 Roubo iniciado · ' .. name,
                    color       = WEBHOOK_COLORS.start,
                    description = 'Os policiais entraram no perímetro e a ação começou.',
                    fields = {
                        { name = '👤 Pusher',   value = describePlayer(pusher),     inline = true },
                        { name = '🔫 Bandidos', value = tostring(#(bandits  or {})), inline = true },
                        { name = '👮 Policiais',value = tostring(#(cops     or {})), inline = true },
                        { name = '🙇 Reféns',   value = tostring(#(hostages or {})), inline = true },
                        { name = '💰 Valor estimado',
                          value = (rob.isDarkMoney and 'R$ ' or 'R$ ') .. tostring(rob.estimatedValue or 0) ..
                                  (rob.isDarkMoney and ' (sujo)' or ''),
                          inline = true },
                    },
                })

                break
            elseif not anyCopsAlive then
                lotusRoubos:removeDrawmarker(k)
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo foi cancelado porque um dos policiais acabou morrendo antes de começar a ação.', 15000, 'cops')
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo foi cancelado porque um dos policiais acabou morrendo antes de começar a ação.', 15000, 'bandits')
                lotusRoubos:cancelRobbery(k)
                break
            elseif os.time() - startTime >= START_TIME_LIMIT then
                lotusRoubos:removeDrawmarker(k)
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo foi cancelado porque os policias não entraram na área do roubo a tempo.', 15000, 'bandits')
                TriggerEvent('core-roubos:tryrobnotify', k, 'importante',
                    'O roubo foi cancelado porque vocês não entraram na área do roubo a tempo.', 15000, 'cops')
                lotusRoubos:cancelRobbery(k)
                break
            end
        end
    end)

    -- Inicializa HUD imediato + blip da rota dos cops
    notifyParticipants(cops, function(s)
        vCLIENT._initRobbery(s, rob, 'cops')
        if coords then
            vCLIENT._createCopsBlip(s, coords, name, Config.Roubos.blipCooldown)
        end
    end)
    notifyParticipants(bandits,  function(s) vCLIENT._initRobbery(s, rob, 'bandits') end)
    notifyParticipants(hostages, function(s) vCLIENT._initRobbery(s, rob, 'hostages') end)
end

-----------------------------------------------------------------------------
-- VOTO DE RENDIÇÃO
-----------------------------------------------------------------------------
function lotusRoubos:voteRobberyGiveUp(team)
    local _, _, key, Team = IsInRobbery(source)
    if not (key and tostring(Team) == tostring(team)) then
        return { status = false, msg = 'Ocorreu um erro ao votar!' }
    end

    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then
        return { status = false, msg = 'Algo deu errado! (ERROR: 420)' }
    end

    local data = GetPlayerTable(source)
    if data.giveup then
        return { status = false, msg = 'Você já votou!' }
    end
    data.giveup = true

    local members      = GetGiveUpMembers(k, tostring(team))
    local teamSources  = GetRobberySources(k, team)

    if type(teamSources) == 'table' and type(members) == 'table'
            and #teamSources == #members then
        local winner    = (team == 'cops') and 'bandits' or 'cops'
        local teamLabel = { cops = 'policiais', bandits = 'bandidos' }
        local sources   = GetRobberySources(k)

        for _, p in ipairs(sources) do
            TriggerClientEvent('winnernotify', p, tostring(winner))
            TriggerClientEvent('robnotify',    p, 'aviso',
                'O time dos ' .. teamLabel[team] .. ' se renderam!', 15000)
            lotusRoubos:removeDrawmarker(k)
            vCLIENT._updateActualRobbery(p, false)
        end

        -- 💰 Distribui recompensa para o time vencedor (faltava antes!)
        DistributeMoneyToWinners(winner, k)
        lotusRoubos:removeDrawmarker(k)

        InsertRobberyData(k, tostring(winner))
        return { status = true,
            msg = 'O roubo terminou, todos os integrantes do seu time desistiram!' }
    end

    if #members == 1 then
        TriggerEvent('core-roubos:tryrobnotify', key, 'importante',
            'Uma votação de desistência foi iniciada, abra o menu e vote!', 15000, team)
    else
        TriggerEvent('core-roubos:tryrobnotify', key, 'importante',
            'O passaporte ' .. tostring(data.id) .. ' votou para se render!', 8000, team)
    end

    return { status = true, msg = 'Você votou para se render!' }
end

function lotusRoubos:giveAwardRobbery(user_id, amount, moneytype)
    if user_id and amount and moneytype then
        return true
    end
end

-----------------------------------------------------------------------------
-- LISTAGEM (comando admin /roubos listar)
-----------------------------------------------------------------------------
function lotusRoubos:listRobberys()
    local message = 'Lista de Roubos:\n'
    for k, v in pairs(ActualRobberies) do
        message = message .. string.format(
            'Roubo ID %d:\n Nome: %s, Ladrões: %d, Policiais: %d, Reféns: %d\n',
            k, v.name,
            #(v.bandits or {}), #(v.cops or {}), #(v.hostages or {}))
    end
    return message
end

function lotusRoubos:deleteRobbery(robberyKey)
    ActualRobberies[robberyKey] = nil
end

-----------------------------------------------------------------------------
-- EVENTOS DE REDE
-----------------------------------------------------------------------------
RegisterNetEvent('core-roubos:playerKilled', function(killedBy, data)
    local victim  = source
    local assasin = killedBy
    if not victim or not assasin then return end

    if tonumber(assasin) == -1 or tonumber(assasin) == tonumber(victim) then
        assasin = false
    elseif Config.Roubos.hitMarker then
        TriggerClientEvent('robhitmarker', assasin)
    end

    local inRobbery, _, key, team = IsInRobbery(victim)
    if not tonumber(key) or not inRobbery then return end

    local _, _, key2, team2
    if assasin then
        _, _, key2, team2 = IsInRobbery(assasin)
    end

    local reason = data.weaponhash
    local reasonData = Config.DeathEvent.reasonsKill[tonumber(reason)]
    local weaponed, weaponClass

    if reasonData and reasonData.reason and reasonData.weapon and reasonData.class then
        weaponClass = tostring(reasonData.class)
        weaponed    = Config.DeathEvent.WeaponClassIcons[weaponClass]
        reason      = tostring(reasonData.reason)
    else
        weaponClass = 'unarmed'
        weaponed    = Config.DeathEvent.WeaponClassIcons.unarmed
        reason      = 'O motivo da morte do jogador não foi encontrado!'
    end

    if assasin and key2 and key == key2 then
        AnyKillInRobbery(tonumber(key),
            { parseInt(victim), tostring(team) },
            weaponed,
            { parseInt(assasin), team2 })
    else
        AnyKillInRobbery(tonumber(key),
            { parseInt(victim), tostring(team) },
            weaponed)
    end
end)

RegisterNetEvent('core-roubos:tryrobnotify', function(key, style, msg, time, team)
    local src = source
    if key == false then
        TriggerClientEvent('core-roubos:robnotify', src, style, msg, tonumber(time))
        return
    end

    local k = tonumber(key)
    if not k or type(ActualRobberies[k]) ~= 'table' then return end
    if type(style) ~= 'string' or type(msg) ~= 'string' or not tonumber(time) then return end

    local sources = GetRobberySources(k, team)
    if type(sources) ~= 'table' then return end

    for _, v in ipairs(sources) do
        if tonumber(v) then
            TriggerClientEvent('core-roubos:robnotify',
                tonumber(v), style, msg, tonumber(time))
        end
    end
end)
