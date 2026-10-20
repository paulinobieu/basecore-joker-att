fx_version "cerulean"
game "gta5"
lua54 "yes"

author "@paulinobieu - Core Network"
description "Lojas de compra com interface própria e carrinho"

ui_page "web/dist/index.html"

shared_scripts {
    "@vrp/lib/Utils.lua",
    "config/config.lua",
    "config/locations.lua",
    "config/language.lua",
}

client_scripts {
    "client/framework.lua",
    "client/modules/common.lua",
    "client/modules/shops.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "@vrp/config/Global.lua",
    "@vrp/config/Item.lua",
    "server/framework.lua",
    "server/modules/catalog.lua",
    "server/modules/purchase.lua",
    "server/server.lua",
}

files {
    "web/dist/index.html",
    "web/dist/**/*",
}
