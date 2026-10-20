fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "@vrp/config/Global.lua",
    "config/config.lua",
}

client_scripts {
    "client-side/_core.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@vrp/config/Item.lua",
    "@vrp/config/Vehicle.lua",
    "config/functions.lua",
    "server-side/core.lua",
}

files {
    "web-side/dist/index.html",
    "web-side/dist/**/*",
}
