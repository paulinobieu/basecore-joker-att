-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local RegisterNetEvent = RegisterNetEvent
local TriggerEvent = TriggerEvent
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local FromCreator = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function RequestClothes(fromCreator)
    if not CanOpenShop() then return end

    FromCreator = fromCreator and true or false

    SendServerAction("requestClothes")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:OPENCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:openClothes", function(payload)
    InClothes = true

    local config = ReadClothes()
    BackupClothes = CopyClothes(CurrentClothes)

    EnterScene(FromCreator)

    OpenScreen("clothes", {
        pedType = PlayerGender(),
        admin = payload and payload.admin or false,
        clothes = config,
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSECLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
local function CloseClothes()
    if not InClothes then return end

    InClothes = false
    BackupClothes = nil

    local wasCreator = FromCreator
    FromCreator = false

    CloseScreen()
    LeaveScene(wasCreator)

    if wasCreator then
        TriggerEvent("core-character:finishedClothing")
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVECLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function SaveClothes()
    if not InClothes then return false end

    SendServerAction("saveClothes", { clothes = CurrentClothes })
    CloseClothes()

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function CancelClothes()
    if not InClothes then return false end

    if BackupClothes then
        CurrentClothes = BackupClothes
        WearClothes(CurrentClothes)
    end

    CloseClothes()

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:OPENCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:openCreator", function()
    RequestClothes(true)
end)
