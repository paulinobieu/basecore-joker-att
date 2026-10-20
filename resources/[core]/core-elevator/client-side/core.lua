-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local IsMenuOpen    = false
local CurrentFloors = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------

local function SendInterfaceMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function GetClosestFloor(elevator)
    local pos = GetEntityCoords(PlayerPedId())
    local best, bestDist = nil, math.huge

    for _, floor in ipairs(elevator.floors) do
        local dist = #(pos - vector3(floor.coords[1], floor.coords[2], floor.coords[3]))
        if dist < bestDist then
            bestDist = dist
            best     = floor
        end
    end

    return best
end

local function GetClosestElevator()
    local pos = GetEntityCoords(PlayerPedId())
    local bestElevator, bestFloor, bestDist = nil, nil, math.huge

    for _, elevator in pairs(Elevator.Locations) do
        for _, floor in ipairs(elevator.floors) do
            local dist = #(pos - vector3(floor.coords[1], floor.coords[2], floor.coords[3]))
            if dist < bestDist then
                bestDist     = dist
                bestElevator = elevator
                bestFloor    = floor
            end
        end
    end

    return bestElevator, bestFloor
end

local function TeleportToFloor(coords)
    local ped = PlayerPedId()

    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do Wait(0) end

    FreezeEntityPosition(ped, true)
    Wait(1000)

    SetEntityCoords(ped, coords[1], coords[2], coords[3] - 1, false, false, false, false)
    if coords[4] then SetEntityHeading(ped, coords[4]) end

    TriggerEvent("sounds:source", "elevator", 0.5)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(ped, false)
end

local function ClosePanel()
    if not IsMenuOpen then return end
    SetNuiFocus(false, false)
    SendInterfaceMessage("setVisible", false)
    IsMenuOpen    = false
    CurrentFloors = {}
end

local function RequestOpen(elevatorIndex)
    if IsMenuOpen then return end
    TriggerServerEvent("core-elevator:server:requestOpen", elevatorIndex)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("core-elevator", function(data, cb)
    if data.action == "close" then
        ClosePanel()
    elseif data.action == "selectFloor" then
        local floor = CurrentFloors[data.floorIndex]
        if floor then
            ClosePanel()
            TeleportToFloor(floor.coords)
        end
    end

    cb("ok")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERAÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------

local function RegisterSleeplessInteractions()
    local settings = Elevator.Interaction.Sleepless or {}

    if GetResourceState("sleepless_interact") ~= "started" or not exports.sleepless_interact then
        return
    end

    for idx, elevator in ipairs(Elevator.Locations) do
        for _, floor in ipairs(elevator.floors) do
            exports.sleepless_interact:addCoords(
                vec3(floor.coords[1], floor.coords[2], floor.coords[3]),
                {
                    {
                        label    = settings.Label or "Abrir Elevador",
                        icon     = settings.Icon or "elevator",
                        distance = settings.Distance or 1.5,
                        onSelect = function() RequestOpen(idx) end,
                    },
                }
            )
        end
    end
end

local function RegisterInteractions()
    if Elevator.Interaction.System == "sleepless" then
        RegisterSleeplessInteractions()
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    while not LocalPlayer.state.Active do
        Wait(1000)
    end

    RegisterInteractions()
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS DO SERVIDOR
-----------------------------------------------------------------------------------------------------------------------------------------

local function ResolveThemeColor()
    if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
        return Theme.main
    end
    return Elevator.ThemeColor or "#dc1553"
end

RegisterNetEvent("core-elevator:client:openPanel", function(elevatorData, floors)
    if IsMenuOpen then return end

    IsMenuOpen    = true
    CurrentFloors = floors

    SetNuiFocus(true, true)
    SendInterfaceMessage("setThemeColor", ResolveThemeColor())
    SendInterfaceMessage("openElevator", elevatorData)
end)

RegisterNetEvent("core-elevator:teleport", function(coords)
    TeleportToFloor(coords)
end)

RegisterNetEvent("core-elevator:showMenu", function()
    local elevator, _ = GetClosestElevator()
    if not elevator then return end

    for idx, loc in ipairs(Elevator.Locations) do
        if loc == elevator then
            RequestOpen(idx)
            return
        end
    end
end)
