-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("core-esc")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local isEscMenuOpen = false
local isNativeMenuOpen = false
local notifyId = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
local function Notify(notifyType,message,duration)
    notifyId = notifyId + 1
    SendNUIMessage({
        action = "sendNotify",
        payload = {
            type = notifyType or "info",
            desc = message or "",
            time = duration or 5000,
            id = notifyId,
        },
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OTIMIZATION ( /fps on | /fps off )
-----------------------------------------------------------------------------------------------------------------------------------------
local function LoadOtimization()
    return GetResourceKvpString("otimization") == "true"
end

local Otimization = LoadOtimization()

CreateThread(function()
    Wait(1000)
    ExecuteCommand(Otimization and Config.Commands.fpsOn or Config.Commands.fpsOff)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
function openEscMenu()
    if isEscMenuOpen or isNativeMenuOpen then return end
    isEscMenuOpen = true

    SendNUIMessage({ action = "setVisible", payload = true })
    SetNuiFocus(true,true)
    SetPauseMenuActive(false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
function closeEscMenu()
    if not isEscMenuOpen then return end
    isEscMenuOpen = false

    SendNUIMessage({ action = "setVisible", payload = false })
    SetNuiFocus(false,false)
end

AddEventHandler("esc:close",closeEscMenu)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NATIVEMENU ( mapa / configurações do GTA )
-----------------------------------------------------------------------------------------------------------------------------------------
local function openNativeMenu(menuHash)
    closeEscMenu()
    CreateThread(function()
        Wait(100)
        isNativeMenuOpen = true
        TriggerScreenblurFadeOut(200)
        ActivateFrontendMenu(menuHash,false,-1)

        local timeout = GetGameTimer() + 2000
        while not IsPauseMenuActive() and GetGameTimer() < timeout do
            Wait(0)
        end

        while isNativeMenuOpen do
            Wait(100)
            if not IsPauseMenuActive() then
                isNativeMenuOpen = false
                break
            end
        end
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIDEFRAME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("hideFrame",function(_,cb)
    closeEscMenu()
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETDATA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:esc:data",function(_,cb)
    local data = vSERVER.EscData() or {}
    data.logo = Config.UI.logo
    data.links = Config.Links
    data.config = {}
    data.otimization = Otimization
    data.battlepass = data.battlepass or Config.BattlePass
    cb(data)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETCOLORS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("getColors",function(_,cb)
    cb(Config.Theme)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:toggleOtimization",function(_,cb)
    Otimization = not Otimization
    ExecuteCommand(Otimization and Config.Commands.fpsOn or Config.Commands.fpsOff)
    SetResourceKvp("otimization",tostring(Otimization))
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONSKINS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:openWeaponSkins",function(_,cb)
    closeEscMenu()
    ExecuteCommand(Config.Commands.skins)
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:openMap",function(_,cb)
    openNativeMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"))
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG ( configurações nativas do GTA )
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:openConfig",function(_,cb)
    openNativeMenu(-1031775802)
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPCENTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:openHelpCenter",function(_,cb)
    closeEscMenu()
    ExecuteCommand("help")
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:openSettings",function(_,cb)
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETCONFIG ( sem esc configs )
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:setConfig",function(_,cb)
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EM BREVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:esc:openBattlePass",function(_,cb)
    Notify("info","Em breve.",5000)
    cb(true)
end)

RegisterNUICallback("post:esc:openMisteryBoxs",function(_,cb)
    Notify("info","Em breve.",5000)
    cb(true)
end)

RegisterNUICallback("post:esc:openUltraBoost",function(_,cb)
    Notify("info","Em breve.",5000)
    cb(true)
end)

RegisterNUICallback("post:esc:openDailyReward",function(_,cb)
    Notify("info","Em breve.",5000)
    cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPDATA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:shop:data",function(_,cb)
    cb(vSERVER.ShopData())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPBUY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:shop:buy",function(payload,cb)
    cb(vSERVER.ShopBuy(payload) == true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY ( servidor -> web )
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-esc:notify",function(notifyType,message,duration)
    Notify(notifyType,message,duration)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND / KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Config.Controls.commands.esc,function()
    if isNativeMenuOpen then return end
    if isEscMenuOpen then
        closeEscMenu()
    else
        openEscMenu()
    end
end,false)

CreateThread(function()
    RegisterKeyMapping(
        Config.Controls.commands.esc,
        Config.Controls.descriptions.esc,
        "keyboard",
        Config.Controls.defaultKey
    )
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAP ( tecla P -> mapa nativo do GTA )
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Config.Controls.commands.map,function()
    if isEscMenuOpen or isNativeMenuOpen then return end
    openNativeMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"))
end,false)

CreateThread(function()
    RegisterKeyMapping(
        Config.Controls.commands.map,
        Config.Controls.descriptions.map,
        "keyboard",
        Config.Controls.mapKey
    )
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOCK NATIVE PAUSE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)
        if not isNativeMenuOpen then
            if isEscMenuOpen then
                DisableControlAction(0,199,true)
                DisableControlAction(0,200,true)
                DisableControlAction(0,322,true)
            end

            SetPauseMenuActive(false)
        end
    end
end)
