-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING [ Em breve ]
-----------------------------------------------------------------------------------------------------------------------------------------
local playerId = nil

local function getRankingCategories()
    local processed = {}
    for id,data in pairs(Config.Ranking.Categories) do
        processed[#processed + 1] = {
            id = id,
            name = data.name,
            showValue = data.showValue,
        }
    end

    return processed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:ranking:categories",function(_,cb)
    cb(getRankingCategories())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BYCATEGORY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:ranking:byCategory",function(data,cb)
    cb(vSERVER.Rankings(data and data.categoryId) or { rank = {}, weeklyRank = {}, dailyRank = {} })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERID
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:player:id",function(_,cb)
    if playerId ~= nil then
        return cb(playerId)
    end

    playerId = vSERVER.Passport()
    cb(playerId)
end)
