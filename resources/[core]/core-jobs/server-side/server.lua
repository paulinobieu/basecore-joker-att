-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------
local function DatabaseQuery(query, parameters)
    parameters = parameters or {}
    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, parameters)
    end
    return exports.oxmysql:query_async(query, parameters)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local CharactersWorking = {}
local Impound = {}
local WorkerLevels = Config.workerLevels or {
    [1] = 1000,
    [2] = 15000,
    [3] = 45000
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SECURITY (validacoes server-authoritative)
-----------------------------------------------------------------------------------------------------------------------------------------
local function ServerPlayerCoords(source)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return nil end
    return GetEntityCoords(ped)
end

local function ValidCoords(c)
    return c and type(c.x) == "number" and c.x == c.x and math.abs(c.x) <= 10000.0
        and type(c.y) == "number" and c.y == c.y and math.abs(c.y) <= 10000.0
        and type(c.z) == "number" and c.z == c.z and math.abs(c.z) <= 10000.0
end

local function PointCoords(point)
    if not point then return nil end
    return vector3(point.x or point[1], point.y or point[2], point.z or point[3])
end

local function NearPoint(coords, point, radius)
    local target = PointCoords(point)
    return coords and target and #(coords - target) <= radius
end

local function NearAnyPoint(coords, points, radius)
    if not points then return true end
    if not coords then return false end
    local r2 = radius * radius
    for _, p in ipairs(points) do
        local px = p.x or p[1]
        local py = p.y or p[2]
        if px and py then
            local dx = coords.x - px
            local dy = coords.y - py
            if (dx * dx + dy * dy) <= r2 then
                return true
            end
        end
    end
    return false
end

local function InList(list, value)
    if not list then return false end
    for _, v in ipairs(list) do
        if v == value then return true end
    end
    return false
end

local RateLimits = {}
local function RateLimited(source, key, interval)
    local bucket = RateLimits[source]
    if not bucket then bucket = {} RateLimits[source] = bucket end
    local now = GetGameTimer()
    local last = bucket[key]
    if last and (now - last) < interval then
        return true
    end
    bucket[key] = now
    return false
end

local function TreePoints(trees)
    local out = {}
    if trees then for _, t in ipairs(trees) do out[#out + 1] = t.point end end
    return out
end

local function RestaurantPoints(list)
    local out = {}
    if list then for _, r in ipairs(list) do out[#out + 1] = r.point end end
    return out
end

local function MergePoints(...)
    local out = {}
    for _, list in ipairs({ ... }) do
        if list then for _, p in ipairs(list) do out[#out + 1] = p end end
    end
    return out
end

local R = Config.routes or {}
local SequentialRules = {
    ["minerador"] = { points = R["minerador"] and R["minerador"].minerPoints, radius = 12.0, vehicleRadius = 100.0 },
    ["motorista"] = { points = R["motorista"] and R["motorista"].routePoints, radius = 15.0, vehicleRadius = 20.0, driver = true },
    ["agricultor-trigo"] = { points = R["agricultor-trigo"] and R["agricultor-trigo"].crops, radius = 12.0, vehicleRadius = 20.0, driver = true },
}
local CollectCooldowns = {
    minerador = 5000, motorista = 2000, pescador = 3000, lixeiro = 2000,
    ["agricultor-trigo"] = 3000, ["agricultor-laranjas"] = 5000,
    lenhador = 5000, eletricista = 5000, entregador = 2000,
    ["entregador-jornais"] = 1500, reboque = 3000, cegonha = 3000, taxista = 10000,
}

local Violations = {}
local LastAttempt = {}
local CleanupWorker
local AntiCheat = {
    burstMs = 500,
    decayMs = 30000,
    logAt = 3,
}

local function FlagViolation(source, Passport, reason, weight)
    weight = weight or 1
    local now = GetGameTimer()
    local v = Violations[source]
    if not v or (now - v.last) > AntiCheat.decayMs then
        v = { count = 0, last = now, logged = false }
        Violations[source] = v
    end
    v.count = math.min(v.count + weight, 20)
    v.last = now

    if v.count >= AntiCheat.logAt and not v.logged then
        v.logged = true
        Functions.log("ANTICHEAT-EMPREGO", {
            message    = Functions.getFullName(Passport) .. " #" .. tostring(Passport) .. " acumulou divergencias em eventos de emprego (" .. tostring(reason) .. ")",
            playerName = Functions.getFullName(Passport),
            playerId   = Passport,
            Motivo     = reason,
            Violacoes  = v.count,
        })
    end

    return false
end

local function NearestPointIndex(coords, points, radius, field)
    if not coords or not points then return nil end
    local nearest, nearestDistance
    for index, entry in ipairs(points) do
        local point = field and entry[field] or entry
        local target = PointCoords(point)
        if target then
            local distance = #(coords - target)
            if distance <= radius and (not nearestDistance or distance < nearestDistance) then
                nearest = index
                nearestDistance = distance
            end
        end
    end
    return nearest
end

local function ReservePoint(WorkerData, namespace, index, cooldown)
    WorkerData.pointCooldowns = WorkerData.pointCooldowns or {}
    local key = namespace .. ":" .. tostring(index)
    local now = os.time()
    if (WorkerData.pointCooldowns[key] or 0) > now then return false end
    return true, function()
        WorkerData.pointCooldowns[key] = os.time() + cooldown
    end
end

local function ResolveNetVehicle(Network)
    if type(Network) ~= "number" or Network <= 0 then return nil end
    local Vehicle = NetworkGetEntityFromNetworkId(Network)
    if not Vehicle or Vehicle == 0 or not DoesEntityExist(Vehicle) or GetEntityType(Vehicle) ~= 2 then return nil end
    return Vehicle
end

local function ValidNetworkObject(source, Network, Model, Coords)
    if type(Network) ~= "number" or Network <= 0 then return true end
    local Object = NetworkGetEntityFromNetworkId(Network)
    return Object and Object > 0 and DoesEntityExist(Object) and GetEntityType(Object) == 3
        and GetEntityModel(Object) == Model
        and GetEntityRoutingBucket(Object) == GetPlayerRoutingBucket(source)
        and #(GetEntityCoords(Object) - PointCoords(Coords)) <= 0.75
end

local function RemoveNetVehicle(Network)
    local removed = false
    if GetResourceState("core-vehicles") == "started" then
        local ok, result = pcall(function()
            return exports["core-vehicles"]:removeVehicleEntity(Network)
        end)
        removed = ok and result == true
    end
    if not removed then
        local Vehicle = ResolveNetVehicle(Network)
        if Vehicle then DeleteEntity(Vehicle) end
    end
end

local function ValidMissionVehicle(source, Network, Model, radius)
    local Vehicle = ResolveNetVehicle(Network)
    local coords = ServerPlayerCoords(source)
    if not Vehicle or not coords or GetPlayerRoutingBucket(source) ~= GetEntityRoutingBucket(Vehicle) then return nil end
    if Model and GetEntityModel(Vehicle) ~= GetHashKey(Model) then return nil end
    if #(coords - GetEntityCoords(Vehicle)) > radius then return nil end
    return Vehicle
end

local function IsVehicleDriver(source, Vehicle)
    local Ped = GetPlayerPed(source)
    return Ped and Ped > 0 and GetPedInVehicleSeat(Vehicle, -1) == Ped
end

local function VehicleOwnedByPassport(Passport, Vehicle)
    if GetResourceState("core-vehicles") ~= "started" then return false end
    local Plate = (GetVehicleNumberPlateText(Vehicle) or ""):gsub("%s+", "")
    if Plate == "" then return false end
    local ok, Owner = pcall(function()
        return exports["core-vehicles"]:getVehicleOwnerByPlate(Plate)
    end)
    return ok and tonumber(Owner) == tonumber(Passport)
end

CleanupWorker = function(Passport)
    local WorkerData = CharactersWorking[Passport]
    if WorkerData and WorkerData.Cegonha and WorkerData.Cegonha.Network then
        RemoveNetVehicle(WorkerData.Cegonha.Network)
    end
    for Plate, Data in pairs(Impound) do
        if Data.Passport == Passport then
            RemoveNetVehicle(Data.Network)
            Impound[Plate] = nil
        end
    end
    CharactersWorking[Passport] = nil
end

local function ValidateCollectAction(source, Passport, WorkerData, Data)
    local jobId = WorkerData.jobId
    local coords = ServerPlayerCoords(source)
    if not coords then return false, "sem_ped" end

    local sequential = SequentialRules[jobId]
    if sequential then
        local expected = WorkerData.nextPoint or 1
        local point = sequential.points and sequential.points[expected]
        if not point or not NearPoint(coords, point, sequential.radius) then
            return false, "fora_da_sequencia"
        end
        local Network = type(Data) == "table" and tonumber(Data.vehicle) or nil
        local RequiredVehicle = R[jobId] and R[jobId].requiredVehicle
        local Vehicle = ValidMissionVehicle(source, Network, RequiredVehicle, sequential.vehicleRadius)
        if not Vehicle or (WorkerData.ServiceNetwork and WorkerData.ServiceNetwork ~= Network)
            or not VehicleOwnedByPassport(Passport, Vehicle)
            or (sequential.driver and not IsVehicleDriver(source, Vehicle)) then
            return false, "veiculo_de_servico_invalido"
        end
        return true, nil, function()
            WorkerData.ServiceNetwork = WorkerData.ServiceNetwork or Network
            WorkerData.nextPoint = expected >= #sequential.points and 1 or expected + 1
        end
    end

    if jobId == "pescador" then
        return NearestPointIndex(coords, R[jobId] and R[jobId].fishingAreas, 105.0) ~= nil, "fora_da_area"
    end

    if jobId == "agricultor-laranjas" or jobId == "lenhador" then
        local trees = R[jobId] and R[jobId].trees
        local index = NearestPointIndex(coords, trees, 5.0, "point")
        if not index then return false, "fora_da_arvore" end
        local available, commit = ReservePoint(WorkerData, jobId, index, 55)
        return available, "ponto_em_cooldown", commit
    end

    if jobId == "entregador" then
        local index = NearestPointIndex(coords, R[jobId] and R[jobId].deliveryPoints, 5.0)
        if not index then return false, "fora_da_entrega" end
        local available, commit = ReservePoint(WorkerData, jobId, index, 15)
        return available, "ponto_em_cooldown", commit
    end

    if jobId == "entregador-jornais" then
        local locations = R[jobId] and R[jobId].locations
        local index = type(Data) == "table" and tonumber(Data.point) or nil
        if not index or index % 1 ~= 0 or not locations or not locations[index]
            -- O jornal pode atingir a caixa enquanto o entregador ainda está na rua.
            -- A tolerância continua limitada ao ponto configurado e validada no servidor.
            or not NearPoint(coords, locations[index], 35.0) then
            return false, "fora_da_entrega"
        end
        local available, commit = ReservePoint(WorkerData, jobId, index, 180)
        return available, "ponto_em_cooldown", commit
    end

    if jobId == "lixeiro" or jobId == "eletricista" then
        local pending = WorkerData.PendingAction
        if not pending or pending.JobId ~= jobId or os.time() < pending.CompleteAt or os.time() > pending.ExpiresAt then
            return false, "acao_dinamica_invalida"
        end
        if type(Data) ~= "table" or not ValidCoords(Data.coords) or tonumber(Data.model) ~= pending.Model
            or #(PointCoords(Data.coords) - pending.Coords) > 0.75
            or tonumber(Data.network or 0) ~= pending.Network
            or not ValidNetworkObject(source, pending.Network, pending.Model, pending.Coords) then
            return false, "objeto_dinamico_divergente"
        end
        if jobId == "eletricista" and not NearPoint(coords, pending.Coords, 4.0) then return false, "longe_do_objeto" end
        local available, pointCommit = ReservePoint(WorkerData, jobId, pending.Key, 180)
        if not available then return false, "ponto_em_cooldown" end
        if jobId == "lixeiro" then
            local Network = tonumber(Data.vehicle)
            if (WorkerData.ServiceNetwork and WorkerData.ServiceNetwork ~= Network)
                or not ValidMissionVehicle(source, Network, R[jobId].requiredVehicle, 5.0) then
                return false, "caminhao_invalido"
            end
            local ServiceVehicle = ResolveNetVehicle(Network)
            if not ServiceVehicle or not VehicleOwnedByPassport(Passport, ServiceVehicle) then
                return false, "caminhao_sem_vinculo"
            end
        end
        return true, nil, function()
            WorkerData.PendingAction = nil
            if jobId == "lixeiro" and not WorkerData.ServiceNetwork then
                WorkerData.ServiceNetwork = tonumber(Data.vehicle)
            end
            pointCommit()
        end
    end

    if jobId == "reboque" then
        if type(Data) ~= "table" or type(Data.plate) ~= "string" or #Data.plate > 16 then return false, "placa_invalida" end
        local mission = Impound[Data.plate]
        if not mission or mission.Passport ~= Passport or not NearPoint(coords, R[jobId].dropOff, 12.0) then
            return false, "reboque_invalido"
        end
        local Vehicle = ValidMissionVehicle(source, mission.Network, nil, 18.0)
        if not Vehicle or GetVehicleNumberPlateText(Vehicle):gsub("%s+", "") ~= Data.plate:gsub("%s+", "") then
            return false, "veiculo_reboque_invalido"
        end
        return true, nil, function()
            RemoveNetVehicle(mission.Network)
            Impound[Data.plate] = nil
        end
    end

    if jobId == "cegonha" then
        local state = WorkerData.Cegonha
        local points = R[jobId] and R[jobId].locations
        if not state or state.Step ~= #points or not NearPoint(coords, points[#points], 12.0)
            or not ValidMissionVehicle(source, state.PackerNetwork, R[jobId].requiredVehicle, 20.0) then
            return false, "rota_cegonha_incompleta"
        end
        local Packer = ResolveNetVehicle(state.PackerNetwork)
        if not Packer or not IsVehicleDriver(source, Packer) then return false, "motorista_cegonha_invalido" end
        return true, nil, function()
            WorkerData.Cegonha = nil
            WorkerData.nextCegonhaAt = os.time() + 10
        end
    end

    if jobId == "taxista" then
        local index = NearestPointIndex(coords, R[jobId] and R[jobId].locations, 6.0, "Vehicle")
        local now = os.time()
        if not index or now - (WorkerData.lastTaxiAt or WorkerData.startedAt or now) < 15 then
            return false, "corrida_invalida"
        end
        local destination = PointCoords(R[jobId].locations[index].Vehicle)
        if WorkerData.lastTaxiCoords and #(destination - WorkerData.lastTaxiCoords) < 80.0 then
            return false, "corrida_curta"
        end
        local ped = GetPlayerPed(source)
        local Vehicle = ped and GetVehiclePedIsIn(ped, false)
        if not Vehicle or Vehicle == 0 or GetEntityModel(Vehicle) ~= GetHashKey(R[jobId].requiredVehicle) then
            return false, "taxi_invalido"
        end
        if not IsVehicleDriver(source, Vehicle) then return false, "taxista_fora_do_volante" end
        if not VehicleOwnedByPassport(Passport, Vehicle) then return false, "taxi_sem_vinculo" end
        return true, nil, function()
            WorkerData.lastTaxiAt = now
            WorkerData.lastTaxiCoords = destination
        end
    end

    return false, "emprego_sem_politica"
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    DatabaseQuery([[CREATE TABLE IF NOT EXISTS `core_jobs_data` (
        `characterId` int(11) NOT NULL,
        `currentExp` bigint(255) DEFAULT 0,
        `currentLvl` int(11) DEFAULT 1,
        `missionsProgress` longtext DEFAULT '{}',
        `jobsExp` longtext DEFAULT '{}',
        `todayEarnings` bigint(255) DEFAULT 0,
        `totalEarnings` bigint(255) DEFAULT 0,
        `earningsDate` varchar(20) DEFAULT '',
        `rewardsResetTime` bigint(255) DEFAULT 0,
        `workedMinutes` int(11) DEFAULT 0,
        `bonusProgress` longtext DEFAULT '{}',
        `bonusResetTime` bigint(255) DEFAULT 0,
        PRIMARY KEY (`characterId`)
    )]])
    DatabaseQuery([[ALTER TABLE `core_jobs_data`
        ADD COLUMN IF NOT EXISTS `workedMinutes` int(11) DEFAULT 0,
        ADD COLUMN IF NOT EXISTS `bonusProgress` longtext DEFAULT '{}',
        ADD COLUMN IF NOT EXISTS `bonusResetTime` bigint(255) DEFAULT 0
    ]])
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER: get per-job level from XP
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetJobLevel(jobXp)
    local lvl = 0
    if Config.perJobLevels then
        for level, requiredXp in pairs(Config.perJobLevels) do
            if jobXp >= requiredXp and level > lvl then
                lvl = level
            end
        end
    end
    return lvl
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER: get reward multiplier from job level
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetJobMultiplier(jobLevel)
    if Config.perLevelMultiplier and Config.perLevelMultiplier[jobLevel] then
        return Config.perLevelMultiplier[jobLevel]
    end
    return 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER: get reward multiplier from global worker level
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetWorkerMultiplier(workerLevel)
    if Config.workerLevelMultiplier and Config.workerLevelMultiplier[workerLevel] then
        return Config.workerLevelMultiplier[workerLevel]
    end
    return 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER: save full data
-----------------------------------------------------------------------------------------------------------------------------------------
local function PersistJobData(Passport, Data)
    DatabaseQuery([[REPLACE INTO `core_jobs_data`
        (`characterId`,`currentExp`,`currentLvl`,`missionsProgress`,`jobsExp`,
         `todayEarnings`,`totalEarnings`,`earningsDate`,`rewardsResetTime`,
         `workedMinutes`,`bonusProgress`,`bonusResetTime`)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
    ]], {
        Passport,
        Data.currentExp or 0,
        Data.currentLvl or 1,
        Data.missionsProgress or "{}",
        Data.jobsExp or "{}",
        Data.todayEarnings or 0,
        Data.totalEarnings or 0,
        Data.earningsDate or "",
        Data.rewardsResetTime or 0,
        Data.workedMinutes or 0,
        Data.bonusProgress or "{}",
        Data.bonusResetTime or 0,
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CACHE SYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
local JobsCache = {}

local function NormalizeWorkerLevel(Data)
    local Level = math.floor(tonumber(Data.currentLvl) or 1)
    if Level < 1 then
        Data.currentLvl = 1
        Data._dirty = true
    else
        Data.currentLvl = Level
    end
end

local function EnsureJobData(Passport)
    if not JobsCache[Passport] then
        local DataResult = DatabaseQuery("SELECT * FROM `core_jobs_data` WHERE `characterId` = ?", { Passport })
        if DataResult and DataResult[1] then
            JobsCache[Passport] = DataResult[1]
            NormalizeWorkerLevel(JobsCache[Passport])
        else
            DatabaseQuery([[INSERT IGNORE INTO `core_jobs_data`
                (`characterId`,`currentExp`,`currentLvl`,`missionsProgress`,`jobsExp`,
                 `todayEarnings`,`totalEarnings`,`earningsDate`,`rewardsResetTime`,
                 `workedMinutes`,`bonusProgress`,`bonusResetTime`)
                VALUES (?,0,1,'{}','{}',0,0,'',0,0,'{}',0)
            ]], { Passport })
            local NewDataResult = DatabaseQuery("SELECT * FROM `core_jobs_data` WHERE `characterId` = ?", { Passport })
            if NewDataResult and NewDataResult[1] then
                JobsCache[Passport] = NewDataResult[1]
                NormalizeWorkerLevel(JobsCache[Passport])
            end
        end
    end
end

local function SaveJobData(Passport, Data)
    if Passport and Data then
        JobsCache[Passport] = Data
        -- Marcamos que esse Passport tem uma alteração pendente de salvamento
        JobsCache[Passport]._dirty = true
    end
end

local function GetTodayStr()
    return os.date("%Y-%m-%d")
end

local function LoadJobData(Passport)
    if not JobsCache[Passport] then return nil end
    local d = JobsCache[Passport]
    
    local today = GetTodayStr()
    if (d.earningsDate or "") ~= today then
        d.todayEarnings = 0
        d.earningsDate = today
        JobsCache[Passport]._dirty = true
    end
    
    return d
end

-- Thread to save data back to DB every 10 minutes (robust, batch save)
CreateThread(function()
    while true do
        Wait(10 * 60000)
        local savesCount = 0
        for Passport, Data in pairs(JobsCache) do
            if Data._dirty then
                PersistJobData(Passport, Data)
                Data._dirty = false
                savesCount = savesCount + 1
            end
        end
        if savesCount > 0 then
            print("[core-jobs] Sistema de Cache: "..savesCount.." dados de jogadores salvos no banco de dados com sucesso.")
        end
    end
end)

local function HandleDisconnect(Passport, source)
    if not Passport then return end
    if JobsCache[Passport] and JobsCache[Passport]._dirty then
        PersistJobData(Passport, JobsCache[Passport])
    end
    JobsCache[Passport] = nil
    CleanupWorker(Passport)
    if source then
        RateLimits[source] = nil
        Violations[source] = nil
        LastAttempt[source] = nil
    end
end

-- O hook local Disconnect entrega o Passport antes de o vRP limpar o vínculo source/personagem.
AddEventHandler("Disconnect", function(Passport, source)
    HandleDisconnect(Passport, source)
end)

-- Fallback apenas para tabelas indexadas por source; não resolve Passport tarde demais.
AddEventHandler("playerDropped", function()
    local source = source
    RateLimits[source] = nil
    Violations[source] = nil
    LastAttempt[source] = nil
end)

-- Track worked minutes for all active workers (every 60 seconds)
CreateThread(function()
    while true do
        Wait(60000)
        for Passport, WorkerData in pairs(CharactersWorking) do
            if WorkerData and WorkerData.jobId then
                EnsureJobData(Passport)
                local d = LoadJobData(Passport)
                if d then
                    d.workedMinutes = (d.workedMinutes or 0) + 1
                    SaveJobData(Passport, d)
                end
            end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- GET RANKING (local helper)
-----------------------------------------------------------------------------------------------------------------------------------------
local RankingCache = nil
local RankingCacheExpires = 0
local function GetRanking()
    if RankingCache and os.time() < RankingCacheExpires then return RankingCache end
    local rows = DatabaseQuery("SELECT `characterId`,`currentExp`,`currentLvl`,`workedMinutes` FROM `core_jobs_data` ORDER BY `currentExp` DESC LIMIT 15")
    local ranking = {}
    if rows then
        for i, row in ipairs(rows) do
            local charId = row.characterId
            local pName = Functions.getFullName(charId)

            local workedMins = row.workedMinutes or 0
            local hrs = math.floor(workedMins / 60)
            local mins = workedMins % 60
            local timeString = string.format("%dh %dm", hrs, mins)

            table.insert(ranking, {
                id = i,
                name = pName,
                playerId = tostring(charId),
                job = timeString,
                xp = row.currentExp or 0
            })
        end
    end
    RankingCache = ranking
    RankingCacheExpires = os.time() + 30
    return RankingCache
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILD UI MISSIONS (local helper)
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildUIMissions(Progress)
    local uiMissions = {}
    if Config.missions then
        for _, m in ipairs(Config.missions) do
            local mData = Progress[tostring(m.id)] or { current = 0, completed = false }
            table.insert(uiMissions, {
                id = m.id,
                title = m.title,
                description = m.description,
                current = mData.current,
                total = m.target,
                xp = m.xp,
                completed = mData.completed
            })
        end
    end
    return uiMissions
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE MISSION PROGRESS
-----------------------------------------------------------------------------------------------------------------------------------------
local function UpdateMissionProgress(Passport, CurrentJobId)
    local d = LoadJobData(Passport)
    if not d then return end

    local Progress = {}
    if d.missionsProgress then
        Progress = json.decode(d.missionsProgress) or {}
    end

    local Updated = false
    if Config.missions then
        for _, m in ipairs(Config.missions) do
            if m.jobId == CurrentJobId then
                local msKey = tostring(m.id)
                if not Progress[msKey] then Progress[msKey] = { current = 0, completed = false } end
                if not Progress[msKey].completed and Progress[msKey].current < m.target then
                    Progress[msKey].current = Progress[msKey].current + 1
                    Updated = true
                end
            end
        end
    end

    if Updated then
        d.missionsProgress = json.encode(Progress)
        SaveJobData(Passport, d)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS (client → server)
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-jobs:requestAgencyData", function(callbackId)
    local source = source
    local Passport = Functions.getUserId(source)
    if not Passport then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if RateLimited(source, "agencyData", 2000) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local Identity = Functions.getIdentity(Passport)
    if not Identity then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    EnsureJobData(Passport)
    local d = LoadJobData(Passport)
    if not d then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local Level = math.max(math.floor(tonumber(d.currentLvl) or 1), 1)
    local Xp = d.currentExp or 0
    local Progress = {}
    if d.missionsProgress then
        Progress = json.decode(d.missionsProgress) or {}
    end
    local JobsExpMap = {}
    if d.jobsExp then
        JobsExpMap = json.decode(d.jobsExp) or {}
    end

    local NextLevelTarget = WorkerLevels[Level + 1] or (WorkerLevels[Level] or 1000)

    local playerName = Functions.getFullName(Passport)
    local RankingData = GetRanking()

    local JobLevelsMap = {}
    for jobId, jobXp in pairs(JobsExpMap) do
        JobLevelsMap[jobId] = GetJobLevel(jobXp)
    end

    -- Build bonus data
    local uiBonuses = {}
    local bonusCfg = Config.bonusByWorkedHours
    if bonusCfg and bonusCfg.enabled then
        local workedMins = d.workedMinutes or 0
        local workedHrs = workedMins / 60
        local BonusProgress = {}
        if d.bonusProgress then
            BonusProgress = json.decode(d.bonusProgress) or {}
        end

        local bonusResetTime = d.bonusResetTime or 0
        local now = os.time()
        if bonusResetTime > 0 and now >= bonusResetTime then
            workedMins = 0
            d.workedMinutes = 0
            BonusProgress = {}
            d.bonusProgress = "{}"
            d.bonusResetTime = now + (bonusCfg.resetEveryDays * 86400)
            SaveJobData(Passport, d)
            PersistJobData(Passport, d)
            d._dirty = false
        elseif bonusResetTime == 0 then
            d.bonusResetTime = now + (bonusCfg.resetEveryDays * 86400)
            SaveJobData(Passport, d)
            PersistJobData(Passport, d)
            d._dirty = false
        end

        for i, r in ipairs(bonusCfg.rewards) do
            local bKey = tostring(i)
            local claimed = BonusProgress[bKey] and BonusProgress[bKey].claimed or false
            table.insert(uiBonuses, {
                id = i,
                workedHours = r.workedHours,
                reward = r.reward,
                currentHours = math.floor(workedHrs * 10) / 10,
                claimed = claimed
            })
        end
    end

    TriggerClientEvent("core-jobs:response", source, callbackId, {
        name = playerName,
        avatar = nil,
        level = Level,
        xp = Xp,
        maxXp = NextLevelTarget,
        todayEarnings = d.todayEarnings or 0,
        totalEarnings = d.totalEarnings or 0,
        missions = BuildUIMissions(Progress),
        ranking = RankingData,
        jobLevels = JobLevelsMap,
        themeColor = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or Config.ThemeColor or "#ca27f4",
        bonuses = uiBonuses,
        workedMinutes = d.workedMinutes or 0
    })
end)

RegisterNetEvent("core-jobs:claimBonus", function(callbackId, missionId)
    local source = source
    local Passport = Functions.getUserId(source)
    if not Passport then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    if RateLimited(source, "claimBonus", 750) then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    if type(missionId) ~= "number" or missionId % 1 ~= 0 then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    EnsureJobData(Passport)
    local d = LoadJobData(Passport)
    if not d then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    local missionCfg = nil
    for _, m in ipairs(Config.missions) do
        if m.id == missionId then
            missionCfg = m
            break
        end
    end
    if not missionCfg then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    local Progress = {}
    if d.missionsProgress then
        Progress = json.decode(d.missionsProgress) or {}
    end

    local mData = Progress[tostring(missionId)]
    if not mData or mData.completed or mData.current < missionCfg.target then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    mData.completed = true
    Progress[tostring(missionId)] = mData

    local Xp = (d.currentExp or 0) + missionCfg.xp
    local Level = d.currentLvl or 1

    local nextTarget = WorkerLevels[Level + 1]
    while nextTarget and Xp >= nextTarget do
        Level = Level + 1
        Functions.notify(source, "Emprego", "Parabéns! Você subiu para o nível " .. Level .. " de Trabalhador!", "verde", 5000)
        nextTarget = WorkerLevels[Level + 1]
    end

    d.currentExp = Xp
    d.currentLvl = Level
    d.missionsProgress = json.encode(Progress)
    SaveJobData(Passport, d)
    PersistJobData(Passport, d)
    d._dirty = false
    RankingCache = nil

    local NextLevelTarget = WorkerLevels[Level + 1] or (WorkerLevels[Level] or 1000)

    TriggerClientEvent("core-jobs:response", source, callbackId, {
        success = true,
        missions = BuildUIMissions(Progress),
        xp = Xp,
        maxXp = NextLevelTarget,
        level = Level
    })
end)

RegisterNetEvent("core-jobs:claimHourBonus", function(callbackId, bonusId)
    local source = source
    local Passport = Functions.getUserId(source)
    if not Passport then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    if RateLimited(source, "claimHourBonus", 750) then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    if type(bonusId) ~= "number" or bonusId % 1 ~= 0 then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    EnsureJobData(Passport)
    local d = LoadJobData(Passport)
    if not d then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    local bonusCfg = Config.bonusByWorkedHours
    if not bonusCfg or not bonusCfg.enabled then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    local reward = bonusCfg.rewards[bonusId]
    if not reward then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    local workedHrs = (d.workedMinutes or 0) / 60
    if workedHrs < reward.workedHours then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    local BonusProgress = {}
    if d.bonusProgress then
        BonusProgress = json.decode(d.bonusProgress) or {}
    end

    local bKey = tostring(bonusId)
    if BonusProgress[bKey] and BonusProgress[bKey].claimed then
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    if not Functions.checkWeight(Passport, "dollar", reward.reward) then
        Functions.notify(source, "Emprego", "Mochila cheia. Libere espaço para resgatar o bônus.", "vermelho", 5000)
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end

    BonusProgress[bKey] = { claimed = true }
    d.bonusProgress = json.encode(BonusProgress)

    if not Functions.giveItem(Passport, "dollar", reward.reward) then
        BonusProgress[bKey] = nil
        d.bonusProgress = json.encode(BonusProgress)
        TriggerClientEvent("core-jobs:response", source, callbackId, { error = true })
        return
    end
    SaveJobData(Passport, d)
    PersistJobData(Passport, d)
    d._dirty = false
    Functions.notify(source, "Emprego", "Bônus resgatado! Você recebeu $"..reward.reward..".", "verde", 5000)

    Functions.log("EMPREGO-BONUS", {
        message    = Functions.getFullName(Passport) .. " #" .. Passport .. " resgatou o bônus de horas trabalhadas de R$ " .. reward.reward,
        playerName = Functions.getFullName(Passport),
        playerId   = Passport,
        Valor      = reward.reward,
    })

    TriggerClientEvent("core-jobs:response", source, callbackId, { success = true, bonusId = bonusId })
end)

RegisterNetEvent("core-jobs:tryStartJob", function(callbackId, JobId)
    local source = source
    local Passport = Functions.getUserId(source)

    if not Passport then
        TriggerClientEvent("core-jobs:response", source, callbackId, { ok = false })
        return
    end

    if CharactersWorking[Passport] then
        Functions.notify(source, "Emprego", "Você já está em um serviço.", "amarelo", 3000)
        TriggerClientEvent("core-jobs:response", source, callbackId, { ok = false })
        return
    end

    if RateLimited(source, "startJob", 1000) then
        TriggerClientEvent("core-jobs:response", source, callbackId, { ok = false })
        return
    end

    if type(JobId) ~= "string" or not Config.professions[JobId] then
        FlagViolation(source, Passport, "start_job_invalido", 2)
        TriggerClientEvent("core-jobs:response", source, callbackId, { ok = false })
        return
    end

    if not NearAnyPoint(ServerPlayerCoords(source), Config.jobsAgencies.coords, 30.0) then
        Functions.notify(source, "Emprego", "Você precisa estar na Agência de Empregos para iniciar um serviço.", "vermelho", 5000)
        TriggerClientEvent("core-jobs:response", source, callbackId, { ok = false })
        return
    end

    EnsureJobData(Passport)
    local Data = LoadJobData(Passport)
    local RequiredLevel = math.max(math.floor(tonumber(Config.professions[JobId].requiredLevel) or 1), 1)
    local WorkerLevel = Data and math.max(math.floor(tonumber(Data.currentLvl) or 1), 1) or 1
    if not Data or WorkerLevel < RequiredLevel then
        Functions.notify(source, "Emprego", "Seu nível de trabalhador ainda não permite iniciar este serviço.", "vermelho", 5000)
        TriggerClientEvent("core-jobs:response", source, callbackId, { ok = false })
        return
    end

    CharactersWorking[Passport] = {
        jobId = JobId,
        updateTime = os.time(),
        startedAt = os.time(),
        nextPoint = 1,
        pointCooldowns = {}
    }

    Functions.notify(source, "Emprego", "Serviço iniciado.", "verde", 3000)
    local StartNotification = Config.professions[JobId].startNotification
    if type(StartNotification) == "string" and StartNotification ~= "" then
        Functions.notify(source, "Emprego", StartNotification, "amarelo", 8000)
    end
    TriggerClientEvent("core-jobs:response", source, callbackId, { ok = true, jobData = Config.professions[JobId] })
end)

RegisterNetEvent("core-jobs:endedJob", function()
    local source = source
    local Passport = Functions.getUserId(source)

    if Passport and CharactersWorking[Passport] then
        CleanupWorker(Passport)
        Functions.notify(source, "Emprego", "Serviço encerrado.", "verde", 3000)
    end
end)

RegisterNetEvent("core-jobs:beginDynamicAction", function(JobId, Data)
    local source = source
    local Passport = Functions.getUserId(source)
    local WorkerData = Passport and CharactersWorking[Passport]
    if not Passport or not WorkerData or WorkerData.jobId ~= JobId or (JobId ~= "lixeiro" and JobId ~= "eletricista") then
        return
    end
    if RateLimited(source, "beginDynamicAction", 1000) or type(Data) ~= "table"
        or not ValidCoords(Data.coords) or type(Data.model) ~= "number" then return end

    local Route = R[JobId]
    local Models = JobId == "lixeiro" and Route.dumpstersModels or Route.eBoxesModels
    if not Models or not Models[Data.model] or not NearPoint(ServerPlayerCoords(source), Data.coords, 3.0) then
        FlagViolation(source, Passport, "objeto_dinamico_invalido")
        return
    end
    local ObjectNetwork = tonumber(Data.network) or 0
    if not ValidNetworkObject(source, ObjectNetwork, Data.model, Data.coords) then
        FlagViolation(source, Passport, "entidade_dinamica_invalida")
        return
    end

    if JobId == "eletricista" then
        local Network = tonumber(Data.vehicle)
        local Vehicle = ValidMissionVehicle(source, Network, Route.requiredVehicle, 100.0)
        if not Vehicle or not VehicleOwnedByPassport(Passport, Vehicle)
            or (WorkerData.ServiceNetwork and WorkerData.ServiceNetwork ~= Network) then
            FlagViolation(source, Passport, "veiculo_eletricista_invalido")
            return
        end
        WorkerData.ServiceNetwork = Network
    end

    local coords = PointCoords(Data.coords)
    local key = ("%.1f:%.1f:%.1f"):format(coords.x, coords.y, coords.z)
    local duration = JobId == "eletricista" and 9 or 1
    WorkerData.PendingAction = {
        JobId = JobId,
        Model = Data.model,
        Network = ObjectNetwork,
        Coords = coords,
        Key = key,
        CompleteAt = os.time() + duration,
        ExpiresAt = os.time() + (JobId == "lixeiro" and 120 or 30)
    }
end)

local function CollectAction(source, Data)
    local Passport = Functions.getUserId(source)
    if not Passport then return end

    local Now = GetGameTimer()
    if LastAttempt[source] and (Now - LastAttempt[source]) < AntiCheat.burstMs then
        LastAttempt[source] = Now
        FlagViolation(source, Passport, "collect_rajada")
        return
    end
    LastAttempt[source] = Now

    local WorkerData = CharactersWorking[Passport]
    if not WorkerData or not WorkerData.jobId then
        FlagViolation(source, Passport, "collect_sem_servico")
        return
    end
    if WorkerData.ActionInProgress then return end

    local JobConfig = Config.professions[WorkerData.jobId]
    if not JobConfig then return end

    local Cooldown = CollectCooldowns[WorkerData.jobId] or 2000
    if WorkerData.lastCollect and (Now - WorkerData.lastCollect) < Cooldown then
        return
    end

    local Valid, Reason, CommitAction = ValidateCollectAction(source, Passport, WorkerData, Data)
    if not Valid then
        FlagViolation(source, Passport, "collect_" .. tostring(Reason))
        return
    end

    EnsureJobData(Passport)
    local d = LoadJobData(Passport)
    if not d then return end

    local JobsExpMap = {}
    if d.jobsExp then
        JobsExpMap = json.decode(d.jobsExp) or {}
    end
    local jobId = WorkerData.jobId
    local currentJobXp = JobsExpMap[jobId] or 0
    local currentJobLevel = GetJobLevel(currentJobXp)
    local jobMultiplier = GetJobMultiplier(currentJobLevel)

    local currentWorkerLevel = d.currentLvl or 1
    local workerMultiplier = GetWorkerMultiplier(currentWorkerLevel)

    local multiplier = jobMultiplier + workerMultiplier
    local earnedMoney = 0

    local consumeQueue = {}
    if JobConfig.requiredItems then
        for _, req in ipairs(JobConfig.requiredItems) do
            local owned
            for _, item in ipairs(req.items) do
                if Functions.consultItem(Passport, item, req.consume or 1) then
                    owned = item
                    break
                end
            end
            if not owned then
                Functions.notify(source, "Emprego", req.notify, "vermelho", 5000)
                return
            end
            if req.consume then
                consumeQueue[#consumeQueue+1] = { item = owned, amount = req.consume }
            end
        end
    end

    local pendingItems = {}
    local function plan(req)
        local base = type(req.amount) == "table" and math.random(req.amount[1], req.amount[2]) or req.amount
        local total = base + math.floor(base * multiplier)
        if GetResourceState("core-bonus") == "started" then
            total = exports["core-bonus"]:Apply(Passport, "jobs", total)
        end
        if total > 0 then
            pendingItems[#pendingItems+1] = { item = req.item, amount = total }
        end
    end

    if JobConfig.collectItems then
        for _, req in pairs(JobConfig.collectItems) do plan(req) end
    end

    if JobConfig.extraItems and JobConfig.extraItemsChance and math.random(1, 100) <= JobConfig.extraItemsChance then
        plan(JobConfig.extraItems[math.random(#JobConfig.extraItems)])
    end

    for _, p in ipairs(pendingItems) do
        if not Functions.checkWeight(Passport, p.item, p.amount) then
            Functions.notify(source, "Emprego", "Mochila cheia. Libere espaço para receber a recompensa.", "vermelho", 5000)
            return
        end
    end

    if type(JobConfig.taskCollect) == "function" then
        WorkerData.ActionInProgress = true
        local TaskOk, TaskResult = pcall(JobConfig.taskCollect, source, Passport)
        WorkerData.ActionInProgress = nil

        if not TaskOk or TaskResult ~= true then return end

        local CurrentWorker = CharactersWorking[Passport]
        if CurrentWorker ~= WorkerData or CurrentWorker.jobId ~= jobId then return end

        local StillValid, EndReason, EndCommitAction = ValidateCollectAction(source, Passport, WorkerData, Data)
        if not StillValid then
            FlagViolation(source, Passport, "collect_final_" .. tostring(EndReason))
            return
        end
        CommitAction = EndCommitAction

        for _, p in ipairs(pendingItems) do
            if not Functions.checkWeight(Passport, p.item, p.amount) then
                Functions.notify(source, "Emprego", "Mochila cheia. Libere espaço para receber a recompensa.", "vermelho", 5000)
                return
            end
        end
    end

    for _, c in ipairs(consumeQueue) do
        if not Functions.takeItem(Passport, c.item, c.amount) then
            return
        end
    end

    for _, p in ipairs(pendingItems) do
        if not Functions.giveItem(Passport, p.item, p.amount) then
            return
        end
        if p.item == "dollar" then
            earnedMoney = earnedMoney + p.amount
        end
    end

    WorkerData.lastCollect = GetGameTimer()
    if CommitAction then CommitAction() end

    local xpGain = JobConfig.expGainPerCollect or 0
    if xpGain > 0 then
        d.currentExp = d.currentExp + xpGain

        for lvl, req in pairs(WorkerLevels) do
            if d.currentExp >= req and lvl > d.currentLvl then
                d.currentLvl = lvl
                Functions.notify(source, "Emprego", "Parabéns! Você subiu para o nível geral "..d.currentLvl.."!", "verde", 5000)
            end
        end
    end

    local oldJobLevel = currentJobLevel
    JobsExpMap[jobId] = currentJobXp + (xpGain > 0 and xpGain or 1)
    local newJobLevel = GetJobLevel(JobsExpMap[jobId])
    d.jobsExp = json.encode(JobsExpMap)

    if newJobLevel > oldJobLevel then
        local newMultiplier = GetJobMultiplier(newJobLevel)
        local bonusPercent = math.floor(newMultiplier * 100)
        Functions.notify(source, "Emprego", "Nível "..newJobLevel.." em "..JobConfig.name.."! Bônus de +"..bonusPercent.."% nas recompensas!", "verde", 5000)
    end

    if earnedMoney > 0 then
        d.todayEarnings = (d.todayEarnings or 0) + earnedMoney
        d.totalEarnings = (d.totalEarnings or 0) + earnedMoney
    end

    SaveJobData(Passport, d)
    UpdateMissionProgress(Passport, jobId)
    RankingCache = nil

    if jobId == "entregador-jornais" and earnedMoney > 0 then
        Functions.notify(source, "Emprego", "Jornal entregue! Você recebeu $" .. earnedMoney .. ".", "verde", 4000)
    elseif jobId == "cegonha" and earnedMoney > 0 then
        Functions.notify(source, "Emprego", "Rota da Cegonha concluída! Você recebeu $" .. earnedMoney .. ".", "verde", 6000)
    end

    local rewards = ""
    for _, p in ipairs(pendingItems) do
        rewards = rewards .. (rewards ~= "" and ", " or "") .. p.amount .. "x " .. p.item
    end

    Functions.log("EMPREGO-" .. string.upper(jobId), {
        message    = Functions.getFullName(Passport) .. " #" .. Passport .. " recebeu " .. (rewards ~= "" and rewards or "nada") .. " no emprego " .. (JobConfig.name or jobId),
        playerName = Functions.getFullName(Passport),
        playerId   = Passport,
        Emprego    = JobConfig.name or jobId,
        Recompensas = rewards ~= "" and rewards or "Nenhuma",
        Dinheiro   = earnedMoney > 0 and earnedMoney or nil,
    })
    return true
end

RegisterNetEvent("core-jobs:jobCollectAction", function(Data)
    CollectAction(source, Data)
end)

RegisterNetEvent("core-jobs:requestCollectAction", function(callbackId, Data)
    local source = source
    if type(callbackId) ~= "number" or callbackId % 1 ~= 0 then return end
    TriggerClientEvent("core-jobs:response", source, callbackId, CollectAction(source, Data) == true)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REBOQUE SYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-jobs:reboqueSpawn", function(callbackId, Model, Coords)
    local source = source
    local Passport = Functions.getUserId(source)
    if not Passport then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if RateLimited(source, "reboqueSpawn", 4000) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local WorkerData = CharactersWorking[Passport]
    if not WorkerData or WorkerData.jobId ~= "reboque" then
        FlagViolation(source, Passport, "reboque_sem_servico")
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local RouteCfg = Config.routes["reboque"]
    if not RouteCfg or not ValidCoords(Coords) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if not InList(RouteCfg.models, Model) then
        FlagViolation(source, Passport, "reboque_model_invalido", 2)
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if not NearAnyPoint(Coords, RouteCfg.locations, 3.0) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if not NearAnyPoint(ServerPlayerCoords(source), { Coords }, 60.0) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    for _, Mission in pairs(Impound) do
        if Mission.Passport == Passport then
            TriggerClientEvent("core-jobs:response", source, callbackId, false)
            return
        end
    end

    if (WorkerData.SpawnLockUntil or 0) > os.time() then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local Ped = GetPlayerPed(source)
    local ServiceVehicle = Ped and GetVehiclePedIsIn(Ped, false)
    if not ServiceVehicle or ServiceVehicle == 0 or GetEntityModel(ServiceVehicle) ~= GetHashKey(RouteCfg.requiredVehicle) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end
    if not IsVehicleDriver(source, ServiceVehicle) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end
    if not VehicleOwnedByPassport(Passport, ServiceVehicle) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if GetResourceState("core-vehicles") == "started" then
        local ok, info = pcall(function() return exports["core-vehicles"]:getVehicleInfo(Model) end)
        if not ok or not info then
            TriggerClientEvent("core-jobs:response", source, callbackId, false)
            return
        end
    end

    WorkerData.SpawnLockUntil = os.time() + 12
    local CurrentTimer = os.time() + 10
    local Vehicle = CreateVehicle(GetHashKey(Model), Coords.x, Coords.y, Coords.z, Coords.w, true, false)

    while not DoesEntityExist(Vehicle) or NetworkGetNetworkIdFromEntity(Vehicle) == 0 do
        if os.time() >= CurrentTimer then
            WorkerData.SpawnLockUntil = 0
            if Vehicle and Vehicle ~= 0 and DoesEntityExist(Vehicle) then DeleteEntity(Vehicle) end
            TriggerClientEvent("core-jobs:response", source, callbackId, false)
            return
        end
        Wait(100)
    end

    local Plate = Functions.generatePlate()
    local Network = NetworkGetNetworkIdFromEntity(Vehicle)
    SetEntityRoutingBucket(Vehicle, GetPlayerRoutingBucket(source))

    SetVehicleBodyHealth(Vehicle, 10.0)
    SetVehicleNumberPlateText(Vehicle, Plate)

    Entity(Vehicle).state:set("Fuel", 0, true)
    Entity(Vehicle).state:set("Nitro", 0, true)

    Impound[Plate] = {
        Source = source,
        Passport = Passport,
        Network = Network,
        Model = Model
    }

    WorkerData.SpawnLockUntil = 0
    TriggerClientEvent("core-jobs:response", source, callbackId, { netId = Network, plate = Plate })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CEGONHA SYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-jobs:cegonhaSpawn", function(callbackId, PackerNetwork)
    local source = source
    local Passport = Functions.getUserId(source)
    if not Passport then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if RateLimited(source, "cegonhaSpawn", 4000) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local WorkerData = CharactersWorking[Passport]
    if not WorkerData or WorkerData.jobId ~= "cegonha" then
        FlagViolation(source, Passport, "cegonha_sem_servico")
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local RouteCfg = R["cegonha"]
    local FirstPoint = RouteCfg and RouteCfg.locations and RouteCfg.locations[1]
    local Packer = ValidMissionVehicle(source, PackerNetwork, RouteCfg and RouteCfg.requiredVehicle, 15.0)
    if not FirstPoint or not Packer or not NearPoint(ServerPlayerCoords(source), FirstPoint, 12.0)
        or (WorkerData.nextCegonhaAt or 0) > os.time() or WorkerData.Cegonha
        or (WorkerData.SpawnLockUntil or 0) > os.time() then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end
    if not IsVehicleDriver(source, Packer) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end
    if not VehicleOwnedByPassport(Passport, Packer) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    local Coords = GetEntityCoords(Packer)
    local Heading = GetEntityHeading(Packer)
    local Radians = math.rad(Heading)
    local Spawn = vector3(Coords.x + math.sin(Radians) * 12.0, Coords.y - math.cos(Radians) * 12.0, Coords.z)

    WorkerData.SpawnLockUntil = os.time() + 12
    local CurrentTimer = os.time() + 10
    local Vehicle = CreateVehicle(GetHashKey("tr4"), Spawn.x, Spawn.y, Spawn.z, Heading, true, false)

    while not DoesEntityExist(Vehicle) or NetworkGetNetworkIdFromEntity(Vehicle) == 0 do
        if os.time() >= CurrentTimer then
            WorkerData.SpawnLockUntil = 0
            if Vehicle and Vehicle ~= 0 and DoesEntityExist(Vehicle) then DeleteEntity(Vehicle) end
            TriggerClientEvent("core-jobs:response", source, callbackId, false)
            return
        end
        Wait(100)
    end

    local Network = NetworkGetNetworkIdFromEntity(Vehicle)
    SetEntityRoutingBucket(Vehicle, GetPlayerRoutingBucket(source))
    WorkerData.Cegonha = {
        Network = Network,
        PackerNetwork = PackerNetwork,
        Step = 2,
        Route = GetPlayerRoutingBucket(source)
    }
    WorkerData.SpawnLockUntil = 0
    TriggerClientEvent("core-jobs:response", source, callbackId, { netId = Network })
end)

RegisterNetEvent("core-jobs:cegonhaCheckpoint", function(callbackId, Index, TrailerNetwork)
    local source = source
    local Passport = Functions.getUserId(source)
    local WorkerData = Passport and CharactersWorking[Passport]
    local State = WorkerData and WorkerData.Cegonha
    local RouteCfg = R["cegonha"]
    local CheckpointRadius = Index == 2 and 25.0 or 12.0
    if not Passport or not WorkerData or WorkerData.jobId ~= "cegonha" or not State
        or type(Index) ~= "number" or Index % 1 ~= 0 or Index ~= State.Step
        or GetPlayerRoutingBucket(source) ~= State.Route
        or not NearPoint(ServerPlayerCoords(source), RouteCfg.locations[Index], CheckpointRadius) then
        TriggerClientEvent("core-jobs:response", source, callbackId, false)
        return
    end

    if Index == 2 then
        if TrailerNetwork ~= State.Network or not ValidMissionVehicle(source, State.Network, "tr4", 25.0) then
            TriggerClientEvent("core-jobs:response", source, callbackId, false)
            return
        end
        RemoveNetVehicle(State.Network)
        State.Network = nil
    else
        local Packer = ValidMissionVehicle(source, State.PackerNetwork, RouteCfg.requiredVehicle, 20.0)
        if not Packer or not IsVehicleDriver(source, Packer) then
            TriggerClientEvent("core-jobs:response", source, callbackId, false)
            return
        end
    end

    State.Step = Index + 1
    TriggerClientEvent("core-jobs:response", source, callbackId, true)
end)

AddEventHandler("onResourceStop", function(Resource)
    if Resource ~= GetCurrentResourceName() then return end
    for Passport in pairs(CharactersWorking) do CleanupWorker(Passport) end
end)

---------------------------------------------------------------------------------------------------------------------------------------
-- AUTH / WEBHOOK
---------------------------------------------------------------------------------------------------------------------------------------
