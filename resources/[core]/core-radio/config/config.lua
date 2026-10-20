-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
Radio = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERAL SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Radio.Command = "radio"
Radio.EnableCommand = false
Radio.RequiredItem = "radio"
Radio.RadioProp = "prop_cs_hand_radio"
Radio.DefaultVolume = 60
Radio.MinFrequency = 1
Radio.MaxFrequency = 999
Radio.AnimDict = "cellphone@"
Radio.AnimName = "cellphone_text_read_base"
Radio.BoneIndex = 28422
-----------------------------------------------------------------------------------------------------------------------------------------
-- UI SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Radio.ThemeColor = "#dc1553"
Radio.RadioAlign = "left"
Radio.SpeakingAlign = "right"
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESTRICTED FREQUENCIES
-----------------------------------------------------------------------------------------------------------------------------------------
Radio.RestrictedFrequencies = {
	[1] = { "Admin" },
	[190] = { "Policia" },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMATION DATA
-----------------------------------------------------------------------------------------------------------------------------------------
Radio.Animations = {
	["1"]  = { dict = "random@arrests", anim = "generic_radio_chatter", blend = 8.0, blendOut = 0.0, flag = 49 },
	["2"]  = { dict = "anim@male@holding_radio", anim = "holding_radio_clip", bone = 28422, coords = vector3(0.0750, 0.0230, -0.0230), rot = vector3(-90.0, 0.0, -59.9999), blend = 8.0, blendOut = 0.0, flag = 49, vertex = 2 },
	["3"]  = { dict = "pazeee@radiog@animations", anim = "pazeee@radiog@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["4"]  = { dict = "pazeee@radioh@animations", anim = "pazeee@radioh@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["5"]  = { dict = "pazeee@radiok@animations", anim = "pazeee@radiok@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["6"]  = { dict = "pazeee@radiol@animations", anim = "pazeee@radiol@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["7"]  = { dict = "pazeee@radiom@animations", anim = "pazeee@radiom@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["8"]  = { dict = "pazeee@radion@animations", anim = "pazeee@radion@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["9"]  = { dict = "pazeee@radioo@animations", anim = "pazeee@radioo@clip", blend = 8.0, blendOut = 0.0, flag = 49 },
	["10"] = { dict = "pazeee@radioa@animations", anim = "pazeee@radioa@clip", bone = 57005, coords = vector3(0.160, 0.060, -0.010), rot = vector3(-119.52, -157.824, 46.041), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["11"] = { dict = "pazeee@radiob@animations", anim = "pazeee@radiob@clip", bone = 18905, coords = vector3(0.141, 0.066, 0.0110), rot = vector3(-120.8, -33.752, -32.259), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["12"] = { dict = "pazeee@radioc@animations", anim = "pazeee@radioc@clip", bone = 57005, coords = vector3(0.160, 0.060, 0.0), rot = vector3(-119.52, -157.824, 46.041), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["13"] = { dict = "pazeee@radiod@animations", anim = "pazeee@radiod@clip", bone = 18905, coords = vector3(0.154, 0.067, 0.010), rot = vector3(-120.8, -33.752, -32.259), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["14"] = { dict = "pazeee@radioe@animations", anim = "pazeee@radioe@clip", bone = 57005, coords = vector3(0.160, 0.060, 0.0), rot = vector3(-119.52, -157.824, 46.041), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["15"] = { dict = "pazeee@radiof@animations", anim = "pazeee@radiof@clip", bone = 18905, coords = vector3(0.154, 0.067, 0.010), rot = vector3(-120.8, -33.752, -32.259), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["16"] = { dict = "pazeee@radioi@animations", anim = "pazeee@radioi@clip", bone = 57005, coords = vector3(0.160, 0.060, 0.0), rot = vector3(-119.52, -157.824, 46.041), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["17"] = { dict = "pazeee@radioj@animations", anim = "pazeee@radioj@clip", bone = 57005, coords = vector3(0.160, 0.060, 0.0), rot = vector3(-119.52, -157.824, 46.041), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
	["18"] = { dict = "pazeee@radiop@animations", anim = "pazeee@radiop@clip", bone = 60309, coords = vector3(0.120, 0.050, 0.190), rot = vector3(-59.618, -30.381, -72.701), blend = 4.0, blendOut = 4.0, flag = 49, vertex = 1 },
}
