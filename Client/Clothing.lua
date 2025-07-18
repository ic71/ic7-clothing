--SevenM Clothing Config
local Drawables = {
	["Top"] = {
		Drawable = 11,
		Table = { Standalone = true, Male = 15, Female = 15 },
		Emote = { Dict = "missmic4", Anim = "michael_tux_fidget", Move = 51, Dur = 1500 }
		
	},
	["Gloves"] = {
		Drawable = 3,
		Table = Variations.Gloves,
		Remember = true,
		Emote = { Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200 }
	},
	["Shoes"] = {
		Drawable = 6,
		Table = { Standalone = true, Male = 99, Female = 51 },
		Emote = { Dict = "random@domestic", Anim = "pickup_low", Move = 0, Dur = 1200 }
	},
	["Neck"] = {
		Drawable = 7,
		Table = { Standalone = true, Male = 0, Female = 0 },
		Emote = { Dict = "clothingtie", Anim = "try_tie_positive_a", Move = 51, Dur = 2100 }
	},
	["Vest"] = {
		Drawable = 9,
		Table = { Standalone = true, Male = 0, Female = 0 },
		Emote = { Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200 }
	},
	["Bag"] = {
		Drawable = 5,
		Table = { Standalone = true, Male = 0, Female = 0 },
		Emote = { Dict = "anim@heists@ornate_bank@grab_cash", Anim = "intro", Move = 51, Dur = 1600 }
	},
	["Mask"] = {
		Drawable = 1,
		Table = { Standalone = true, Male = 0, Female = 0 },
		Emote = { Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 800 }
	},
	["Hair"] = {
		Drawable = 2,
		Table = Variations.Hair,
		Remember = true,
		Emote = { Dict = "clothingtie", Anim = "check_out_a", Move = 51, Dur = 2000 }
	},
}

local Extras = {
	["Shirt"] = {
		Drawable = 8,
		Table = {
			Standalone = true, Male = 15, Female = 15,
	
			},
		Emote = { Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Dur = 1200 }
	},
	["Pants"] = {
		Drawable = 4,
		Table = { Standalone = true, Male = 14, Female = 47 },
		Emote = { Dict = "re@construction", Anim = "out_of_breath", Move = 51, Dur = 1300 }
	},
}

local Props = {
	["Visor"] = {
		Prop = 0,
		Variants = Variations.Visor,
		Emote = {
			On = { Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 600 },
			Off = { Dict = "missheist_agency2ahelmet", Anim = "take_off_helmet_stand", Move = 51, Dur = 1200 }
		}
	},
	["Hat"] = {
		Prop = 0,
		Emote = {
			On = { Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Dur = 600 },
			Off = { Dict = "missheist_agency2ahelmet", Anim = "take_off_helmet_stand", Move = 51, Dur = 1200 }
		}
	},
	["Glasses"] = {
		Prop = 1,
		Emote = {
			On = { Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400 },
			Off = { Dict = "clothingspecs", Anim = "take_off", Move = 51, Dur = 1400 }
		}
	},
	["Ear"] = {
		Prop = 2,
		Emote = {
			On = { Dict = "mp_cp_stolen_tut", Anim = "b_think", Move = 51, Dur = 900 },
			Off = { Dict = "mp_cp_stolen_tut", Anim = "b_think", Move = 51, Dur = 900 }
		}
	},
	["Watch"] = {
		Prop = 6,
		Emote = {
			On = { Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200 },
			Off = { Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200 }
		}
	},
	["Bracelet"] = {
		Prop = 7,
		Emote = {
			On = { Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200 },
			Off = { Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Dur = 1200 }
		}
	},
}

LastEquipped = {}
Cooldown = false

local function PlayToggleEmote(e, cb)
	local Ped = PlayerPedId()
	while not HasAnimDictLoaded(e.Dict) do RequestAnimDict(e.Dict) Wait(100) end
	if IsPedInAnyVehicle(Ped) then e.Move = 51 end
	TaskPlayAnim(Ped, e.Dict, e.Anim, 3.0, 3.0, e.Dur, e.Move, 0, false, false, false)
	local Pause = e.Dur-500 if Pause < 500 then Pause = 500 end
	IncurCooldown(Pause)
	Wait(Pause) 
	cb()
end

function ResetClothing()
	local Ped = PlayerPedId()
	for k,v in pairs(LastEquipped) do
		if v then
			if v.Ped == Ped then
				if v.Drawable then
					SendNUIMessage({
						action = 'getallresets',
						cloth = k,
					})
					SetPedComponentVariation(Ped, v.ID, v.Drawable, v.Texture, 0)
				elseif v.Prop then ClearPedProp(Ped, v.ID) SetPedPropIndex(Ped, v.ID, v.Prop, v.Texture, true)
					SendNUIMessage({
						action = 'getallresets',
						cloth = k,
					})
				end
			else 
				SendNUIMessage({
					action = 'getallresets',
					cloth = k,
				})
			end
		end
	end
	LastEquipped = {}
end

function ToggleClothing(which, extra)
	if Cooldown then return end

	local Toggle = Drawables[which] if extra then Toggle = Extras[which] end
	local Ped = PlayerPedId()
	local Cur = { 
		Drawable = GetPedDrawableVariation(Ped, Toggle.Drawable), 
		ID = Toggle.Drawable,
		Ped = Ped,
		Texture = GetPedTextureVariation(Ped, Toggle.Drawable),
	}
	local Gender = IsMpPed(Ped)
	if which ~= "Mask" then
		if not Gender then Notify(Lang("NotAllowedPed")) return false end 
	end
	local Table = Toggle.Table[Gender]



	if not Toggle.Table.Standalone then 
		for k,v in pairs(Table) do
			if not Toggle.Remember then
				if k == Cur.Drawable then
					PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) end) return true
				end
			else
				if not LastEquipped[which] then
					if k == Cur.Drawable then
						PlayToggleEmote(Toggle.Emote, function() LastEquipped[which] = Cur SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) 
							SendNUIMessage({
								action = 'update',
								cloth = which,
							})
						end) return true
					end
				else
					local Last = LastEquipped[which]
					PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0) LastEquipped[which] = false
					
						SendNUIMessage({
							action = 'update2',
							cloth = which,
						})
					
					end) return true
				end
			end
		end
		Notify(Lang("NoVariants")) return
	else
		if not LastEquipped[which] then
		
			if Cur.Drawable ~= Table then 
				PlayToggleEmote(Toggle.Emote, function()
					LastEquipped[which] = Cur
					SetPedComponentVariation(Ped, Toggle.Drawable, Table, 0, 0)
					SendNUIMessage({
						action = 'update',
						cloth = which,
					})
					if Toggle.Table.Extra then
						local Extras = Toggle.Table.Extra
						for k,v in pairs(Extras) do
							local ExtraCur = {Drawable = GetPedDrawableVariation(Ped, v.Drawable),  Texture = GetPedTextureVariation(Ped, v.Drawable), Id = v.Drawable}
							if v.Drawable ~= ExtraCur.Drawable then
								SetPedComponentVariation(Ped, v.Drawable, v.Id, v.Tex, 0)

								LastEquipped[v.Name] = ExtraCur
							end
						end
					end
				end)
				return true
			end
		else
			local Last = LastEquipped[which]
			PlayToggleEmote(Toggle.Emote, function()
				SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0)
				SendNUIMessage({
					action = 'update2',
					cloth = which,
				})
				LastEquipped[which] = false
				if Toggle.Table.Extra then
					local Extras = Toggle.Table.Extra
					for k,v in pairs(Extras) do
						if LastEquipped[v.Name] then
							local Last = LastEquipped[v.Name]
							SetPedComponentVariation(Ped, Last.Id, Last.Drawable, Last.Texture, 0)

							LastEquipped[v.Name] = false
						end
					end
				end
			end)
			return true
		end
	end
	Notify(Lang("AlreadyWearing")) return false
end

function ToggleProps(which)
	if Cooldown then return end
	local Prop = Props[which]
	local Ped = PlayerPedId()
	local Gender = IsMpPed(Ped)
		local Cur = { 
		ID = Prop.Prop,
		Ped = Ped,
		Prop = GetPedPropIndex(Ped, Prop.Prop), 
		Texture = GetPedPropTextureIndex(Ped, Prop.Prop),
	}
	if not Prop.Variants then
		if Cur.Prop ~= -1 then 
			PlayToggleEmote(Prop.Emote.Off, function()
			SendNUIMessage({
				action = 'update',
				cloth = which,
			})
			LastEquipped[which] = Cur ClearPedProp(Ped, Prop.Prop) end) return true
		else
			local Last = LastEquipped[which] 
			if Last then
				PlayToggleEmote(Prop.Emote.On, function() 
				SendNUIMessage({
					action = 'update2',
					cloth = which,
				})
				SetPedPropIndex(Ped, Prop.Prop, Last.Prop, Last.Texture, true) end) LastEquipped[which] = false return true
			end
		end
		Notify(Lang("NothingToRemove")) return false
	else
		local Gender = IsMpPed(Ped)
		if not Gender then Notify(Lang("NotAllowedPed")) return false end 
		local Variations = Prop.Variants[Gender]
		for k,v in pairs(Variations) do
			if Cur.Prop == k then
				PlayToggleEmote(Prop.Emote.On, function()
				SetPedPropIndex(Ped, Prop.Prop, v, Cur.Texture, true) end) return true
			end
		end
		Notify(Lang("NoVariants")) return false
	end
end
for k,v in pairs(Config.Commands) do
	RegisterCommand(k, v.Func)
	TriggerEvent("chat:addSuggestion", "/"..k, v.Desc)
end
if Config.ExtrasEnabled then
	for k,v in pairs(Config.ExtraCommands) do
		RegisterCommand(k, v.Func)
		TriggerEvent("chat:addSuggestion", "/"..k, v.Desc)
	end
end

	AddEventHandler('onResourceStop', function(resource) 
	if resource == GetCurrentResourceName() then
		ResetClothing()
	end
end)