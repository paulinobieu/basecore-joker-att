-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local RegisterNUICallback = RegisterNUICallback
local SendNUIMessage = SendNUIMessage
local SetNuiFocus = SetNuiFocus
local ipairs = ipairs
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDINTERFACEMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
function SendInterfaceMessage(action, data)
    local payload = { action = action, payload = data }

    if not NUIReady then
        NUIQueue[#NUIQueue + 1] = payload
        return
    end

    SendNUIMessage(payload)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FLUSHQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
function FlushQueue()
    for _, payload in ipairs(NUIQueue) do
        SendNUIMessage(payload)
    end

    NUIQueue = {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENSCREEN
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenScreen(screen, data)
    data = data or {}
    data.screen = screen

    NUIOpen = true

    SetNuiFocus(true, true)
    SendInterfaceMessage("open", data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESCREEN
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseScreen()
    if not NUIOpen then return end

    NUIOpen = false

    SetNuiFocus(false, false)
    SendInterfaceMessage("close", {})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEREADYACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleReadyAction()
    NUIReady = true
    FlushQueue()

    SendInterfaceMessage("setup", {
        colors = BuildThemePalette(Customization.Colors),
        logo = Customization.LogoUrl,
    })

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEUNLOCKACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleUnlockAction()
    NUIUnlocked = true
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEUPDATEPREVIEWACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleUpdatePreviewAction(data)
    if not InClothes then return { ok = false } end

    return { ok = PreviewClothes(data and data.config) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEAPPLYCLOTHESACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleApplyClothesAction()
    return { ok = SaveClothes() }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLECANCELCLOTHESACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleCancelClothesAction()
    return { ok = CancelClothes() }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLETOGGLETATTOOACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleToggleTattooAction(data)
    if not InTattoos or type(data) ~= "table" then return { ok = false } end

    return { ok = ToggleTattooAt(data.zone, data.index) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEAPPLYTATTOOSACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleApplyTattoosAction()
    return { ok = SaveTattoos() }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLECANCELTATTOOSACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleCancelTattoosAction()
    return { ok = CancelTattoos() }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEROTATECHARACTERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleRotateCharacterAction(data)
    RotateCharacter(data and data.side)
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLESETFOVACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleSetFovAction(data)
    SetCamFovTarget(ValidateNumber(data and data.fov, 0, 130, 45))
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLESETHEADINGACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleSetHeadingAction(data)
    SetHeadingTarget(ValidateNumber(data and data.angle, 0, 360, 180))
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEUPDATECAMERAACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleUpdateCameraAction(data)
    if not ShopCam or type(data) ~= "table" then return "ok" end

    local index = data.index

    if index == "fov" then
        SetCamFovTarget(ValidateNumber(data.fov, 0, 130, 45))
    elseif index == "rotation" then
        SetHeadingTarget(ValidateNumber(data.rotation, 0, 360, 180))
    elseif index == "pose" then
        Framework.PlayPose(ValidateNumber(data.pose, 0, 1, 0) == 1 and "t" or "idle")
    elseif index == "cam" then
        local fov = CreateShopCam(ValidateNumber(data.cam, 0, 3, 0))

        if fov then return { fov = fov } end
    end

    return "ok"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUIACTIONHANDLERS
-- Os nomes sao opacos de proposito. O comentario ao lado e a action real,
-- e tem que continuar batendo com src/app/constants/callbacks.ts do frontend.
-----------------------------------------------------------------------------------------------------------------------------------------
NUIActionHandlers = {
    CORENETWORKQAsInReVJgrcfqqm = HandleReadyAction, -- ready
    CORENETWORKIpoxZMPKdqLpgvJZ = HandleUnlockAction, -- unlock

    CORENETWORKbJKoyxfjmygbKpuw = HandleUpdatePreviewAction, -- updatePreview
    CORENETWORKpaAIAGxmQkoZvVuD = HandleApplyClothesAction, -- applyClothes
    CORENETWORKuEMmKdMthLiOEgvi = HandleCancelClothesAction, -- cancelClothes

    CORENETWORKxGXyQSzXBPLnJvAM = HandleToggleTattooAction, -- toggleTattoo
    CORENETWORKbdoiQcyiYQaewpTj = HandleApplyTattoosAction, -- applyTattoos
    CORENETWORKSKKRsLrJcTiRrtvR = HandleCancelTattoosAction, -- cancelTattoos

    CORENETWORKiKxRiHVfrCnDTCwg = HandleRotateCharacterAction, -- rotateCharacter
    CORENETWORKsJFVUKimuLTPEihU = HandleSetFovAction, -- setFov
    CORENETWORKLoaBbVbAweKeQqsL = HandleSetHeadingAction, -- setHeading
    CORENETWORKouvpiZYSNKqWOyLM = HandleUpdateCameraAction, -- updateCamera
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("core-customization", function(data, cb)
    local action = data and data.action

    if not action then
        cb({ ok = false })
        return
    end

    local handler = NUIActionHandlers[action]

    if not handler then
        cb({ ok = false, err = "unknown_action" })
        return
    end

    cb(handler(data))
end)
