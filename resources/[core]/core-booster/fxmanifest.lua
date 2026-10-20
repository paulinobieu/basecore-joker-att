fx_version "cerulean"
game "gta5"
lua54 "yes"

author "@paulinobieu - Core Network"
description "Recompensas por boost e tag do servidor no Discord"

ui_page "web/dist/index.html"

shared_scripts {
    "@vrp/lib/Utils.lua",
    "config/config.lua",
    "config/language.lua",
}

client_scripts {
    "client/framework.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@vrp/config/Global.lua",
    "@vrp/config/Item.lua",
    "config/bot.lua",
    "server/framework.lua",
    "server/modules/discord.lua",
    "server/modules/database.lua",
    "server/modules/benefits.lua",
    "server/server.lua",
}

files {
    "web/dist/index.html",
    "web/dist/**/*",
}
