-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Cooldown     = 3000
local LoginDelay   = 20000
local SyncInterval = 300000
local SyncSpacing  = 500
local Cooldowns    = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ALLOWREQUEST
-----------------------------------------------------------------------------------------------------------------------------------------
local function AllowRequest(Passport)
    local Now = GetGameTimer()

    if Cooldowns[Passport] and Cooldowns[Passport] > Now then
        return false
    end

    Cooldowns[Passport] = Now + Cooldown

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLAIM
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Claim(BenefitId)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return { success = false, message = Booster.Language.Failed }
    end

    if type(BenefitId) ~= "string" or #BenefitId > 48 then
        return { success = false, message = Booster.Language.NotFound }
    end

    if not AllowRequest(Passport) then
        return { success = false, message = Booster.Language.Cooldown }
    end

    return ClaimBenefit(Passport, source, BenefitId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Booster.Commands.Open, function(source)

    if source <= 0 then
        return
    end

    CreateThread(function()
        local Passport = Framework.Passport(source)
        if not Passport then
            return
        end

        if not AllowRequest(Passport) then
            Framework.Notify(source, Booster.Language.Cooldown, "amarelo")
            return
        end

        local Data, Message = BuildStatus(Passport, source, false)
        if not Data then
            Framework.Notify(source, Message, "vermelho")
            return
        end

        Framework.OpenPanel(source, Data)
    end)
end, false)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCTHREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(SyncInterval)

        local Players = Framework.Players()

        for _, Passport in ipairs(LinkedOwners()) do
            local Source = Players[Passport]

            if Source then
                SyncPlayer(Passport, Source)

                Wait(SyncSpacing)
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIFECYCLE
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.OnCharacterChosen(function(Passport, Source)
    CreateThread(function()
        Wait(LoginDelay)

        if Framework.Passport(Source) ~= Passport then
            return
        end

        SyncPlayer(Passport, Source)
    end)
end)

Framework.OnPlayerDropped(function(Passport)
    Cooldowns[Passport] = nil

    ReleaseBenefit(Passport)
end)
