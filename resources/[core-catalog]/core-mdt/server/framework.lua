-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP por padrão). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local pcall      = pcall
local type       = type
local next       = next
local tonumber   = tonumber
local tostring   = tostring
local str_format = string.format
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUERIES
-- O SQL de cidadãos/veículos depende só do config, então é montado uma única vez
-- (na primeira consulta) e reaproveitado — evita refazer os format() a cada busca.
-----------------------------------------------------------------------------------------------------------------------------------------
local queries = nil

local function Queries()
    if queries then return queries end

    local c = Mdt.database.characters
    local v = Mdt.database.vehicles

    queries = {
        searchCharacters = str_format([[
            SELECT `%s` AS id, `%s` AS name, `%s` AS lastname, `%s` AS phone, `%s` AS account
            FROM `%s`
            WHERE `%s` LIKE ? OR `%s` LIKE ? OR CONCAT(`%s`, ' ', `%s`) LIKE ? OR `%s` LIKE ? OR CAST(`%s` AS CHAR) LIKE ?
            ORDER BY `%s` ASC, `%s` ASC
            LIMIT ? OFFSET ?
        ]],
            c.id, c.name, c.lastname, c.phone, c.license,
            c.table,
            c.name, c.lastname, c.name, c.lastname, c.phone, c.id,
            c.name, c.lastname
        ),

        countCharacters = str_format([[
            SELECT COUNT(*) AS total FROM `%s`
            WHERE `%s` LIKE ? OR `%s` LIKE ? OR CONCAT(`%s`, ' ', `%s`) LIKE ? OR `%s` LIKE ? OR CAST(`%s` AS CHAR) LIKE ?
        ]], c.table, c.name, c.lastname, c.name, c.lastname, c.phone, c.id),

        getCharacter = str_format([[
            SELECT `%s` AS id, `%s` AS name, `%s` AS lastname, `%s` AS phone, `%s` AS account
            FROM `%s` WHERE `%s` = ? LIMIT 1
        ]], c.id, c.name, c.lastname, c.phone, c.license, c.table, c.id),

        searchVehicles = str_format([[
            SELECT v.`%s` AS plate, v.`%s` AS model, v.`%s` AS owner, v.`%s` AS status,
                   CONCAT(c.`%s`, ' ', c.`%s`) AS owner_name
            FROM `%s` v
            LEFT JOIN `%s` c ON c.`%s` = v.`%s`
            WHERE v.`%s` LIKE ? OR CONCAT(c.`%s`, ' ', c.`%s`) LIKE ? OR CAST(v.`%s` AS CHAR) LIKE ?
            ORDER BY v.`%s` ASC
            LIMIT ? OFFSET ?
        ]],
            v.plate, v.model, v.owner, v.status,
            c.name, c.lastname,
            v.table,
            c.table, c.id, v.owner,
            v.plate, c.name, c.lastname, v.owner,
            v.plate
        ),

        countVehicles = str_format([[
            SELECT COUNT(*) AS total
            FROM `%s` v
            LEFT JOIN `%s` c ON c.`%s` = v.`%s`
            WHERE v.`%s` LIKE ? OR CONCAT(c.`%s`, ' ', c.`%s`) LIKE ? OR CAST(v.`%s` AS CHAR) LIKE ?
        ]], v.table, c.table, c.id, v.owner, v.plate, c.name, c.lastname, v.owner),

        getVehicle = str_format([[
            SELECT v.`%s` AS plate, v.`%s` AS model, v.`%s` AS owner, v.`%s` AS status,
                   CONCAT(c.`%s`, ' ', c.`%s`) AS owner_name
            FROM `%s` v LEFT JOIN `%s` c ON c.`%s` = v.`%s`
            WHERE v.`%s` = ? LIMIT 1
        ]], v.plate, v.model, v.owner, v.status, c.name, c.lastname, v.table, c.table, c.id, v.owner, v.plate),

        vehiclesByOwner = str_format([[
            SELECT `%s` AS plate, `%s` AS model, `%s` AS status FROM `%s` WHERE `%s` = ?
        ]], v.plate, v.model, v.status, v.table, v.owner),
    }

    return queries
end
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Retorna o identificador único do jogador a partir do source da conexão.
    Passport = function(source)
        return vRP.Passport(source) or vRP.passport(source) or vRP.GetUserId(source) or vRP.getUserId(source)
    end,

    -- Source (id de conexão) online a partir do passaporte, ou nil se offline.
    Source = function(passport)
        local check = vRP.Source or vRP.source or vRP.getUserSource or vRP.GetUserSource
        if not check then return nil end

        local ok, result = pcall(check, passport)
        if not ok then return nil end

        local src = tonumber(result)
        return (src and src > 0) and src or nil
    end,

    -- Retorna a identidade completa do jogador (nome, sobrenome, saldo...).
    Identity = function(passport)
        if not passport then return nil end

        local check = vRP.Identity or vRP.identity
        if not check then return nil end

        local ok, result = pcall(check, passport)
        if not ok or type(result) ~= "table" then return nil end

        return result
    end,

    -- Nome completo (cobre name/name2, Name/Name2, name/lastname e Name/Lastname).
    FullName = function(passport)
        local identity = Framework.Identity(passport)
        if not identity then return nil end

        local firstName = identity.name or identity.Name or identity.firstname or identity.firstName
        local lastName  = identity.name2 or identity.Name2 or identity.lastname or identity.Lastname

        if not firstName then return nil end
        if not lastName or lastName == "" then return firstName end

        return str_format("%s %s", firstName, lastName)
    end,

    -- Só o primeiro nome do jogador.
    Name = function(passport)
        local identity = Framework.Identity(passport)
        if not identity then return nil end

        return identity.name or identity.Name or identity.firstname or identity.firstName
    end,

    -- Documento/registro do cidadão (RG/CPF/telefone — o que sua base usar).
    -- Ajuste o corpo pra retornar o identificador que aparece na ficha.
    Document = function(passport)
        local identity = Framework.Identity(passport)
        if not identity then return "" end

        return tostring(
            identity.registration or identity.Registration or
            identity.phone or identity.Phone or passport
        )
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERMISSÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Verifica se o jogador possui a permissão informada.
    HasPermission = function(passport, permission, level)
        if not passport then return false end

        local check = vRP.HasPermission or vRP.hasPermission
        if not check then return false end

        local requiredLevel = tonumber(level)
        local ok, result

        if requiredLevel then
            ok, result = pcall(check, passport, permission, requiredLevel)
        else
            ok, result = pcall(check, passport, permission)
        end
        if not ok then return false end

        if type(result) == "number" then return result > 0 end

        return result == true or result == 1
    end,

    -- Membros do grupo ({ [passaporte] = nível }) e o efetivo total.
    GroupData = function(permission)
        local check = vRP.DataGroups or vRP.dataGroups
        if not check then return {}, 0 end

        local ok, members, amount = pcall(check, permission)
        if not ok or type(members) ~= "table" then return {}, 0 end

        return members, tonumber(amount) or 0
    end,

    -- Nível de permissão (posição da patente) do jogador no grupo.
    PermissionLevel = function(passport, permission)
        if not passport then return 0 end

        local members = Framework.GroupData(permission)
        local level = members[passport] or members[tostring(passport)]

        return tonumber(level) or 0
    end,

    -- Quantidade de membros do grupo em serviço no momento.
    ServiceAmount = function(permission)
        local check = vRP.AmountService or vRP.amountService
        if not check then return 0 end

        local ok, result = pcall(check, permission)
        if not ok then return 0 end

        return tonumber(result) or 0
    end,

    -- Efetivo total (todos os membros) do grupo.
    GroupAmount = function(permission)
        local _, amount = Framework.GroupData(permission)
        return amount
    end,

    -- Contrata/promove: coloca o passaporte no grupo/permissão no nível (patente).
    SetPermission = function(passport, permission, level)
        return vRP.SetPermission(passport, permission, level)
    end,

    -- Demite: remove o passaporte do grupo/permissão.
    RemovePermission = function(passport, permission)
        return vRP.RemovePermission(passport, permission)
    end,

    -- Status de serviço do jogador (true = em serviço) via vRP.HasService.
    InService = function(passport, permission)
        local check = vRP.HasService or vRP.hasService
        if not check then return false end

        local ok, result = pcall(check, passport, permission)
        if not ok then return false end

        if type(result) == "number" then return result > 0 end
        if type(result) == "string" then return result ~= "" end

        return result == true
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- GRUPOS (sincronização de patentes)
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Todos os grupos da base (vRP.Groups()).
    Groups = function()
        local check = vRP.Groups or vRP.groups
        if not check then return {} end

        local ok, result = pcall(check)
        if not ok or type(result) ~= "table" then return {} end

        return result
    end,

    -- Confere se o grupo/permissão existe na base antes de amarrar um app nele.
    -- Se a base não expõe a lista de grupos, não dá pra validar: libera.
    GroupExists = function(permission)
        if not permission or permission == "" then return false end

        local groups = Framework.Groups()

        if next(groups) == nil then return true end

        return groups[permission] ~= nil
    end,

    -- Patentes do grupo na ordem do vRP (índice 1 = cargo mais alto = nível 1).
    GroupHierarchy = function(permission)
        if not permission or permission == "" then return {} end

        local group = Framework.Groups()[permission]
        if type(group) ~= "table" or type(group.Hierarchy) ~= "table" then return {} end

        local names = {}
        for i = 1, #group.Hierarchy do
            local name = tostring(group.Hierarchy[i] or "")
            if name ~= "" then names[#names + 1] = name end
        end

        return names
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- MULTAS
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Lança a multa do boletim na base do jogador (datatable "Multas" do vRP).
    ApplyFine = function(passport, amount)
        if not passport then return false end

        local value = tonumber(amount) or 0
        if value <= 0 then return false end

        local check = vRP.UpdateDatatable or vRP.updateDatatable
        if not check then return false end

        local ok = pcall(check, passport, "Multas", value)
        return ok
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- FIANÇA (dinheiro entrando e saindo)
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Cobra o valor do jogador ao pagar a fiança. Retorna true SÓ se o valor
    -- realmente saiu da conta dele (sem saldo = false, e a fiança não é aplicada).
    -- Adapte o corpo se a sua base usa outro nome de função.
    Payment = function(passport, amount)
        if not passport then return false end

        local value = tonumber(amount) or 0
        if value <= 0 then return true end

        local check = vRP.PaymentFull or vRP.paymentFull or vRP.Payment or vRP.payment
        if not check then return false end

        local ok, result = pcall(check, passport, value)
        if not ok then return false end

        -- Algumas bases devolvem nil quando o pagamento dá certo.
        return result ~= false
    end,

    -- Deposita o valor na conta do jogador (repasse da fiança ao oficial).
    Deposit = function(passport, amount)
        if not passport then return false end

        local value = tonumber(amount) or 0
        if value <= 0 then return false end

        local check = vRP.GiveBank or vRP.giveBank or vRP.GiveMoney or vRP.giveMoney
        if not check then return false end

        local ok, result = pcall(check, passport, value)
        if not ok then return false end

        return result ~= false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CIDADÃOS (tabela `characters` — nomes em Mdt.database.characters)
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Busca paginada. Retorna linhas { id, name, lastname, phone, account }.
    SearchCharacters = function(query, limit, offset)
        local like = "%" .. (query or "") .. "%"

        return Framework.Query(Queries().searchCharacters,
            { like, like, like, like, like, limit, offset }) or {}
    end,

    CountCharacters = function(query)
        local like = "%" .. (query or "") .. "%"

        local row = Framework.Single(Queries().countCharacters, { like, like, like, like, like })

        return row and tonumber(row.total) or 0
    end,

    GetCharacter = function(id)
        return Framework.Single(Queries().getCharacter, { tonumber(id) })
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- VEÍCULOS (tabela `core_characters_vehicles` — nomes em Mdt.database.vehicles)
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Busca paginada. Retorna linhas { plate, model, owner, status, owner_name }.
    SearchVehicles = function(query, limit, offset)
        local like = "%" .. (query or "") .. "%"

        return Framework.Query(Queries().searchVehicles, { like, like, like, limit, offset }) or {}
    end,

    CountVehicles = function(query)
        local like = "%" .. (query or "") .. "%"

        local row = Framework.Single(Queries().countVehicles, { like, like, like })

        return row and tonumber(row.total) or 0
    end,

    GetVehicle = function(plate)
        return Framework.Single(Queries().getVehicle, { plate })
    end,

    GetVehiclesByOwner = function(ownerId)
        return Framework.Query(Queries().vehiclesByOwner, { tonumber(ownerId) }) or {}
    end,

    -- Dono do veículo a partir da placa (usado na criação de ocorrência).
    VehicleOwner = function(plate)
        if not plate or plate == "" then return nil end

        local row = Framework.GetVehicle(plate)
        if not row or not row.owner then return nil end

        local passport = tonumber(row.owner)
        local name = (row.owner_name and row.owner_name ~= "" and row.owner_name)
            or Framework.FullName(passport)
            or ("Passaporte #" .. tostring(passport))

        return { id = passport, name = name }
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    -- SELECT (retorna lista de linhas).
    Query = function(query, params)
        return MySQL.query.await(query, params or {})
    end,

    -- INSERT (retorna o id gerado).
    Insert = function(query, params)
        return MySQL.insert.await(query, params or {})
    end,

    -- UPDATE/DELETE (retorna nº de linhas afetadas).
    Update = function(query, params)
        return MySQL.update.await(query, params or {})
    end,

    -- SELECT de uma única linha (retorna a primeira linha).
    Single = function(query, params)
        return MySQL.single.await(query, params or {})
    end,
}
