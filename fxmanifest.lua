fx_version 'adamant'

game 'gta5'

description 'Old Gunrange'

version '1.0.0'

client_scripts {
    '@es_extended/locale.lua', 
    'locales/en.lua',
    'locales/fr.lua', 
    'config.lua', 
    'client/main.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua', 
    'server/main.lua', 
    'server/scoreboard.lua'
}

shared_script '@es_extended/imports.lua'