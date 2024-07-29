fx_version 'cerulean'

games { 'gta5' }

lua54 'yes'

author 'tuomass'

description ''

version '1.0.0'

shared_scripts {
'@es_extended/imports.lua',
'@ox_lib/init.lua',
}

client_scripts {

}

server_scripts {
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',
    'sx.lua'
}