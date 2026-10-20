fx_version "cerulean"
game "gta5"
lua54 "yes"

description "core-wardrobe"

ui_page "web-side/dist/index.html"

files {
    "web-side/dist/**/*"
}

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client-side/core.lua",
}

server_scripts {
    "@vrp/config/Global.lua",
    "@oxmysql/lib/MySQL.lua",
    "server-side/core.lua",
}
