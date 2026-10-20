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

local function DatabaseExecute(query, parameters)
    parameters = parameters or {}
    local result
    if MySQL and MySQL.update and MySQL.update.await then
        result = MySQL.update.await(query, parameters)
    else
        result = exports.oxmysql:update_async(query, parameters)
    end
    if type(result) == "number" then
        return { affectedRows = result }
    end
    if type(result) == "table" then
        if not result.affectedRows then
            result.affectedRows = tonumber(result.changes) or 0
        end
        return result
    end
    return { affectedRows = 0 }
end

local function DatabaseInsert(query, parameters)
    parameters = parameters or {}
    if MySQL and MySQL.insert and MySQL.insert.await then
        return MySQL.insert.await(query, parameters)
    end
    return exports.oxmysql:insert_async(query, parameters)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CORELOGS
-----------------------------------------------------------------------------------------------------------------------------------------
local function HasAdminLevel(user_id, level)
    return Functions.hasGroup(user_id, Config.Permission, level)
end

local function CoreLog(category, data)
    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog(category, data)
    end
end

local function LogName(user_id)
    return Functions.getUserName(user_id) .. " #" .. user_id
end

local function LogCoords(src)
    local ped = GetPlayerPed(src)
    if not DoesEntityExist(ped) then return "0.0, 0.0, 0.0" end
    local c = GetEntityCoords(ped)
    return ("%.1f, %.1f, %.1f"):format(c.x, c.y, c.z)
end

local function InitDatabase()
    DatabaseExecute([[
        CREATE TABLE IF NOT EXISTS core_admin_notify (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])

    DatabaseExecute([[
        CREATE TABLE IF NOT EXISTS core_admin_chat (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            name VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])

    DatabaseExecute([[
        CREATE TABLE IF NOT EXISTS core_admin_salary (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            `group` VARCHAR(255) NOT NULL,
            amount INT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])

    DatabaseExecute([[
        CREATE TABLE IF NOT EXISTS core_admin_chests (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(120) NOT NULL UNIQUE,
            coords_x DOUBLE NOT NULL,
            coords_y DOUBLE NOT NULL,
            coords_z DOUBLE NOT NULL,
            mode VARCHAR(8) NOT NULL DEFAULT '2',
            permission VARCHAR(120) NULL,
            weight INT NOT NULL DEFAULT 50,
            slots INT NOT NULL DEFAULT 25,
            distance DOUBLE NOT NULL DEFAULT 1.25,
            created_by INT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])

    -- migração defensiva (instalações antigas sem a coluna distance)
    local hasDistance = DatabaseQuery([[
        SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'core_admin_chests' AND COLUMN_NAME = 'distance'
    ]])
    if not hasDistance or #hasDistance == 0 then
        DatabaseExecute("ALTER TABLE core_admin_chests ADD COLUMN distance DOUBLE NOT NULL DEFAULT 1.25")
    end
end

CreateThread(function()
    InitDatabase()
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local VehiclesCache = nil

local function LoadVehiclesCache()
    if VehiclesCache then return VehiclesCache end
    local vehicles = {}
    local vrpVehicles = VehicleList and VehicleList() or {}
    for k, v in pairs(vrpVehicles) do
        vehicles[#vehicles + 1] = {
            id       = #vehicles + 1,
            name     = v.name or "Veículo Desconhecido",
            spawn    = k,
            image    = Config.ImagesProvider.Vehicles .. k .. ".png",
            favorite = false,
            attributes = { engine = 100, body = 100, gas = 100, trunk = 0 },
        }
    end
    VehiclesCache = vehicles
    return VehiclesCache
end

local function GetPlayerGender(source)
    local Ped   = GetPlayerPed(source)
    local Model = GetEntityModel(Ped)
    if Model == GetHashKey("mp_m_freemode_01") then return "Masculino" end
    if Model == GetHashKey("mp_f_freemode_01") then return "Feminino" end
    return "Indefinido"
end

local function GetUserVehicles(user_id)
    local data = exports["core-vehicles"]:getCharacterVehicles(tonumber(user_id))
    local arr  = {}
    if data then
        for plate, v in pairs(data) do
            local health = type(v.health) == "table" and v.health or {}
            arr[#arr + 1] = {
                name   = v.name or Functions.getVehicleDisplayName(v.index),
                spawn  = v.index,
                plate  = plate,
                image  = Config.ImagesProvider.Vehicles .. v.index .. ".png",
                attributes = {
                    engine = health[1] or 1000,
                    body   = health[2] or 1000,
                    gas    = health[3] or 100,
                    trunk  = v.trunk or 0,
                },
            }
        end
    end
    return arr
end

local function GetUserItems(user_id)
    local dataTable = Functions.getDatatable(user_id)
    local arr = {}
    if dataTable and dataTable["Inventory"] then
        for _, v in pairs(dataTable["Inventory"]) do
            if v and v.item and v.amount and v.amount > 0 then
                local imageName = (ItemIndex and ItemIndex(v.item)) or Functions.getItemImageName(v.item)
                arr[#arr + 1] = {
                    name     = Functions.getItemDisplayName(v.item),
                    quantity = v.amount,
                    spawn    = v.item,
                    image    = Config.ImagesProvider.Items .. imageName .. ".png",
                }
            end
        end
    end
    return arr
end

local function GetUserProperties(user_id)
    local data = DatabaseQuery("SELECT * FROM propertys WHERE Passport = ?", { user_id })
    local arr  = {}
    if data then
        for _, v in pairs(data) do
            arr[#arr + 1] = {
                name   = v.Name,
                street = v.Interior or "Endereço não informado",
            }
        end
    end
    return arr
end

local OrganizationsCache     = nil
local OrganizationsCacheTime = 0

local function ClearOrganizationsCache()
    OrganizationsCache     = nil
    OrganizationsCacheTime = 0
end

-- Nivel 1 e o topo da Hierarchy do vRP, entao promover diminui o nivel.
local function GetAllStaff()
    -- StaffGroups e chaveado por nome de cargo (Hierarchy do grupo), nao por grupo
    -- vRP. Os membros ficam sob o grupo real Config.Permission ("Admin"), entao
    -- iteramos esse grupo e mapeamos o nivel para o cargo pela Hierarchy.
    local group     = Config.Permission
    local hierarchy = Functions.getHierarchy(group)
    local top       = 1
    local bottom    = #hierarchy

    local staffMembers = {}
    for rawPassport, rawLevel in pairs(Functions.getGroupMembers(group)) do
        local user_id = tonumber(rawPassport)
        local level   = tonumber(rawLevel)

        if user_id and level then
            local rankName    = hierarchy[level] or group
            local groupConfig = Config.StaffGroups[rankName] or {}
            local identity    = Functions.getUserIdentity(user_id)
            local fullName    = (identity and identity["Name"] and identity["Lastname"])
                and (identity["Name"] .. " " .. identity["Lastname"])
                or ("Passaporte " .. user_id)

            staffMembers[#staffMembers + 1] = {
                id             = user_id,
                name           = fullName,
                group          = group,
                level          = groupConfig.Level or (bottom - level + 1),
                hierarchy      = rankName,
                hierarchyLevel = level,
                promoteTo      = (level > top)    and hierarchy[level - 1] or nil,
                demoteTo       = (level < bottom) and hierarchy[level + 1] or nil,
                online         = Functions.getUserSource(user_id) and true or false,
                color          = groupConfig.Color,
                bgColor        = groupConfig.BgColor,
                canPromote     = groupConfig.CanPromote,
                canDemote      = groupConfig.CanDemote,
                canManage      = groupConfig.CanManage,
            }
        end
    end

    table.sort(staffMembers, function(a, b)
        if a.online ~= b.online then return a.online end
        if a.level ~= b.level then return a.level > b.level end
        if a.hierarchyLevel ~= b.hierarchyLevel then return a.hierarchyLevel < b.hierarchyLevel end
        return a.name < b.name
    end)

    return staffMembers
end

-- Move o membro dentro da Hierarchy do proprio grupo. O fluxo antigo removia a
-- permissao atual e adicionava outra ("Owner"/"Moderador"/"Suporte"), grupos que
-- nao existem em vrp/config/Global.lua -- o vRP.SetPermission falhava e o alvo
-- terminava sem permissao nenhuma.
local function SetStaffRank(targetUserId, group, rankName)
    if group ~= Config.Permission then return false, "Grupo inválido" end

    local hierarchy = Functions.getHierarchy(group)
    local target
    for level, name in ipairs(hierarchy) do
        if name == rankName then
            target = level
            break
        end
    end

    if not target then return false, "Cargo inválido" end

    -- vRP.SetPermission/RemovePermission nao retornam nada em caso de sucesso e
    -- devolvem false quando o grupo nao existe (ou o membro nao esta nele),
    -- entao a comparacao precisa ser explicita.
    if Functions.setPermission(targetUserId, group, target) == false then
        return false, "Não foi possível alterar o cargo"
    end

    return true, "Cargo alterado para " .. rankName
end

local function RemoveStaff(targetUserId, currentGroup)
    if Functions.remPermission(targetUserId, currentGroup) == false then
        return false, "Membro não encontrado nesse grupo"
    end
    return true, "Membro demitido com sucesso"
end

local function GetUsersByPermission(permission)
    local users   = {}
    local players = GetPlayers()
    for _, playerId in pairs(players) do
        local user_id = Functions.getUserId(tonumber(playerId))
        if user_id and Functions.hasPermission(user_id, permission) then
            users[#users + 1] = user_id
        end
    end
    return users
end

local function GiveSalary(user_id, value, group)
    local userSource = Functions.getUserSource(user_id)
    if user_id and userSource then
        Functions.addBank(user_id, value)
        Functions.notify(userSource, Functions.NotifyTypes.Info, "Salário do cargo " .. group .. " creditado: $" .. value, 5000)

        CoreLog("SALARIO", {
            message    = Functions.getUserName(user_id) .. " #" .. user_id .. " recebeu o salário de R$ " .. value .. " do cargo " .. group,
            playerName = Functions.getUserName(user_id),
            playerId   = user_id,
            Grupo      = group,
            Valor      = value,
        })
    end
end

local RentalDuration = {
    [5]  = 432000,
    [10] = 864000,
    [15] = 1296000,
    [20] = 1728000,
    [30] = 2592000,
}

-- Spawn é executado no cliente: SetPedIntoVehicle é client-only e estava
-- causando "Argument at index 0 was null" quando chamado server-side.

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("admin", function(source)
    local user_id = Functions.getUserId(source)
    if not user_id then return end
    if not HasAdminLevel(user_id, 4) then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Você não tem permissão para acessar o painel.", 5000)
        return
    end
    TriggerClientEvent("core-admin:openPanel", source)
end, false)

-----------------------------------------------------------------------------------------------------------------------------------------
-- AVISOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:getNotifications", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    local result = DatabaseQuery("SELECT * FROM core_admin_notify ORDER BY created_at DESC LIMIT 10")
    TriggerClientEvent("core-admin:receiveNotifications", source, result or {})
end)

RegisterNetEvent("core-admin:createNotification", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    if not data or not data.title or not data.message or data.title == "" or data.message == "" then
        TriggerClientEvent("core-admin:notificationResult", source, { success = false, message = "Título e mensagem são obrigatórios!" })
        return
    end

    local insertId = DatabaseInsert("INSERT INTO core_admin_notify (title, message) VALUES (?, ?)", { data.title, data.message })
    if insertId then
        TriggerClientEvent("core-admin:notificationResult", source, { success = true, message = "Aviso criado com sucesso!" })
        TriggerClientEvent("core-admin:newNotification", -1, {
            id         = insertId,
            title      = data.title,
            message    = data.message,
            created_at = os.date("%d/%m/%Y %H:%M"),
        })

        CoreLog("CRIOU-AVISO", {
            message   = LogName(user_id) .. " criou o aviso do painel: " .. data.title,
            adminName = Functions.getUserName(user_id),
            adminId   = user_id,
            Titulo    = data.title,
            Mensagem  = data.message,
            Coords    = LogCoords(source),
        })
    else
        TriggerClientEvent("core-admin:notificationResult", source, { success = false, message = "Erro ao criar aviso!" })
    end
end)

RegisterNetEvent("core-admin:deleteNotification", function(notificationId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    local result = DatabaseExecute("DELETE FROM core_admin_notify WHERE id = ?", { tonumber(notificationId) })
    if result and result.affectedRows and result.affectedRows > 0 then
        TriggerClientEvent("core-admin:notificationResult", source, { success = true, message = "Aviso removido!" })
        TriggerClientEvent("core-admin:notificationDeleted", -1, notificationId)

        CoreLog("REMOVEU-AVISO", {
            message   = LogName(user_id) .. " removeu o aviso #" .. tostring(notificationId) .. " do painel",
            adminName = Functions.getUserName(user_id),
            adminId   = user_id,
            Aviso     = tonumber(notificationId),
            Coords    = LogCoords(source),
        })
    else
        TriggerClientEvent("core-admin:notificationResult", source, { success = false, message = "Aviso não encontrado!" })
    end
end)

RegisterNetEvent("core-admin:editNotification", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    if not data or not data.id or not data.title or not data.message then
        TriggerClientEvent("core-admin:notificationResult", source, { success = false, message = "Dados inválidos!" })
        return
    end

    local result = DatabaseExecute("UPDATE core_admin_notify SET title = ?, message = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", { data.title, data.message, tonumber(data.id) })
    if result and result.affectedRows and result.affectedRows > 0 then
        TriggerClientEvent("core-admin:notificationResult", source, { success = true, message = "Aviso atualizado!" })
        TriggerClientEvent("core-admin:notificationUpdated", -1, {
            id         = data.id,
            title      = data.title,
            message    = data.message,
            updated_at = os.date("%d/%m/%Y %H:%M"),
        })

        CoreLog("EDITOU-AVISO", {
            message   = LogName(user_id) .. " editou o aviso do painel: " .. data.title,
            adminName = Functions.getUserName(user_id),
            adminId   = user_id,
            Aviso     = tonumber(data.id),
            Titulo    = data.title,
            Mensagem  = data.message,
            Coords    = LogCoords(source),
        })
    else
        TriggerClientEvent("core-admin:notificationResult", source, { success = false, message = "Aviso não encontrado!" })
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANÚNCIOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:createAnnouncement", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    if not data or not data.title or not data.message then
        TriggerClientEvent("core-admin:announcementResult", source, { success = false, message = "Dados inválidos!" })
        return
    end

    TriggerClientEvent("Notify", -1, data.title, data.message, "azul", 15000)
    TriggerClientEvent("core-admin:announcementResult", source, { success = true, message = "Anúncio enviado!" })

    CoreLog("ANNOUNCE", {
        message   = LogName(user_id) .. " enviou o anúncio global: " .. data.title,
        adminName = Functions.getUserName(user_id),
        adminId   = user_id,
        Titulo    = data.title,
        Mensagem  = data.message,
        Origem    = "Painel Admin",
        Coords    = LogCoords(source),
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DADOS DO SERVIDOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:getOnlinePlayers", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    local players = GetPlayers()
    local count   = 0
    for _ in pairs(players) do count = count + 1 end

    TriggerClientEvent("core-admin:receiveOnlinePlayers", source, {
        players = count,
        slots   = GetConvarInt("sv_maxclients", 64),
    })
end)

RegisterNetEvent("core-admin:getServerData", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    TriggerClientEvent("core-admin:requestServerData", source)
end)

RegisterNetEvent("core-admin:receiveClientServerData", function(data)
    local source = source
    TriggerClientEvent("core-admin:receiveServerData", source, data)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAT ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:sendChatMessage", function(message)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    if not message or message == "" then return end

    local identity = Functions.getUserIdentity(user_id)
    if not identity or not identity["Name"] then return end
    local name = identity["Name"]

    local insertId = DatabaseInsert("INSERT INTO core_admin_chat (user_id, name, message) VALUES (?, ?, ?)", { user_id, name, message })
    if insertId then
        CoreLog("CHAT-ADMIN", {
            message   = LogName(user_id) .. " enviou no chat admin: " .. message,
            adminName = Functions.getUserName(user_id),
            adminId   = user_id,
            Mensagem  = message,
        })

        local players = GetPlayers()
        for _, playerId in pairs(players) do
            local pid = Functions.getUserId(tonumber(playerId))
            if pid and HasAdminLevel(pid, 4) then
                TriggerClientEvent("core-admin:receiveChatMessage", tonumber(playerId), {
                    id         = insertId,
                    user_id    = user_id,
                    name       = name,
                    message    = message,
                    created_at = os.date("%Y-%m-%d %H:%M:%S"),
                })
            end
        end
    end
end)

RegisterNetEvent("core-admin:getChatMessages", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    TriggerClientEvent("core-admin:setCurrentUserId", source, user_id)

    local result = DatabaseQuery("SELECT * FROM core_admin_chat ORDER BY created_at DESC LIMIT 50")
    local messages = {}
    if result then
        for i = #result, 1, -1 do
            messages[#messages + 1] = result[i]
        end
    end
    TriggerClientEvent("core-admin:receiveChatMessages", source, messages)
end)

RegisterNetEvent("core-admin:getUserInfo", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    local identity = Functions.getUserIdentity(user_id)
    if identity and identity["Name"] then
        TriggerClientEvent("core-admin:receiveUserInfo", source, {
            id         = user_id,
            name       = identity["Name"],
            permission = Config.Permission,
        })
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- JOGADORES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:getPlayers", function(searchTerm)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then
        TriggerClientEvent("core-admin:receivePlayers", source, {})
        return
    end

    local allPlayers = {}
    local addedIds   = {}

    if searchTerm and searchTerm ~= "" then
        local players = GetPlayers()
        for _, playerId in pairs(players) do
            local pid = Functions.getUserId(tonumber(playerId))
            if pid then
                local match = false
                if tonumber(searchTerm) and pid == tonumber(searchTerm) then
                    match = true
                elseif not tonumber(searchTerm) then
                    local identity = Functions.getUserIdentity(pid)
                    if identity and identity["Name"] and identity["Lastname"] then
                        local fullName = identity["Name"] .. " " .. identity["Lastname"]
                        if string.find(string.lower(fullName), string.lower(searchTerm)) then
                            match = true
                        end
                    end
                end

                if match and not addedIds[pid] then
                    local identity = Functions.getUserIdentity(pid)
                    if identity and identity["Name"] and identity["Lastname"] then
                        allPlayers[#allPlayers + 1] = {
                            id              = pid,
                            name            = identity["Name"] .. " " .. identity["Lastname"],
                            profession      = Functions.getUserGroup(pid),
                            passport        = tostring(pid),
                            vip             = "Sem Vip",
                            status          = "Online",
                            professionColor = "#3C8EDC",
                            vipColor        = "#F3C623",
                            online          = true,
                        }
                        addedIds[pid] = true
                    end
                end
            end
        end

        local query, params
        if tonumber(searchTerm) then
            query  = "SELECT id, Name, Lastname, License FROM characters WHERE id = ? ORDER BY id ASC LIMIT 10"
            params = { tonumber(searchTerm) }
        else
            query  = "SELECT id, Name, Lastname, License FROM characters WHERE Name LIKE ? OR Lastname LIKE ? ORDER BY id ASC LIMIT 10"
            params = { "%" .. searchTerm .. "%", "%" .. searchTerm .. "%" }
        end

        local dbResult = DatabaseQuery(query, params)
        if dbResult then
            for _, user in pairs(dbResult) do
                if not addedIds[user.id] then
                    allPlayers[#allPlayers + 1] = {
                        id              = user.id,
                        name            = (user.Name or "Individuo") .. " " .. (user.Lastname or "Indigente"),
                        profession      = Functions.getUserGroup(user.id),
                        passport        = tostring(user.id),
                        vip             = "Sem Vip",
                        status          = "Offline",
                        professionColor = "#3C8EDC",
                        vipColor        = "#F3C623",
                        online          = false,
                    }
                    addedIds[user.id] = true
                end
            end
        end
    else
        local players = GetPlayers()
        for _, playerId in pairs(players) do
            local pid = Functions.getUserId(tonumber(playerId))
            if pid and not addedIds[pid] then
                local identity = Functions.getUserIdentity(pid)
                if identity and identity["Name"] and identity["Lastname"] then
                    allPlayers[#allPlayers + 1] = {
                        id              = pid,
                        name            = identity["Name"] .. " " .. identity["Lastname"],
                        profession      = Functions.getUserGroup(pid),
                        passport        = tostring(pid),
                        vip             = "Sem Vip",
                        status          = "Online",
                        professionColor = "#3C8EDC",
                        vipColor        = "#F3C623",
                        online          = true,
                    }
                    addedIds[pid] = true
                end
            end
        end

        local dbResult = DatabaseQuery("SELECT id, Name, Lastname, License FROM characters ORDER BY id ASC LIMIT 10")
        if dbResult then
            for _, user in pairs(dbResult) do
                if not addedIds[user.id] then
                    allPlayers[#allPlayers + 1] = {
                        id              = user.id,
                        name            = (user.Name or "Individuo") .. " " .. (user.Lastname or "Indigente"),
                        profession      = Functions.getUserGroup(user.id),
                        passport        = tostring(user.id),
                        vip             = "Sem Vip",
                        status          = "Offline",
                        professionColor = "#3C8EDC",
                        vipColor        = "#F3C623",
                        online          = false,
                    }
                    addedIds[user.id] = true
                end
            end
        end
    end

    table.sort(allPlayers, function(a, b) return a.id < b.id end)
    TriggerClientEvent("core-admin:receivePlayers", source, allPlayers)
end)

RegisterNetEvent("core-admin:getPlayerDetails", function(targetUserId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then
        TriggerClientEvent("core-admin:receivePlayerDetails", source, {})
        return
    end

    targetUserId = tonumber(targetUserId)
    if not targetUserId then
        TriggerClientEvent("core-admin:receivePlayerDetails", source, {})
        return
    end

    local identity    = Functions.getUserIdentity(targetUserId)
    local dataTable   = Functions.getDatatable(targetUserId)
    local targetSource = Functions.getUserSource(targetUserId)
    local isOnline    = targetSource ~= nil

    local playerData = {
        id          = targetUserId,
        name        = ((identity and identity["Name"]) or "Individuo") .. " " .. ((identity and identity["Lastname"]) or "Indigente"),
        age         = identity and identity["age"] or 25,
        gender      = isOnline and GetPlayerGender(targetSource) or "Indefinido",
        phone       = identity and identity["Phone"] or "N/A",
        nationality = identity and identity["nationality"] or "Brasil",
        bank        = Functions.getBank(targetUserId),
        wallet      = dataTable and dataTable["dollars"] or 0,
        arrested    = (dataTable and dataTable["prison"]) and "Preso" or "Livre",
        online      = isOnline,
        stats       = { health = 0, armour = 0, thirst = 100, hunger = 100 },
        vehicles    = GetUserVehicles(targetUserId),
        items       = GetUserItems(targetUserId),
        properties  = GetUserProperties(targetUserId),
    }

    if isOnline then
        local userPed = GetPlayerPed(targetSource)
        local maxHealth = GetPedMaxHealth(userPed)
        local curHealth = GetEntityHealth(userPed)
        playerData.stats = {
            health = math.floor(math.max(0, (curHealth - 100) / math.max(1, maxHealth - 100) * 100)),
            armour = math.floor(GetPedArmour(userPed)),
            thirst = dataTable and dataTable["thirst"] or 100,
            hunger = dataTable and dataTable["hunger"] or 100,
        }
    end

    TriggerClientEvent("core-admin:receivePlayerDetails", source, playerData)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- AÇÕES EM JOGADORES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:teleportToPlayer", function(targetUserId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, nil) then return end

    local targetSource = Functions.getUserSource(tonumber(targetUserId))
    if not targetSource then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado ou offline!", 5000)
        return
    end

    local adminCoords  = LogCoords(source)
    local targetPed    = GetPlayerPed(targetSource)
    local targetCoords = GetEntityCoords(targetPed)
    local adminPed     = GetPlayerPed(source)
    SetEntityCoords(adminPed, targetCoords.x, targetCoords.y, targetCoords.z)
    Functions.notify(source, Functions.NotifyTypes.Success, "Teleportado para o jogador ID: " .. targetUserId, 5000)

    CoreLog("TPTO", {
        message      = LogName(user_id) .. " teleportou até " .. LogName(tonumber(targetUserId)),
        adminName    = Functions.getUserName(user_id),
        adminId      = user_id,
        playerName   = Functions.getUserName(tonumber(targetUserId)),
        playerId     = tonumber(targetUserId),
        Origem       = "Painel Admin",
        CoordsOrigem = adminCoords,
        CoordsDestino = LogCoords(targetSource),
    })
end)

RegisterNetEvent("core-admin:pullPlayer", function(targetUserId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, nil) then return end

    local targetSource = Functions.getUserSource(tonumber(targetUserId))
    if not targetSource then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado ou offline!", 5000)
        return
    end

    local targetOrigin = LogCoords(targetSource)
    local adminPed    = GetPlayerPed(source)
    local adminCoords = GetEntityCoords(adminPed)
    local targetPed   = GetPlayerPed(targetSource)
    SetEntityCoords(targetPed, adminCoords.x, adminCoords.y, adminCoords.z)
    Functions.notify(source, Functions.NotifyTypes.Success, "Jogador ID: " .. targetUserId .. " puxado até você!", 5000)
    Functions.notify(targetSource, Functions.NotifyTypes.Info, "Você foi puxado por um administrador.", 5000)

    CoreLog("TPTOME", {
        message      = LogName(user_id) .. " puxou " .. LogName(tonumber(targetUserId)) .. " até si",
        adminName    = Functions.getUserName(user_id),
        adminId      = user_id,
        playerName   = Functions.getUserName(tonumber(targetUserId)),
        playerId     = tonumber(targetUserId),
        Origem       = "Painel Admin",
        CoordsOrigem = targetOrigin,
        CoordsDestino = LogCoords(source),
    })
end)

RegisterNetEvent("core-admin:revivePlayer", function(id)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, nil) then return end

    local targetId     = tonumber(id)
    local targetSource = Functions.getUserSource(targetId)
    if not targetSource then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado ou offline!", 5000)
        return
    end

    TriggerClientEvent("core-admin:setEntityHealth", targetSource, 200)
    Functions.notify(source, Functions.NotifyTypes.Success, "Jogador ID " .. targetId .. " revivido!", 5000)

    CoreLog("REVIVE", {
        message    = LogName(user_id) .. " reviveu " .. LogName(targetId),
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(targetId),
        playerId   = targetId,
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
        CoordsAlvo = LogCoords(targetSource),
    })
end)

RegisterNetEvent("core-admin:killPlayer", function(targetUserId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    local targetId     = tonumber(targetUserId)
    local targetSource = Functions.getUserSource(targetId)
    if not targetSource then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado ou offline!", 5000)
        return
    end

    TriggerClientEvent("core-admin:setEntityHealth", targetSource, 101)
    Functions.notify(source, Functions.NotifyTypes.Success, "Jogador ID: " .. targetId .. " eliminado!", 5000)

    CoreLog("KILL", {
        message    = LogName(user_id) .. " matou " .. LogName(targetId) .. " via painel",
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(targetId),
        playerId   = targetId,
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
        CoordsAlvo = LogCoords(targetSource),
    })
end)

RegisterNetEvent("core-admin:godPlayer", function(targetUserId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, nil) then return end

    local targetId     = tonumber(targetUserId)
    local targetSource = Functions.getUserSource(targetId)
    if not targetSource then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado ou offline!", 5000)
        return
    end

    TriggerClientEvent("core-admin:setEntityHealth", targetSource, 200)
    Functions.upgradeThirst(targetId, 100)
    Functions.upgradeHunger(targetId, 100)
    Functions.downgradeStress(targetId, 100)
    Functions.notify(source, Functions.NotifyTypes.Success, "God mode aplicado no jogador ID: " .. targetId, 5000)

    CoreLog("GOD", {
        message    = LogName(user_id) .. " aplicou god em " .. LogName(targetId),
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(targetId),
        playerId   = targetId,
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
        CoordsAlvo = LogCoords(targetSource),
    })
end)

RegisterNetEvent("core-admin:armorPlayer", function(targetUserId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, nil) then return end

    local targetId     = tonumber(targetUserId)
    local targetSource = Functions.getUserSource(targetId)
    if not targetSource then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado ou offline!", 5000)
        return
    end

    TriggerClientEvent("core-admin:setEntityArmour", targetSource, 100)
    Functions.notify(source, Functions.NotifyTypes.Success, "Colete dado ao jogador ID: " .. targetId, 5000)

    CoreLog("COLETE", {
        message    = LogName(user_id) .. " aplicou colete em " .. LogName(targetId),
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(targetId),
        playerId   = targetId,
        Quantidade = 100,
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
        CoordsAlvo = LogCoords(targetSource),
    })
end)

RegisterNetEvent("core-admin:kickPlayer", function(id)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 5) then return end

    local targetId = tonumber(id)
    if not targetId or targetId <= 0 then
        Functions.notify(source, Functions.NotifyTypes.Denied, "ID inválido!", 5000)
        return
    end
    Functions.kick(targetId, "Você foi expulso do servidor por um administrador.")
    Functions.notify(source, Functions.NotifyTypes.Success, "Jogador ID " .. targetId .. " foi expulso!", 5000)

    CoreLog("KICK", {
        message    = LogName(user_id) .. " expulsou " .. LogName(targetId) .. " do servidor",
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(targetId),
        playerId   = targetId,
        Motivo     = "Expulso pelo painel admin",
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
    })
end)

RegisterNetEvent("core-admin:addBank", function(targetId, amount)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 1) then return end

    targetId = tonumber(targetId)
    amount   = tonumber(amount)
    if not targetId or targetId <= 0 then
        Functions.notify(source, Functions.NotifyTypes.Denied, "ID inválido!", 5000)
        return
    end
    if not amount or amount <= 0 then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Quantia inválida!", 5000)
        return
    end

    Functions.addBank(targetId, amount)
    Functions.notify(source, Functions.NotifyTypes.Success, "R$ " .. amount .. " adicionado ao banco do jogador ID " .. targetId .. "!", 5000)

    CoreLog("MONEY", {
        message    = LogName(user_id) .. " adicionou R$ " .. amount .. " no banco de " .. LogName(targetId),
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(targetId),
        playerId   = targetId,
        Valor      = amount,
        SaldoNovo  = Functions.getBank(targetId),
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- WHITELIST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:removeWhitelist", function(id)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    local targetId = tonumber(id)
    if not targetId or targetId <= 0 then
        Functions.notify(source, Functions.NotifyTypes.Denied, "ID inválido!", 5000)
        return
    end

    local identity = Functions.getUserIdentity(targetId)
    if identity and identity["steam"] then
        DatabaseExecute("UPDATE accounts SET whitelist = 0 WHERE steam = ?", { identity["steam"] })
        Functions.notify(source, Functions.NotifyTypes.Success, "Whitelist removida do jogador ID: " .. targetId, 5000)

        CoreLog("REMOVEU-WHITELIST", {
            message    = LogName(user_id) .. " removeu a whitelist de " .. LogName(targetId),
            adminName  = Functions.getUserName(user_id),
            adminId    = user_id,
            playerName = Functions.getUserName(targetId),
            playerId   = targetId,
            Coords     = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Jogador não encontrado!", 5000)
    end
end)

RegisterNetEvent("core-admin:addWhitelist", function(id)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    local accountId = tonumber(id)
    if not accountId or accountId <= 0 then
        Functions.notify(source, Functions.NotifyTypes.Denied, "ID inválido!", 5000)
        return
    end

    DatabaseExecute("UPDATE accounts SET whitelist = 1 WHERE id = ?", { accountId })
    Functions.notify(source, Functions.NotifyTypes.Success, "Whitelist adicionada ao account ID: " .. accountId, 5000)

    CoreLog("ADICIONOU-WHITELIST", {
        message   = LogName(user_id) .. " adicionou whitelist na conta " .. accountId,
        adminName = Functions.getUserName(user_id),
        adminId   = user_id,
        Conta     = accountId,
        Coords    = LogCoords(source),
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TELEPORT CDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:teleportCDS", function(cds)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, nil) then return end

    local coords = {}
    for coord in string.gmatch(cds or "0,0,0", "[^,]+") do
        coords[#coords + 1] = tonumber(coord)
    end

    if #coords >= 3 then
        local originCoords = LogCoords(source)
        local userPed = GetPlayerPed(source)
        SetEntityCoords(userPed, coords[1], coords[2], coords[3])
        Functions.notify(source, Functions.NotifyTypes.Success, "Teleportado para: " .. cds, 5000)

        CoreLog("TPCDS", {
            message       = LogName(user_id) .. " teleportou para as coordenadas " .. cds,
            adminName     = Functions.getUserName(user_id),
            adminId       = user_id,
            Origem        = "Painel Admin",
            CoordsOrigem  = originCoords,
            CoordsDestino = cds,
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Formato inválido! Use: x,y,z", 5000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VEÍCULOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:fixVehicle", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 5) then return end

    TriggerClientEvent("core-admin:repairVehicle", source)
    Functions.notify(source, Functions.NotifyTypes.Success, "Veículo reparado!", 5000)

    CoreLog("FIX", {
        message   = LogName(user_id) .. " reparou o próprio veículo via painel",
        adminName = Functions.getUserName(user_id),
        adminId   = user_id,
        Origem    = "Painel Admin",
        Coords    = LogCoords(source),
    })
end)

RegisterNetEvent("core-admin:tuningVehicle", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 1) then return end

    TriggerClientEvent("core-admin:tuneVehicle", source)
    Functions.notify(source, Functions.NotifyTypes.Success, "Veículo tunado!", 5000)

    CoreLog("TUNING", {
        message   = LogName(user_id) .. " tunou o próprio veículo via painel",
        adminName = Functions.getUserName(user_id),
        adminId   = user_id,
        Origem    = "Painel Admin",
        Coords    = LogCoords(source),
    })
end)

RegisterNetEvent("core-admin:destroyAllVehicles", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 1) then return end

    TriggerClientEvent("core-admin:destroyVehicles", -1)
    Functions.notify(source, Functions.NotifyTypes.Success, "Todos os veículos foram destruídos!", 5000)

    CoreLog("DESTRUIU-VEICULOS", {
        message   = LogName(user_id) .. " destruiu todos os veículos do servidor",
        adminName = Functions.getUserName(user_id),
        adminId   = user_id,
        Origem    = "Painel Admin",
        Coords    = LogCoords(source),
    })
end)

RegisterNetEvent("core-admin:getServerVehicles", function(page, limit, searchTerm, category)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    page       = page or 1
    limit      = limit or 1200
    searchTerm = searchTerm or ""
    category   = category or "all"

    local allVehicles      = LoadVehiclesCache()
    local filteredVehicles = {}

    if searchTerm ~= "" then
        local st = string.lower(searchTerm)
        for _, vehicle in ipairs(allVehicles) do
            if string.find(string.lower(vehicle.name), st) or string.find(string.lower(vehicle.spawn), st) then
                filteredVehicles[#filteredVehicles + 1] = vehicle
            end
        end
    else
        filteredVehicles = allVehicles
    end

    local totalVehicles = #filteredVehicles
    local startIndex    = (page - 1) * limit + 1
    local endIndex      = math.min(startIndex + limit - 1, totalVehicles)

    local paginatedVehicles = {}
    for i = startIndex, endIndex do
        if filteredVehicles[i] then
            paginatedVehicles[#paginatedVehicles + 1] = filteredVehicles[i]
        end
    end

    TriggerClientEvent("core-admin:receiveServerVehicles", source, {
        vehicles = paginatedVehicles,
        total    = totalVehicles,
        page     = page,
        limit    = limit,
        hasMore  = endIndex < totalVehicles,
    })
end)

RegisterNetEvent("core-admin:spawnVehicle", function(vehicleSpawn)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end
    if not vehicleSpawn or vehicleSpawn == "" then return end
    if GetResourceState("PL_PROTECT") == "started" then exports['PL_PROTECT']:setSpawnClient(source,vehicleSpawn) end
    TriggerClientEvent("core-admin:executeSpawn", source, vehicleSpawn)
end)

RegisterNetEvent("core-admin:vehicleSpawned", function(vehicleSpawn, plate)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end
    if not plate or plate == "" then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Falha ao spawnar o veículo.", 5000)
        return
    end

    TriggerEvent("engine:tryFuel", plate, 100)
    TriggerEvent("plateEveryone", plate)
    Functions.notify(source, Functions.NotifyTypes.Success, "Veículo " .. Functions.getVehicleDisplayName(vehicleSpawn) .. " spawnado!", 5000)

    CoreLog("SPAWNCAR", {
        message   = LogName(user_id) .. " spawnou o veículo " .. Functions.getVehicleDisplayName(vehicleSpawn),
        adminName = Functions.getUserName(user_id),
        adminId   = user_id,
        Veiculo   = Functions.getVehicleDisplayName(vehicleSpawn) .. " (" .. vehicleSpawn .. ")",
        Placa     = plate,
        Origem    = "Painel Admin",
        Coords    = LogCoords(source),
    })
end)

RegisterNetEvent("core-admin:addVehicleToUser", function(vehicleSpawn, targetUserId, duration)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 1) then return end

    local permanent = duration == "permanente"

    local Result = exports["core-vehicles"]:giveVehicle(tonumber(targetUserId), vehicleSpawn)
    if not Result or not Result.ok then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Não foi possível adicionar o veículo.", 5000)
        return
    end

    if not permanent then
        local rentalSeconds = RentalDuration[duration] or 864000
        DatabaseExecute("UPDATE core_characters_vehicles SET expire_time = ?, expired = 0 WHERE plate = ?", { os.time() + rentalSeconds, Result.plate })
    end

    local label = permanent and "permanentemente" or ("por " .. duration .. " dias")
    Functions.notify(source, Functions.NotifyTypes.Success, "Veículo " .. Functions.getVehicleDisplayName(vehicleSpawn) .. " adicionado " .. label .. "!", 5000)

    CoreLog("ADDCAR", {
        message    = LogName(user_id) .. " adicionou o veículo " .. Functions.getVehicleDisplayName(vehicleSpawn) .. " (" .. label .. ") para " .. LogName(tonumber(targetUserId)),
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(tonumber(targetUserId)),
        playerId   = tonumber(targetUserId),
        Veiculo    = Functions.getVehicleDisplayName(vehicleSpawn) .. " (" .. vehicleSpawn .. ")",
        Placa      = Result.plate,
        Tipo       = permanent and "Permanente" or (duration .. " dias"),
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITENS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:getServerItems", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    local items    = ItemList and ItemList() or {}
    local arr      = {}
    local counter  = 0
    for spawn, data in pairs(items) do
        counter = counter + 1
        local imageName = data.Index or Functions.getItemImageName(spawn)
        arr[#arr + 1] = {
            id     = counter,
            name   = data.Name or spawn,
            spawn  = spawn,
            image  = Config.ImagesProvider.Items .. imageName .. ".png",
            weight = data.Weight or 0,
            type   = data.Type or "Comum",
        }
    end

    TriggerClientEvent("core-admin:receiveServerItems", source, arr)
end)

RegisterNetEvent("core-admin:takeItem", function(item, quantity)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 3) then return end

    quantity = tonumber(quantity) or 1
    if quantity < 1 then quantity = 1 end
    if quantity > 999 then quantity = 999 end

    Functions.giveInventoryItem(user_id, item, quantity)
    Functions.notify(source, Functions.NotifyTypes.Success, "Você recebeu " .. quantity .. "x " .. Functions.getItemDisplayName(item), 5000)

    CoreLog("ITEM", {
        message    = LogName(user_id) .. " gerou " .. quantity .. "x " .. Functions.getItemDisplayName(item) .. " para si mesmo via painel",
        adminName  = Functions.getUserName(user_id),
        adminId    = user_id,
        playerName = Functions.getUserName(user_id),
        playerId   = user_id,
        Item       = Functions.getItemDisplayName(item) .. " (" .. item .. ")",
        Quantidade = quantity,
        Origem     = "Painel Admin",
        Coords     = LogCoords(source),
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ORGANIZAÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:getServerOrganizations", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    if Config.Cache.Organizations.Enabled and OrganizationsCache and (GetGameTimer() - OrganizationsCacheTime) < Config.Cache.Organizations.Duration then
        TriggerClientEvent("core-admin:receiveServerOrganizations", source, OrganizationsCache)
        return
    end

    local groups        = Functions.getGroups()
    local organizations = {}
    local counter       = 0

    for groupName, _ in pairs(groups) do
        counter = counter + 1
        local members      = GetUsersByPermission(groupName)
        local totalMembers = #members
        local leader       = nil

        if totalMembers > 0 then
            local firstId  = members[1]
            local identity = Functions.getUserIdentity(firstId)
            if identity and identity["Name"] then
                leader = {
                    id     = firstId,
                    name   = identity["Name"] .. " " .. (identity["Lastname"] or ""),
                    online = Functions.getUserSource(firstId) ~= nil,
                }
            end
        end

        organizations[#organizations + 1] = {
            id            = counter,
            name          = groupName,
            leader        = leader,
            members       = {},
            totalMembers  = totalMembers,
            onlineMembers = 0,
        }
    end

    OrganizationsCache     = organizations
    OrganizationsCacheTime = GetGameTimer()
    TriggerClientEvent("core-admin:receiveServerOrganizations", source, organizations)
end)

RegisterNetEvent("core-admin:getOrganizationMembers", function(groupName)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    local members    = GetUsersByPermission(groupName)
    local memberList = {}
    for _, memberId in pairs(members) do
        local identity = Functions.getUserIdentity(memberId)
        if identity and identity["Name"] then
            memberList[#memberList + 1] = {
                id     = memberId,
                name   = identity["Name"] .. " " .. (identity["Lastname"] or ""),
                online = Functions.getUserSource(memberId) ~= nil,
                role   = groupName,
            }
        end
    end

    TriggerClientEvent("core-admin:receiveOrganizationMembers", source, { groupName = groupName, members = memberList })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- STAFF
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:getServerStaff", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    TriggerClientEvent("core-admin:receiveServerStaff", source, GetAllStaff())
end)

RegisterNetEvent("core-admin:promoteStaff", function(targetUserId, currentGroup, newGroup)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 1) then return end

    local success, message = SetStaffRank(targetUserId, currentGroup, newGroup)
    if success then
        ClearOrganizationsCache()
        Functions.notify(source, Functions.NotifyTypes.Success, message, 5000)
        local targetSource = Functions.getUserSource(targetUserId)
        if targetSource then
            Functions.notify(targetSource, Functions.NotifyTypes.Info, "Seu cargo no staff agora é " .. newGroup, 5000)
        end

        CoreLog("PROMOVEU-STAFF", {
            message     = LogName(user_id) .. " alterou o cargo de " .. LogName(tonumber(targetUserId)) .. " em " .. tostring(currentGroup) .. " para " .. tostring(newGroup),
            adminName   = Functions.getUserName(user_id),
            adminId     = user_id,
            playerName  = Functions.getUserName(tonumber(targetUserId)),
            playerId    = tonumber(targetUserId),
            CargoAntigo = currentGroup,
            CargoNovo   = newGroup,
            Coords      = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, message, 5000)
    end
end)

RegisterNetEvent("core-admin:removeStaff", function(targetUserId, currentGroup)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 1) then return end

    local success, message = RemoveStaff(targetUserId, currentGroup)
    if success then
        ClearOrganizationsCache()
        Functions.notify(source, Functions.NotifyTypes.Success, message, 5000)
        local targetSource = Functions.getUserSource(targetUserId)
        if targetSource then
            Functions.notify(targetSource, Functions.NotifyTypes.Warning, "Você foi demitido do staff.", 5000)
        end

        CoreLog("REMOVEU-STAFF", {
            message    = LogName(user_id) .. " removeu " .. LogName(tonumber(targetUserId)) .. " do staff (" .. tostring(currentGroup) .. ")",
            adminName  = Functions.getUserName(user_id),
            adminId    = user_id,
            playerName = Functions.getUserName(tonumber(targetUserId)),
            playerId   = tonumber(targetUserId),
            Cargo      = currentGroup,
            Coords     = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, message, 5000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPRIEDADES
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetPropertyCoords(name)
    -- exports["propertys"]:Coords(name) retorna a vec3 da porta da propriedade
    local ok, coords = pcall(function() return exports["propertys"]:Coords(name) end)
    if ok and coords then
        return { x = coords.x, y = coords.y, z = coords.z }
    end
    return nil
end

local function GetInteriorFeatures(interior)
    -- Cada resource tem sua propria VM Lua. A tabela Internal vive em propertys
    -- e nao eh visivel aqui; usamos export pra consultar.
    if not interior then
        return { hasVault = false, hasFridge = false, hasClothes = false }
    end
    local ok, features = pcall(function() return exports["propertys"]:InteriorFeatures(interior) end)
    if ok and type(features) == "table" then
        return features
    end
    return { hasVault = false, hasFridge = false, hasClothes = false }
end

local function GetAvailableInteriors()
    local ok, list = pcall(function() return exports["propertys"]:Interiors() end)
    if not ok or type(list) ~= "table" then return {} end
    table.sort(list, function(a, b) return (a.name or "") < (b.name or "") end)
    return list
end

local function FetchAllProperties()
    local rows = DatabaseQuery([[
        SELECT p.Name, p.Interior, p.Passport, p.Vault, p.Fridge, p.Tax, p.Garage,
               c.Name AS OwnerName, c.Lastname AS OwnerLastname
        FROM propertys p
        LEFT JOIN characters c ON c.id = p.Passport
        ORDER BY p.Passport ASC
    ]])
    local arr = {}
    if rows then
        for _, v in pairs(rows) do
            local interior = v.Interior or "Indefinido"
            local features = GetInteriorFeatures(interior)
            arr[#arr + 1] = {
                name      = v.Name,
                interior  = interior,
                passport  = v.Passport,
                ownerName = (v.OwnerName and v.OwnerLastname)
                            and (v.OwnerName .. " " .. v.OwnerLastname) or "Sem dono",
                vault     = tonumber(v.Vault) or 0,
                fridge    = tonumber(v.Fridge) or 0,
                tax       = tonumber(v.Tax) or 0,
                coords    = GetPropertyCoords(v.Name),
                hasGarage = v.Garage ~= nil and v.Garage ~= "",
                hasVault  = features.hasVault,
                hasFridge = features.hasFridge,
                garage    = v.Garage,
            }
        end
    end
    return arr
end

RegisterNetEvent("core-admin:getProperties", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    TriggerClientEvent("core-admin:receiveProperties", source, { properties = FetchAllProperties(), interiors = GetAvailableInteriors() })
end)

RegisterNetEvent("core-admin:teleportToProperty", function(propertyName)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    if not propertyName or propertyName == "" then return end

    local coords = GetPropertyCoords(propertyName)
    if not coords then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Coordenadas da propriedade não encontradas.", 5000)
        return
    end

    local originCoords = LogCoords(source)
    local ped = GetPlayerPed(source)
    SetEntityCoords(ped, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0)
    Functions.notify(source, Functions.NotifyTypes.Success, "Teleportado para " .. propertyName .. "!", 5000)

    CoreLog("TP-PROPRIEDADE", {
        message      = LogName(user_id) .. " teleportou para a propriedade " .. propertyName,
        adminName    = Functions.getUserName(user_id),
        adminId      = user_id,
        Propriedade  = propertyName,
        CoordsOrigem = originCoords,
        CoordsDestino = ("%.1f, %.1f, %.1f"):format(coords.x, coords.y, coords.z),
    })
end)

RegisterNetEvent("core-admin:updateProperty", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    if type(data) ~= "table" or not data.name then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Dados inválidos!", 5000)
        return
    end

    local name = data.name
    local existing = DatabaseQuery("SELECT Name FROM propertys WHERE Name = ? LIMIT 1", { name })
    if not existing or not existing[1] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Propriedade não encontrada.", 5000)
        return
    end

    local updates  = {}
    local params   = {}
    if data.passport ~= nil then
        local newPassport = tonumber(data.passport)
        if newPassport then
            -- valida que o passaporte existe
            local owner = DatabaseQuery("SELECT id FROM characters WHERE id = ? LIMIT 1", { newPassport })
            if not owner or not owner[1] then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Passaporte " .. newPassport .. " não existe.", 5000)
                return
            end
            updates[#updates + 1] = "Passport = ?"
            params[#params + 1]   = newPassport
        end
    end
    if data.interior ~= nil and data.interior ~= "" then
        -- Valida que o interior eh um dos compraveis (filtra Hotel etc)
        local valid = false
        for _, it in ipairs(GetAvailableInteriors()) do
            if it.name == data.interior then valid = true; break end
        end
        if not valid then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Interior '" .. data.interior .. "' nao eh valido para propriedades comuns.", 5000)
            return
        end
        updates[#updates + 1] = "Interior = ?"
        params[#params + 1]   = data.interior
    end
    if data.vault ~= nil then
        local newVault = tonumber(data.vault)
        if newVault and newVault >= 0 then
            updates[#updates + 1] = "Vault = ?"
            params[#params + 1]   = newVault
        end
    end
    if data.fridge ~= nil then
        local newFridge = tonumber(data.fridge)
        if newFridge and newFridge >= 0 then
            updates[#updates + 1] = "Fridge = ?"
            params[#params + 1]   = newFridge
        end
    end
    if data.tax ~= nil then
        local newTax = tonumber(data.tax)
        if newTax then
            updates[#updates + 1] = "Tax = ?"
            params[#params + 1]   = newTax
        end
    end

    if #updates == 0 then
        Functions.notify(source, Functions.NotifyTypes.Warning, "Nada para atualizar.", 5000)
        return
    end

    params[#params + 1] = name
    local result = DatabaseExecute(
        "UPDATE propertys SET " .. table.concat(updates, ", ") .. " WHERE Name = ?",
        params
    )

    if result and result.affectedRows and result.affectedRows >= 0 then
        -- Resincroniza caches do propertys (Markers, Lock, Saved) com o DB
        -- e atualiza blip nos clientes em tempo real.
        pcall(function() exports["propertys"]:RefreshProperty(name) end)

        Functions.notify(source, Functions.NotifyTypes.Success, "Propriedade '" .. name .. "' atualizada!", 5000)
        TriggerClientEvent("core-admin:receiveProperties", source, { properties = FetchAllProperties(), interiors = GetAvailableInteriors() })

        CoreLog("EDITOU-PROPRIEDADE", {
            message     = LogName(user_id) .. " editou a propriedade " .. name,
            adminName   = Functions.getUserName(user_id),
            adminId     = user_id,
            Propriedade = name,
            NovoDono    = data.passport and tonumber(data.passport) or nil,
            Interior    = data.interior,
            Vault       = data.vault and tonumber(data.vault) or nil,
            Fridge      = data.fridge and tonumber(data.fridge) or nil,
            Imposto     = data.tax and tonumber(data.tax) or nil,
            Coords      = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Falha ao atualizar.", 5000)
    end
end)

RegisterNetEvent("core-admin:removeProperty", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    local propertyName
    if type(data) == "table" then
        propertyName = data.name or data.propertyName
    else
        propertyName = data
    end

    if not propertyName or propertyName == "" then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Nome da propriedade ausente.", 5000)
        return
    end

    local result = DatabaseExecute("DELETE FROM propertys WHERE Name = ? LIMIT 1", { propertyName })
    if result and result.affectedRows and result.affectedRows > 0 then
        -- Limpa caches do propertys (Markers/Lock/Saved) e remove o blip
        -- dos clientes em tempo real.
        pcall(function() exports["propertys"]:RefreshProperty(propertyName) end)

        Functions.notify(source, Functions.NotifyTypes.Success, "Propriedade '" .. propertyName .. "' removida!", 5000)
        TriggerClientEvent("core-admin:receiveProperties", source, { properties = FetchAllProperties(), interiors = GetAvailableInteriors() })

        CoreLog("REMOVEU-PROPRIEDADE", {
            message     = LogName(user_id) .. " removeu a propriedade " .. propertyName,
            adminName   = Functions.getUserName(user_id),
            adminId     = user_id,
            Propriedade = propertyName,
            Coords      = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Propriedade não encontrada.", 5000)
    end
end)

-- Garagens dinâmicas vivem no core-vehicles (/gmanager).

-----------------------------------------------------------------------------------------------------------------------------------------
-- BAÚS (CHEST RESOURCE)
-----------------------------------------------------------------------------------------------------------------------------------------
local ValidChestModes = { ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true }

-- A tabela vRP 'chests' nao tem UNIQUE em Name (PRIMARY KEY eh id),
-- entao ON DUPLICATE KEY UPDATE nao dispara. Para garantir uma unica
-- row por Name, deletamos as existentes com aquele Name e inserimos
-- uma nova com os valores atualizados.
local function UpsertVrpChest(name, permission, weight, slots)
    DatabaseExecute("DELETE FROM chests WHERE Name = ?", { name })
    DatabaseInsert(
        "INSERT INTO chests (Name, Permission, Weight, Slots) VALUES (?, ?, ?, ?)",
        { name, permission or name, weight, slots }
    )
end

local function FetchChests()
    local rows = DatabaseQuery("SELECT id, name, coords_x, coords_y, coords_z, mode, permission, weight, slots, distance, created_by FROM core_admin_chests ORDER BY id ASC")
    local arr  = {}
    if rows then
        for _, v in pairs(rows) do
            arr[#arr + 1] = {
                id         = v.id,
                name       = v.name,
                coords     = { x = v.coords_x, y = v.coords_y, z = v.coords_z },
                mode       = tostring(v.mode or "2"),
                permission = v.permission or "",
                weight     = tonumber(v.weight) or 50,
                slots      = tonumber(v.slots) or 25,
                distance   = tonumber(v.distance) or 1.25,
                created_by = v.created_by,
            }
        end
    end
    return arr
end

local function BroadcastChests()
    -- Replica via statebag global (cliente lê com AddStateBagChangeHandler / GlobalState)
    GlobalState:set("coreAdminChests", FetchChests(), true)
end

CreateThread(function()
    Wait(1500)
    BroadcastChests()
end)

RegisterNetEvent("core-admin:getChests", function()
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    TriggerClientEvent("core-admin:receiveChests", source, FetchChests())
end)

RegisterNetEvent("core-admin:createChest", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    if type(data) ~= "table" then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Dados inválidos!", 5000)
        return
    end

    local name = (data.name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Informe o nome do baú.", 5000)
        return
    end

    local mode = tostring(data.mode or "2")
    if not ValidChestModes[mode] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Modo inválido (use 1, 2, 3 ou 4).", 5000)
        return
    end

    local coords = data.coords
    if type(coords) ~= "table" or not coords.x or not coords.y or not coords.z then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Coordenadas inválidas.", 5000)
        return
    end

    local permission = (data.permission ~= "" and data.permission) or nil
    local weight     = math.max(1, tonumber(data.weight) or 50)
    local slots      = math.max(1, tonumber(data.slots) or 25)
    local distance   = math.max(0.5, math.min(10.0, tonumber(data.distance) or 1.25))

    -- Modo 4 (organização): baú já nasce com 5000kg/500 slots no Líder e no Membro
    if mode == "4" then
        weight = math.max(5000, weight)
        slots  = math.max(500, slots)
    end

    local exists = DatabaseQuery("SELECT id FROM core_admin_chests WHERE name = ? LIMIT 1", { name })
    if exists and exists[1] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Já existe um baú com esse nome.", 5000)
        return
    end

    local insertId = DatabaseInsert(
        "INSERT INTO core_admin_chests (name, coords_x, coords_y, coords_z, mode, permission, weight, slots, distance, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        { name, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, mode, permission, weight, slots, distance, user_id }
    )

    if insertId then
        -- Espelha na tabela vRP 'chests' usada pelo script chest p/ permissão/peso/slots
        UpsertVrpChest(name, permission, weight, slots)

        BroadcastChests()
        Functions.notify(source, Functions.NotifyTypes.Success, "Baú '" .. name .. "' criado!", 5000)
        TriggerClientEvent("core-admin:receiveChests", source, FetchChests())

        CoreLog("CRIOU-BAU", {
            message   = LogName(user_id) .. " criou o baú " .. name,
            adminName = Functions.getUserName(user_id),
            adminId   = user_id,
            Bau       = name,
            Permissao = permission or name,
            Peso      = weight,
            Slots     = slots,
            CoordsBau = ("%.1f, %.1f, %.1f"):format(coords.x, coords.y, coords.z),
            Coords    = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Falha ao salvar baú.", 5000)
    end
end)

RegisterNetEvent("core-admin:updateChest", function(data)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    if type(data) ~= "table" or not data.id then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Dados inválidos!", 5000)
        return
    end

    local id = tonumber(data.id)
    if not id then return end

    local existing = DatabaseQuery("SELECT name FROM core_admin_chests WHERE id = ? LIMIT 1", { id })
    if not existing or not existing[1] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Baú não encontrado.", 5000)
        return
    end
    local oldName = existing[1].name

    local name = (data.name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Informe o nome do baú.", 5000)
        return
    end

    local mode = tostring(data.mode or "2")
    if not ValidChestModes[mode] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Modo inválido (use 1, 2, 3 ou 4).", 5000)
        return
    end

    local coords = data.coords
    if type(coords) ~= "table" or not coords.x or not coords.y or not coords.z then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Coordenadas inválidas.", 5000)
        return
    end

    local permission = (data.permission ~= "" and data.permission) or nil
    local weight     = math.max(1, tonumber(data.weight) or 50)
    local slots      = math.max(1, tonumber(data.slots) or 25)
    local distance   = math.max(0.5, math.min(10.0, tonumber(data.distance) or 1.25))

    if name ~= oldName then
        local dup = DatabaseQuery("SELECT id FROM core_admin_chests WHERE name = ? AND id <> ? LIMIT 1", { name, id })
        if dup and dup[1] then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Já existe outro baú com esse nome.", 5000)
            return
        end
    end

    local result = DatabaseExecute(
        "UPDATE core_admin_chests SET name = ?, coords_x = ?, coords_y = ?, coords_z = ?, mode = ?, permission = ?, weight = ?, slots = ?, distance = ? WHERE id = ?",
        { name, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, mode, permission, weight, slots, distance, id }
    )

    if result and result.affectedRows and result.affectedRows >= 0 then
        -- Se mudou o nome, remove as rows com o nome antigo na tabela vRP
        if name ~= oldName then
            DatabaseExecute("DELETE FROM chests WHERE Name = ?", { oldName })
        end

        -- Garante uma unica row no chests com os valores atualizados
        UpsertVrpChest(name, permission, weight, slots)

        BroadcastChests()
        Functions.notify(source, Functions.NotifyTypes.Success, "Baú '" .. name .. "' atualizado!", 5000)
        TriggerClientEvent("core-admin:receiveChests", source, FetchChests())

        CoreLog("EDITOU-BAU", {
            message    = LogName(user_id) .. " editou o baú " .. name,
            adminName  = Functions.getUserName(user_id),
            adminId    = user_id,
            Bau        = name,
            NomeAntigo = oldName ~= name and oldName or nil,
            Permissao  = permission or name,
            Peso       = weight,
            Slots      = slots,
            CoordsBau  = ("%.1f, %.1f, %.1f"):format(coords.x, coords.y, coords.z),
            Coords     = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Falha ao atualizar baú.", 5000)
    end
end)

RegisterNetEvent("core-admin:deleteChest", function(chestId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 2) then return end

    local id = tonumber(chestId)
    if not id then return end

    local rows = DatabaseQuery("SELECT name FROM core_admin_chests WHERE id = ? LIMIT 1", { id })
    if not rows or not rows[1] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Baú não encontrado.", 5000)
        return
    end
    local chestName = rows[1].name

    local result = DatabaseExecute("DELETE FROM core_admin_chests WHERE id = ?", { id })
    if result and result.affectedRows and result.affectedRows > 0 then
        BroadcastChests()
        Functions.notify(source, Functions.NotifyTypes.Success, "Baú '" .. chestName .. "' removido!", 5000)
        TriggerClientEvent("core-admin:receiveChests", source, FetchChests())

        CoreLog("REMOVEU-BAU", {
            message   = LogName(user_id) .. " removeu o baú " .. chestName,
            adminName = Functions.getUserName(user_id),
            adminId   = user_id,
            Bau       = chestName,
            Coords    = LogCoords(source),
        })
    else
        Functions.notify(source, Functions.NotifyTypes.Denied, "Baú não encontrado.", 5000)
    end
end)

RegisterNetEvent("core-admin:teleportToChest", function(chestId)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not HasAdminLevel(user_id, 4) then return end

    local id = tonumber(chestId)
    if not id then return end

    local rows = DatabaseQuery("SELECT coords_x, coords_y, coords_z FROM core_admin_chests WHERE id = ? LIMIT 1", { id })
    if not rows or not rows[1] then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Baú não encontrado.", 5000)
        return
    end

    local originCoords = LogCoords(source)
    local ped = GetPlayerPed(source)
    SetEntityCoords(ped, rows[1].coords_x + 0.0, rows[1].coords_y + 0.0, rows[1].coords_z + 0.0)
    Functions.notify(source, Functions.NotifyTypes.Success, "Teleportado para o baú!", 5000)

    CoreLog("TP-BAU", {
        message       = LogName(user_id) .. " teleportou para o baú #" .. id,
        adminName     = Functions.getUserName(user_id),
        adminId       = user_id,
        Bau           = id,
        CoordsOrigem  = originCoords,
        CoordsDestino = ("%.1f, %.1f, %.1f"):format(rows[1].coords_x, rows[1].coords_y, rows[1].coords_z),
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTO AUTOMÁTICO DE SALÁRIOS (30 MIN)
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    Wait(5000)
    while true do
        local data = DatabaseQuery("SELECT * FROM core_admin_salary")
        if data then
            for _, v in pairs(data) do
                local groupMembers = GetUsersByPermission(v.group)
                for _, memberId in pairs(groupMembers) do
                    GiveSalary(memberId, v.amount, v.group)
                end
            end
        end
        Wait(1000 * 60 * 30)
    end
end)
