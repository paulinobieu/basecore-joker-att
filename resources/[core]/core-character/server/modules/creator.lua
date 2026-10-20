-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local RegisterNetEvent = RegisterNetEvent
local TriggerClientEvent = TriggerClientEvent
local math_random = math.random
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local UsedBuckets = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTERROUTING
-----------------------------------------------------------------------------------------------------------------------------------------
function EnterRouting(src)
    local bucket = math_random(1, 9999)

    while UsedBuckets[bucket] do
        bucket = math_random(1, 9999)
    end

    UsedBuckets[bucket] = src
    ServerState.Buckets[src] = bucket

    Framework.SetRouting(src, bucket)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXITROUTING
-----------------------------------------------------------------------------------------------------------------------------------------
function ExitRouting(src)
    local buckets = ServerState.Buckets
    local bucket = buckets and buckets[src]

    if bucket then
        UsedBuckets[bucket] = nil
        buckets[src] = nil
    end

    Framework.SetRouting(src, 0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETGENDER
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.setGender(src, userId, data)
    local gender = type(data) == "table" and data.gender or nil
    if gender ~= "mp_m_freemode_01" and gender ~= "mp_f_freemode_01" then return end

    Framework.SkinCharacter(userId, gender)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISHCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.finishCharacter(src, userId, data)
    if type(data) ~= "table" then return SendActionResult(src, false) end

    local name = ValidateName(data.name)
    local lastname = ValidateName(data.lastname)

    if not name or not lastname or (name == "Individuo" and lastname == "Indigente") then
        Notify(src, L("createInvalidName"), "error")
        return SendActionResult(src, false, "finishCharacter", "nome_invalido")
    end

    local gender = data.gender == "mp_f_freemode_01" and "mp_f_freemode_01" or "mp_m_freemode_01"
    local appearance = SanitizeAppearance(data.appearance)

    if not appearance then
        return SendActionResult(src, false, "finishCharacter", "visual_invalido")
    end

    DB_SaveAppearance(userId, appearance, gender, Framework.License(src))
    Framework.SaveIdentity(userId, name, lastname, gender)
    Framework.SkinCharacter(userId, gender)

    ForgetUserName(userId)
    Framework.OnCharacterCreated(src, userId)

    SendActionResult(src, true, "finishCharacter")
    TriggerClientEvent("core-character:characterCreated", src, appearance)

    CoreLog("CHARACTER_CREATE", {
        playerName = name .. " " .. lastname, playerId = userId,
        name = name .. " " .. lastname, gender = gender == "mp_f_freemode_01" and "Feminino" or "Masculino",
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVEBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.saveBarber(src, userId, data)
    if not Character.Features.Barber then return end

    local appearance = SanitizeAppearance(type(data) == "table" and data.appearance)
    if not appearance then return SendActionResult(src, false, "saveBarber") end

    DB_SaveAppearance(userId, appearance)
    ServerState.Backup[src] = nil

    Notify(src, L("barberSaved"), "success")
    SendActionResult(src, true, "saveBarber")
    CoreLog("CHARACTER_BARBER", { playerName = UserName(userId), playerId = userId })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.cancelBarber(src, userId)
    if not Character.Features.Barber then return end

    local backup = ServerState.Backup[src]
    ServerState.Backup[src] = nil

    if not backup then return end

    DB_SaveAppearance(userId, backup)
    TriggerClientEvent("core-character:applyAppearance", src, backup)
    Notify(src, L("barberDiscarded"))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenBarber(src, userId)
    if not Character.Features.Barber then return end

    local stored = DB_LoadCharacter(userId)
    local appearance = SanitizeAppearance(stored and stored.chardata)
        or SanitizeAppearance(Appearance.Default)

    ServerState.Backup[src] = appearance

    SendInterfaceMessage(src, "open", {
        screen = "barber",
        hairs = GlobalState["CharacterHairs"],
        character = appearance,
        admin = Framework.HasGroup(userId, Character.AdminPermission, 1),
    })

    TriggerClientEvent("core-character:openBarber", src, appearance)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
-- `fresh` = personagem sem visual gravado. Ele entra no criador como se fosse
-- novo (visual padrão e roupa do criador), mas com o sexo e o nome que já tem:
-- quem já jogava não vira outra pessoa só porque a tabela nova está vazia.
function OpenCreator(src, userId, fresh)
    local stored = DB_LoadCharacter(userId)
    local identity = Framework.Identity(userId) or {}
    local name = identity.name or ""
    local lastname = identity.lastname or ""

    if name == "Individuo" and lastname == "Indigente" then
        name = ""
        lastname = ""
    end

    local appearance = not fresh and SanitizeAppearance(stored and stored.chardata)
        or SanitizeAppearance(Appearance.Default)

    ServerState.Backup[src] = nil

    TriggerClientEvent("core-character:openCreator", src, {
        edit = not fresh,
        appearance = appearance,
        model = IsModel(identity.model) and identity.model or nil,
        name = name,
        lastname = lastname,
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:REQUESTBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:requestBarber", function()
    local src = source
    local userId = Framework.UserId(src)
    if not userId then return end

    OpenBarber(src, userId)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXITCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.exitCreator(src, userId)
    ExitRouting(src)
    Framework.OnCharacterSpawned(src, userId)
end
