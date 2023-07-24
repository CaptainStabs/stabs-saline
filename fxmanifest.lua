fx_version 'bodacious'
game 'gta5'

author 'Stabs'
version '1.0.0'

client_script 'client/client.lua'
server_script 'server/server.lua'
shared_scripts {
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
}
