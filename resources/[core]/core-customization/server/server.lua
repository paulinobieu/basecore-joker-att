-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddEventHandler = AddEventHandler
local RegisterCommand = RegisterCommand
local RegisterNetEvent = RegisterNetEvent
local TriggerClientEvent = TriggerClientEvent
local next = next
local pairs = pairs
local tonumber = tonumber
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:HANDLEACTION
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:handleAction", function(action, data)

    local src = source

    local userId = Framework.UserId(src)
    if not userId then return end

    local handler = Handlers[action]
    if handler then handler(src, userId, data) end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARTCOMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
for command, part in pairs(Customization.PartCommands) do
    RegisterCommand(command, function(src, args)
        local userId = Framework.UserId(src)
        if not userId then return end

        ChangePart(src, userId, part, tonumber(args[1]), tonumber(args[2]) or 0)
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Customization.ShopCommand, function(src)
    local userId = Framework.UserId(src)
    if not userId then return end

    if not IsAdmin(userId, Customization.AdminLevels.Shop)
        and not Framework.HasPremium(userId) then
        return
    end

    OpenClothesShop(src, userId)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TATTOOCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Customization.TattooCommand, function(src)
    local userId = Framework.UserId(src)
    if not userId then return end

    if not IsAdmin(userId, Customization.AdminLevels.Shop)
        and not Framework.HasPremium(userId) then
        return
    end

    OpenTattooShop(src, userId)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRESETCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Customization.PresetCommand, function(src, args)
    local userId = Framework.UserId(src)
    if not userId then return end
    if not IsAdmin(userId, Customization.AdminLevels.Preset) then return end

    local targetId = tonumber(args[1])
    if not targetId or not Framework.Source(targetId) then
        return Framework.Notify(src, L("commandNoTarget"), "error")
    end

    Framework.SendText(src, L("presetCopied"), BuildPreset(targetId))
    CoreLog("CUSTOMIZATION_PRESET", { playerName = UserName(userId), playerId = userId, targetId = targetId })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:REMOVEPROPS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:removeProps", function(parts)
    local src = source
    local list = type(parts) == "string" and { parts } or parts

    if type(list) ~= "table" then return end

    local userId = Framework.UserId(src)
    if not userId or not Framework.HasService(userId) then return end
    if Framework.Health(src) <= 100 then return end
    if not Framework.CanCustomize(src, userId) then return end

    local target = Framework.NearestPlayer(src, 2)
    if not target then return end

    local model = Framework.Model(target)
    local overlay = {}

    for _, part in pairs(list) do
        if Clothes.Parts[part] then
            overlay[part] = { item = Clothes.DefaultOf(part, model), texture = 0 }
        end
    end

    if not next(overlay) then return end

    TriggerClientEvent("core-customization:overlayClothes", target, overlay)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped", function()
    ForgetUserName(Framework.UserId(source))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GetOutfit", function(passport)
    if not passport then return nil end
    return LoadOutfit(passport)
end)

exports("SetOutfit", function(passport, clothes, tattoos)
    if not passport then return false end

    SaveOutfit(passport, clothes, tattoos)

    local src = Framework.Source(passport)
    if src then Handlers.requestOutfit(src, passport) end

    return true
end)

exports("IsDefaultPart", function(passport, part)
    if not passport or not Clothes.Parts[part] then return nil end

    local src = Framework.Source(passport)
    if not src then return nil end

    local entry = LoadOutfit(passport).clothes[part]
    if not entry then return nil end

    return entry.item == Clothes.DefaultOf(part, Framework.Model(src))
end)

exports("OpenClothesShop", function(passport)
    local src = Framework.Source(passport)
    if not src then return false end

    return OpenClothesShop(src, passport)
end)

exports("OpenTattooShop", function(passport)
    local src = Framework.Source(passport)
    if not src then return false end

    return OpenTattooShop(src, passport)
end)

exports("LockClothes", function(passport, state)
    local src = Framework.Source(passport)
    if not src then return false end

    TriggerClientEvent("core-customization:lockClothes", src, state and true or false)
    return true
end)
