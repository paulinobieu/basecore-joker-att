-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES INTERNAS
-----------------------------------------------------------------------------------------------------------------------------------------

local function BuildOpenPayload(elevator, playerPos, user_id)
    -- Filtra andares que exigem permissao (floor.permission). Andares sem
    -- floor.permission ficam visiveis pra todo mundo. O andar onde o player
    -- esta agora aparece sempre (origem nunca eh ocultada).
    local visibleFloors = {}
    local originLabel = nil
    local originDist = math.huge
    for _, floor in ipairs(elevator.floors) do
        local dist = #(vector3(playerPos.x, playerPos.y, playerPos.z) - vector3(floor.coords[1], floor.coords[2], floor.coords[3]))
        if dist < originDist then
            originDist  = dist
            originLabel = floor.label
        end
    end

    for _, floor in ipairs(elevator.floors) do
        local allowed = true
        if floor.permission and floor.label ~= originLabel then
            allowed = Functions.hasPermission(user_id, floor.permission)
        end
        if allowed then
            visibleFloors[#visibleFloors + 1] = floor
        end
    end

    local bestFloor, bestDist = nil, math.huge
    for _, floor in ipairs(visibleFloors) do
        local dist = #(vector3(playerPos.x, playerPos.y, playerPos.z) - vector3(floor.coords[1], floor.coords[2], floor.coords[3]))
        if dist < bestDist then
            bestDist  = dist
            bestFloor = floor
        end
    end

    local floors = {}
    for i, floor in ipairs(visibleFloors) do
        floors[#floors + 1] = {
            label    = floor.label,
            index    = i,
            disabled = bestFloor and bestFloor.label == floor.label,
        }
    end

    return {
        currentFloor = bestFloor and bestFloor.label or "Desconhecido",
        floors       = floors,
    }, visibleFloors
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-elevator:server:requestOpen", function(elevatorIndex)
    local source  = source
    local user_id = Functions.getUserId(source)
    if not user_id or not elevatorIndex then return end

    local elevator = Elevator.Locations[elevatorIndex]
    if not elevator then return end

    if elevator.permission and not Functions.hasPermission(user_id, elevator.permission) then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Você não tem permissão para usar este elevador.")
        return
    end

    local playerPos = GetEntityCoords(GetPlayerPed(source))
    local payload, floors = BuildOpenPayload(elevator, playerPos, user_id)

    TriggerClientEvent("core-elevator:client:openPanel", source, payload, floors)
end)
