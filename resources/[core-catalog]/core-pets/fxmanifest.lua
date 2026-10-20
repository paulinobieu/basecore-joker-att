fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "config/catalog.lua",
    "config/language.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/objects.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "token.lua",
    "@oxmysql/lib/MySQL.lua",
    "@vrp/config/Item.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "config/webhooks.lua",
    "server/modules/catalog.lua",
    "server/modules/database.lua",
    "server/modules/trade.lua",
    "server/modules/admin.lua",
    "server/modules/objects.lua",
    "server/modules/shop.lua",
    "server/server.lua",
}

files {
    "web/index.html",
    "web/**/*",
}
