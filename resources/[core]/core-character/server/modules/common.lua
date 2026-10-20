-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local GetResourceState = GetResourceState
local TriggerClientEvent = TriggerClientEvent
local tonumber = tonumber
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATENUMBER
-----------------------------------------------------------------------------------------------------------------------------------------
function ValidateNumber(val, min, max, default)
    local num = tonumber(val)
    if not num then return default or 0 end
    if min and num < min then return min end
    if max and num > max then return max end
    return num
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATESTRING
-----------------------------------------------------------------------------------------------------------------------------------------
function ValidateString(val, minLen, maxLen, default)
    if type(val) ~= "string" then return default or "" end
    local trimmed = val:gsub("^%s+", ""):gsub("%s+$", "")
    if minLen and #trimmed < minLen then return default or "" end
    if maxLen and #trimmed > maxLen then return trimmed:sub(1, maxLen) end
    return trimmed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATENAME
-----------------------------------------------------------------------------------------------------------------------------------------
function ValidateName(val)
    local name = ValidateString(val, 2, 20, "")
    if name == "" then return nil end
    if name:find("%s") then return nil end
    if name:find("[%d%p]") then return nil end
    return name
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDINTERFACEMESSAGE
-----------------------------------------------------------------------------------------------------------------------------------------
function SendInterfaceMessage(src, action, data)
    TriggerClientEvent("core-character:nuiMessage", src, action, data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDACTIONRESULT
-----------------------------------------------------------------------------------------------------------------------------------------
function SendActionResult(src, ok, action, err)
    SendInterfaceMessage(src, "actionResult", { ok = ok, action = action, err = err })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
function Notify(src, message, severity)
    SendInterfaceMessage(src, "notify", {
        severity = severity or "info",
        title = "Personagem",
        message = message,
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORELOG
-----------------------------------------------------------------------------------------------------------------------------------------
function CoreLog(category, data)
    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog(category, data)
    elseif Webhooks and Webhooks.Log then
        Webhooks.Log(category, data)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USERNAME
-----------------------------------------------------------------------------------------------------------------------------------------
local UserNames = {}

function UserName(userId)
    if not userId then return nil end

    local cached = UserNames[userId]
    if cached ~= nil then return cached or nil end

    local name = Framework.UserName(userId)
    UserNames[userId] = name or false
    return name
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORGETUSERNAME
-----------------------------------------------------------------------------------------------------------------------------------------
function ForgetUserName(userId)
    if userId then UserNames[userId] = nil end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
function IsModel(model)
    return model == "mp_m_freemode_01" or model == "mp_f_freemode_01"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLERS
-----------------------------------------------------------------------------------------------------------------------------------------
Handlers = {}
