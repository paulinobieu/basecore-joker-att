fx_version "bodacious"
game "gta5"
lua54 "yes"

author "@nagasakicode e @paulinobieu"
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
    "client/modules/actions.lua",
    "client/modules/nui.lua",
    "client/modules/request.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "config/webhooks.lua",
    "server/modules/database.lua",
    "server/server.lua",
    "server/modules/members.lua",
    "server/modules/goals.lua",
    "server/modules/bank.lua",
    "server/modules/settings.lua",
    "token.lua",
}

files {
    "web/index.html",
    "web/**/*",
}
