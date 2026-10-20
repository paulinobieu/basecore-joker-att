fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web/dist/index.html"

shared_scripts {
	"@vrp/lib/utils.lua",
	"config/config.lua",
}

client_scripts {
	"config/functions.lua",
	"client/core.lua",
}

server_scripts {
	"@vrp/config/Item.lua",
	"config/functions.lua",
	"server/core.lua",
}

files {
	"web/dist/index.html",
	"web/dist/**/*",
}
