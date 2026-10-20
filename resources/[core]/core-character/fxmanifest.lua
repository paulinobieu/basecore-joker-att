fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/dist/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "config/appearance.lua",
    "config/language.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/camera.lua",
    "client/modules/appearance.lua",
    "client/modules/cutscene.lua",
    "client/modules/creator.lua",
    "client/modules/barber.lua",
    "client/modules/select.lua",
    "client/modules/spawn.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "config/webhooks.lua",
    "server/modules/database.lua",
    "server/modules/appearance.lua",
    "server/modules/characters.lua",
    "server/modules/creator.lua",
    "server/server.lua",
}

files {
    "web/dist/index.html",
    "web/dist/**/*",
}
