fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

shared_scripts {
	"@vrp/lib/utils.lua",
	"config/config.lua",
}

client_scripts {
	"@vrp/config/Global.lua",
	"client-side/core.lua",
}

server_scripts {
	"config/functions.lua",
	"server-side/core.lua",
}

files {
	"web-side/dist/index.html",
	"web-side/dist/**/*"
}