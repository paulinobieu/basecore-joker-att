-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local PanelOpen = false
local PanelData = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENPANEL
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenPanel(Data)
    if PanelOpen or type(Data) ~= "table" then
        return
    end

    PanelOpen = true
    PanelData = Data

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "setVisible", payload = true })

    Framework.Open()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEPANEL
-----------------------------------------------------------------------------------------------------------------------------------------
function ClosePanel()
    if not PanelOpen then
        return
    end

    PanelOpen = false
    PanelData = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "setVisible", payload = false })

    Framework.Close()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOOSTER:READY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("booster:ready", function(_, Callback)
    Callback({ colors = Booster.Colors })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOOSTER:GETDATA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("booster:getData", function(_, Callback)
    if not PanelOpen or not PanelData then
        Callback(false)
        return
    end

    local Interface = Booster.Language.Interface

    PanelData.language = {
        title            = Interface.Title,
        subtitle         = Interface.Subtitle,
        close            = Interface.Close,
        claim            = Interface.Claim,
        claimed          = Interface.Claimed,
        unavailable      = Interface.Unavailable,
        collected        = Interface.Collected,
        rewardsLabel     = Interface.RewardsLabel,
        viewAll          = Interface.ViewAll,
        linked           = Interface.Linked,
        claimedMessage   = Interface.ClaimedMessage,
        availableMessage = Interface.AvailableMessage,
        inactiveMessage  = Interface.InactiveMessage,
        empty            = Interface.Empty,
    }

    Callback(PanelData)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOOSTER:CLAIM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("booster:claim", function(Data, Callback)
    if not PanelOpen or type(Data) ~= "table" or type(Data.id) ~= "string" then
        Callback({ success = false, message = Booster.Language.Failed })
        return
    end

    local Result = vSERVER.Claim(Data.id)
    if type(Result) ~= "table" then
        Callback({ success = false, message = Booster.Language.Failed })
        return
    end

    if PanelData and type(Result.benefits) == "table" then
        PanelData.benefits = Result.benefits
    end

    Callback(Result)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOOSTER:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("booster:close", function(_, Callback)
    ClosePanel()
    Callback(true)
end)
