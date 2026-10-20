load(LoadResourceFile("vrp","lib/utils.lua"))()

Tunnel = module("vrp","lib/Tunnel")
Proxy = module("vrp","lib/Proxy")
Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local function getCharacterGroupTitleByType(characterId,groupType)
    local groups = vRP.UserGroups(characterId)
    if not groups then
        return "---"
    end

    for permission,level in pairs(groups) do
        if vRP.GroupType(permission) == groupType then
            local title = vRP.NameHierarchy(permission,level)
            if title and title ~= "" then
                return title
            end

            return permission
        end
    end

    return "---"
end

------------------------------------------------------------------------------------------------------------------------
-- # Database
------------------------------------------------------------------------------------------------------------------------

query = function(command,params)
    if params then
        command = command:format(table.unpack(params))
    end
    return exports["oxmysql"]:query_async(command) or {}
end

execute = function(command,params)
    if params then
        command = command:format(table.unpack(params))
    end
    return exports["oxmysql"]:execute(command)
end

------------------------------------------------------------------------------------------------------------------------
-- # Characters
------------------------------------------------------------------------------------------------------------------------

getCharacterId = function(src)
    return vRP.Passport(src)
end

getCharacterSource = function(characterId)
    return vRP.Source(characterId)
end

isCharacterDead = function(src)
    return (GetEntityHealth(GetPlayerPed(src)) <= 101)
end

getCharacterIdentity = function(characterId)
    local identity = vRP.Identity(characterId)
    if identity then
        local vipGroupTitle = getCharacterGroupTitleByType(characterId,"vip")
        local legalJob = getCharacterGroupTitleByType(characterId,"job")
        local ilegalJob = getCharacterGroupTitleByType(characterId,"ilegal-job")

        return {
            ["name"] = ((identity.Name or "").." "..(identity.Lastname or "")):gsub("[%p%c]",""):gsub("^%s+",""):gsub("%s+$",""),
            ["passport"] = characterId,
            ["identity"] = identity.Serial,
            ["phone"] = identity.Phone or (vRP.Phone and vRP.Phone(characterId)) or "",
            ["age"] = identity.Age,
            ["bank-account"] = vRP.GetBank(characterId),
            ["cash"] = vRP.ItemAmount(characterId,"dollar"),
            ["vip"] = vipGroupTitle,
            ["legal-job"] = legalJob,
            ["ilegal-job"] = ilegalJob,
        }
    end
    return {}
end

hasPermission = function(characterId,permission)
    if not permission then return true end
    if type(permission) == "table" then
        for _,perm in pairs(permission) do
            if hasPermission(characterId,perm) then
                return true
            end
        end
        return false
    elseif type(permission) == "string" then
        local at = permission:find("@")
        if at then
            local group = permission:sub(1, at - 1)
            local level = tonumber(permission:sub(at + 1))
            return vRP.HasGroup(characterId, group, level)
        end
        return vRP.HasPermission(characterId,permission)
    end
    return false
end

getCharactersByPermission = function(permission)
    return vRP.NumPermission(permission)
end

getAllCharacters = function()
    local characters = {}

    for _,src in ipairs(GetPlayers()) do
        local source = tonumber(src)
        local characterId = source and vRP.Passport(source)
        if characterId then
            characters[characterId] = source
        end
    end

    return characters
end

------------------------------------------------------------------------------------------------------------------------
-- # Currency
------------------------------------------------------------------------------------------------------------------------

removeCurrency = function(characterId,value,paymentType)
    if not characterId or value == nil then return false end
    value = parseInt(value) if value == 0 then return true end
    if not paymentType then paymentType = "" end

    if paymentType == "secondary" then
        return vRP.PaymentGems(characterId,value)
    elseif paymentType == "fromBank" or paymentType == "tabletBank" then
        return vRP.PaymentBank(characterId,value,true)
    else
        return vRP.PaymentFull(characterId,value,true)
    end
end

giveCurrency = function(characterId,value,currencyType)
    if not characterId or value == nil then return end
    value = parseInt(value) if value <= 0 then return end
    if not currencyType then currencyType = "" end

    if currencyType == "secondary" then
        vRP.UpgradeGemstone(characterId,value)
    else
        vRP.GiveBank(characterId,value,true)
    end
end

------------------------------------------------------------------------------------------------------------------------
-- # Request
------------------------------------------------------------------------------------------------------------------------

requestResponse = function(src,actionId,infos)
    local title,ask = "?","?"
    if actionId == "VEHICLE_SELL" then
        title,ask = "Proposta de Venda","Deseja comprar um <b>"..infos.vehicle.."</b> por <b>R$ "..formatCurrency(infos.price).."</b>?"
    elseif actionId == "VEHICLE_INVOICE_REPLACE" then
        title,ask = "Alerta","Este veículo já possuí um <b>pedido de tunagem</b> pendente. Ao acessar a mecânica ele será cancelado. Deseja prosseguir?"
    elseif actionId == "VEHICLE_INVOICE_PAYMENT" then
        title,ask = "Confirmação do Pedido","Deseja realizar o pagamento do pedido de tunagem do veículo <b>"..infos.vehicle.." ("..infos.plate..")</b> por <b>R$ "..formatCurrency(infos.value).."</b>?"
    end
    return vRP.Request(src,title,ask)
end

------------------------------------------------------------------------------------------------------------------------
-- # Logs
------------------------------------------------------------------------------------------------------------------------

_LOG = function(webhook,log,color)
    if not webhook or webhook == "" then return end
    if not color then color = 16777215 end
    if not string.find(webhook,"discord") then return end
    local e = { { title = os.date("%d/%m/%Y - %H:%M:%S"), color = color, description = log, footer = { text = "core-vehicles" } } }
    PerformHttpRequest(webhook,function() end,'POST',json.encode({ username = "Core Vehicles", embeds = e }), { ['Content-Type'] = 'application/json' })
end

------------------------------------------------------------------------------------------------------------------------
-- # Vehicle Identity (for external scripts)
------------------------------------------------------------------------------------------------------------------------

getVehicleIdentity = function(vehiclePlate)
    if vehiclePlate then
        local data = exports['core-vehicles']:getVehicleData(vehiclePlate)
        if data then
            local ownerName = "#"..data.owner
            local ownerIdentity = getCharacterIdentity(data.owner)
            if ownerIdentity and ownerIdentity.name then
                ownerName = ownerIdentity.name.." "..ownerName
            end
            return {
                model = (data.isServiceRental and (data.name.." (Alugado)") or data.name),
                index = data.index,
                owner = ownerName,
            }
        end
    end
    return false
end
exports('getVehicleIdentity',getVehicleIdentity)

removeVehicleEntity = function(netEntity)
    local entity = NetworkGetEntityFromNetworkId(netEntity)
    if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
        DeleteEntity(entity)
    end
end
exports('removeVehicleEntity',removeVehicleEntity)

------------------------------------------------------------------------------------------------------------------------
-- # Reset Route
------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent("core-vehicles/resetRoute")
AddEventHandler("core-vehicles/resetRoute",function()
    local src = source
    SetPlayerRoutingBucket(src,0)
end)

------------------------------------------------------------------------------------------------------------------------
-- # canCharacterBuyVehicle: verificar se um personagem pode comprar um novo veículo (limite de vagas)
------------------------------------------------------------------------------------------------------------------------

local permissionLimits = {
    ['vip1'] = 20,
    ['vip2'] = 30,
    ['vip3'] = 40,
    ['admin'] = 50
}

canCharacterBuyVehicle = function(characterId, vehicleCount)

    local limit = 10
    for permission, _limit in pairs(permissionLimits) do
        if hasPermission(characterId, permission) then
            limit = _limit
        end
    end

    if vehicleCount >= limit then
        return false
    end

    return true

end

------------------------------------------------------------------------------------------------------------------------
-- # canParkOutVehicle: checar se um veículo pode ser retirado da garagem
------------------------------------------------------------------------------------------------------------------------

canParkOutVehicle = function(src, characterId, vehicleData, vehicleModelInfo)

    if GetResourceState('core-bank') == 'started' then
        if exports['core-bank']:CheckTaxes(characterId) or exports['core-bank']:CheckFines(characterId) then
            return {
                title = 'DÉBITOS EM ABERTO',
                description = 'Você possuí <b>débitos pendentes</b> no banco, quite-os antes de utilizar a garagem!'
            }
        end
    end

    if vehicleData.expire_time <= 0 and vehicleData.taxEndTime <= os.time() then
        local value = parseInt(vehicleModelInfo.price * vehicleTaxes.percentFromPrice)
        return {
            title = 'IPVA ATRASADO',
            description = 'O IPVA do veículo encontra-se em <b>atraso</b>, <br>para retirá-lo será necessário realizar o pagamento da taxa, no valor de <b>R$ '..formatCurrency(value)..'</b>.<br>Deseja prosseguir com o pagamento?',
            paymentValue = value,
            updateTax = true,
            resetStatus = false
        }
    end

    if vehicleData.status == 'ARRESTED' then
        local value = parseInt(vehicleModelInfo.price * 0.25)
        return {
            title = 'VEÍCULO APREENDIDO',
            description = 'Seu veículo foi <b>apreendido</b> e para retirá-lô será necessário pagar uma multa de <b>R$ '..formatCurrency(value)..'</b>.<br>Deseja prosseguir com o pagamento?',
            paymentValue = value,
            updateTax = false,
            resetStatus = true
        }
    end

    if vehicleData.status == 'STOLEN' then
        local value = parseInt(vehicleModelInfo.price * 0.10)
        return {
            title = 'VEÍCULO NA SEGURADORA',
            description = 'Seu veículo foi <b>furtado</b> e a seguradora o recuperou! Para retirá-lô será necessário pagar uma taxa de <b>R$ '..formatCurrency(value)..'</b>.<br>Deseja prosseguir com o pagamento?',
            paymentValue = value,
            updateTax = false,
            resetStatus = true
        }
    end

    if vehicleData.status == 'DISMANTLED' then
        local value = parseInt(vehicleModelInfo.price * 0.30)
        return {
            title = 'VEÍCULO DESMANCHADO',
            description = 'Seu veículo foi <b>desmanchado</b> e a seguradora o recuperou em estado precário! Para retirá-lô será necessário pagar uma taxa de recuperação de <b>R$ '..formatCurrency(value)..'</b>.<br>Deseja prosseguir com o pagamento?',
            paymentValue = value,
            updateTax = false,
            resetStatus = true
        }
    end

    return true

end

------------------------------------------------------------------------------------------------------------------------
-- # onVehicleCreation: API quando um veículo é criado (server-side)
------------------------------------------------------------------------------------------------------------------------

onVehicleCreation = function(entity, hash, plate)
    TriggerEvent("core-vehicles:vehicleCreated",plate,NetworkGetNetworkIdFromEntity(entity))
end

------------------------------------------------------------------------------------------------------------------------
-- # hasPropertyPermission: checar se um personagem tem permissão em uma garagem de casa
------------------------------------------------------------------------------------------------------------------------

hasPropertyPermission = function(src, characterId, propertyId, propertyType)
    return false
end

------------------------------------------------------------------------------------------------------------------------
-- # setupCharacterVehicle: API para utilização de mecânicas externas
------------------------------------------------------------------------------------------------------------------------

setupCharacterVehicle = false

------------------------------------------------------------------------------------------------------------------------
-- # getVehicleName: retorna o nome de um veículo pelo hash ou index
------------------------------------------------------------------------------------------------------------------------

getVehicleName = function(hashOrIndex)
    if type(hashOrIndex) == 'string' then
        local info = vehlist[hashOrIndex]
        return info and info.name or hashOrIndex
    end
    for index,info in pairs(vehlist) do
        if GetHashKey(index) == hashOrIndex then
            return info.name or index
        end
    end
    return tostring(hashOrIndex)
end

------------------------------------------------------------------------------------------------------------------------
-- # getVehicleCategory: retorna a categoria de um veículo pelo index
------------------------------------------------------------------------------------------------------------------------

getVehicleCategory = function(vehicleIndex)
    local info = vehlist[vehicleIndex]
    return info and info.category or 'car'
end
