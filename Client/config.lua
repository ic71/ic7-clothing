--SevenM Clothing Config

Config = {}

-- General Settings
Config.Language = "en"
Config.ExtrasEnabled = true
Config.Debug = false 

-- NUI Settings
Config.NUI = {
    AllowInCars = false,      -- السماح بفتح القائمة في السيارات
    AllowWhenRagdolled = false, -- السماح بفتح القائمة عند السقوط
    DefaultKey = 'Y',         -- المفتاح الافتراضي لفتح القائمة
    Sound = true,             -- تفعيل الأصوات
    Camera = true,            -- تفعيل الكاميرا
    HideUnwornItems = true,   -- إخفاء العناصر غير المرتدية
}

Config.Sounds = {
    Open = {"NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
    Close = {"TOGGLE_ON", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
    Select = {"SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
    Hover = {"NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET"},
    Reset = {"WAYPOINT_SET", "HUD_FRONTEND_DEFAULT_SOUNDSET"}
}

Config.Commands = {
    ["hat"] = {
        Func = function() ToggleProps("Hat") end,
        Category = "head",
        Name = "Hat",
        Description = "Toggle hat on/off",
        Icon = "hat"
    },
    ["hair"] = {
        Func = function() ToggleClothing("Hair") end,
        Category = "head", 
        Name = "Hair",
        Description = "Toggle hair style",
        Icon = "hair"
    },
    ["glasses"] = {
        Func = function() ToggleProps("Glasses") end,
        Category = "head",
        Name = "Glasses",
        Description = "Toggle glasses on/off",
        Icon = "glasses"
    },
    ["mask"] = {
        Func = function() ToggleClothing("Mask") end,
        Category = "head",
        Name = "Mask",
        Description = "Toggle mask on/off",
        Icon = "mask"
    },
    ["ear"] = {
        Func = function() ToggleProps("Ear") end,
        Category = "head",
        Name = "Earrings",
        Description = "Toggle earrings on/off",
        Icon = "earrings"
    },
    
    ["top"] = {
        Func = function() ToggleClothing("Top") end,
        Category = "torso",
        Name = "Jacket",
        Description = "Toggle jacket/top on/off",
        Icon = "top"
    },
    ["shirt"] = {
        Func = function() ToggleClothing("Shirt", true) end,
        Category = "torso",
        Name = "Shirt",
        Description = "Toggle shirt on/off",
        Icon = "shirt"
    },
    ["vest"] = {
        Func = function() ToggleClothing("Vest") end,
        Category = "torso",
        Name = "Vest",
        Description = "Toggle vest on/off",
        Icon = "vest"
    },
    ["neck"] = {
        Func = function() ToggleClothing("Neck") end,
        Category = "torso",
        Name = "Neck",
        Description = "Toggle neck accessory on/off",
        Icon = "neck"
    },
    
    ["pants"] = {
        Func = function() ToggleClothing("Pants", true) end,
        Category = "legs",
        Name = "Pants",
        Description = "Toggle pants on/off",
        Icon = "pants"
    },
    ["shoes"] = {
        Func = function() ToggleClothing("Shoes") end,
        Category = "legs",
        Name = "Shoes",
        Description = "Toggle shoes on/off",
        Icon = "shoes"
    },
    
    ["gloves"] = {
        Func = function() ToggleClothing("Gloves") end,
        Category = "arms",
        Name = "Gloves",
        Description = "Toggle gloves on/off",
        Icon = "gloves"
    },
    ["watch"] = {
        Func = function() ToggleProps("Watch") end,
        Category = "arms",
        Name = "Watch",
        Description = "Toggle watch on/off",
        Icon = "watch"
    },
    ["bag"] = {
        Func = function() ToggleClothing("Bag") end,
        Category = "arms",
        Name = "Bag",
        Description = "Toggle bag on/off",
        Icon = "bag"
    }
}

Config.ExtraCommands = {
    ["visor"] = {
        Func = function() ToggleProps("Visor") end,
        Desc = "Toggle hat variation",
        Category = "head",
        Name = "Visor",
        Icon = "hat"
    },
    ["bracelet"] = {
        Func = function() ToggleProps("Bracelet") end,
        Desc = "Toggle bracelet",
        Category = "arms",
        Name = "Bracelet",
        Icon = "watch"
    },
    ["reset"] = {
        Func = function() ResetClothing() end,
        Desc = "Reset all clothing",
        Category = "general",
        Name = "Reset",
        Icon = "reset"
    }
}


-- Notifications
Config.Notifications = {
    Enabled = true,
    Type = "qb", -- "native", "qb",
    Duration = 3000
}



