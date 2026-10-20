-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddEventHandler = AddEventHandler
local CreateThread = CreateThread
local RegisterCommand = RegisterCommand
local RegisterNetEvent = RegisterNetEvent
local TriggerClientEvent = TriggerClientEvent
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTSELECT
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.requestSelect(src)
    if ServerState.EntryRequested[src] then return end

    ServerState.EntryRequested[src] = true

    OpenSelection(src)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.requestSpawn(src, userId)
    if not Character.Features.SelectSpawn then
        return TriggerClientEvent("core-character:spawnPlayer", src, LastPosition(userId))
    end

    local points = Framework.SpawnPoints(userId) or {}

    TriggerClientEvent("core-character:openSpawn", src, {
        last = LastPosition(userId),
        homes = type(points.homes) == "table" and points.homes or {},
        groups = type(points.groups) == "table" and points.groups or {},
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANONYMOUS
-----------------------------------------------------------------------------------------------------------------------------------------
local Anonymous = {
    requestSelect = true,
    previewCharacter = true,
    selectCharacter = true,
    createCharacter = true,
    buySlot = true,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:HANDLEACTION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:handleAction", function(action, data)

    local src = source
    if not DatabaseReady then return end

    local handler = Handlers[action]
    if not handler then return end

    local userId = Framework.UserId(src)
    if not userId and not Anonymous[action] then return end

    handler(src, userId or nil, data)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BARBERCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Character.BarberCommand, function(src)
    if src <= 0 then return end
    if not Character.Features.Barber then return end

    CreateThread(function()
        local userId = Framework.UserId(src)
        if not userId then return end

        if not IsAdmin(userId, Character.AdminLevels.Barber) then
            return Framework.Notify(src, L("barberNoPermission"))
        end

        OpenBarber(src, userId)
    end)
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MODELCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Character.ModelCommand, function(src, args)
    if src <= 0 then return end

    CreateThread(function()
        local userId = Framework.UserId(src)
        if not userId then return end
        if not IsAdmin(userId, Character.AdminLevels.Model) then return end

        local targetId = tonumber(args[1])
        local model = args[2]

        if not targetId or not IsModel(model) then return end

        local target = Framework.Source(targetId)
        if not target then
            return Framework.Notify(src, L("commandNoTarget"))
        end

        Framework.SkinCharacter(targetId, model)
        TriggerClientEvent("core-character:applySkin", target, model)

        CoreLog("CHARACTER_MODEL", {
            playerName = UserName(userId),
            playerId = userId,
            targetId = targetId,
            model = model,
        })
    end)
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATECOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Character.CreateCommand, function(src, args)
    if src <= 0 then return end

    CreateThread(function()
        local userId = Framework.UserId(src)
        if not userId then return end
        if not IsAdmin(userId, Character.AdminLevels.Create) then return end

        local targetId = tonumber(args[1]) or userId
        local target = Framework.Source(targetId)

        if not target then
            return Framework.Notify(src, L("commandNoTarget"))
        end

        Handlers.createCharacter(target, targetId)
    end)
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESETCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Character.ResetCommand, function(src, args)
    if src <= 0 then return end

    CreateThread(function()
        local userId = Framework.UserId(src)
        if not userId then return end
        if not IsAdmin(userId, Character.AdminLevels.Reset) then return end

        local targetId = tonumber(args[1]) or userId
        local target = Framework.Source(targetId)

        if not target then
            return Framework.Notify(src, L("commandNoTarget"))
        end

        OpenCreator(target, targetId)

        if target ~= src then
            Framework.Notify(src, L("resetSent", { id = targetId }), "success")
        end

        CoreLog("CHARACTER_RESET", {
            playerName = UserName(userId),
            playerId = userId,
            targetId = targetId,
        })
    end)
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped", function()
    local src = source
    local userId = Framework.UserId(src)

    if userId then ForgetUserName(userId) end

    ExitRouting(src)
    ForgetUser(src)
    ServerState.EntryRequested[src] = nil
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:REQUESTROUTING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:requestRouting", function()
    EnterRouting(source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
exports("OpenBarber", function(passport)
    local src = Framework.Source(passport)
    if not src then return false end

    OpenBarber(src, passport)
    return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
exports("OpenCreator", function(passport)
    local src = Framework.Source(passport)
    if not src then return false end

    OpenCreator(src, passport)
    return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENSPAWNSCREEN
-----------------------------------------------------------------------------------------------------------------------------------------
exports("OpenSpawnScreen", function(passport)
    local src = Framework.Source(passport)
    if not src then return false end

    Handlers.requestSpawn(src, passport)
    return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GetAppearance", function(passport)
    if not passport then return nil end

    local stored = DB_LoadCharacter(passport)
    return SanitizeAppearance(stored and stored.chardata)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("SetAppearance", function(passport, appearance)
    local clean = SanitizeAppearance(appearance)
    if not passport or not clean then return false end

    DB_SaveAppearance(passport, clean)

    local src = Framework.Source(passport)
    if src then TriggerClientEvent("core-character:applyAppearance", src, clean) end

    return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSLOTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GetSlots", function(source)
    local license = Framework.License(source)
    if not license then return nil end

    return { used = Framework.CountCharacters(license), total = AccountSlots(license) }
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GetOutfit", function(passport)
    if not passport then return nil end

    local stored = DB_LoadCharacter(passport)

    return {
        clothes = stored and stored.clothes or nil,
        tattoos = stored and stored.tattoos or nil,
    }
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
exports("SetOutfit", function(passport, clothes, tattoos)
    if not passport then return false end
    return DB_SaveOutfit(passport, clothes, tattoos)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEEDSCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
exports("NeedsCreator", function(passport)
    local stored = DB_LoadCharacter(passport)
    return stored == nil or stored.reset == true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETECHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
exports("DeleteCharacter", function(passport)
    if not passport then return false end

    DB_DeleteCharacter(passport)
    return true
end)
