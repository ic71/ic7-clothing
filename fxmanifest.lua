fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ic7'
description 'SevenM Clothing UI'
version '1.0.0'

client_scripts {
    'Client/config.lua',
    'Client/Functions.lua',
    'Client/Variations.lua',
    'Client/Clothing.lua',
    'Client/nui.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/style.css',
    'ui/js/ui.js',
    'ui/imgs/*.png'
}

files {
    'Locale/*.lua'
}


export 'OpenClothingUI'
export 'CloseClothingUI'
export 'IsUIOpen'
export 'UpdateUIClothingState'

