--SevenM NUI

local isUIOpen = false
local cam = nil
local lastCamView = nil
local currentClothingState = {}


local Sounds = {
	["Close"] = {"TOGGLE_ON", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
	["Open"] = {"NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
	["Select"] = {"SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
    ["Reset"] = {"WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
    ["Hover"] = {"NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET"}
}

local function SoundPlay(which)
	if Config.NUI.Sound then
        local Sound = Sounds[which]
        PlaySoundFrontend(-1, Sound[1], Sound[2])
    end
end


function ToggleCamera(type)
	if not Config.NUI.Camera then return end
    
	if type == 'open' then
        lastCamView = {
            pos = GetEntityCoords(PlayerPedId()),
            heading = GetEntityHeading(PlayerPedId())
        }
        
        FreezeEntityPosition(PlayerPedId(), true)
        
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		local camOffset = vector3(-0.025120, 1.512561, 0.559709)
		
        SetCamActive(cam, true)
		
		SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(PlayerPedId(), camOffset))
		SetCamRot(cam, vector3(-15.0, 0.0, GetEntityHeading(PlayerPedId()) + 180), 2)
		
		RenderScriptCams(true, true, 500, true, false)
        
    
        
	elseif type == 'close' then
        EnableAllControlActions(0)
        
		RenderScriptCams(false, true, 500, true, false)
            DestroyCam(cam, false)
            cam = nil
        
        FreezeEntityPosition(PlayerPedId(), false)
        
        end
    end


function rotation(dir)
    local pedRot = GetEntityHeading(PlayerPedId()) + dir
    SetEntityHeading(PlayerPedId(), pedRot % 360)
end


function HandleCameraControls()
    if cam and isUIOpen then
        if IsControlPressed(0, 34) then 
            rotation(2.0)
        end
        
        if IsControlPressed(0, 35) then 
            rotation(-2.0)
        end
        
        DisableControlAction(0, 30, true) 
        DisableControlAction(0, 31, true) 
        DisableControlAction(0, 24, true) 
        DisableControlAction(0, 25, true) 
        DisableControlAction(0, 1, true)   
        DisableControlAction(0, 2, true)   
        DisableControlAction(0, 22, true) 
        DisableControlAction(0, 21, true) 
        DisableControlAction(0, 23, true) 
        DisableControlAction(0, 75, true) 
        DisableControlAction(0, 49, true) 
        DisableControlAction(0, 45, true) 
        DisableControlAction(0, 58, true) 
        DisableControlAction(0, 140, true) 
        DisableControlAction(0, 141, true) 
        DisableControlAction(0, 142, true) 
        DisableControlAction(0, 37, true) 
    end
end


local function Check(ped)
    if IsPedInAnyVehicle(ped) and not Config.NUI.AllowInCars then
        return false, "Cannot open clothing menu while in a vehicle"
	elseif IsPedSwimmingUnderWater(ped) then
        return false, "Cannot open clothing menu while swimming"
	elseif IsPedRagdoll(ped) and not Config.NUI.AllowWhenRagdolled then
        return false, "Cannot open clothing menu while ragdolled"
	elseif IsHudComponentActive(19) then 
		return false, "Cannot open menu while weapon wheel is active"
    elseif IsEntityDead(ped) then
        return false, "Cannot open clothing menu while dead"
    end
    return true, nil
end




function OpenClothingUI()
    if isUIOpen then return end
    
    local ped = PlayerPedId()
    local canOpen, reason = Check(ped)
    if not canOpen then
        if reason and Config.Notifications.Enabled then
            ShowNotification(reason, "error")
        end
        return
    end
    
    ClearPedTasks(ped)
    
    isUIOpen = true
    
    SoundPlay("Open")
    
    ToggleCamera('open')
    
    Citizen.Wait(100)
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = 'setConfig',
        config = Config.NUI
    })
    
    SendNUIMessage({
        action = 'openUI'
    })
    
    Citizen.SetTimeout(100, function()
        UpdateUIClothingState()
    end)
    
end

function CloseClothingUI()
    if not isUIOpen then return end
    
    isUIOpen = false
    
    SoundPlay("Close")
    
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeUI'
    })
    
    ToggleCamera('close')
    
end

function UpdateUIClothingState()
    for command, config in pairs(Config.Commands) do
        local isWearing = IsWearingClothingItem(command)
        
        SendNUIMessage({
            action = 'updateClothingState',
            item = config.Name,
            state = isWearing and 'active' or 'inactive'
        })
        
        currentClothingState[command] = isWearing
    end
end

function IsWearingClothingItem(command)
    local configItem = Config.Commands[command]
    if not configItem then return false end
    
    local itemType = configItem.Name
    
    if LastEquipped and LastEquipped[itemType] then
    return false
    else
        return true
    end
end

function ShowNotification(message, type)
    if not Config.Notifications.Enabled then return end
    
    if Config.Notifications.Type == "native" then
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
    elseif Config.Notifications.Type == "qb" then
        TriggerEvent('QBCore:Notify', message, type)
    end
end


RegisterNUICallback('toggleClothing', function(data, cb)
    if not data.command then
        cb('error')
        return
    end
    
    local command = data.command
    local config = Config.Commands[command]
    
    if not config then
        DebugLog("Unknown clothing command: " .. command)
        cb('error')
        return
    end
    
    SoundPlay("Select")
    
    if config.Func then
        config.Func()
        
        Citizen.SetTimeout(100, function()
            local isWearing = IsWearingClothingItem(command)
            SendNUIMessage({
                action = 'updateClothingState',
                item = config.Name,
                state = isWearing and 'active' or 'inactive'
            })
            currentClothingState[command] = isWearing
        end)
        
    end
    
    cb('ok')
end)

RegisterNUICallback('resetClothing', function(data, cb)
    SoundPlay("Reset")
    
    if ResetClothing then
        ResetClothing()
        
        Citizen.SetTimeout(200, function()
            SendNUIMessage({
                action = 'resetAllItems'
            })
            
            currentClothingState = {}
            
            UpdateUIClothingState()
        end)
        
        ShowNotification("All clothing items have been reset", "success")
    end
    
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseClothingUI()
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isUIOpen then
            HandleCameraControls()
        end
        
        if IsControlJustReleased(0, 246) then
    if isUIOpen then
        CloseClothingUI()
    else
        OpenClothingUI()
    end
        end
        
        if IsControlJustReleased(0, 177) and isUIOpen then 
            CloseClothingUI()
        end
    end
end)

function IsUIOpen()
    return isUIOpen
end


exports('OpenClothingUI', OpenClothingUI)
exports('CloseClothingUI', CloseClothingUI)
exports('IsUIOpen', IsUIOpen)
exports('UpdateUIClothingState', UpdateUIClothingState)


