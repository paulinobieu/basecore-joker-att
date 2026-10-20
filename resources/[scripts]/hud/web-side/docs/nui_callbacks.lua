---@class MessageProps
---@field context string
---@field author? string
---@field typeIcon? { src: string, className?: string }
---@field content? string
---@field header? { title: string, subtitle?: string, icon: { src: string, className?: string }, textDirection: "row" | "column", className?: string }
---@field footer? { title: string, subtitle?: string, icon: { src: string, className?: string }, textDirection: "row" | "column", className?: string }
---@field typeStyles? table
---@field containerStyles? table

---@class IVelocimeterData
---@field speed number
---@field headlight boolean
---@field seatbelt boolean
---@field lock boolean
---@field fuel number
---@field nitro number
---@field rpm number
---@field gear string
---@field engine number

---@class IWeapon
---@field image string
---@field name string
---@field ammo { current: number, loader: number }

---@class IAnnounce
---@field image { src: string, dimensions?: { width: string, height: string } }
---@field header { text: string, icon: string }
---@field text string
---@field id string
---@field timeout number
---@field color string
---@field footer? { pressKey: string, action: string }

---@class IMenu
---@field notify boolean
---@field radar boolean
---@field chat boolean
---@field hide boolean
---@field velocimeter "rounded" | "digital"
---@field survival "rounded" | "lonzege"
---@field survivalSettings { life: boolean, shield: boolean, hungry: boolean, thirst: boolean, stamina: boolean, stress: boolean, oxygen: boolean }

---@class MinimapDimensions
---@field width number
---@field height number
---@field left number
---@field top number

---@class ServerColors
---@field primaryColor string
---@field secondaryColor string
---@field thirdyColor string

local chatState = {}
local menuState = {}
local minimapState = {}
local uiState = {}

---@param data MessageProps
local function sendChatMessage(data)
    SendNUIMessage({
        action = "chat:message",
        payload = data
    })
end

---@param focused boolean
local function setChatInputFocus(focused)
    SendNUIMessage({
        action = "chat:inputfocus",
        payload = focused
    })
end

---@param velocimeterData IVelocimeterData
local function setVelocimeter(velocimeterData)
    SendNUIMessage({
        action = "set:velocimeter",
        payload = velocimeterData
    })
end

---@param visible boolean
local function setMenuVisible(visible)
    SendNUIMessage({
        action = "set:menu:visible",
        payload = visible
    })
end

---@param announce IAnnounce
local function addAnnounce(announce)
    SendNUIMessage({
        action = "set:announces:add",
        payload = announce
    })
end

---@param weapon IWeapon
local function setWeapon(weapon)
    SendNUIMessage({
        action = "set:weapon",
        payload = weapon
    })
end

---@param wanted boolean
local function setWanted(wanted)
    SendNUIMessage({
        action = "set:wanted",
        payload = wanted
    })
end

---@param thirst number
local function setThirst(thirst)
    SendNUIMessage({
        action = "set:thirst",
        payload = thirst
    })
end

---@param stress number
local function setStress(stress)
    SendNUIMessage({
        action = "set:stress",
        payload = stress
    })
end

---@param passport number
local function setPassport(passport)
    SendNUIMessage({
        action = "set:passport",
        payload = passport
    })
end

---@param callback function
local function refetchMinimapDimensions(callback)
    SendNUIMessage({
        action = "refetch:minimapDimensions",
        payload = callback
    })
end

---@param data { message: string, context: string }
RegisterNUICallback("sendChatMessage", function(data, cb)
    local message = data.message
    local context = data.context

    chatState.lastMessage = {
        message = message,
        context = context,
        timestamp = os.time()
    }

    cb(true)
end)

---@param data boolean
RegisterNUICallback("setChatFocus", function(data, cb)
    local isFocused = data

    chatState.inputFocused = isFocused

    cb(true)
end)

---@param data nil
RegisterNUICallback("getChatCategories", function(data, cb)
    local categories = {
        "global",
        "OCC",
        "staff"
    }

    cb(categories)
end)

---@param data nil
RegisterNUICallback("get:menu:savedSettings", function(data, cb)
    local settings = {
        velocimeter = "digital",
        survival = "rounded",
        chat = true,
        radar = true,
        hide = false,
        notify = true,
        survivalSettings = {
            hungry = true,
            life = true,
            shield = true,
            stamina = true,
            thirst = true,
            stress = true,
            oxygen = true
        }
    }

    menuState = settings
    cb(settings)
end)

---@param data { option: "notify" | "radar" | "chat" | "hide" | "life" | "shield" | "hungry" | "thirst" | "stamina" | "stress" | "oxygen" }
RegisterNUICallback("post:menu:toggle:*", function(data, cb)
    local option = data.option

    cb(true)
end)

---@param data nil
RegisterNUICallback("post:menu:setVelocimeter", function(data, cb)
    cb(true)
end)

---@param data nil
RegisterNUICallback("post:menu:setSurvival", function(data, cb)
    cb(true)
end)

---@param data nil
RegisterNUICallback("post:closeUi", function(data, cb)
    uiState.visible = false

    cb(true)
end)

---@param data nil
RegisterNUICallback("fetchMapPosition", function(data, cb)
    local minimapDimensions = {
        width = 250,
        height = 174,
        left = 40,
        top = 700
    }

    minimapState = minimapDimensions
    cb(minimapDimensions)
end)

---@param data nil
RegisterNUICallback("get:colors", function(data, cb)
    local colors = {
        primaryColor = "#dc1553",
        secondaryColor = "#dc1553",
        thirdyColor = "#dc1553"
    }

    cb(colors)
end)
