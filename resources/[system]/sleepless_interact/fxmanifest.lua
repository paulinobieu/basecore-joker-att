-- FX Information
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

version '2.1.2'

shared_scripts {
	'@vrp/lib/Utils.lua',
	'@vrp/config/Global.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/compat/init.lua',
	'init.lua',
	'client/api.lua',
	'client/main.lua',
}

files {
	'web/**',
	'client/modules/*.lua',
	'client/framework/*.lua',
	'client/compat/resources/*.lua'
}

provides {
	'ox_target',
	'qtarget'
}

dependency 'ox_lib'
