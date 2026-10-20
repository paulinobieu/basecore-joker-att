---@diagnostic disable: duplicate-set-field
Notify = Notify or {}

---This will send a notification to the specified player of the passed message and type
---@param src number
---@param message string
---@param _type string
---@param time number
Notify.SendNotify = function(src, message, _type, time)
    TriggerClientEvent(Scriptname .. ':client:Notify', src, message, _type, time)
end

return Notify