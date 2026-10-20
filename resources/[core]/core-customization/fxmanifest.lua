fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/dist/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "config/clothes.lua",
    "config/tattoos.lua",
    "config/language.lua",
    "shared/clothes.lua",
}

client_scripts {
    "@vrp/config/Global.lua",
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/camera.lua",
    "client/modules/clothes.lua",
    "client/modules/tattoos.lua",
    "client/modules/scene.lua",
    "client/modules/skinshop.lua",
    "client/modules/tattooshop.lua",
    "client/modules/nui.lua",
    "client/modules/catalog.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "config/webhooks.lua",
    "server/modules/outfit.lua",
    "server/modules/clothes.lua",
    "server/modules/tattoos.lua",
    "server/server.lua",
}

files {
    "web/dist/index.html",
    "web/dist/**/*",
}
