-- ------------------------------------------------
-- # Garage Manager (gmanager)
-- ------------------------------------------------
-- CRUD de garagens dinamicas via /gmanager.
-- Server-side: persiste no banco, registra no `garages` (via registerGarage)
-- e publica em GlobalState['coreAdminGarages'] pra sync nativa com clients.

local STATEBAG_KEY = 'coreAdminGarages'
local VALID_TYPES  = { NORMAL = true, AIR = true, WATER = true, SERVICE = true }

-- dbId (banco) -> gId (id retornado por registerGarage no core)
local GM_MAP = {}

-- ------------------------------------------------
-- # DB wrappers (oxmysql com placeholders `?` reais)
-- ------------------------------------------------
local function dbQuery(sql, params)
    return exports.oxmysql:query_async(sql, params or {}) or {}
end

local function dbInsert(sql, params)
    return exports.oxmysql:insert_async(sql, params or {})
end

local function dbExecute(sql, params)
    return exports.oxmysql:update_async(sql, params or {})
end

-- ------------------------------------------------
-- # Helpers
-- ------------------------------------------------
local function requireAuth(src)
    local characterId = getCharacterId(src)
    if not characterId then return nil end
    if not hasPermission(characterId, commands['garageManager']['permission']) then return nil end
    return characterId
end

local function trim(s)
    return (s or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function safeJsonEncode(value)
    if value == nil then return nil end
    local ok, encoded = pcall(json.encode, value)
    return ok and encoded or nil
end

local function safeJsonDecode(value)
    if not value or value == '' then return nil end
    local ok, decoded = pcall(json.decode, value)
    return ok and decoded or nil
end

local function countEntries(t)
    if type(t) ~= 'table' then return 0 end
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

-- Converte { x=,y=,z=,h= } para o formato array { x,y,z,h }
local function coordsToArray(c)
    if type(c) ~= 'table' then return nil end
    return { c.x or 0.0, c.y or 0.0, c.z or 0.0, c.h or 0.0 }
end

local function spawnsToArray(arr)
    local out = {}
    if type(arr) == 'table' then
        for _, s in ipairs(arr) do
            local conv = coordsToArray(s)
            if conv then out[#out + 1] = conv end
        end
    end
    return out
end

local function logAction(action, fields)
    if not logsWebhooks or not logsWebhooks['garageManager'] then return end
    local parts = {}
    for k, v in pairs(fields) do
        parts[#parts + 1] = ('[%s]: %s'):format(k, tostring(v))
    end
    _LOG(logsWebhooks['garageManager'], ('%s\n```prolog\n%s\n```'):format(action, table.concat(parts, '\n')))
end

-- Validacao usada por gmCreate e gmUpdate. Retorna `nil` se ok, ou a mensagem
-- de erro a ser devolvida ao client.
local function validateGarageInput(data)
    if type(data) ~= 'table'                 then return 'Dados invalidos.' end
    if trim(data.name) == ''                 then return 'Informe o nome da garagem.' end
    if not VALID_TYPES[data.type or 'NORMAL']then return 'Tipo invalido.' end
    if type(data.open) ~= 'table' or not data.open.x or not data.open.y or not data.open.z then
        return 'Coordenada do blip nao informada.'
    end
    if type(data.spawns) ~= 'table' or #data.spawns == 0 then
        return 'Adicione pelo menos um spawn.'
    end
    if data.type == 'SERVICE' and countEntries(data.vehicles) == 0 then
        return 'Garagens de servico precisam de pelo menos 1 veiculo.'
    end
end

-- ------------------------------------------------
-- # Persistencia: ler e converter linhas
-- ------------------------------------------------
local function fetchAll()
    local rows = dbQuery('SELECT * FROM core_vehicles_garages ORDER BY id DESC')
    local arr  = {}
    for _, row in ipairs(rows or {}) do
        arr[#arr + 1] = {
            id         = row.id,
            name       = row.name,
            type       = row.type,
            permission = row.permission,
            payment    = row.payment or 0,
            open       = safeJsonDecode(row.open_coords),
            spawns     = safeJsonDecode(row.spawns) or {},
            blip       = safeJsonDecode(row.blip),
            marker     = safeJsonDecode(row.marker),
            vehicles   = safeJsonDecode(row.vehicles),
            created_at = tostring(row.created_at or ''),
        }
    end
    return arr
end

-- Linha do banco -> garage data no formato esperado pelo core-vehicles
local function buildRuntimeData(row)
    return {
        name       = row.name,
        type       = row.type,
        permission = (row.permission ~= '' and row.permission) or nil,
        payment    = tonumber(row.payment) or 0,
        open       = coordsToArray(row.open),
        spawns     = spawnsToArray(row.spawns),
        blip       = row.blip,
        marker     = row.marker,
        vehicles   = row.vehicles,
    }
end

-- ------------------------------------------------
-- # Registro no core-vehicles + StateBag
-- ------------------------------------------------
-- Usamos insertGarage/removeGarage (versao "completa") pra que o tunnel
-- CL.insertGarage(-1,..) / CL.removeGarage(-1,..) propague pros clients
-- em tempo real (cria/remove blip e marker sem precisar de reload).
local function registerOne(dbId, row)
    local ok, gId = pcall(function() return insertGarage(buildRuntimeData(row)) end)
    if ok and gId then GM_MAP[dbId] = gId end
end

local function unregisterOne(dbId)
    local gId = GM_MAP[dbId]
    if not gId then return end
    pcall(function() removeGarage(gId) end)
    GM_MAP[dbId] = nil
end

local function publishState()
    local payload = {}
    for _, gId in pairs(GM_MAP) do
        if garages and garages[gId] then
            payload[tostring(gId)] = garages[gId]
        end
    end
    GlobalState:set(STATEBAG_KEY, payload, true)
end

local function syncAll()
    for dbId in pairs(GM_MAP) do unregisterOne(dbId) end
    for _, row in ipairs(fetchAll()) do registerOne(row.id, row) end
    publishState()
end

-- ------------------------------------------------
-- # Init
-- ------------------------------------------------
CreateThread(function()
    dbExecute([[
        CREATE TABLE IF NOT EXISTS core_vehicles_garages (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(120) NOT NULL,
            type VARCHAR(20) NOT NULL,
            permission VARCHAR(120) NULL,
            payment INT DEFAULT 0,
            open_coords TEXT NOT NULL,
            spawns TEXT NOT NULL,
            blip TEXT NULL,
            marker TEXT NULL,
            vehicles TEXT NULL,
            created_by INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])

    Wait(3000) -- aguarda core-vehicles registrar `registerGarage`/`unregisterGarage`
    syncAll()
end)

-- ------------------------------------------------
-- # SV API (chamadas via tunnel pelo client/NUI)
-- ------------------------------------------------
SV.gmGetGarages = function()
    if not requireAuth(source) then return { error = 1 } end
    return { success = true, garages = fetchAll() }
end

SV.gmCreate = function(data)
    local characterId = requireAuth(source)
    if not characterId then return { error = 1 } end

    local err = validateGarageInput(data)
    if err then return { error = 1, message = err } end

    local name       = trim(data.name)
    local gtype      = data.type or 'NORMAL'
    local permission = (data.permission ~= '' and data.permission) or nil
    local payment    = tonumber(data.payment) or 0

    local insertId = dbInsert([[
        INSERT INTO core_vehicles_garages
            (name, type, permission, payment, open_coords, spawns, blip, marker, vehicles, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        name, gtype, permission, payment,
        safeJsonEncode(data.open),
        safeJsonEncode(data.spawns),
        safeJsonEncode(data.blip),
        safeJsonEncode(data.marker),
        safeJsonEncode(data.vehicles),
        characterId,
    })

    if not insertId or insertId <= 0 then
        return { error = 1, message = 'Falha ao salvar.' }
    end

    registerOne(insertId, {
        id = insertId, name = name, type = gtype,
        permission = permission, payment = payment,
        open = data.open, spawns = data.spawns,
        blip = data.blip, marker = data.marker, vehicles = data.vehicles,
    })
    publishState()
    logAction('Garagem criada.', { STAFF = characterId, NAME = name, TYPE = gtype, ID = insertId })

    return { success = true, id = insertId }
end

SV.gmUpdate = function(data)
    local characterId = requireAuth(source)
    if not characterId then return { error = 1 } end

    if type(data) ~= 'table' or not data.id then return { error = 1 } end
    local err = validateGarageInput(data)
    if err then return { error = 1, message = err } end

    local id         = tonumber(data.id)
    local name       = trim(data.name)
    local gtype      = data.type or 'NORMAL'
    local permission = (data.permission ~= '' and data.permission) or nil
    local payment    = tonumber(data.payment) or 0

    local affected = dbExecute([[
        UPDATE core_vehicles_garages
        SET name = ?, type = ?, permission = ?, payment = ?,
            open_coords = ?, spawns = ?, blip = ?, marker = ?, vehicles = ?
        WHERE id = ?
    ]], {
        name, gtype, permission, payment,
        safeJsonEncode(data.open),
        safeJsonEncode(data.spawns),
        safeJsonEncode(data.blip),
        safeJsonEncode(data.marker),
        safeJsonEncode(data.vehicles),
        id,
    })

    if not affected or affected <= 0 then
        return { error = 1, message = 'Garagem nao encontrada.' }
    end

    unregisterOne(id)
    registerOne(id, {
        id = id, name = name, type = gtype,
        permission = permission, payment = payment,
        open = data.open, spawns = data.spawns,
        blip = data.blip, marker = data.marker, vehicles = data.vehicles,
    })
    publishState()
    logAction('Garagem editada.', { STAFF = characterId, ID = id, NAME = name })

    return { success = true, id = id }
end

SV.gmDelete = function(garageId)
    local characterId = requireAuth(source)
    if not characterId then return { error = 1 } end

    local id = tonumber(garageId)
    if not id then return { error = 1 } end

    local affected = dbExecute('DELETE FROM core_vehicles_garages WHERE id = ?', { id })
    if not affected or affected <= 0 then
        return { error = 1, message = 'Garagem nao encontrada.' }
    end

    unregisterOne(id)
    publishState()
    logAction('Garagem removida.', { STAFF = characterId, ID = id })

    return { success = true, id = id }
end

SV.gmTeleport = function(garageId)
    if not requireAuth(source) then return { error = 1 } end

    local id = tonumber(garageId)
    if not id then return { error = 1 } end

    local rows = dbQuery('SELECT open_coords FROM core_vehicles_garages WHERE id = ? LIMIT 1', { id })
    if not rows or not rows[1] then return { error = 1, message = 'Garagem nao encontrada.' } end

    local open = safeJsonDecode(rows[1].open_coords)
    if not open or not open.x then return { error = 1, message = 'Coordenada invalida.' } end

    return { success = true, coords = { open.x + 0.0, open.y + 0.0, open.z + 0.0 } }
end
