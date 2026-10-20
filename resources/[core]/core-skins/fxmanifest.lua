fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/index.html"

shared_scripts {
	"@vrp/lib/utils.lua",
	"config/config.lua",
	"config/weapons.lua",
	"config/cases.lua",
}

client_scripts {
	"@vrp/config/Global.lua",
	"config/framework.lua",
	"client/core.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"config/framework.lua",
	"config/webhook.lua",
	"server/core.lua",
}

files {
	"web/index.html",
	"web/**/*",
}
