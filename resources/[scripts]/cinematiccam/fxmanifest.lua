fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Randolio'
description 'Cinematic Cam'

shared_scripts {
	'@ox_lib/init.lua',
}

client_scripts {
	'cl_freecam.lua',
}

server_scripts {
	'@vrp/lib/utils.lua',
	'sv_freecam.lua',
}

files {
	'config.lua',
}
