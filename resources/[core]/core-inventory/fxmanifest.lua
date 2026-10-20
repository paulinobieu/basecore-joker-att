fx_version "cerulean"
game "gta5"
lua54 "yes"

author "@paulinobieu - Core Network"
description "Inventario, baus e revista em um unico recurso"

ui_page "web/build/index.html"

shared_scripts {
    "@vrp/config/Item.lua",
    "@vrp/config/Vehicle.lua",
    "@vrp/config/Global.lua",
    "@vrp/config/Drops.lua",
    "@vrp/lib/Utils.lua",
    "config/shared/general.lua",
    "config/shared/chests.lua",
    "config/shared/robberies.lua",
    "config/shared/sprays.lua",
    "config/language.lua",
}

client_scripts {
	"config/client/gameplay.lua",
	"config/client/items.lua",
    "config/client/dismantle.lua",
    "config/client/drugs.lua",
    "config/client/hunting.lua",
    "config/client/moneywash.lua",
    "config/client/sprays.lua",
    "config/client/weapons.lua",
    "@vrp/config/Native.lua",
    "@PolyZone/client.lua",
    "client/framework.lua",
    "client/modules/core.lua",
    "client/modules/dismantle.lua",
    "client/modules/drugs.lua",
    "client/modules/hunting.lua",
    "client/modules/moneywash.lua",
    "client/modules/robbery.lua",
    "client/modules/rope.lua",
    "client/modules/screenshot.lua",
    "client/modules/scuba.lua",
    "client/modules/sprays.lua",
    "client/modules/stealpeds.lua",
    "client/modules/tow.lua",
    "client/modules/weapons.lua",
    "client/modules/chest.lua",
    "client/modules/inspect.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "config/server/actions.lua",
    "config/server/chests.lua",
    "config/server/crafting.lua",
    "config/server/dismantle.lua",
    "config/server/drops.lua",
    "config/server/drugs.lua",
	"config/server/items.lua",
    "config/server/loot.lua",
    "config/server/moneywash.lua",
    "config/server/objects.lua",
    "config/server/robberies.lua",
    "config/server/stockade.lua",
    "config/server/weapons.lua",
    "server/modules/weapons.lua",
    "server/modules/lunchbag.lua",
    "server/modules/core.lua",
    "server/modules/dismantle.lua",
    "server/modules/drops.lua",
    "server/modules/drugs.lua",
    "server/modules/itens.lua",
    "server/modules/moneywash.lua",
    "server/modules/nui.lua",
    "server/modules/objects.lua",
    "server/modules/robbery.lua",
    "server/modules/rope.lua",
    "server/modules/stockade.lua",
    "server/modules/swimming.lua",
    "server/modules/tow.lua",
    "server/modules/chest.lua",
    "server/modules/inspect.lua",
    "server/server.lua",
}

files {
    "web/build/index.html",
    "web/build/**/*",
}

escrow_ignore {
    "config/*.lua",
    "config/**/*.lua",
    "client/framework.lua",
    "server/framework.lua",
}
