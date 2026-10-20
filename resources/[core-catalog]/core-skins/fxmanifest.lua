fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "server/tunnel.lua",
    "config/config.lua",
    "config/language.lua",
    "config/weapons.lua",
    "config/cases.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/weapons.lua",
    "client/modules/preview.lua",
    "client/modules/weapontest.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "token.lua",
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "config/webhooks.lua",
    "server/modules/common.lua",
    "server/modules/catalog.lua",
    "server/modules/database.lua",
    "server/modules/inventory.lua",
    "server/modules/cases.lua",
    "server/modules/trade.lua",
    "server/modules/improvement.lua",
    "server/modules/ranking.lua",
    "server/modules/weapontest.lua",
    "server/modules/admin.lua",
    "server/server.lua",
}

files {
    "web/index.html",
    "web/**/*",
}
