-- ------------------------------------------------
-- # Vehicle Register - client (catalogo paginado + revisao via StateBag)
-- ------------------------------------------------
-- O banco eh a unica fonte de verdade. O server replica apenas uma revisao
-- pequena e o client busca o catalogo em paginas via Tunnel. Isto evita que a
-- vehlist inteira exceda o tamanho de uma unica State Bag.

local REVISION_STATEBAG_KEY = 'coreDynamicVehiclesRevision'
local catalogReady = false
local catalogSyncing = false
local appliedRevision = 0

local function fetchCatalog()
    local newList = {}
    local firstPage = SV.getVehicleCatalogPage(1)
    if type(firstPage) ~= 'table' or firstPage.loading or not firstPage.revision then
        return false
    end

    local revision = tonumber(firstPage.revision)
    local totalPages = math.max(tonumber(firstPage.totalPages) or 0, 0)

    local function appendPage(response)
        if type(response) ~= 'table' or tonumber(response.revision) ~= revision or type(response.vehicles) ~= 'table' then
            return false
        end

        for _, data in ipairs(response.vehicles) do
            if type(data) == 'table' and type(data.index) == 'string' and data.index ~= '' then
                data.hash = data.hash or GetHashKey(data.index)
                newList[data.index] = data
            end
        end
        return true
    end

    if not appendPage(firstPage) then return false end

    for page = 2, totalPages do
        if not appendPage(SV.getVehicleCatalogPage(page)) then
            return false
        end
    end

    local currentRevision = tonumber(GlobalState[REVISION_STATEBAG_KEY])
    if currentRevision and currentRevision ~= revision then
        return false
    end

    vehlist = newList
    appliedRevision = revision
    catalogReady = true
    return true
end

local function syncCatalog()
    if catalogSyncing then
        local timeout = GetGameTimer() + 10000
        while catalogSyncing and GetGameTimer() < timeout do
            Wait(50)
        end
        return catalogReady
    end

    catalogSyncing = true
    local success = false
    for _ = 1, 3 do
        if fetchCatalog() then
            success = true
            break
        end
        Wait(250)
    end
    catalogSyncing = false
    return success
end

ensureVehicleCatalog = function()
    if catalogReady then return true end
    return syncCatalog()
end

CreateThread(function()
    Wait(1000)
    while not ensureVehicleCatalog() do
        Wait(1000)
    end
end)

AddStateBagChangeHandler(REVISION_STATEBAG_KEY, 'global', function(_, _, value)
    local revision = tonumber(value) or tonumber(GlobalState[REVISION_STATEBAG_KEY])
    if not revision or revision == appliedRevision then return end

    catalogReady = false
    CreateThread(function()
        syncCatalog()
    end)
end)

-- ------------------------------------------------
-- # NUI Router (chamado a partir do RegisterNUICallback "_GET" em core.lua)
-- ------------------------------------------------
function vrHandleNuiAction(action, d, cb)
    if action == 'vrGetList' then
        cb(SV.vrGetList())
        return true
    end
    if action == 'vrSave' then
        cb(SV.vrSave(d.data))
        return true
    end
    if action == 'vrDelete' then
        cb(SV.vrDelete(d.spawn))
        return true
    end
    return false
end
