fx_version "cerulean"
game "gta5"
lua54 "yes"

author "@paulinobieu - Core Network"
description "Banco: contas, PIX, faturas, multas, investimentos e criptomoedas"

ui_page "web/dist/index.html"

shared_scripts {
    "@vrp/lib/utils.lua",
    "config/config.lua",
    "config/investments.lua",
    "config/cryptos.lua",
    "config/language.lua",
}

client_scripts {
    "client/framework.lua",
    "client/modules/nui.lua",
    "client/client.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/framework.lua",
    "server/modules/common.lua",
    "server/modules/database.lua",
    "server/modules/accounts.lua",
    "server/modules/ledger.lua",
    "server/modules/transfers.lua",
    "server/modules/pix.lua",
    "server/modules/invoices.lua",
    "server/modules/fines.lua",
    "server/modules/investments.lua",
    "server/modules/crypto.lua",
    "server/server.lua",
}

files {
    "web/dist/index.html",
    "web/dist/assets/*",
}
