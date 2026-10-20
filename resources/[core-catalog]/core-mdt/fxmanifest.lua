fx_version "bodacious"
game "gta5"
lua54 "yes"

author "Nagasakicode"
description "Core Network - https://corenetwork.dev"

dependency "oxmysql"

ui_page "web/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "server/tunnel.lua",
}

client_scripts {
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/proximity.lua",
    "client/modules/nui.lua",
    "client/modules/request.lua",
    "client/modules/prison.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "config/webhooks.lua",
    "server/modules/database.lua",
    "server/server.lua",
    "server/modules/occurrences.lua",
    "server/modules/records.lua",
    "server/modules/officers.lua",
    "server/modules/investigations.lua",
    "server/modules/prison.lua",
    "token.lua",
}

files {
    "web/index.html",
    "web/**/*",
}
