local _callId = 0
local _serverResponses = {}

function ServerCall(eventName, ...)
    _callId = _callId + 1
    local id = _callId
    _serverResponses[id] = nil
    TriggerServerEvent(eventName, id, ...)
    local timeout = GetGameTimer() + 15000
    while _serverResponses[id] == nil and GetGameTimer() < timeout do Wait(50) end
    local result = _serverResponses[id]
    _serverResponses[id] = nil
    return result
end

RegisterNetEvent("core-jobs:response")
AddEventHandler("core-jobs:response", function(id, data)
    _serverResponses[id] = data
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local InterfaceLoaded = false
local JobsCenterOpen = false
local ProfList = nil

local SkinShopComponents = {
    masks = 1, hands = 3, pants = 4, bags = 5, shoes = 6, accs = 7, shirts = 8, vests = 9, decals = 10,
    jackets = 11, hats = "p0", glasses = "p1", ears = "p2", watches = "p6", bracelets = "p7"
}

local CurrentJobTipText = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("jobs-center", function(Data, Callback)
    if type(Data) ~= "table" or type(Data.action) ~= "string" then
        Callback({ error = true })
        return
    end
    local Action = Data.action

    if Action == "interface-loaded" then
        InterfaceLoaded = true
        Callback(true)
        return
    end

    if Action == "close" then
        TransitionFromBlurred(800)
        SetNuiFocus(false, false)
        SetTimeout(700, function()
            JobsCenterOpen = false
            SendNUIMessage({ action = "setVisible", data = false })
        end)
        Callback(true)
        return
    end

    if Action == "claimBonus" then
        local Id = tonumber(Data.id)
        if Id and Id % 1 == 0 then
            CreateThread(function()
                local result = ServerCall("core-jobs:claimBonus", Id)
                Callback(result or { error = true })
            end)
            return
        end
        Callback({ error = true })
        return
    end

    if Action == "claimHourBonus" then
        local Id = tonumber(Data.id)
        if Id and Id % 1 == 0 then
            CreateThread(function()
                local result = ServerCall("core-jobs:claimHourBonus", Id)
                Callback(result or { error = true })
            end)
            return
        end
        Callback({ error = true })
        return
    end

    Callback(true)
end)

RegisterNUICallback("startJob", function(Data, Callback)
    if type(Data) == "table" and type(Data.jobId) == "string" and #Data.jobId <= 48 then
        StartJob(Data.jobId)
    end
    Callback(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPEN AGENCY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core_jobs:openAgency")
AddEventHandler("core_jobs:openAgency", function(ProfessionsList)
    if JobsCenterOpen then return end

    local Response = ServerCall("core-jobs:requestAgencyData")
    if Response and not JobsCenterOpen then
        TransitionToBlurred(500)
        JobsCenterOpen = true

        local JobLevelsMap = Response.jobLevels or {}

        local JobsArray = {}
        for Key, Info in pairs(ProfessionsList) do
            table.insert(JobsArray, {
                id = Key,
                name = Info.name,
                salary = Info.displaySalary or 0,
                jobLevel = JobLevelsMap[Key] or 0,
                description = Info.description,
                image = Info.image or "",
                canStart = (Response.level or 1) >= (Info.requiredLevel or 1)
            })
        end

        local UiData = {
            jobs = JobsArray,
            missions = Response.missions or {},
            player = {
                name = Response.name,
                avatar = Response.avatar,
                level = Response.level,
                xp = Response.xp,
                maxXp = Response.maxXp,
                todayEarnings = Response.todayEarnings or 0,
                totalEarnings = Response.totalEarnings or 0
            },
            ranking = Response.ranking or {},
            themeColor = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or Response.themeColor or Config.ThemeColor or "#ca27f4",
            bonuses = Response.bonuses or {},
            workedMinutes = Response.workedMinutes or 0
        }

        SendNUIMessage({
            action = "openJobCenter",
            data = UiData
        })
        SetNuiFocus(true, true)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- START JOB
-----------------------------------------------------------------------------------------------------------------------------------------
function StartJob(JobId)
    local result = ServerCall("core-jobs:tryStartJob", JobId)
    if result and result.ok then
        LocalPlayer.state.currentJob = JobId
        local JobData = result.jobData
        if JobData then
            local Gender = false
            local Model = GetEntityModel(PlayerPedId())
            if Model == GetHashKey("mp_m_freemode_01") then
                Gender = "male"
            elseif Model == GetHashKey("mp_f_freemode_01") then
                Gender = "female"
            end

            if Gender and JobData.clothes and JobData.clothes[Gender] then
                LocalPlayer.state.jobWardrobe = GetClothes()
                SetClothes(JobData.clothes[Gender])
            end
        end

        CreateThread(function()
            jobThread(JobId)
        end)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- END CURRENT JOB
-----------------------------------------------------------------------------------------------------------------------------------------
function EndCurrentJob()
    if LocalPlayer.state.currentJob then
        LocalPlayer.state.currentJob = nil
    end
    SetJobTip(nil)
    if onEndJob then onEndJob() end
    TriggerServerEvent("core-jobs:endedJob")
    if LocalPlayer.state.jobWardrobe then
        SetClothes(LocalPlayer.state.jobWardrobe)
        LocalPlayer.state.jobWardrobe = nil
    end
end

RegisterCommand("@core_jobs:endJob", EndCurrentJob)
RegisterKeyMapping("@core_jobs:endJob", "Cancelar o Emprego", "keyboard", "F7")

AddEventHandler("onResourceStop", function(Resource)
    if Resource == GetCurrentResourceName() then
        SetNuiFocus(false, false)
        TransitionFromBlurred(0)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SET JOB TIP
-----------------------------------------------------------------------------------------------------------------------------------------
function SetJobTip(Text)
    if CurrentJobTipText ~= Text then
        CurrentJobTipText = Text
        if Text == nil then
            SendNUIMessage({ action = "setJobTip", data = { text = nil } })
        else
            SendNUIMessage({ action = "setJobTip", data = { text = Text, position = Config.jobTipPosition or "bottom-left" } })
        end
    end
end
exports('SetJobTip', SetJobTip)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOTHES MANAGEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
function GetComponentName(x)
    for k, v in pairs(SkinShopComponents) do
        if v == x then return k end
    end
    return "COMPONENT_NOT_FOUND"
end

function GetComponentPart(x)
    if SkinShopComponents[x] ~= nil then
        return SkinShopComponents[x]
    end
    return "PART_NOT_FOUND"
end

function SParse(k)
    if type(k) == "string" and string.sub(k, 1, 1) == "p" then
        return true, tonumber(string.sub(k, 2))
    else
        return false, tonumber(k)
    end
end

function GetClothes()
    local ped = PlayerPedId()
    local t = {}
    for i = 0, 20 do
        local k = GetComponentName(i)
        if k ~= "COMPONENT_NOT_FOUND" then
            t[k] = { GetPedDrawableVariation(ped, i), GetPedTextureVariation(ped, i) }
        end
    end
    for i = 0, 10 do
        local k = GetComponentName("p" .. i)
        if k ~= "COMPONENT_NOT_FOUND" then
            t[k] = { GetPedPropIndex(ped, i), math.max(GetPedPropTextureIndex(ped, i), 0) }
        end
    end
    return t
end

function SetClothes(clothes)
    local ped = PlayerPedId()
    for k, v in pairs(clothes) do
        if k ~= "model" and k ~= "modelhash" then
            local component = GetComponentPart(k)
            local isprop, index = SParse(component)
            if isprop then
                local value1 = v[1]
                local value2 = v[2]
                if type(value1) == "string" then value1 = tonumber(value1:gsub('"', '')) end
                if type(value2) == "string" then value2 = tonumber(value2:gsub('"', '')) end
                if value1 < 0 then
                    ClearPedProp(ped, index)
                else
                    local drawableCount = GetNumberOfPedPropDrawableVariations(ped, index)
                    if value1 >= drawableCount then value1 = 0 end
                    local textureCount = GetNumberOfPedPropTextureVariations(ped, index, value1)
                    if value2 < 0 or value2 >= textureCount then value2 = 0 end
                    SetPedPropIndex(ped, index, value1, value2, 1)
                end
            else
                local value1 = v[1]
                local value2 = v[2]
                if type(value1) == "string" then value1 = tonumber(value1:gsub('"', '')) end
                if type(value2) == "string" then value2 = tonumber(value2:gsub('"', '')) end
                local drawableCount = GetNumberOfPedDrawableVariations(ped, index)
                if value1 < 0 or value1 >= drawableCount then value1 = 0 end
                local textureCount = GetNumberOfPedTextureVariations(ped, index, value1)
                if value2 < 0 or value2 >= textureCount then value2 = 0 end
                SetPedComponentVariation(ped, index, value1, value2, 1)
            end
        end
    end
    if not clothes.decals then SetPedComponentVariation(ped, 10, 0, 0, 1) end
    if not clothes.vests then SetPedComponentVariation(ped, 9, 0, 0, 1) end
end
