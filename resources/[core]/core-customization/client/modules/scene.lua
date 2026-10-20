-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreateThread = CreateThread
local DoScreenFadeIn = DoScreenFadeIn
local DoScreenFadeOut = DoScreenFadeOut
local GetActivePlayers = GetActivePlayers
local GetPlayerPed = GetPlayerPed
local InvalidateIdleCam = InvalidateIdleCam
local IsPedInAnyVehicle = IsPedInAnyVehicle
local PlayerPedId = PlayerPedId
local SetEntityNoCollisionEntity = SetEntityNoCollisionEntity
local SetEntityVisible = SetEntityVisible
local Wait = Wait
local ipairs = ipairs
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIDEOTHERPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function HideOtherPlayers()
    local ped = PlayerPedId()

    for _, player in ipairs(GetActivePlayers()) do
        local other = GetPlayerPed(player)

        if ped ~= other then
            SetEntityVisible(other, false, false)
            SetEntityNoCollisionEntity(ped, other, true)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANOPENSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
function CanOpenShop()
    if InClothes or InTattoos then return false end

    if not NUIUnlocked then
        Notify(L("clothesLoading"), "error")
        return false
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        Notify(L("clothesInVehicle"), "error")
        return false
    end

    -- Sem isto a loja abriria de uniforme e cada ajuste dentro dela seria
    -- recusado um por um.
    if ClothesLocked then
        Notify(L("clothesUniform"), "error")
        return false
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTERSCENE
-----------------------------------------------------------------------------------------------------------------------------------------
function EnterScene(fromCreator)
    Framework.Open()

    SetHeadingTarget(Customization.ShopHeading)
    Framework.PlayPose("idle")

    CreateShopCam(0)

    if fromCreator then
        Wait(5000)
        DoScreenFadeIn(2000)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LEAVESCENE
-----------------------------------------------------------------------------------------------------------------------------------------
function LeaveScene(fromCreator)
    if fromCreator then
        DoScreenFadeOut(1000)
        Wait(3000)
    end

    DestroyShopCam()
    Framework.StopAnim()
    Framework.Close()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIDEPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        if InClothes or InTattoos then
            HideOtherPlayers()
            InvalidateIdleCam()
            Wait(1)
        else
            Wait(500)
        end
    end
end)
