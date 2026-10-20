---@class IWeapon
---@field image string
---@field name string
---@field ammo { current: number, loader: number }

---@class IData
---@field logo string
---@field dimensions { width: string, height: string, top: string }

---@class NotifyProps
---@field id string
---@field type "success" | "error" | "warn" | "info"
---@field message string
---@field title? string
---@field timeout number

---@class IProgress
---@field time number
---@field text string

---@class IPlayer
---@field id number
---@field name string

---@class IHoverfy
---@field pressKey string
---@field action string

local radio = nil
local time = "00:00"
local voiceLevel = 1
local isTalking = false
local passport = 0
local rest = false
local wanted = false
local robbery = nil
local weapon = nil
local hoverfy = nil
local progress = nil
local safezone = false
local radioUsers = {}

---@param data number | nil
local function setRadio(data)
    SendNUIMessage({
        action = "set:radio",
        payload = data
    })
end

---@param data string
local function setTime(data)
    SendNUIMessage({
        action = "set:time",
        payload = data
    })
end

---@param data number
local function setVoiceLevel(data)
    SendNUIMessage({
        action = "set:voice:level",
        payload = data
    })
end

---@param data boolean
local function setVoiceIsTalking(data)
    SendNUIMessage({
        action = "set:voice:isTalking",
        payload = data
    })
end

---@param data number
local function setPassport(data)
    SendNUIMessage({
        action = "set:passport",
        payload = data
    })
end

---@param data boolean
local function setRest(data)
    SendNUIMessage({
        action = "set:rest",
        payload = data
    })
end

---@param data boolean
local function setWanted(data)
    SendNUIMessage({
        action = "set:wanted",
        payload = data
    })
end

---@param data string | nil
local function setRobbery(data)
    SendNUIMessage({
        action = "set:robbery",
        payload = data
    })
end

---@param data IWeapon | nil
local function setWeapon(data)
    SendNUIMessage({
        action = "set:weapon",
        payload = data
    })
end

---@param data IHoverfy | nil
local function setHoverfy(data)
    SendNUIMessage({
        action = "set:hoverfy",
        payload = data
    })
end

---@param data NotifyProps
local function sendNotify(data)
    SendNUIMessage({
        action = "notify:message",
        payload = data
    })
end

---@param data IProgress | nil
local function setProgress(data)
    SendNUIMessage({
        action = "set:progress",
        payload = data
    })
end

---@param data IPlayer[]
local function setRadioUsers(data)
    SendNUIMessage({
        action = "radio:users",
        payload = data
    })
end

---@param data boolean
local function setSafezone(data)
    SendNUIMessage({
        action = "set:safezone",
        payload = data
    })
end

---@param data {  }
RegisterNUICallback("get:logo:data", function(data, cb)
    cb({
        logo = "",
        dimensions = {
            width = "9.375rem",
            height = "9.375rem",
            top = "-1.1875rem"
        }
    })
end)

RegisterNUICallback('get:colors', function(_, cb)
    cb({
        primaryColor = "#8000FF",   -- HEX ou RGB/RGBA
        secondaryColor = "#8000FF", -- HEX ou RGB/RGBA
        thirdyColor = "#8000FF",    -- HEX ou RGB/RGBA
    })
end)
