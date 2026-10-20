local Config = require 'config.main'

--- Gets nail data from player's ped statebag
--- @param playerId number
--- @return table
function GetPlayerNailData(playerId)
    if not playerId then
        Debug('warning', 'GetPlayerNailData called with nil playerId')
        return {}
    end

    if PlayerNails[tostring(playerId)] then
        return PlayerNails[tostring(playerId)]
    end

    return {}
end

--- Updates player nails data and syncs to StateBag
--- @param playerId number
--- @param data table
function UpdatePlayerNails(playerId, data)
    if not playerId then
        Debug('warning', 'UpdatePlayerNails called with nil playerId')
        return {}
    end

    local currentNailData = GetPlayerNailData(playerId)
    if not currentNailData then
        currentNailData = {}
    end

    if not next(data) then
        Debug('warning', 'Empty data provided for player %d', playerId)
        return
    end

    local fingerCount = 0
    if data then
        for _ in pairs(data) do
            fingerCount = fingerCount + 1
        end
    end
    Debug('info', 'Updating nails for player %d (%d fingers)', playerId, fingerCount)

    PlayerNails[tostring(playerId)] = data
    Debug('success', 'Updated nail data for player %d in StateBag', playerId)
end

--- Sets player nails data directly (for loading from database)
--- @param playerId number
--- @param nailData table
function SetPlayerNails(playerId, nailData)
    if not playerId then
        Debug('warning', 'SetPlayerNails called with nil playerId')
        return
    end

    local nailCount = 0
    if nailData then
        for _ in pairs(nailData) do
            nailCount = nailCount + 1
        end
    end

    PlayerNails[tostring(playerId)] = nailData or {}
    Debug('info', 'Set nail data for player %d (%d nails)', playerId, nailCount)
end

--- Clears player nails data
--- @param playerId number
function ClearPlayerNails(playerId)
    if not playerId then
        Debug('warning', 'ClearPlayerNails called with nil playerId')
        return
    end

    PlayerNails[tostring(playerId)] = nil
    Debug('info', 'Cleared nail data for player %d', playerId)
end

--- Loads nail data from database for a player
--- @param playerId number
--- @return table|nil nailData, boolean exists
function LoadPlayerNailDataFromDB(playerId)
    local identifier = Framework.GetPlayerIdentifier(playerId)
    if not identifier then
        Debug('warning', 'Failed to get identifier for player %d', playerId)
        return nil, false
    end

    local searchQuery = [[
        SELECT nail_data FROM `nailshop` WHERE identifier = ?
    ]]
    local row = MySQL.single.await(searchQuery, { identifier })

    if row then
        local nailData = row.nail_data and json.decode(row.nail_data) or {}
        Debug('info', 'Loaded nail data from database for player %d', playerId)
        return nailData, true
    end

    Debug('info', 'No nail data found in database for player %d', playerId)
    return nil, false
end

--- Loads or creates nail data for a player from database
--- @param playerId number
--- @return table nailData
function LoadOrCreatePlayerNailData(playerId)
    local nailData, exists = LoadPlayerNailDataFromDB(playerId)

    if exists and type(nailData) == 'table' then
        return nailData
    end

    Debug('info', 'Creating new nail data entry for player %d', playerId)
    local identifier = Framework.GetPlayerIdentifier(playerId)
    if identifier then
        local insertQuery = [[
            INSERT INTO `nailshop` (identifier, nail_data) VALUES (?, ?)
        ]]
        MySQL.insert.await(insertQuery, { identifier, json.encode({}) })
        Debug('success', 'Created new nail data entry for player %d', playerId)
    else
        Debug('error', 'Failed to get identifier for player %d, cannot create entry', playerId)
    end

    return {}
end

-- ██████╗ ██████╗ ███████╗██╗    ██╗██╗███████╗██╗   ██╗    ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
-- ██╔══██╗██╔══██╗██╔════╝██║    ██║██║██╔════╝╚██╗ ██╔╝    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
-- ██████╔╝██████╔╝█████╗  ██║ █╗ ██║██║███████╗ ╚████╔╝     █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
-- ██╔═══╝ ██╔══██╗██╔══╝  ██║███╗██║██║╚════██║  ╚██╔╝      ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
-- ██║     ██║  ██║███████╗╚███╔███╔╝██║███████║   ██║       ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
-- ╚═╝     ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝╚══════╝   ╚═╝       ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

--- Gets preview nail data from player's preview nails table
--- @param playerId number
--- @return table
function GetPlayerPreviewNailData(playerId)
    if not playerId then
        Debug('warning', 'GetPlayerPreviewNailData called with nil playerId')
        return {}
    end

    if PreviewNails[tostring(playerId)] then
        return PreviewNails[tostring(playerId)]
    end

    return {}
end

--- Updates player preview nails data
--- @param playerId number
--- @param data table
function UpdatePlayerPreviewNails(playerId, data)
    if not playerId then
        Debug('warning', 'UpdatePlayerPreviewNails called with nil playerId')
        return
    end

    local currentPreviewNailData = GetPlayerPreviewNailData(playerId)
    if not currentPreviewNailData then
        currentPreviewNailData = {}
    end

    if not next(data) then
        Debug('warning', 'Empty data provided for preview nails for player %d', playerId)
        return
    end

    local updatedCount = 0
    local boneIdKey = nil

    local isArray = false
    for _, value in pairs(data) do
        if type(value) == 'table' and value.boneId then
            isArray = true
            break
        end
    end

    if isArray then
        for _, fingerData in pairs(data) do
            if fingerData.boneId then
                boneIdKey = tostring(fingerData.boneId)
                currentPreviewNailData[boneIdKey] = fingerData
                updatedCount = updatedCount + 1
            end
        end
    else
        for boneId, fingerData in pairs(data) do
            boneIdKey = tostring(boneId)
            currentPreviewNailData[boneIdKey] = fingerData
            updatedCount = updatedCount + 1
        end
    end

    Debug('info', 'Updating preview nails for player %d (%d new/updated fingers)', playerId, updatedCount)

    PreviewNails[tostring(playerId)] = currentPreviewNailData

    local totalCount = 0
    for _ in pairs(currentPreviewNailData) do
        totalCount = totalCount + 1
    end

    Debug('success', 'Updated preview nail data for player %d (total bones: %d)', playerId, totalCount)
end

--- Sets player preview nails data directly
--- @param playerId number
--- @param nailData table
function SetPlayerPreviewNails(playerId, nailData)
    if not playerId then
        Debug('warning', 'SetPlayerPreviewNails called with nil playerId')
        return
    end

    local nailCount = 0
    if nailData then
        for _ in pairs(nailData) do
            nailCount = nailCount + 1
        end
    end

    PreviewNails[tostring(playerId)] = nailData or {}
    Debug('info', 'Set preview nail data for player %d (%d nails)', playerId, nailCount)
end

--- Clears player preview nail design
--- @param playerId number
function ClearPreviewNailDesign(playerId)
    if not playerId then
        Debug('warning', 'ClearPreviewNailDesign called with nil playerId')
        return
    end

    PreviewNails[tostring(playerId)] = nil
    Debug('info', 'Cleared preview nail data for player %d', playerId)
end

--- Clears a specific finger's preview nail design
--- @param playerId number
--- @param fingerId number|string
--- @param hand string
function ClearPlayerPreviewFingerDesign(playerId, fingerId, hand)
    if not playerId then
        Debug('warning', 'ClearPlayerPreviewFingerDesign called with nil playerId')
        return
    end

    if not fingerId or not hand then
        Debug('warning', 'ClearPlayerPreviewFingerDesign called with nil fingerId or hand for player %d', playerId)
        return
    end

    local currentPreviewNailData = GetPlayerPreviewNailData(playerId)
    if not currentPreviewNailData or not next(currentPreviewNailData) then
        Debug('info', 'No preview nail data to clear for player %d', playerId)
        return
    end

    local finger = Config.FingerBones[hand .. '_' .. tostring(fingerId)]
    if not finger then
        Debug('warning', 'Invalid finger bone for hand %s, id %s', hand, tostring(fingerId))
        return
    end

    if currentPreviewNailData[tostring(finger)] then
        currentPreviewNailData[tostring(finger)] = nil
        Debug('info', 'Cleared preview nail design for finger %s (hand: %s, bone: %d) for player %d', tostring(fingerId), hand, finger, playerId)

        if not next(currentPreviewNailData) then
            PreviewNails[tostring(playerId)] = nil
            Debug('info', 'Preview nail data is now empty for player %d, cleared entire table', playerId)
        else
            PreviewNails[tostring(playerId)] = currentPreviewNailData
        end
    else
        Debug('info', 'No preview nail design found for finger %s (hand: %s, bone: %d) for player %d', tostring(fingerId), hand, finger, playerId)
    end
end