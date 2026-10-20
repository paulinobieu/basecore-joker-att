-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ApiUrl     = "https://discord.com/api/v10"
local AvatarUrl  = "https://cdn.discordapp.com/avatars/"
local DefaultUrl = "https://cdn.discordapp.com/embed/avatars/"
local BadgeUrl   = "https://cdn.discordapp.com/guild-tag-badges/"
local UserAgent  = "DiscordBot (https://corenetwork.dev, 1.0)"
local Timeout    = 5000
local CacheTtl   = 30000
local Cache      = {}
local BotReady   = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTUP
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    if type(BoosterBot) ~= "table" then
        print("^1[CORE-BOOSTER]^7 config/bot.lua não foi carregado.")
        return
    end

    if type(BoosterBot.Token) ~= "string" or #BoosterBot.Token < 32 then
        print("^1[CORE-BOOSTER]^7 preencha o Token em config/bot.lua.")
        return
    end

    if type(BoosterBot.GuildId) ~= "string" or not BoosterBot.GuildId:match("^%d+$") then
        print("^1[CORE-BOOSTER]^7 preencha o GuildId em config/bot.lua.")
        return
    end

    BotReady = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUEST
-----------------------------------------------------------------------------------------------------------------------------------------
local function Request(Path)
    local Response = promise.new()
    local Answered = false

    local function Resolve(Status, Body)
        if Answered then
            return
        end

        Answered = true
        Response:resolve({ Status = Status, Body = Body })
    end

    SetTimeout(Timeout, function()
        Resolve(0, false)
    end)

    PerformHttpRequest(ApiUrl .. Path, function(Status, Body)
        Resolve(Status, Body)
    end, "GET", "", {
        ["Authorization"] = "Bot " .. BoosterBot.Token,
        ["User-Agent"]    = UserAgent,
        ["Content-Type"]  = "application/json",
    })

    local Result = Citizen.Await(Response)

    return Result.Status, Result.Body
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DECODE
-----------------------------------------------------------------------------------------------------------------------------------------
local function Decode(Body)
    if type(Body) ~= "string" or Body == "" then
        return false
    end

    local Success, Data = pcall(json.decode, Body)
    if not Success or type(Data) ~= "table" then
        return false
    end

    return Data
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDAVATAR
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildAvatar(User)
    if type(User.avatar) == "string" and User.avatar ~= "" then
        return AvatarUrl .. User.id .. "/" .. User.avatar .. ".png?size=256"
    end

    if type(User.discriminator) == "string" and User.discriminator ~= "0" then
        return DefaultUrl .. (parseInt(User.discriminator) % 5) .. ".png"
    end

    local Snowflake = math.tointeger(tonumber(User.id) or 0) or 0

    return DefaultUrl .. ((Snowflake >> 22) % 6) .. ".png"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDSERVERTAG
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildServerTag(User)
    local Primary = User.primary_guild or User.clan
    if type(Primary) ~= "table" then
        return { Active = false, MatchesGuild = false }
    end

    if not Primary.identity_enabled or type(Primary.tag) ~= "string" or Primary.tag == "" then
        return { Active = false, MatchesGuild = false }
    end

    local GuildId = tostring(Primary.identity_guild_id or "")
    local Badge   = false

    if type(Primary.badge) == "string" and Primary.badge ~= "" then
        Badge = BadgeUrl .. GuildId .. "/" .. Primary.badge .. ".png?size=64"
    end

    return {
        Active       = true,
        MatchesGuild = GuildId == BoosterBot.GuildId,
        Tag          = Primary.tag,
        Badge        = Badge,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FETCHUSER
-----------------------------------------------------------------------------------------------------------------------------------------
local function FetchUser(DiscordId)
    local Status, Body = Request("/users/" .. DiscordId)

    if Status == 404 then
        return false, "user_not_found"
    end

    if Status == 401 or Status == 403 then
        return false, "invalid_bot_config"
    end

    if Status == 429 then
        return false, "discord_rate_limited"
    end

    if Status ~= 200 then
        return false, "discord_unavailable"
    end

    local User = Decode(Body)
    if not User or type(User.id) ~= "string" then
        return false, "invalid_discord_response"
    end

    return true, User
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FETCHMEMBER
-----------------------------------------------------------------------------------------------------------------------------------------
local function FetchMember(DiscordId)
    local Status, Body = Request("/guilds/" .. BoosterBot.GuildId .. "/members/" .. DiscordId)

    if Status == 404 then
        return true, false
    end

    if Status == 401 then
        return false, "invalid_bot_config"
    end

    if Status == 403 then
        return false, "guild_access_denied"
    end

    if Status == 429 then
        return false, "discord_rate_limited"
    end

    if Status ~= 200 then
        return false, "discord_unavailable"
    end

    local Member = Decode(Body)
    if not Member then
        return false, "invalid_discord_response"
    end

    return true, Member
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMEMBER
-----------------------------------------------------------------------------------------------------------------------------------------
local function Remember(DiscordId, Data)
    local Now = GetGameTimer()

    for Key, Entry in pairs(Cache) do
        if Entry.Expires <= Now then
            Cache[Key] = nil
        end
    end

    Cache[DiscordId] = { Expires = Now + CacheTtl, Data = Data }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOKUPDISCORD
-----------------------------------------------------------------------------------------------------------------------------------------
function LookupDiscord(DiscordId, ForceRefresh)
    if not BotReady then
        return false, "invalid_bot_config"
    end

    if type(DiscordId) ~= "string" or not DiscordId:match("^%d+$") or #DiscordId > 32 then
        return false, "invalid_discord_id"
    end

    local Cached = Cache[DiscordId]
    if not ForceRefresh and Cached and Cached.Expires > GetGameTimer() then
        return true, Cached.Data
    end

    local Success, User = FetchUser(DiscordId)
    if not Success then
        return false, User
    end

    local Found, Member = FetchMember(DiscordId)
    if not Found then
        return false, Member
    end

    local Data = {
        User = {
            Id     = User.id,
            Name   = User.global_name or User.username or User.id,
            Avatar = BuildAvatar(User),
        },
        ServerTag = BuildServerTag(User),
        Boost = {
            Active = Member and type(Member.premium_since) == "string" or false,
        },
    }

    Remember(DiscordId, Data)

    return true, Data
end
