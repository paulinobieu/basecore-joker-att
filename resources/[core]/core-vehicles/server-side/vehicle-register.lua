-- ------------------------------------------------
-- # Vehicle Register
-- ------------------------------------------------
-- CRUD de veiculos em runtime via /gmanager (aba Veiculos).
-- O banco eh a unica fonte de verdade: o `vehlist` global eh reconstruido a
-- partir do banco, mantido em cache e versionado por uma State Bag pequena.

local LEGACY_STATEBAG_KEY = 'coreDynamicVehicles'
local REVISION_STATEBAG_KEY = 'coreDynamicVehiclesRevision'
local CATALOG_PAGE_SIZE = 25
local CATALOG_REQUEST_WINDOW = 5000
local CATALOG_REQUEST_LIMIT = 80

local catalogRevision = 0
local catalogPages = {}
local catalogTotal = 0
local catalogRequests = {}

-- ------------------------------------------------
-- # DB wrappers (oxmysql com placeholders `?` reais)
-- ------------------------------------------------
local function dbQuery(sql, params)
    return exports.oxmysql:query_async(sql, params or {}) or {}
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

local function isDatabaseFlagEnabled(value)
    return value == true or value == 1 or value == '1'
end

-- Converte uma linha do banco em uma entry do `vehlist` (formato esperado
-- por dealership/garages/vstock: precisa de `index` e `hash`).
local function rowToData(row)
    local d = {
        index       = row.spawn,
        hash        = GetHashKey(row.spawn),
        name        = row.name,
        category    = row.category,
        paymentType = row.payment_type or 'primary',
        price       = tonumber(row.price) or 0,
        weights     = {
            trunk  = tonumber(row.weight_trunk)  or 0,
            gloves = tonumber(row.weight_gloves) or 0,
        },
    }
    if row.gemstone ~= nil               then d.gemstone      = tonumber(row.gemstone) end
    if row.class and row.class ~= ''     then d.class         = row.class end
    if row.mode  and row.mode  ~= ''     then d.mode          = row.mode end
    if isDatabaseFlagEnabled(row.out_dealership) then d.outDealership = true end
    return d
end

local function rebuildCatalogPages(list)
    local spawns = {}
    for spawn in pairs(list) do
        spawns[#spawns + 1] = spawn
    end
    table.sort(spawns)

    local pages = {}
    for position, spawn in ipairs(spawns) do
        local page = math.floor((position - 1) / CATALOG_PAGE_SIZE) + 1
        pages[page] = pages[page] or {}
        pages[page][#pages[page] + 1] = list[spawn]
    end

    catalogPages = pages
    catalogTotal = #spawns
    catalogRevision = catalogRevision + 1

    -- Replica somente uma revisao pequena. O catalogo completo (cerca de 800
    -- entradas) ultrapassa o tamanho seguro de uma unica State Bag e fazia o
    -- cliente permanecer com `vehlist = {}`. Os clientes buscam as paginas do
    -- cache abaixo via Tunnel quando a revisao muda.
    GlobalState:set(LEGACY_STATEBAG_KEY, nil, true)
    GlobalState:set(REVISION_STATEBAG_KEY, catalogRevision, true)
end

local function loadFromDB()
    local rows = dbQuery('SELECT * FROM core_vehicles_registered ORDER BY spawn ASC')
    local newList = {}
    for _, row in ipairs(rows or {}) do
        newList[row.spawn] = rowToData(row)
    end
    vehlist = newList
    rebuildCatalogPages(newList)
    return newList
end

local function logAction(action, fields)
    if not logsWebhooks or not logsWebhooks['garageManager'] then return end
    local parts = {}
    for k, v in pairs(fields) do
        parts[#parts + 1] = ('[%s]: %s'):format(k, tostring(v))
    end
    _LOG(logsWebhooks['garageManager'], ('%s\n```prolog\n%s\n```'):format(action, table.concat(parts, '\n')))
end

local function canReadCatalog(src)
    src = tonumber(src)
    if not src or src <= 0 then return false end

    local now = GetGameTimer()
    local bucket = catalogRequests[src]
    if not bucket or now - bucket.startedAt >= CATALOG_REQUEST_WINDOW then
        catalogRequests[src] = { startedAt = now, count = 1 }
        return true
    end

    bucket.count = bucket.count + 1
    return bucket.count <= CATALOG_REQUEST_LIMIT
end

AddEventHandler('playerDropped', function()
    catalogRequests[source] = nil
end)

-- ------------------------------------------------
-- # Init
-- ------------------------------------------------
CreateThread(function()
    dbExecute([[
        CREATE TABLE IF NOT EXISTS core_vehicles_registered (
            id INT AUTO_INCREMENT PRIMARY KEY,
            spawn VARCHAR(60) NOT NULL UNIQUE,
            name VARCHAR(120) NOT NULL,
            category VARCHAR(40) NOT NULL,
            payment_type VARCHAR(40) DEFAULT 'primary',
            weight_trunk INT DEFAULT 0,
            weight_gloves INT DEFAULT 0,
            price INT DEFAULT 0,
            gemstone INT NULL,
            class VARCHAR(80) NULL,
            mode VARCHAR(80) NULL,
            out_dealership TINYINT(1) DEFAULT 0,
            created_by INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    loadFromDB()
end)

-- ------------------------------------------------
-- # SV API (chamadas via tunnel pelo client/NUI)
-- ------------------------------------------------
SV.getVehicleCatalogPage = function(page)
    if not canReadCatalog(source) then
        return { error = 'RATE_LIMITED' }
    end

    page = math.floor(tonumber(page) or 1)
    if page < 1 then page = 1 end

    if catalogRevision == 0 then
        return { loading = true }
    end

    return {
        revision = catalogRevision,
        page = page,
        total = catalogTotal,
        totalPages = #catalogPages,
        vehicles = catalogPages[page] or {},
    }
end

SV.vrGetList = function()
    if not requireAuth(source) then return { error = 1 } end

    local rows = dbQuery('SELECT * FROM core_vehicles_registered ORDER BY spawn ASC')
    local out = {}
    for _, row in ipairs(rows or {}) do
        out[#out + 1] = {
            spawn         = row.spawn,
            name          = row.name,
            category      = row.category,
            paymentType   = row.payment_type or 'primary',
            price         = tonumber(row.price) or 0,
            gemstone      = row.gemstone and tonumber(row.gemstone) or nil,
            class         = row.class,
            mode          = row.mode,
            outDealership = isDatabaseFlagEnabled(row.out_dealership),
            weights       = {
                trunk  = tonumber(row.weight_trunk)  or 0,
                gloves = tonumber(row.weight_gloves) or 0,
            },
        }
    end
    return { success = true, vehicles = out, categories = categories }
end

-- Compatibilidade para consumidores que precisam apenas dos spawns ocultos.
-- A concessionaria principal recebe o mesmo campo no catalogo paginado.
SV.vrGetHiddenModels = function()
    local rows = dbQuery('SELECT spawn FROM core_vehicles_registered WHERE out_dealership = 1')
    local hidden = {}
    for _, row in ipairs(rows or {}) do
        hidden[row.spawn] = true
    end
    return hidden
end

SV.vrSave = function(data)
    local characterId = requireAuth(source)
    if not characterId then return { error = 1 } end

    if type(data) ~= 'table' then return { error = 1, message = 'Dados invalidos.' } end
    local spawn = (data.spawn or ''):gsub('%s+', ''):lower()
    if spawn == ''                                 then return { error = 1, message = 'Informe o spawn do veiculo.' } end
    if not data.name or data.name == ''            then return { error = 1, message = 'Informe o nome.' } end
    if not data.category or data.category == ''    then return { error = 1, message = 'Informe a categoria.' } end
    if not categories[data.category]               then return { error = 1, message = 'Categoria invalida.' } end
    local paymentType = data.paymentType == 'secondary' and 'secondary' or 'primary'

    dbExecute([[
        INSERT INTO core_vehicles_registered
            (spawn, name, category, payment_type, weight_trunk, weight_gloves, price, gemstone, class, mode, out_dealership, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            category = VALUES(category),
            payment_type = VALUES(payment_type),
            weight_trunk = VALUES(weight_trunk),
            weight_gloves = VALUES(weight_gloves),
            price = VALUES(price),
            gemstone = VALUES(gemstone),
            class = VALUES(class),
            mode = VALUES(mode),
            out_dealership = VALUES(out_dealership)
    ]], {
        spawn,
        data.name,
        data.category,
        paymentType,
        tonumber(data.weightTrunk)  or 0,
        tonumber(data.weightGloves) or 0,
        tonumber(data.price) or 0,
        nil,
        (data.class and data.class ~= '' and data.class) or nil,
        (data.mode  and data.mode  ~= '' and data.mode)  or nil,
        data.outDealership and 1 or 0,
        characterId,
    })

    loadFromDB()
    logAction('Veiculo salvo.', { STAFF = characterId, SPAWN = spawn, NAME = data.name })

    return { success = true, spawn = spawn }
end

SV.vrDelete = function(spawn)
    local characterId = requireAuth(source)
    if not characterId then return { error = 1 } end

    spawn = (spawn or ''):gsub('%s+', ''):lower()
    if spawn == '' then return { error = 1 } end

    dbExecute('DELETE FROM core_vehicles_registered WHERE spawn = ?', { spawn })
    loadFromDB()
    logAction('Veiculo removido.', { STAFF = characterId, SPAWN = spawn })

    return { success = true }
end
