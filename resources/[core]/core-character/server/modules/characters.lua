-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local TriggerClientEvent = TriggerClientEvent
local Wait = Wait
local ipairs = ipairs
local tonumber = tonumber
local tostring = tostring
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEWPAYLOAD
-----------------------------------------------------------------------------------------------------------------------------------------
local function PreviewPayload(stored)
    if not stored then return nil end

    return {
        model = stored.model,
        chardata = stored.chardata,
        clothes = stored.clothes,
        tattoos = stored.tattoos,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDSLOTS
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildSlots(license)
    local characters = Framework.ListCharacters(license)
    local available = AccountSlots(license)

    local slots = {}
    local owned = { Ids = {}, Data = {} }

    for index, entry in ipairs(characters) do
        if index > MaxSlots then break end

        slots[index] = {
            id = tostring(entry.id),
            name = entry.name,
        }

        owned.Ids[entry.id] = true
        owned.Data[entry.id] = PreviewPayload(DB_LoadCharacter(entry.id))
    end

    for index = 1, MaxSlots do
        if not slots[index] then
            slots[index] = { createPerson = index <= available }
        end
    end

    return slots, owned
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
function IsAdmin(userId, level)
    return Framework.HasGroup(userId, Character.AdminPermission, level or 1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OWNSCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function OwnsCharacter(src, characterId)
    local owned = ServerState.Slots[src]
    return type(owned) == "table" and owned.Ids[characterId] == true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENSELECTION
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenSelection(src)
    local license = Framework.License(src)

    -- Sem licença o jogador ficaria numa tela preta para sempre: a seleção
    -- nunca abre e ele não tem como saber por quê.
    if not license then
        return Notify(src, L("selectLicenseFail"), "error")
    end

    if Framework.CountCharacters(license) <= 0 then
        return CreateCharacter(src)
    end

    local slots, owned = BuildSlots(license)
    ServerState.Slots[src] = owned

    local first = slots[1] and tonumber(slots[1].id)

    SendInterfaceMessage(src, "open", { screen = "select", slots = slots })
    TriggerClientEvent("core-character:openSelect", src, first and owned.Data[first] or nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATECHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateCharacter(src)
    if ServerState.Creating[src] then return end
    ServerState.Creating[src] = true

    local license = Framework.License(src)
    local model = Framework.Model(src)
    local characterId = license and Framework.CreateCharacter(license, model)

    if characterId then
        ServerState.SpawnSessions[characterId] = true
        DB_CreateCharacterRow(license, characterId, model)

        -- CharacterChosen primeiro: é ele que dá o passaporte, e sem passaporte
        -- o finishCharacter no fim da criação não teria em quem gravar.
        Framework.CharacterChosen(src, characterId, model)
        OpenCreator(src, characterId, true)
    else
        Notify(src, L("selectCharacterFail"), "error")
    end

    ServerState.Creating[src] = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SELECTCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.selectCharacter(src, _userId, data)
    local characterId = tonumber(type(data) == "table" and data.characterId)
    if not characterId then return end

    if not OwnsCharacter(src, characterId) then
        return Notify(src, L("selectInvalidChar"), "error")
    end

    local stored = DB_LoadCharacter(characterId)
    local initialSpawn = ServerState.SpawnSessions[characterId] ~= true
    ServerState.SpawnSessions[characterId] = true

    Framework.SetRouting(src, 0)
    Framework.CharacterChosen(src, characterId)

    CoreLog("CHARACTER_SELECT", { playerName = UserName(characterId), playerId = characterId })
    ForgetUser(src)

    -- Personagem sem visual gravado volta para o criador em vez de entrar no
    -- mundo com o ped padrão. Pega quem caiu no meio da criação e também todo
    -- mundo que já existia antes deste resource, já que a tabela nasce vazia.
    if not stored or stored.reset then
        return OpenCreator(src, characterId, true)
    end

    -- O vRP apenas ativa e teleporta o personagem. O restante do fluxo ainda
    -- pertence a este resource: sem abrir o seletor (ou executar o spawn direto
    -- quando ele estiver desativado), a seleção fecha sem nenhum fade-in e o
    -- jogador fica indefinidamente na tela preta.
    if initialSpawn then
        Handlers.requestSpawn(src, characterId)
    else
        TriggerClientEvent("core-character:spawnPlayer", src, LastPosition(characterId))
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.previewCharacter(src, _userId, data)
    local characterId = tonumber(type(data) == "table" and data.characterId)
    if not characterId or not OwnsCharacter(src, characterId) then return end

    local preview = ServerState.Slots[src].Data[characterId]
    if not preview then return end

    TriggerClientEvent("core-character:previewCharacter", src, preview)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTCREATE
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.createCharacter(src)
    local license = Framework.License(src)
    if not license then return end

    if Framework.CountCharacters(license) >= AccountSlots(license) then
        return Notify(src, L("selectSlotMax"), "error")
    end

    CreateCharacter(src)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUYSLOT
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.buySlot(src, userId)
    if not Character.Slots.Buy then return end

    local license = Framework.License(src)
    if not license then return end

    if AccountSlots(license) >= MaxSlots then
        return Notify(src, L("selectSlotMax"), "error")
    end

    local price = ValidateNumber(Character.Slots.BuyPrice, 0, nil, 0)

    if not Framework.Coins.Remove(license, price) then
        return Notify(src, L("selectSlotNoFunds", { price = price }), "error")
    end

    Framework.AddAccountSlot(license)
    Notify(src, L("selectSlotBought"), "success")
    CoreLog("CHARACTER_SLOT", { playerName = UserName(userId), playerId = userId, price = price })

    Wait(100)
    OpenSelection(src)
end
