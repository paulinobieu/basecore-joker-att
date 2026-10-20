-- Global variables (assuming these are accessed from other files)
local IS_PLAYER_SITTING = false
local IS_PLAYER_IN_STAND_UP_COOLDOWN = false
local CURRENTLY_SEATED_ENTITY = nil

-- Checks if the player can sit again (not sitting and not in cooldown)
function CanSitAgain()
    return not IS_PLAYER_SITTING and not IS_PLAYER_IN_STAND_UP_COOLDOWN
end

-- Performs a raycast from given coordinates in a specified direction
function RaycastFromCoords(collisionFlags, startCoords, direction, maxDistance, ignoreEntity, intersectionType)
    local endCoords = startCoords + (direction * maxDistance)
    local rayHandle = StartShapeTestLosProbe(startCoords.x, startCoords.y, startCoords.z, endCoords.x, endCoords.y, endCoords.z, collisionFlags, ignoreEntity, intersectionType)

    local result, hit, hitCoords, surfaceNormal, materialHash, hitEntity = 1, 0, 0, 0, 0, 0

    while result == 1 do
        Wait(0)
        result, hit, hitCoords, surfaceNormal, materialHash, hitEntity = GetShapeTestResultIncludingMaterial(rayHandle)
        if result ~= 1 then
            return hit, hitEntity, hitCoords, surfaceNormal, materialHash
        end
    end
end

-- Draws 2D help text on the screen
function DrawText2D(message, loop)
    AddTextEntry(GetCurrentResourceName(), message)
    BeginTextCommandDisplayHelp(GetCurrentResourceName(), 0, 0, loop, -1)
    EndTextCommandDisplayHelp(0, 0, loop, -1)
end

-- Analyzes Z-coordinate differences to determine if an area resembles stairs
local function checkStairs(zCoords)
    local minDifferenceThreshold = 0.1
    local medianTolerance = 0.5 -- How close to the median a difference must be
    local percentageMatchThreshold = 0.5 -- Percentage of differences within tolerance for it to be considered stairs

    local validDifferences = {}
    for _, z in ipairs(zCoords) do
        if z ~= 0.0 then
            table.insert(validDifferences, z)
        end
    end

    if #validDifferences == 0 then
        return false
    end

    table.sort(validDifferences)

    local differences = {}
    for i = 1, #validDifferences - 1 do
        table.insert(differences, validDifferences[i+1] - validDifferences[i])
    end

    local filteredDifferences = {}
    for _, diff in ipairs(differences) do
        if minDifferenceThreshold < diff then
            table.insert(filteredDifferences, diff)
        end
    end

    if #filteredDifferences == 0 then
        return false
    end

    table.sort(filteredDifferences)

    local medianDifference = nil
    if #filteredDifferences % 2 == 0 then
        local middle1 = filteredDifferences[#filteredDifferences // 2]
        local middle2 = filteredDifferences[(#filteredDifferences // 2) + 1]
        medianDifference = (middle1 + middle2) / 2
    else
        medianDifference = filteredDifferences[math.ceil(#filteredDifferences / 2)]
    end

    local matches = 0
    for _, diff in ipairs(differences) do
        local absDiff = math.abs(diff - medianDifference)
        local toleranceRange = medianDifference * medianTolerance
        if absDiff < toleranceRange then
            matches = matches + 1
        end
    end

    return (matches / #differences) >= percentageMatchThreshold
end

-- Finds the closest ped to a given coordinate within a certain distance
local function findClosestPed(coords)
    local playerPed = PlayerPedId()
    local peds = GetGamePool("CPed")
    local minDistance = math.huge
    local closestPed = nil

    for i = 0, #peds do
        local ped = peds[i]
        local pedCoords = GetEntityCoords(ped)
        local distance = #(pedCoords - coords)

        if distance <= Config.DistanceCheckPed and distance < minDistance then
            minDistance = distance
            closestPed = ped
        end
    end

    -- Don't return the player ped as the closest ped to themselves
    if closestPed == playerPed then
        closestPed = nil
    end

    return closestPed
end

-- Checks if the player is pressing a key to get up from sitting
local function isGetUpKeyHeld()
    if Config.UseMoveKeyToGetUp then
        -- Check for movement keys (W, A, S, D controls)
        local movementKeys = {32, 33, 34, 35} -- Control IDs for W, S, A, D
        for _, key in pairs(movementKeys) do
            if IsControlPressed(0, key) then
                return true
            end
        end
    else
        -- Check for a specific configured key
        if IsDisabledControlPressed(0, Config.GetUpFromSitKey) then
            return true
        end
    end
    return false
end

-- Manages the sitting task for the player
function PlaySittingScenario(targetCoords, heading, scenarioName, isNetworked, scenarioDisplayName, targetEntity)
    -- Check if the scenario is enabled in the config
    if not Config.EnabledList[scenarioDisplayName] then
        return
    end

    -- Debugging information
    if Config.Debug then
        print(string.format("%s " .. Locale[Config.Language].DebugDetectionAndScenario, Locale[Config.Language].DebugName, scenarioDisplayName, scenarioName))
        print(string.format("%s " .. Locale[Config.Language].DebugCoordsAndHeading, Locale[Config.Language].DebugName, targetCoords.x, targetCoords.y, targetCoords.z, heading))
    end

    -- If targetCoords are all zeros, something is wrong, so return
    if targetCoords == vector3(0.0, 0.0, 0.0) then
        return
    end

    local playerPed = PlayerPedId()
    local initialPlayerHealth = GetEntityHealth(playerPed)

    -- Adjust Z-coordinate based on ped height
    local adjustedZ = targetCoords.z + HeightAdjustment(playerPed)
    targetCoords = vector3(targetCoords.x, targetCoords.y, adjustedZ)

    -- Check for nearby peds to prevent sitting too close
    local nearbyPed = findClosestPed(targetCoords)
    if nearbyPed then
        SittingNotification(Locale[Config.Language].TooCloseFromAnotherPed, 2)
        return
    end

    CURRENTLY_SEATED_ENTITY = targetEntity
    TaskStartScenarioAtPosition(playerPed, scenarioName, targetCoords, heading, -1, isNetworked, true)
    IS_PLAYER_SITTING = true

    -- Create a thread to disable camera collision with the seated entity
    CreateThread(function()
        while CURRENTLY_SEATED_ENTITY do
            if not DoesEntityExist(CURRENTLY_SEATED_ENTITY) then
                break
            end
            DisableCamCollisionForEntity(CURRENTLY_SEATED_ENTITY)
            Wait(0)
        end
    end)

    -- Loop while player is sitting
    while true do
        Wait(50)

        -- Display "get up" instruction if not using movement keys
        if not Config.UseMoveKeyToGetUp then
            DisableControlAction(0, Config.GetUpFromSitKey, true)
            SittingNotification(string.format(Locale[Config.Language].GetUpFromKey, Config.GetUpFromSitKeyName), 0)
        end

        local shouldStandUp = false

        -- Check if get-up key is pressed
        if isGetUpKeyHeld() then
            shouldStandUp = true
        end

        -- Check for health change if enabled
        if Config.GetUpChecks.Health then
            if initialPlayerHealth > GetEntityHealth(playerPed) then
                shouldStandUp = true
            end
        end

        -- Check for ragdoll if enabled
        if Config.GetUpChecks.Ragdoll then
            if IsPedRagdoll(playerPed) then
                shouldStandUp = true
            end
        end

        -- Force stand up if ped is no longer using the scenario
        if not IsPedUsingScenario(playerPed, scenarioName) then
            shouldStandUp = true
        end

        if shouldStandUp then
            IS_PLAYER_IN_STAND_UP_COOLDOWN = true

            -- Log reason for standing up
            if Config.Debug then
                if Config.GetUpChecks.Health and initialPlayerHealth > GetEntityHealth(playerPed) then
                    print(string.format("%s " .. Locale[Config.Language].StandUpDamage, Locale[Config.Language].DebugName))
                elseif Config.GetUpChecks.Ragdoll and IsPedRagdoll(playerPed) then
                    print(string.format("%s " .. Locale[Config.Language].StandUpRagdoll, Locale[Config.Language].DebugName))
                elseif not IsPedUsingScenario(playerPed, scenarioName) then
                    print(string.format("%s " .. Locale[Config.Language].StandUpUnkownReason, Locale[Config.Language].DebugName))
                else -- Must be the get up key
                    print(string.format("%s " .. Locale[Config.Language].StandUpGetUpKey, Locale[Config.Language].DebugName))
                end
            end

            -- Clear ped tasks based on situation
            if Config.GetUpChecks.Ragdoll and IsPedRagdoll(playerPed) then
                ClearPedTasks(playerPed)
            elseif IsPedUsingScenario(playerPed, scenarioName) then
                ClearPedTasks(playerPed)
            else
                ClearPedTasksImmediately(playerPed)
            end

            IS_PLAYER_SITTING = false
            Wait(100) -- Small delay before cooldown

            -- Start cooldown for sitting again
            CreateThread(function()
                local startTime = GetGameTimer()
                local cooldownDuration = 1000 -- 1 second cooldown
                while GetGameTimer() - startTime < cooldownDuration do
                    Wait(100)
                end
                IS_PLAYER_IN_STAND_UP_COOLDOWN = false
                if Config.Debug then
                    print(string.format(Locale[Config.Language].DebugName .. " %s", "Player can sit again"))
                end
                Wait(500)
                CURRENTLY_SEATED_ENTITY = nil
            end)
            break -- Exit the sitting loop
        end
    end
end

-- Checks if an archetype name contains "chair" or "chr"
local function isChairArchetype(archetypeName)
    local chairKeywords = {"chair", "chr"}
    for _, keyword in ipairs(chairKeywords) do
        if string.find(archetypeName, keyword) then
            return true
        end
    end
    return false
end

-- Key mapping and commands for sitting functionality
if Config.CommandUseKey then
    RegisterKeyMapping("+" .. Config.CommandName, Config.CommandTitle, Config.CommandInputMapper, Config.CommandInputParameter)

    RegisterCommand("+" .. Config.CommandName, function(source, args)
        TriggerEvent("otk_sitting:sitAnywhere", args, "pressed")
    end)

    RegisterCommand("-" .. Config.CommandName, function(source, args)
        -- No action on key release for now
    end)
end

RegisterCommand(Config.CommandName, function(source, args)
    if CanSitAgain() then
        TriggerEvent("otk_sitting:sitAnywhere", args, "command")
    elseif IS_PLAYER_IN_STAND_UP_COOLDOWN then
        SittingNotification(Locale[Config.Language].WaitForStandUp, 2)
    end
end)

-- Event handler for "otk_sitting:sitAnywhere"
AddEventHandler("otk_sitting:sitAnywhere", function(args, triggerType)
    local playerPed = PlayerPedId()

    -- Prevent sitting if triggered by key press but CommandUseKey is false
    if not Config.CommandUseKey and triggerType == "pressed" then
        return
    end

    -- Only allow sitting if player is on foot and can sit again
    if not IsPedOnFoot(playerPed) or not CanSitAgain() then
        return
    end

    -- Check if global CanSit function allows sitting (assuming CanSit is defined elsewhere)
    if not CanSit(playerPed) then
        return
    end

    local playerCoords = GetEntityCoords(playerPed)
    local playerForwardVector = GetEntityForwardVector(playerPed)

    -- Raycast collision flags
    local collisionFlags = 0
    if Config.DetectWorld then
        collisionFlags = collisionFlags | 1 -- F_SHAPETEST_COLLECT_GRAPPLING
    end
    if Config.DetectProps then
        collisionFlags = collisionFlags | 16 -- F_SHAPETEST_COLLECT_VEHICLES
    end
    if Config.DetectVehicles then
        collisionFlags = collisionFlags | 2 -- F_SHAPETEST_COLLECT_PEDS
    end

    local firstArg = args[1] or "nil" -- Default to "nil" if no argument is provided

    -- Initial raycast points and variables
    local initialGroundCheckStart = vector3(playerCoords.x, playerCoords.y, playerCoords.z - 0.8)
    local initialForwardCheckStart = vector3(playerCoords.x, playerCoords.y, playerCoords.z - 0.4)

    local hitEntityForward = nil
    local hitCoordsForward = nil
    local initialHitResult = 0

    local rayGroundResult, rayGroundHitEntity, rayGroundHitCoords = RaycastFromCoords(collisionFlags, vector3(initialGroundCheckStart.x, initialGroundCheckStart.y, playerCoords.z + Config.MaxHeight), playerForwardVector, Config.Distance)
    if rayGroundResult ~= 0 then
        initialHitResult = rayGroundResult
        hitCoordsForward = rayGroundHitCoords
    end

    local rayForwardResult, rayForwardHitEntity, rayForwardHitCoords = RaycastFromCoords(collisionFlags, initialGroundCheckStart, playerForwardVector, Config.Distance)
    if rayForwardResult ~= 0 then
        hitEntityForward = rayForwardHitEntity
        if initialHitResult == 0 then -- Prioritize the higher hit if no hit was found from above
            hitCoordsForward = rayForwardHitCoords
        end
    end

    -- Raycasts for stairs detection
    local stairsRayStart = initialForwardCheckStart + (playerForwardVector * Config.StairsDistance)
    local stairsRayDirection = vector3(0.0, 0.0, -1.0) -- Downwards
    local _, _, stairsHit1 = RaycastFromCoords(collisionFlags, stairsRayStart, stairsRayDirection, 0.5)

    local stairsRayStart2 = initialForwardCheckStart + (playerForwardVector * (Config.StairsDistance + 0.2))
    local _, _, stairsHit2 = RaycastFromCoords(collisionFlags, stairsRayStart2, stairsRayDirection, 0.5)

    local stairsRayStart3 = initialForwardCheckStart + (playerForwardVector * (Config.StairsDistance - 0.2))
    local _, _, stairsHit3 = RaycastFromCoords(collisionFlags, stairsRayStart3, stairsRayDirection, 0.5)

    local stairsRayStart4 = initialForwardCheckStart + (playerForwardVector * (Config.StairsDistance - 0.4))
    local _, _, stairsHit4 = RaycastFromCoords(collisionFlags, stairsRayStart4, stairsRayDirection, 0.5)

    local stairsRayStart5 = initialForwardCheckStart + (playerForwardVector * (Config.StairsDistance - 0.6))
    local _, _, stairsHit5 = RaycastFromCoords(collisionFlags, stairsRayStart5, stairsRayDirection, 0.5)


    local currentGroundCheckStart = vector3(initialGroundCheckStart.x, initialGroundCheckStart.y, playerCoords.z + Config.MaxHeight)
    local foundValidSitSpot = false
    local retryCount = 0
    local potentialSitEntity = nil

    -- Iterate upwards to find a valid sitting position
    while currentGroundCheckStart.z < (playerCoords.z + Config.MaxHeight) and not foundValidSitSpot do
        if retryCount >= Config.MaxRetryBeforeSeated then
            break
        end

        local iterRayResult, iterHitEntity, iterHitCoords = RaycastFromCoords(collisionFlags, currentGroundCheckStart, playerForwardVector, Config.Distance)

        if iterRayResult ~= 0 then
            hitCoordsForward = iterHitCoords
            potentialSitEntity = iterHitEntity
        end

        if iterRayResult == 0 and not hitCoordsForward then
            retryCount = retryCount + 1
        else
            if hitCoordsForward ~= vector3(0,0,0) then
                foundValidSitSpot = true
            else
                break
            end
        end

        currentGroundCheckStart = vector3(currentGroundCheckStart.x, currentGroundCheckStart.y, currentGroundCheckStart.z + Config.Precision)
    end

    local groundScanDistance = Config.GroundDistance
    local foundGroundSitSpot = nil
    local initialGroundHitDistance = 0
    local groundHitEntity = nil

    local raycastResultLower, lowerHitEntity, lowerHitCoords = RaycastFromCoords(collisionFlags, vector3(playerCoords.x, playerCoords.y, playerCoords.z - 0.8) + (playerForwardVector * groundScanDistance), vector3(0.0, 0.0, -1.0), 0.4)

    -- Iterate downwards to find a valid ground sitting position
    while rayGroundResult == 0 and groundScanDistance >= 0 and not hitCoordsForward and not foundGroundSitSpot do
        local iterLowerRayResult, iterLowerHitEntity, iterLowerHitCoords = RaycastFromCoords(collisionFlags, vector3(playerCoords.x, playerCoords.y, playerCoords.z - 0.8) + (playerForwardVector * groundScanDistance), vector3(0.0, 0.0, -1.0), 0.4)

        if iterLowerRayResult ~= 0 then
            groundHitEntity = iterLowerHitEntity
            foundGroundSitSpot = iterLowerHitCoords
            if initialGroundHitDistance == 0 then
                initialGroundHitDistance = groundScanDistance
            end
        end

        if initialGroundHitDistance == Config.GroundDistance then
            break
        end
        groundScanDistance = groundScanDistance - Config.Precision
    end

    -- Determine which scenario to use based on raycast results
    if checkStairs({stairsHit1.z, stairsHit2.z, stairsHit3.z, stairsHit4.z, stairsHit5.z}) then
        PlaySittingScenario(stairsHit3, GetEntityHeading(playerPed) - 180, "WORLD_HUMAN_SEAT_STEPS", false, "Stairs", nil)
    elseif hitCoordsForward then
        -- Sitting on a chair/prop or general sitting
        local sitCoords = nil
        local sitHeading = GetEntityHeading(playerPed) - 180
        local scenario = "PROP_HUMAN_SEAT_CHAIR" -- Default for props/chairs
        local displayName = "Sit"
        local target = nil

        local archetypeName = nil
        if potentialSitEntity then
            archetypeName = GetEntityArchetypeName(potentialSitEntity)
        end

        if hitCoordsForward.z < (playerCoords.z + Config.MaxHeight - Config.Precision) then
            if retryCount > 2 then -- If we had to retry, means it was higher
                if potentialSitEntity and isChairArchetype(archetypeName) then
                    sitCoords = vector3(hitEntityForward.x, hitEntityForward.y, hitCoordsForward.z + 0.06)
                else
                    sitCoords = vector3(hitCoordsForward.x, hitCoordsForward.y, hitCoordsForward.z + 0.06) + (playerForwardVector * 0.4)
                end
                if potentialSitEntity and isChairArchetype(archetypeName) then
                    sitHeading = GetEntityHeading(potentialSitEntity) - 180
                end
                displayName = "Chair"
                target = potentialSitEntity
            else -- Closer to the ground
                if potentialSitEntity and isChairArchetype(archetypeName) then
                    sitCoords = vector3(hitEntityForward.x, hitEntityForward.y, hitCoordsForward.z)
                else
                    sitCoords = vector3(hitCoordsForward.x, hitCoordsForward.y, hitCoordsForward.z) + (playerForwardVector * 0.26)
                end
                if potentialSitEntity and isChairArchetype(archetypeName) then
                    sitHeading = GetEntityHeading(potentialSitEntity) - 180
                end

                if potentialSitEntity and isChairArchetype(archetypeName) then
                    scenario = "PROP_HUMAN_SEAT_CHAIR"
                    displayName = "Seat (chair)"
                else
                    scenario = "WORLD_HUMAN_SEAT_WALL"
                    displayName = "Seat"
                end
                target = potentialSitEntity
            end
            PlaySittingScenario(sitCoords, sitHeading, scenario, false, displayName, target)
        else -- Leaning against a wall
            local leanCoords = vector3(hitCoordsForward.x, hitCoordsForward.y, playerCoords.z) - (playerForwardVector * 0.32)
            PlaySittingScenario(leanCoords, GetEntityHeading(playerPed) - 180, "WORLD_HUMAN_LEANING", false, "Wall", nil)
        end
    elseif foundGroundSitSpot and initialGroundHitDistance ~= Config.GroundDistance then
        -- Sitting on a ledge
        local ledgeCoords = vector3(foundGroundSitSpot.x, foundGroundSitSpot.y, foundGroundSitSpot.z) - (playerForwardVector * 0.2)
        PlaySittingScenario(ledgeCoords, GetEntityHeading(playerPed), "WORLD_HUMAN_SEAT_LEDGE", false, "Ledge", nil)
    else
        -- Sitting on the ground (picnic style)
        PlaySittingScenario(playerCoords, GetEntityHeading(playerPed), "WORLD_HUMAN_PICNIC", true, "Ground", nil)
    end
end)

-- Exports for external scripts
exports("IsSitting", function()
    return IS_PLAYER_SITTING
end)
