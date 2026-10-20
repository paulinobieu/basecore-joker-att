fx_version "cerulean"
game "gta5"
lua54 "yes"

loadscreen "web/index.html"
loadscreen_cursor "yes"
loadscreen_manual_shutdown "yes"

shared_script "config/config.lua"

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "@vrp/lib/utils.lua",
    "server/framework.lua",
    "server/server.lua",
}

files {
    "web/index.html",
    "web/**/*",
}
