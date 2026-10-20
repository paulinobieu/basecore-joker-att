-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local ClearAllPedProps = ClearAllPedProps
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local TriggerEvent = TriggerEvent
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ShopCatalog = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLETATTOOAT
-----------------------------------------------------------------------------------------------------------------------------------------
function ToggleTattooAt(zone, index)
    local list = ShopCatalog[zone]
    local entry = list and list[ValidateNumber(index, 0, nil, -1) + 1]

    -- Zona ou índice fora do catálogo que a interface recebeu: sem aviso, o
    -- clique simplesmente não faria nada.
    if not entry then
        Notify(L("tattooInvalid"), "error")
        return false
    end

    ToggleTattoo(entry.name, entry.part)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function RequestTattoos()
    if not CanOpenShop() then return end

    SendServerAction("requestTattoos")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:OPENTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:openTattoos", function(payload)
    if type(payload) ~= "table" then return end

    InTattoos = true
    ShopCatalog = payload.available or {}
    BackupTattoos = CopyTattoos(CurrentTattoos)

    local gender = PlayerGender()
    TriggerEvent("core-customization:applyTemporary", Tattoos.Outfit[gender])
    ClearAllPedProps(PlayerPedId())

    EnterScene(false)

    OpenScreen("tattoos", {
        pedType = gender,
        admin = payload.admin or false,
        tattoos = {
            available = ShopCatalog,
            active = payload.active or {},
        },
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSETATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseTattoos()
    if not InTattoos then return end

    InTattoos = false

    TriggerEvent("core-customization:returnTemporary")

    CloseScreen()
    LeaveScene(false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVETATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function SaveTattoos()
    if not InTattoos then return false end

    BackupTattoos = nil

    SendServerAction("saveTattoos", { tattoos = CurrentTattoos })
    CloseTattoos()

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function CancelTattoos()
    if not InTattoos then return false end

    TriggerEvent("core-customization:returnTattoos")
    CloseTattoos()

    return true
end
