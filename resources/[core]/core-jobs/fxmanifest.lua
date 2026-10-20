dependency "core-vehicles"
fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "config/professions.lua",
    "config/routes.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client-side/client.lua",
    "client-side/professions.lua",
}

server_scripts {
    "@vrp/config/Global.lua",
    "@oxmysql/lib/MySQL.lua",
    "config/webhooks.lua",
    "config/functions.lua",
    "server-side/server.lua",
}

files {
    "web-side/dist/**"
}
