fx_version "bodacious"
game "gta5"
lua54 "yes"

author "@nagasakicode"
description "Core Network - https://corenetwork.dev"

dependency "oxmysql"

ui_page "web/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "shared/tunnel.lua",
}

client_scripts {
    "client/framework.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/common.lua",
    "config/webhooks.lua",
    "server/server.lua",
    "token.lua",
}

files {
    "web/index.html",
    "web/**/*",
    "stream/*.ytyp",
}

data_file "DLC_ITYP_REQUEST" "stream/*.ytyp"
