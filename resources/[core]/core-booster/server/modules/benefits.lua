-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local VehiclesURL = "https://cdn.corenetwork.dev/corevehicles/"
local MoneyItem   = "dollar"
local GemsItem    = "gemstone"
local Locks       = {}
local Warned      = {}

local ErrorMessages = {
    invalid_bot_config       = Booster.Language.Unavailable,
    invalid_discord_id       = Booster.Language.NoDiscord,
    user_not_found           = Booster.Language.NoDiscord,
    guild_access_denied      = Booster.Language.Unavailable,
    discord_rate_limited     = Booster.Language.Unavailable,
    discord_unavailable      = Booster.Language.Unavailable,
    invalid_discord_response = Booster.Language.Unavailable,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- WARN
-----------------------------------------------------------------------------------------------------------------------------------------
local function Warn(Key, Message)
    if Warned[Key] then
        return
    end

    Warned[Key] = true
    print("^3[CORE-BOOSTER]^7 " .. Message)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINDBENEFIT
-----------------------------------------------------------------------------------------------------------------------------------------
local function FindBenefit(BenefitId)
    for _, Benefit in ipairs(Booster.Benefits) do
        if Benefit.Id == BenefitId then
            return Benefit
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMIMAGE
-----------------------------------------------------------------------------------------------------------------------------------------
local function ItemImage(Item)
    if not Framework.ItemExist(Item) then
        return false
    end

    return ItemsURL .. Framework.ItemIndex(Item) .. ".png"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOLVEREWARD
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResolveReward(Benefit, Reward, Index)
    local Id = Benefit.Id .. "-" .. Index

    if Reward.Type == "bank" then
        return {
            id     = Id,
            label  = Booster.Language.Rewards.Bank,
            amount = parseInt(Reward.Amount, true),
            image  = ItemImage(MoneyItem),
            icon   = "money",
        }
    end

    if Reward.Type == "gems" then
        return {
            id     = Id,
            label  = Booster.Language.Rewards.Gems,
            amount = parseInt(Reward.Amount, true),
            image  = ItemImage(GemsItem),
            icon   = "sparkles",
        }
    end

    if Reward.Type == "item" then
        local Image = ItemImage(Reward.Item)
        if not Image then
            Warn(Id, "recompensa fora do painel: " .. tostring(Reward.Item) .. " não está no catálogo de itens.")
            return false
        end

        return {
            id     = Id,
            label  = Framework.ItemName(Reward.Item),
            amount = parseInt(Reward.Amount, true),
            image  = Image,
        }
    end

    if Reward.Type ~= "vehicle" then
        Warn(Id, "recompensa fora do painel: tipo " .. tostring(Reward.Type) .. " não existe.")
        return false
    end

    local Info = Framework.VehicleInfo(Reward.Model)
    if not Info then
        Warn(Id, "recompensa fora do painel: " .. tostring(Reward.Model) .. " não está registrado no core-vehicles.")
        return false
    end

    return {
        id     = Id,
        label  = Info.name or Reward.Model,
        image  = VehiclesURL .. (Info.index or Reward.Model) .. ".png",
        icon   = "vehicle",
        linked = true,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ELIGIBLE
-----------------------------------------------------------------------------------------------------------------------------------------
local function Eligible(Benefit, Discord)
    if not Discord then
        return false
    end

    local Boost = Discord.Boost.Active and true or false
    local Tag   = (Discord.ServerTag.Active and Discord.ServerTag.MatchesGuild) and true or false

    if Benefit.Require == "boost" then
        return Boost
    end

    if Benefit.Require == "tag" then
        return Tag
    end

    if Benefit.Require == "both" then
        return Boost and Tag
    end

    Warn("require:" .. Benefit.Id, "benefício " .. Benefit.Id .. " com Require inválido, use boost, tag ou both.")

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PENDINGREWARDS
-----------------------------------------------------------------------------------------------------------------------------------------
local function PendingRewards(Benefit, Grants)
    local Pending = {}

    for Index, Reward in ipairs(Benefit.Rewards or {}) do
        local Key = Benefit.Id .. "-" .. Index

        if not Grants[Key] and ResolveReward(Benefit, Reward, Index) then
            Pending[#Pending + 1] = { Key = Key, Reward = Reward, Linked = Reward.Type == "vehicle" }
        end
    end

    return Pending
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDBENEFITS
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildBenefits(Discord, Grants)
    local List = {}

    for _, Benefit in ipairs(Booster.Benefits) do
        local Labels  = Benefit.Labels or {}
        local Rewards = {}

        for Index, Reward in ipairs(Benefit.Rewards or {}) do
            local Resolved = ResolveReward(Benefit, Reward, Index)

            if Resolved then
                Rewards[#Rewards + 1] = Resolved
            end
        end

        List[#List + 1] = {
            id          = Benefit.Id,
            title       = Benefit.Title,
            description = Benefit.Description,
            icon        = Benefit.Icon,
            accent      = Benefit.Accent,
            active      = Eligible(Benefit, Discord),
            claimed     = #PendingRewards(Benefit, Grants) <= 0,
            labels      = { active = Labels.Active or Benefit.Title, inactive = Labels.Inactive or Benefit.Title },
            rewards     = Rewards,
        }
    end

    return List
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REVOKEBENEFIT
-----------------------------------------------------------------------------------------------------------------------------------------
local function RevokeBenefit(Passport, Benefit, Grants)
    local Removed = 0

    for Key, Grant in pairs(Grants) do
        if Grant.Linked and Grant.Benefit == Benefit.Id then
            if Grant.Reference ~= "" then
                Framework.DeleteVehicle(Grant.Reference)
            end

            RemoveGrant(Passport, Key)

            Grants[Key] = nil
            Removed = Removed + 1
        end
    end

    if Removed > 0 then
        Framework.Log("PERDEU-BENEFICIO", {
            message    = "#" .. Passport .. " perdeu o benefício " .. Benefit.Title .. " e teve " .. Removed .. " recompensa(s) vinculada(s) removida(s)",
            playerId   = Passport,
            Beneficio  = Benefit.Title,
            Removidas  = Removed,
        })
    end

    return Removed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCBENEFITS
-----------------------------------------------------------------------------------------------------------------------------------------
local function SyncBenefits(Passport, Source, Discord)
    local Grants = FindGrants(Passport)
    if not Grants then
        return false
    end

    for _, Benefit in ipairs(Booster.Benefits) do
        if not Eligible(Benefit, Discord) and RevokeBenefit(Passport, Benefit, Grants) > 0 and Source then
            Framework.Notify(Source, Booster.Language.Revoked:format(Benefit.Title), "vermelho")
        end
    end

    return Grants
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDSTATUS
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildStatus(Passport, Source, ForceRefresh)
    local DiscordId = Framework.DiscordId(Source, Passport)
    if not DiscordId then
        return false, Booster.Language.NoDiscord
    end

    local Found, Discord = LookupDiscord(DiscordId, ForceRefresh)
    if not Found then
        return false, ErrorMessages[Discord] or Booster.Language.Unavailable
    end

    local Grants = SyncBenefits(Passport, Source, Discord)
    if not Grants then
        return false, Booster.Language.Failed
    end

    return {
        player = {
            name   = Discord.User.Name or Framework.FullName(Passport),
            tag    = Discord.ServerTag.MatchesGuild and Discord.ServerTag.Tag or "",
            badge  = Discord.ServerTag.MatchesGuild and Discord.ServerTag.Badge or "",
            avatar = Discord.User.Avatar,
        },
        benefits = BuildBenefits(Discord, Grants),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function SyncPlayer(Passport, Source)
    local Grants = FindGrants(Passport)
    if not Grants then
        return
    end

    local Linked = false
    for _, Grant in pairs(Grants) do
        if Grant.Linked then
            Linked = true
            break
        end
    end

    if not Linked then
        return
    end

    local DiscordId = Framework.DiscordId(Source, Passport)
    if not DiscordId then
        SyncBenefits(Passport, Source, false)
        return
    end

    local Found, Discord = LookupDiscord(DiscordId, true)
    if not Found then
        return
    end

    SyncBenefits(Passport, Source, Discord)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKCAPACITY
-----------------------------------------------------------------------------------------------------------------------------------------
local function CheckCapacity(Passport, Pending)
    local Weight = Framework.InventoryWeight(Passport)

    for _, Entry in ipairs(Pending) do
        if Entry.Reward.Type == "item" then
            local Amount = parseInt(Entry.Reward.Amount, true)

            if Framework.ReachedMax(Passport, Entry.Reward.Item, Amount) then
                return false, Booster.Language.MaxAmount:format(Framework.ItemName(Entry.Reward.Item))
            end

            Weight = Weight + (Framework.ItemWeight(Entry.Reward.Item) * Amount)
        end
    end

    if Weight > Framework.MaxWeight(Passport) then
        return false, Booster.Language.NoSpace
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELIVERREWARD
-----------------------------------------------------------------------------------------------------------------------------------------
local function DeliverReward(Passport, Reward)
    if Reward.Type == "bank" then
        return Framework.GiveBank(Passport, parseInt(Reward.Amount, true))
    end

    if Reward.Type == "gems" then
        return Framework.GiveGems(Passport, parseInt(Reward.Amount, true))
    end

    if Reward.Type == "item" then
        return Framework.GiveItem(Passport, Reward.Item, parseInt(Reward.Amount, true))
    end

    local Success, Result = Framework.GiveVehicle(Passport, Reward.Model)
    if not Success then
        return false, false, Result == "GARAGE_FULL" and Booster.Language.GarageFull or Booster.Language.Failed
    end

    return true, Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSCLAIM
-----------------------------------------------------------------------------------------------------------------------------------------
local function ProcessClaim(Passport, Source, Discord, Benefit, Reserved)
    local Grants = SyncBenefits(Passport, Source, Discord)
    if not Grants then
        return false, Booster.Language.Failed
    end

    if not Eligible(Benefit, Discord) then
        return false, Booster.Language.NotEligible
    end

    local Pending = PendingRewards(Benefit, Grants)
    if #Pending <= 0 then
        return false, Booster.Language.AlreadyClaimed
    end

    local Allowed, Blocked = CheckCapacity(Passport, Pending)
    if not Allowed then
        return false, Blocked
    end

    local Delivered, Failure = 0, false

    for _, Entry in ipairs(Pending) do
        if ReserveGrant(Passport, Benefit.Id, Entry.Key, Entry.Linked) then
            Reserved[Entry.Key] = false

            local Success, Reference, Message = DeliverReward(Passport, Entry.Reward)

            if Success then
                if Reference then
                    ReferenceGrant(Passport, Entry.Key, Reference)
                end

                Reserved[Entry.Key] = true
                Delivered = Delivered + 1
            else
                RemoveGrant(Passport, Entry.Key)

                Reserved[Entry.Key] = true
                Failure = Message or Booster.Language.Failed
            end
        end
    end

    if Delivered <= 0 then
        return false, Failure or Booster.Language.AlreadyClaimed
    end

    local FullName = Framework.FullName(Passport) or "Desconhecido"

    Framework.Log("COLETOU-BENEFICIO", {
        message    = FullName .. " #" .. Passport .. " coletou " .. Delivered .. " recompensa(s) do benefício " .. Benefit.Title,
        playerName = FullName,
        playerId   = Passport,
        Beneficio  = Benefit.Title,
        Coletadas  = Delivered,
    })

    if Failure then
        return true, Booster.Language.Partial
    end

    return true, Booster.Language.Claimed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLAIMBENEFIT
-----------------------------------------------------------------------------------------------------------------------------------------
function ClaimBenefit(Passport, Source, BenefitId)
    local Benefit = FindBenefit(BenefitId)
    if not Benefit then
        return { success = false, message = Booster.Language.NotFound }
    end

    if Locks[Passport] then
        return { success = false, message = Booster.Language.Cooldown }
    end

    Locks[Passport] = true

    local DiscordId = Framework.DiscordId(Source, Passport)
    if not DiscordId then
        Locks[Passport] = nil
        return { success = false, message = Booster.Language.NoDiscord }
    end

    local Found, Discord = LookupDiscord(DiscordId, true)
    if not Found then
        Locks[Passport] = nil
        return { success = false, message = ErrorMessages[Discord] or Booster.Language.Unavailable }
    end

    local Reserved = {}
    local Executed, Success, Message = pcall(ProcessClaim, Passport, Source, Discord, Benefit, Reserved)

    Locks[Passport] = nil

    if not Executed then
        print("^1[CORE-BOOSTER]^7 " .. tostring(Success))

        for Key, Concluded in pairs(Reserved) do
            if not Concluded then
                RemoveGrant(Passport, Key)
            end
        end

        return { success = false, message = Booster.Language.Failed }
    end

    return {
        success  = Success,
        message  = Message,
        benefits = BuildBenefits(Discord, FindGrants(Passport) or {}),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RELEASEBENEFIT
-----------------------------------------------------------------------------------------------------------------------------------------
function ReleaseBenefit(Passport)
    Locks[Passport] = nil
end
