---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local Config <const> = require 'config.main'

local resourceName = "ox_lib"
local configValue = Config.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


Notify.GetResourceName = function()
    return resourceName
end

---This will send a notify message of the type and time passed
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    return exports.ox_lib:notify({ description = message, type = _type, duration = time, position = 'top-right' })
end

RegisterNetEvent(Scriptname .. ':client:Notify', function(message, _type, time)
    Notify.SendNotify(message, _type, time)
end)

return Notify