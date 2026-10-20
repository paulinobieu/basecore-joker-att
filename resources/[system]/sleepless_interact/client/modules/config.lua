local config = {}

-- this is the maximum distance that interacts will render the indicator sprite (little cirlce)
-- recommend keeping this pretty low for optimization
config.maxInteractDistance = 10.0

local r, g, b = HexToRGB(Theme.main)
config.themeColor = { r, g, b, 255 }

--- texture dictionary and texture name for the sprite used to show non active interactions.
config.IndicatorSprite = { dict = 'helicopterhud', txt = 'hudarrow' }

-- boolean true/false use a keybind to show and hide the interactions
config.useShowKeyBind = false

-- string default key mapping for the show interactions keybind
config.defaultShowKeyBind = 'LMENU'

-- "hold" | "toggle" sets the behavior of the show interactions key bind
config.showKeyBindBehavior = 'toggle'

return config