local Config <const> = require 'config.main'
Scriptname = 'core-nailshop'

local debugStatus <const> = {
    ['success'] = '^2[SUCCESS]^0',
    ['error'] = '^1[ERROR]^0',
    ['warning'] = '^3[WARNING]^0',
    ['info'] = '^4[INFO]^0',
}

function Debug(status, message, ...)
    if Config.Debug then
        local formattedMessage = string.format(message, ...)
        print("[DEBUG] " .. debugStatus[status] .. " " .. formattedMessage)
    end
end