local Config = require 'config.main'
local blips = {}

NuiLoaded = false

--- CheckNui()
--- @return nil
--- @description Waits until the NUI is fully loaded before proceeding.
local function CheckNui()
    while not NuiLoaded do
        Wait(100)
    end
end

--- NuiMessage(action, payload)
--- @param action string The action to be sent to the NUI.
--- @param payload table The payload data to be sent with the action.
--- @return nil
--- @description Sends a message to the NUI with the specified action and payload after ensuring the
function NuiMessage(action, payload)
    CheckNui()
    SendNUIMessage({
        action = action,
        payload = payload
    })
end

local function GetWebLocales()
   local path = 'locales/' .. Config.Locale .. '.json'
   local file = LoadResourceFile(GetCurrentResourceName(), path)

   if not file then
      file = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
      Debug('warning', 'Locale file "%s" not found, falling back to default "en".', Config.Locale)
      return {}
   end

   if not file or file == '' then
      Debug('error', 'Locale file is empty or not found')
      error('Locale file is empty or not found')
      return {}
   end

   local success, content = pcall(json.decode, file)
   if not success then
      Debug('error', 'Failed to decode JSON from locale file: %s', content)
      error(('Failed to decode JSON from locale file: %s'):format(content))
      return {}
   end

   if not content['Web'] then
      Debug('error', 'Missing "Web" section in locale file')
      error('Missing "Web" section in locale file')
      return {}
   end

   return content['Web']
end

--- FetchNui()
--- @return nil
--- @description Continuously checks if the NUI is loaded by sending a message every 1 seconds until a response is received.
function FetchNui()
    Debug('info', 'Waiting for NUI to load...')
    while not NuiLoaded do
        if NetworkIsSessionStarted() then
            SendNUIMessage({
                action = 'nui/check',
            })
        end
        Wait(1000)
    end
    Debug('success', 'NUI loaded successfully')

    NuiMessage('nui/set-locales', {
        locales = GetWebLocales()
    })
end

--- CreateBlip(coords, blipConfig, name)
--- @param coords vector3 The coordinates where the blip should be created.
--- @param blipConfig table The configuration for the blip (sprite, color, scale).
--- @param name string The name to be displayed for the blip.
--- @return number The created blip handle.
--- @description Creates a blip on the map at the specified coordinates with the given configuration and
function CreateBlip(coords, blipConfig, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipConfig.sprite)
    SetBlipColour(blip, blipConfig.color)
    SetBlipScale(blip, blipConfig.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(name)
    EndTextCommandSetBlipName(blip)
    return blip
end


local function getChairAtCoords(coords)
    local object = lib.getClosestObject(coords, 1.5)
    return object
end


--- InitLocations()
--- @return nil
--- @description Initializes the nail studio locations by creating blips on the map for each studio defined in the configuration.
function InitLocations()
    Debug('info', 'Initializing nail studio locations')
    for studioIndex, studio in pairs(Config.NailStudios) do
        blips[#blips + 1] = CreateBlip(studio.coords, {
            sprite = Config.BlipSettings.sprite,
            color = Config.BlipSettings.color,
            scale = Config.BlipSettings.scale
        },  studio.name .. " - ".. Config.BlipSettings.name)

        for index, table in pairs(studio.tables) do
            if table.customer and next(table.customer) then
                if studio.job then goto continue end
                exports.sleepless_interact:addCoords(vector3(table.employee.coords.x, table.employee.coords.y, table.employee.coords.z + 0.5), {
                    label =  _T('target.sit_here'),
                    icon = 'fas fa-chair',
                    distance = 5.0,
                        onSelect = function()
                            local customerChair = lib.getClosestObject(vector3(table.customer.coords.x, table.customer.coords.y, table.customer.coords.z), 1.5)

                            if not customerChair then
                                Debug('error', 'No chair found for customer at studio %d, table %d', studioIndex, index)
                                return
                            end

                            Debug('info', 'Entering studio session at studio %d, table %d', studioIndex, index)
                            StudioIndex = studioIndex
                            TableIndex = index

                            local coords = GetOffsetFromEntityInWorldCoords(customerChair, table.customer.chairOffset.x, table.customer.chairOffset.y, table.customer.chairOffset.z)
                            local heading = GetEntityHeading(customerChair) - 180
                            local sittingCoords = vector4(coords.x, coords.y, coords.z, heading)
                            SetEntityHeading(cache.ped, sittingCoords.w or 0.0)
                            SetEntityCoords(cache.ped, sittingCoords.x, sittingCoords.y, sittingCoords.z, false, false, false, true)

                            local dict = "adezanim@anim"
                            local anim = "adezanim_clip"
                            lib.requestAnimDict(dict)

                            TaskPlayAnim(cache.ped, dict, anim, 8.0, 8.0, -1, 1, 0, false, false, false)
                            RemoveAnimDict(dict)

                            TriggerServerEvent(Scriptname .. ':server:setBusyTable', studioIndex, TableIndex, true)

                            Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
                            local cameraOffset = table.customer.cameraOffset or vec3(0.0, 0.0, 1.5)
                            local customerChairCoords = GetOffsetFromEntityInWorldCoords(customerChair, cameraOffset.x, cameraOffset.y, cameraOffset.z)
                            SetCamCoord(Camera, customerChairCoords.x, customerChairCoords.y, customerChairCoords.z)
                            SetCamRot(Camera, 270.0, 0.0, GetEntityHeading(customerChair), 2)
                            SetCamFov(Camera, 70.0)
                            SetCamActive(Camera, true)
                            RenderScriptCams(true, true, 2000, true, true)
                            InNailShop = true

                            Wait(2000)

                            NuiMessage('nui/toggle', {
                                show = true,
                            })
                            SetNuiFocus(true, true)

                            TriggerServerEvent(Scriptname .. ':server:requestPlayerNailData', vector3(table.customer.coords.x, table.customer.coords.y, table.customer.coords.z))
                        end,
                    canInteract = function(entity, distance, coords, name)
                        return distance < 2.0
                    end
                })


                ::continue::
            end

            if table.employee and next(table.employee) then
                if not studio.job then goto continue end
                exports.sleepless_interact:addCoords(vector3(table.employee.coords.x, table.employee.coords.y, table.employee.coords.z + 0.5), {
                    label = _T('target.open_nail_design_menu'),
                    icon = 'fas fa-hand-sparkles',
                    distance = 5.0,
                        onSelect = function()
                            local chair = getChairAtCoords(vector3(table.employee.coords.x, table.employee.coords.y, table.employee.coords.z))
                            if not chair then
                                Notify.SendNotify(_T('notify.chair_not_found'), 'error', 5000)
                                return
                            end

                            local customerChair = getChairAtCoords(vector3(table.customer.coords.x, table.customer.coords.y, table.customer.coords.z))
                            if not customerChair then
                                Notify.SendNotify(_T('notify.chair_not_found'), 'error', 5000)
                                return
                            end

                            local input = lib.inputDialog(_T('input.invite_to_customer'), {
                                {type = 'number', label = _T('input.player_id'), icon = 'hashtag'},
                            })

                            if not input then return end

                            local playerId = tonumber(input[1])
                            TriggerServerEvent(Scriptname .. ':server:inviteCustomerById', playerId, studioIndex, index)
                        end,
                    canInteract = function(entity, distance, coords, name)
                        return distance < 2.0
                    end
                })

                ::continue::
            end
        end
    end
    Debug('success', 'Initialized %d nail studio(s)', #Config.NailStudios)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, blip in pairs(blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
end)