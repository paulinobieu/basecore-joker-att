-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADING (SERVER)
-----------------------------------------------------------------------------------------------------------------------------------------
local RankingCache = {
    data = nil,
    expiresAt = 0,
    pending = nil,
}

local function fallbackResult(card)
    return {
        name = card.EmptyName or Loading.Texts.EmptyName or "Sem dados",
        value = card.EmptyValue or 0,
    }
end

local function buildRanking(source)
    local ranking = {}

    if not Loading.Ranking.Enabled then
        return ranking
    end

    for index = 1, #Loading.Ranking.Cards do
        local card = Loading.Ranking.Cards[index]

        if card.Enabled ~= false then
            local success, result = pcall(Framework.GetRanking, card.Key, card, source)

            if not success then
                print(("^1[loading]^7 Falha no ranking '%s': %s"):format(tostring(card.Key), tostring(result)))
                result = nil
            end

            if type(result) == "table" or not card.HideWhenEmpty then
                result = type(result) == "table" and result or fallbackResult(card)

                ranking[#ranking + 1] = {
                    key = tostring(card.Key or index),
                    title = tostring(card.Title or "RANKING"),
                    icon = tostring(card.Icon or "fa-solid fa-trophy"),
                    color = tostring(card.Color or Loading.Appearance.Accent),
                    secondaryColor = tostring(card.SecondaryColor or Loading.Appearance.AccentSecondary),
                    prefix = tostring(card.Prefix or ""),
                    suffix = tostring(card.Suffix or ""),
                    name = tostring(result.name or result.Name or Loading.Texts.EmptyName),
                    value = result.value or result.Value or 0,
                }
            end
        end
    end

    return ranking
end

local function getRanking(source)
    local now = os.time()
    local cacheSeconds = math.max(tonumber(Loading.CacheSeconds) or 0, 0)

    if RankingCache.data and now < RankingCache.expiresAt then
        return RankingCache.data
    end

    if RankingCache.pending then
        return Citizen.Await(RankingCache.pending)
    end

    local pending = promise.new()
    RankingCache.pending = pending

    local success, result = pcall(buildRanking, source)
    if not success then
        print(("^1[loading]^7 Não foi possível montar o ranking: %s"):format(tostring(result)))
        result = {}
    end

    RankingCache.data = result
    RankingCache.expiresAt = now + cacheSeconds
    RankingCache.pending = nil
    pending:resolve(result)

    return result
end

local function handoverData(source)
    return {
        appearance = Loading.Appearance,
        texts = Loading.Texts,
        background = Loading.Background,
        audio = Loading.Audio,
        news = Loading.News,
        rankingData = getRanking(source),
    }
end

AddEventHandler("playerConnecting", function(_, _, deferrals)
    local source = source

    deferrals.defer()
    Wait(0)

    local success, data = pcall(handoverData, source)
    if success then
        deferrals.handover(data)
    else
        print(("^1[loading]^7 Falha ao preparar o handover: %s"):format(tostring(data)))
    end

    deferrals.done()
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    RankingCache.data = nil
    RankingCache.expiresAt = 0
end)
