fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

client_scripts {
	"@vrp/config/Native.lua",
	"@vrp/config/Global.lua",
	"@PolyZone/client.lua",
	"@vrp/lib/Utils.lua",
	"client-side/*"
}

files {
	"web-side/dist/index.html",
	"web-side/dist/**/*"
}