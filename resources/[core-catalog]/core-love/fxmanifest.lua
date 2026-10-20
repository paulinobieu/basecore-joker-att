fx_version "cerulean"
game "gta5"
lua54 "yes"

author "@paulinobieu e @nagasakicode - Core Network"

ui_page "web/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "server/tunnel.lua",
    "config/config.lua",
    "config/language.lua",
}

client_scripts {
    "client/framework.lua",
    "client/modules/nui.lua",
    "client/modules/requests.lua",
    "client/modules/propose.lua",
    "client/client.lua",
}

server_scripts {
    "token.lua",
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "server/modules/database.lua",
    "server/modules/relationship.lua",
    "server/modules/letters.lua",
    "server/modules/requests.lua",
    "server/server.lua",
}

files {
    "web/index.html",
    "web/**/*",
}
