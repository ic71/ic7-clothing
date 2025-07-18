// SevenM Clothing UI
let isUIOpen = false;
let currentSelectedItem = null;
let branchLines = {};
let linesDrawn = false;
let Config = null; 

const clothingItemsMap = {
    'hat': 'head',
    'hair': 'head',
    'glasses': 'ic7',
    'mask': 'ic7',
    'earrings': 'accessories',
    'neck': 'accessories',
    
    'top': 'torso',
    'shirt': 'torso',
    'vest': 'Sm',
    'bag': 'Sm',
    
    'pants': 'legs',
    'shoes': 'shoes',
    
    'gloves': 'arms',
    'watch': 'arms'
};

const clothingItems = Object.keys(clothingItemsMap);

$(document).ready(function() {
    initializeUI();
    setupEventListeners();
    setupNUICallbacks();
    
    setTimeout(() => {
        checkAndHideUnwornItems();
    }, 500);
});

function checkAndHideUnwornItems() {
    if (Config && Config.NUI && Config.NUI.HideUnwornItems) {
        $('.clothing-item-icon').each(function() {
            if (!$(this).hasClass('active')) {
                $(this).hide();
                
                const itemId = $(this).attr('id').split('-')[0];
                if (branchLines[itemId]) {
                    branchLines[itemId].setAttribute('d', '');
                    $(branchLines[itemId]).hide();
                }
            }
        });
    }
}

function initializeUI() {
    console.log('Initializing DP Clothing UI...');
    
    $('#clothing-ui').addClass('hidden');
    
    initializeBranchingLines();
    
    console.log('UI initialized successfully');
}
    
function setupEventListeners() {
    $('.clothing-item-icon').on('click', function(e) {
        e.preventDefault();
        
        if ($(this).hasClass('disabled')) {
            return;
        }
        
        const command = $(this).data('command');
        const itemName = $(this).data('item');
        
        selectClothingItem(this, itemName, command);
        playClickSound();
        
        $.post(`https://${GetParentResourceName()}/toggleClothing`, JSON.stringify({
            command: command,
            item: itemName
        }));
    });
    
    $('#reset-btn').on('click', function(e) {
        e.preventDefault();
        resetAllClothing();
        playClickSound();
        
        $.post(`https://${GetParentResourceName()}/resetClothing`, JSON.stringify({}));
    });
    
    $('#close-btn').on('click', function(e) {
        e.preventDefault();
        closeUI();
        playClickSound();
        
        $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
    });
    
    $('.clothing-item-icon, .control-btn').on('mouseenter', function() {
        playHoverSound();
    });
    
    $(document).on('keydown', function(e) {
        if (e.key === 'Escape' && isUIOpen) {
            closeUI();
            $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
        }
    });
    
    $(window).on('resize', function() {
        if (isUIOpen) {
            linesDrawn = false;
            setTimeout(drawAllBranchingLines, 200);
        }
    });
}

function setupNUICallbacks() {
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        switch(data.action) {
            case 'openUI':
                openUI();
                break;
                
            case 'closeUI':
                closeUI();
                break;
                
            case 'updateClothingState':
                updateClothingState(data.item, data.state);
                break;
                
            case 'resetAllItems':
                resetAllClothing();
                break;
                
            case 'setConfig': 
                Config = data.config;
                console.log('Received config from server:', Config);
                break;
                
            case 'update':  
                if (data.cloth) {
                    setItemActive(data.cloth);
                }
                break;
                
            case 'update2': 
                if (data.cloth) {
                    setItemInactive(data.cloth);
                }
                break;
                
            case 'getallresets': 
                if (data.cloth) {
                    setItemInactive(data.cloth);
                }
                break;
                
            default:
                console.log('Unknown action:', data.action);
        }
    });
}
    
function openUI() {
    console.log('Opening clothing UI...');
    isUIOpen = true;
    linesDrawn = false;
    
    $('#clothing-ui').removeClass('hidden').addClass('visible fade-in');
    
    $('#clothing-ui').css('display', 'block');
    
    $('.body-part-origin').show();
    
    $('.clothing-item-icon').css({
        'opacity': 0,
        'display': 'flex'
    }).animate({
        'opacity': 1
    }, 300);
    
    $('.control-panel').css({
        'opacity': 0,
        'display': 'flex'
    }).animate({
        'opacity': 1
    }, 300);
    
    setTimeout(() => {
        if (Config && Config.NUI && Config.NUI.HideUnwornItems) {
            $('.clothing-item-icon').each(function() {
                if (!$(this).hasClass('active')) {
                    $(this).hide();
                }
            });
        }
        
        drawAllBranchingLines();
        
        setTimeout(drawAllBranchingLines, 500);
        setTimeout(drawAllBranchingLines, 1000);
    }, 100);
    
    $('body').css('cursor', 'default');
    
    console.log('UI should be visible now');
    console.log('Number of clothing icons:', $('.clothing-item-icon').length);
    console.log('Body origins visible:', $('.body-part-origin').is(':visible'));
}

function closeUI() {
    console.log('Closing clothing UI...');
    isUIOpen = false;
    linesDrawn = false;
    
    $('#clothing-ui').addClass('hidden').removeClass('visible');
    
    clearAllLines();
    
    $('body').css('cursor', 'none');
}

function initializeBranchingLines() {
    const svg = document.getElementById('connecting-lines');
    
    clothingItems.forEach(item => {
        const branchLine = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        branchLine.setAttribute('class', 'branch-line');
        branchLine.setAttribute('id', `branch-${item}`);
        svg.appendChild(branchLine);
        branchLines[item] = branchLine;
    });
    
    console.log("Line elements created: ", Object.keys(branchLines).length);
}

function drawAllBranchingLines() {
    if (linesDrawn) return;
    
    console.log("Drawing all branching lines...");
    
    $('.body-part-origin').show();
    
    let allElementsReady = true;
    
    for (let item of clothingItems) {
        const element = $(`#${item}-icon`);
        if (element.length === 0) {
            allElementsReady = false;
            console.log(`Icon for ${item} not ready`);
            continue;
        }
        
        const originType = clothingItemsMap[item];
        const origin = $(`#${originType}-origin`);
        
        if (origin.length === 0) {
            allElementsReady = false;
            console.log(`Origin for ${originType} not ready`);
            continue;
        }
        
        if (!element.is(':visible') && Config && Config.NUI && Config.NUI.HideUnwornItems) {
            continue;
        }
        
        if (!isElementInViewport(element[0]) || !isElementInViewport(origin[0])) {
            allElementsReady = false;
            console.log(`Element or origin for ${item} not in viewport`);
        }
    }
    
    if (!allElementsReady) {
        console.log("Not all elements are ready, retrying later...");
        setTimeout(drawAllBranchingLines, 200);
        return;
    }
    
    for (let item of clothingItems) {
        const itemElement = $(`#${item}-icon`);
        
        if (itemElement.is(':visible')) {
            drawDirectLineFromOriginToItem(item);
        } else {
            if (branchLines[item]) {
                branchLines[item].setAttribute('d', '');
            }
        }
    }
    
    const branchLinesDrawn = Object.values(branchLines).filter(line => line.getAttribute('d')).length;
    console.log(`Drew ${branchLinesDrawn} direct branch lines`);
    
    if (branchLinesDrawn > 0) {
        linesDrawn = true;
    }
}

function isElementInViewport(el) {
    const rect = el.getBoundingClientRect();
    return (
        rect.width > 0 &&
        rect.height > 0 &&
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth) &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight)
    );
}

function drawDirectLineFromOriginToItem(item) {
    const itemElement = $(`#${item}-icon`);
    
    if (itemElement.length === 0 || !itemElement.is(':visible')) {
        console.log(`Item element not found or not visible: #${item}-icon`);
        return;
    }
    
    const originType = clothingItemsMap[item];
    const origin = $(`#${originType}-origin`);
    
    if (origin.length === 0) {
        console.log(`Origin not found for type: ${originType}`);
        return;
    }
    
    const originRect = origin[0].getBoundingClientRect();
    const itemRect = itemElement[0].getBoundingClientRect();

    if (originRect.width === 0 || originRect.height === 0 || itemRect.width === 0 || itemRect.height === 0) {
        console.log(`Invalid dimensions for ${item} or its origin`);
        return;
    }
    
    const startX = originRect.left + originRect.width / 2;
    const startY = originRect.top + originRect.height / 2;
    const endX = itemRect.left + itemRect.width / 2;
    const endY = itemRect.top + itemRect.height / 2;
    
    if (startX === 0 && startY === 0 || endX === 0 && endY === 0) {
        console.log(`Invalid position for ${item} or its origin`);
        return;
    }
    
    const dx = endX - startX;
    const dy = endY - startY;
    const distance = Math.sqrt(dx*dx + dy*dy);
    
    const midX = startX + dx * 0.5;
    const midY = startY + dy * 0.5;
    
    let perpX, perpY;
    
    if (itemElement.hasClass('head-right') || itemElement.hasClass('torso-right') || itemElement.hasClass('legs-right')) {
        perpX = -dy / distance * 30;
        perpY = dx / distance * 30;
    } else if (itemElement.hasClass('head-left') || itemElement.hasClass('torso-left') || itemElement.hasClass('arms-left')) {
        perpX = dy / distance * 30;
        perpY = -dx / distance * 30;
    } else {
        perpX = -dy / distance * 25;
        perpY = dx / distance * 25;
    }
    
    const controlX = midX + perpX;
    const controlY = midY + perpY;
    
    const path = `M ${startX} ${startY} Q ${controlX} ${controlY} ${endX} ${endY}`;
    
    branchLines[item].setAttribute('d', path);
    branchLines[item].style.display = 'block';
    
    console.log(`Drew direct line for ${item} from ${originType}`);
}

function clearAllLines() {
    Object.values(branchLines).forEach(line => {
        line.setAttribute('d', '');
    });
}

function selectClothingItem(element, itemName, command) {
    $(element).toggleClass('active');
    
    updateSelectedItemDisplay(itemName);
}

function updateClothingState(item, state) {
    const $items = $('.clothing-item-icon').filter(function() {
        return $(this).data('item').toLowerCase() === item.toLowerCase();
    });
    
    if ($items.length > 0) {
        const itemId = $items.attr('id').split('-')[0]; 
        
        if (state === 'active') {
            $items.addClass('active').show();
            
            if (branchLines[itemId]) {
                $(branchLines[itemId]).show();
                
                setTimeout(() => {
                    drawDirectLineFromOriginToItem(itemId);
                }, 50);
            }
        } else {
            $items.removeClass('active');
            
            if (Config && Config.NUI && Config.NUI.HideUnwornItems) {
                $items.hide();
                
                if (branchLines[itemId]) {
                    branchLines[itemId].setAttribute('d', '');
                    $(branchLines[itemId]).hide();
                }
            }
        }
    }
}

function setItemActive(item) {
    const $item = $(`.clothing-item-icon[data-command="${item}"]`);
    $item.addClass('active').show();
    
    $item.show();
    
    const itemId = $item.attr('id').split('-')[0];
    
    if (branchLines[itemId]) {
        $(branchLines[itemId]).show();
    }
    
    setTimeout(() => {
        if (isUIOpen) {
            drawDirectLineFromOriginToItem(itemId);
        }
    }, 50);
}

function setItemInactive(item) {
    const $item = $(`.clothing-item-icon[data-command="${item}"]`);
    $item.removeClass('active');

    if (Config && Config.NUI && Config.NUI.HideUnwornItems) {
        $item.hide();
        
        const itemId = $item.attr('id').split('-')[0]; 
        if (branchLines[itemId]) {
            branchLines[itemId].setAttribute('d', '');
            $(branchLines[itemId]).hide();
        }
    }
}

function resetAllClothing() {
    $('.clothing-item-icon').removeClass('active');
    
    updateSelectedItemDisplay('None');
    
    const clickSound = document.getElementById('click-sound');
    if (clickSound) {
        clickSound.currentTime = 0;
        clickSound.play();
    }
}

function updateSelectedItemDisplay(itemName) {
    $('#selected-item').text(itemName);
}

function playClickSound() {
    const clickSound = document.getElementById('click-sound');
    if (clickSound) {
        clickSound.currentTime = 0;
        clickSound.play();
    }
}

function playHoverSound() {
}

function GetParentResourceName() {
    try {
        return window.GetParentResourceName() || 'Sevem_clothing';
    } catch (e) {
        return 'Sevem_clothing';
    }
}



