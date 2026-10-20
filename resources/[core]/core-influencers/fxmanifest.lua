fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

shared_scripts {
	"@vrp/lib/utils.lua",
	"config/config.lua",
	"config/emotes.lua",
}

client_scripts {
	"@vrp/config/Global.lua",
	"config/functions.lua",
	"client/core.lua",
}

server_scripts {
	"config/functions.lua",
	"server/core.lua",
}

files {
	"web-side/dist/index.html",
	"web-side/dist/**/*",
	"sounds/*.ogg",
}
