fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
}

client_scripts {
    "client-side/core.lua",
    "client-side/thread.lua",
}

server_scripts {
    "@vrp/config/Global.lua",
    "@oxmysql/lib/MySQL.lua",
    "config/functions.lua",
    "config/webhooks.lua",
    "server-side/core.lua",
}

files {
    "web-side/dist/index.html",
    "web-side/dist/**/*"
}
