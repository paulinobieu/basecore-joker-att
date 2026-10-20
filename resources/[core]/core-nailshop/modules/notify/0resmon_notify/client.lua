---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local Config <const> = require 'config.main'

local resourceName = "0resmon_notify"
local configValue = Config.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


Notify.GetResourceName = function()
    return resourceName
end

local function getTitle(status)
    if status == 'error' then
        return _T("notify.error")
    elseif status == 'success' then
        return _T("notify.success")
    elseif status == 'warning' then
        return _T("notify.warning")
    else
        return _T("notify.info")
    end
end

---This will send a notify message of the type and time passed
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(message, _type, time)
    time = time or 3000

    NuiMessage('notification/add', {
        type = _type or 'info',
        title = getTitle(_type),
        message = message,
        duration = time
    })
end

RegisterNetEvent(Scriptname .. ':client:Notify', function(message, _type, time)
    Notify.SendNotify(message, _type, time)
end)

return Notify