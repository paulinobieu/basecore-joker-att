-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local RegisterNUICallback = RegisterNUICallback
local RegisterNetEvent = RegisterNetEvent
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

    if not NUIOpen then Framework.Open() end

    NUIOpen = true
    CurrentScreen = screen

    SetNuiFocus(true, true)
    SendInterfaceMessage("open", data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESCREEN
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseScreen()
    if not NUIOpen then return end

    NUIOpen = false
    CurrentScreen = nil

    SetNuiFocus(false, false)
    SendInterfaceMessage("close", {})
    Framework.Close()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORWARDSERVERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function ForwardServerAction(action, data)
    SendServerAction(action, data)
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEREADYACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleReadyAction()
    NUIReady = true
    FlushQueue()

    SendInterfaceMessage("setup", {
        colors = BuildThemePalette(Character.Colors),
        logo = Character.LogoUrl,
        paths = { face = Character.Images.Faces },
        config = {
            buyPerson = Character.Slots.Buy,
            buyPersonPrice = Character.Slots.BuyPrice,
            eyesBarber = Character.Features.EyesOnBarber,
        },
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
-- HANDLECLOSEACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleCloseAction()
    if InBarber then
        SendServerAction("cancelBarber")
        CloseBarber()
        Framework.ResetClothes()
    end

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLESETGENDERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleSetGenderAction(data)
    local gender = data and data.gender

    if gender ~= "mp_m_freemode_01" and gender ~= "mp_f_freemode_01" then
        return { ok = false }
    end

    Framework.ApplySkin(gender)
    ApplyAppearance(CurrentAppearance)
    Framework.ApplyClothes(Appearance.Clothes.Creator[GenderKey()])
    PlayPose("idle")

    SendServerAction("setGender", { gender = gender })

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEUPDATESKINACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleUpdateSkinAction(data)
    if not MergeAppearance(data and data.config) then return { ok = false } end

    ApplySkin(CurrentAppearance)
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEUPDATEFACEACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleUpdateFaceAction(data)
    if not MergeAppearance(data and data.config) then return { ok = false } end

    ApplyFace(CurrentAppearance)
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEUPDATEHEADACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleUpdateHeadAction(data)
    if not MergeAppearance(data and data.config) then return { ok = false } end

    ApplyHead(CurrentAppearance)
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEFINISHCHARACTERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleFinishCharacterAction(data)
    if not InCreator or type(data) ~= "table" then return { ok = false } end

    SendServerAction("finishCharacter", {
        name = data.name,
        lastname = data.lastname,
        gender = data.gender,
        appearance = CurrentAppearance,
    })

    return { ok = true }
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
    if not CreatorCam or type(data) ~= "table" then return "ok" end

    local index = data.index

    if index == "fov" then
        SetCamFovTarget(ValidateNumber(data.fov, 0, 130, 45))
    elseif index == "rotation" then
        SetHeadingTarget(ValidateNumber(data.rotation, 0, 360, 180))
    elseif index == "pose" then
        PlayPose(ValidateNumber(data.pose, 0, 1, 0) == 1 and "t" or "idle")
    elseif index == "cam" then
        local preset = ValidateNumber(data.cam, 0, 3, 1)
        local fov = CreateCreatorCam(preset)

        if fov then return { fov = fov } end
    end

    return "ok"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLESELECTCHARACTERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleSelectCharacterAction(data)
    if not InSelect then return { ok = false } end

    CloseSelect()
    SendServerAction("selectCharacter", data)

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLECREATECHARACTERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleCreateCharacterAction()
    if not InSelect then return { ok = false } end

    CloseSelect()
    SendServerAction("createCharacter")

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEPREVIEWLOCATIONACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandlePreviewLocationAction(data)
    if not InSpawn then return { ok = false } end

    PreviewLocation(ValidateNumber(data and data.hash, 1, nil, 1))
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLECONFIRMSPAWNACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleConfirmSpawnAction(data)
    if not InSpawn then return { ok = false } end

    ConfirmSpawn(ValidateNumber(data and data.index, 0, nil, 0) + 1)
    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLESAVEBARBERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleSaveBarberAction()
    if not InBarber then return { ok = false } end

    SendServerAction("saveBarber", { appearance = CurrentAppearance })
    CloseBarber()
    Framework.ResetClothes()

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLECANCELBARBERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleCancelBarberAction()
    if not InBarber then return { ok = false } end

    SendServerAction("cancelBarber")
    CloseBarber()
    Framework.ResetClothes()

    return { ok = true }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUIACTIONHANDLERS
-- Os nomes sao opacos de proposito. O comentario ao lado e a action real,
-- e tem que continuar batendo com src/app/constants/callbacks.ts do frontend.
-----------------------------------------------------------------------------------------------------------------------------------------
NUIActionHandlers = {
    CORENETWORKoRLfyvCbHLqbjbFy = HandleReadyAction, -- ready
    CORENETWORKWArMSkgykbQJsvUB = HandleUnlockAction, -- unlock
    CORENETWORKLhTUvuyoojxOfJBz = HandleCloseAction, -- close

    CORENETWORKgEygdlsCPPKJRPyy = HandleSetGenderAction, -- setGender
    CORENETWORKPFsWRjyAweDMshLi = HandleUpdateSkinAction, -- updateSkin
    CORENETWORKTwvzLlMMvibTqLod = HandleUpdateFaceAction, -- updateFace
    CORENETWORKYSkahMLbVuFLuSGD = HandleUpdateHeadAction, -- updateHead
    CORENETWORKtxxuzWaulrMckKrs = HandleFinishCharacterAction, -- finishCharacter

    CORENETWORKNdTjvxtYZMgmquRC = HandleRotateCharacterAction, -- rotateCharacter
    CORENETWORKjIZQuHgSRBaWjpuA = HandleSetFovAction, -- setFov
    CORENETWORKYkPJVZTywmIswyHT = HandleSetHeadingAction, -- setHeading
    CORENETWORKzZOhbRXmWximUPPA = HandleUpdateCameraAction, -- updateCamera

    CORENETWORKUGibAGndpnbbQWZm = HandleSelectCharacterAction, -- selectCharacter
    CORENETWORKwfbrDykAMwfkGzMv = HandleCreateCharacterAction, -- createCharacter
    CORENETWORKMlwAtFhQFCynFWKt = function(data) -- previewCharacter
        return ForwardServerAction("previewCharacter", data)
    end,
    CORENETWORKuDutwNkMpVgQSPGm = function(data) -- buySlot
        return ForwardServerAction("buySlot", data)
    end,

    CORENETWORKlKycstGNoeuARLJU = HandlePreviewLocationAction, -- previewLocation
    CORENETWORKMxBnUvRHLnxIHpUE = HandleConfirmSpawnAction, -- confirmSpawn

    CORENETWORKzMxkJtvBcjVFboJR = HandleSaveBarberAction, -- saveBarber
    CORENETWORKYJHXyabWWBJmjgJo = HandleCancelBarberAction, -- cancelBarber
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("core-character", function(data, cb)
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
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:NUIMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:nuiMessage", function(action, data)
    if action == "open" and type(data) == "table" and data.screen then
        if data.screen == "spawn" and (InBarber or InCreator or InSelect) then return end
        if data.screen == "barber" and (InSpawn or InCreator or InSelect) then return end

        return OpenScreen(data.screen, data)
    end

    SendInterfaceMessage(action, data)
end)
