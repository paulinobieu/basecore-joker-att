fx_version "cerulean"
game "gta5"
lua54 "yes"

author "@paulinobieu - Core Network"
description "Bancadas de fabricação com fila de produção por jogador"

ui_page "web/dist/index.html"

shared_scripts {
    "@vrp/lib/Utils.lua",
    "config/config.lua",
    "config/stations.lua",
    "config/recipes.lua",
    "config/language.lua",
}

client_scripts {
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/workbench.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@vrp/config/Global.lua",
    "@vrp/config/Item.lua",
    "server/framework.lua",
    "server/modules/database.lua",
    "server/modules/queue.lua",
    "server/modules/crafting.lua",
    "server/server.lua",
}

files {
    "web/dist/index.html",
    "web/dist/**/*",
}
