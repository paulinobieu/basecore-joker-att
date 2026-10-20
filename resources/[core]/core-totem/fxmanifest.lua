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
    "client-side/core.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@vrp/config/Item.lua",
    "config/functions.lua",
    "config/webhooks.lua",
    "server-side/core.lua",
}

files {
    "web-side/dist/index.html",
    "web-side/dist/**/*"
}