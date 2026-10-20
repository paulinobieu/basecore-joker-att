fx_version "bodacious"
game "gta5"
lua54 "yes"

ui_page "web-side/dist/index.html"

client_scripts {
	"@vrp/config/Global.lua",
	"@vrp/config/Native.lua",
	"@PolyZone/client.lua",
	"@vrp/lib/Utils.lua",
	"config/*",
	"client-side/*"
}

server_scripts {
	"@vrp/lib/Utils.lua",
	"server-side/*"
}

files {
	"web-side/dist/index.html",
	"web-side/dist/assets/*",
}

shared_scripts {
	"@vrp/config/Item.lua",
	"@vrp/config/Vehicle.lua",
	"@vrp/config/Global.lua",
	"@vrp/config/Drops.lua"
}
