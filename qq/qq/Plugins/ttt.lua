local qq = eqq

local Plugin = {
	Name = "Terror Town",
	Alias = "ttt",
}

local LocalPlayer = qq.GlobalCopy.LocalPlayer
local table = qq.GlobalCopy.table
local player = qq.GlobalCopy.player
local type = qq.GlobalCopy.type
local ValidEntity = qq.GlobalCopy.ValidEntity
local surface = qq.GlobalCopy.surface

local CmdMeta = qq.Meta.Cmd
local PlyMeta = qq.Meta.Ply
local WepMeta = qq.Meta.Wep
local EntMeta = qq.Meta.Ent
local VecMeta = qq.Meta.Vec
local AngMeta = qq.Meta.Ang


Plugin.Traitors = {}
Plugin.IsTraitor = function(ent)
	return table.HasValue(Traitors, ent) or ent:GetTraitor()
end

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_GAMEMODE, Plugin, "friendlyfire", "Don't Other Traitors", true)
	qq.CreateSetting(qq.MENU_GAMEMODE, Plugin, "shoott", "Shoot Traitors Only", false)
	qq.CreateSetting(qq.MENU_GAMEMODE, Plugin, "detecttraitor", "Detect Traitors", true)
	qq.CreateSetting(qq.MENU_GAMEMODE, Plugin, "predictknife", "Predict Knife Throws", true)
end

Plugin.CanLoad = function()
	local IsTTT = string.find(GetConVar("sv_gamemode"):GetString(), "terrortown")
	if not IsTTT then
		qq.Inform("Not loading TTT plugin, Not playing TTT")
		return false
	end
end

Plugin.IsValidTarget = function(ent)

	local lp = LocalPlayer()
	if not ValidEntity(lp) then return end
	if type(ent) != "Player" then return end
	if qq.Setting(Plugin, "friendlyfire") then
		local we_t = lp:GetTraitor()
		if we_t and ent:GetTraitor() then
			return false
		end
		if not we_t and ent:IsDetective() == true then
			return false
		end
	end
end

Plugin.NewRound = function()
	Plugin.Traitors = {}
	Plugin.RoundStart = CurTime()
	for k,v in pairs(ents.GetAll()) do
		v.WallhackColor = nil
		if qq.Setting(Plugin, "detecttraitor") and type(v) == "Player" then
			if v:IsDetective() then
				v.WallhackColor = Color(0,0,255)
			end
			if v:GetTraitor() then
				v.WallhackColor = Color(255,0,0)
			end
		end
	end
end

Plugin.EnableWepFix = false
qq.PlyM_EQ_Old = qq.PlyM_EQ_Old or qq.Meta.Ply.__eq
Plugin.PlyMeta_EQ_Spoof = function(a, b)
	if ValidEntity(a) and ValidEntity(b) then
		if Plugin.EnableWepFix then
			Plugin.EnableWepFix = false
			return true 
		end
		return EntM.EntIndex(a) == EntM.EntIndex(b)
	end
	return false
end
qq.Meta.Ply.__eq = Plugin.PlyMeta_EQ_Spoof

Plugin.TestTraitor = function(pl)
	local ROLE_TRAITOR = ROLE_TRAITOR or -1
	if ROLE_TRAITOR == -1 then return end
	if not qq.Setting(Plugin, "detecttraitor") then return end
	if table.HasValue(Plugin.Traitors, pl) then return end
	
	if EntMeta.GetNWBool(pl, "disguised", false) then
		pl.WallhackColor = Color(255,0,0)
		table.insert(Plugin.Traitors, pl)
		qq.Inform("[TTT] {1} is a traitor! (Disguised)", PlyMeta.Name(pl))
		return
	end
	
	Plugin.EnableWepFix = true
	for k,w in pairs(qq.Meta.Ply.GetWeapons(pl)) do
		if w.QQDropped then
			w.QQSCANNED = true
			continue
		end
		if not w.QQSCANNED then
			local tbl = w.CanBuy or {}
			if table.HasValue(w.CanBuy, ROLE_TRAITOR) and
					not table.HasValue(w.CanBuy, ROLE_INNOCENT) and
					not pl:IsDetective() then
				pl.WallhackColor = Color(255,0,0)
				table.insert(Plugin.Traitors, pl)
				qq.Inform("[TTT] {1} is a traitor! Weapon: {2}", PlyMeta.Name(pl), EntMeta.GetClass(w))
				return
			end
			w.QQSCANNED = true
		end
	end
end

Plugin.ShowUnidedBodies = function(ent,t)
	if(ValidEntity(ent)) then
		local class = ent.GetClass(ent)
		if class == "prop_ragdoll" then
			if CORPSE.GetPlayerNick(ent, false) == false then ent.WallhackColor = nil return end
			if CORPSE.GetFound(ent, false) then ent.WallhackColor = nil return end
			
			if (ent.Created or 0) < (Plugin.RoundStart or 0) then ent.WallhackColor = nil return end
			
			ent.WallhackColor = Color(255,127,0)
			if ent.search_result != nil then
				return
			end
			return 1
		end
	end
end

Plugin.NullifyDroppedWeapons = function(ent)
	if not qq.Setting(Plugin, "detecttraitor") then return end
	
	if type(ent) != "Weapon" then return end
		
	local ROLE_TRAITOR = ROLE_TRAITOR or -1
	if ROLE_TRAITOR == -1 then return end
	
	if ent.QQDropped then return end
	
	local tbl = ent.CanBuy or {}
	
	if table.HasValue(tbl, ROLE_TRAITOR) then
		ent.WallhackColor = Color(255,0,0)
	elseif table.HasValue(tbl, ROLE_DETECTIVE) then
		ent.WallhackColor = Color(0,0,255)
	end
	
	if not ValidEntity(ent.Owner) then
		ent.QQDropped = true
		if table.HasValue(tbl, ROLE_TRAITOR) then
			qq.Inform("Found a dropped weapon {1}", EntMeta.GetClass(ent))
		end
	end
end

Plugin.NadeESP = function(ent)
	if (EntMeta.GetClass(ent) == "ttt_c4" or (ent.Base or "") == "ttt_basegrenade_proj") and ent:GetExplodeTime() - CurTime() > 0 then
		
		local EspPlugin = qq.Plugins["esp"]
		if EspPlugin and (ent.Base or "") == "ttt_basegrenade_proj" then
			local class = EntMeta.GetClass(ent)
			if not table.HasValue(EspPlugin.Classes, class) then
				table.insert(EspPlugin.Classes, class)
			end
		end
		local spos = EntMeta.GetPos(ent)
		local pos = VecMeta.ToScreen(spos)
		
		local prefix = "Nade: "
		if EntMeta.GetClass(ent) == "ttt_c4" then
			prefix = "C4: "
		end
		local text = prefix .. string.FormattedTime(math.max(0, ent:GetExplodeTime() - CurTime()),"%02i:%02i")
		
		local tw,th = surface.GetTextSize(text)
		pos.x = pos.x - tw / 2
		
		surface.SetFont("TabLarge")
		surface.SetTextColor(Color(255,0,0,255))
		surface.SetTextPos(pos.x, pos.y)
		surface.DrawText(text)
	end
end

Plugin.PredictKnifeThrow = function(ply, target, pos, avglatency, iavglatency)
	if not qq.Setting(Plugin, "predictknife") then return end
	if not ValidEntity(target) then return end
	
	local CurveMultiplier = 0.000525104
	local TimeMultiplier = 0.00000360967
	
	local sp = PlyMeta.GetShootPos(ply)
	local dist = VecMeta.Length(pos - sp)
			
	local Time = dist * dist * TimeMultiplier
	Time = Time * 1.8

	
	dist = VecMeta.Length(pos - sp)
	local Drop = dist * dist * CurveMultiplier
	
	pos = pos + Vector(0,0, Drop)
	
	local RemotePlugin = qq.Plugins["nospread"] or {}
	RemotePlugin.DontNospreadThisMove = true
	
	return pos
end

Plugin.WeaponPredictTable = {
	weapon_ttt_knife = Plugin.PredictKnifeThrow
}


Plugin.PredictProjectiles = function(ply, target, pos, avglatency, iavglatency)
	local wep = PlyMeta.GetActiveWeapon(ply)
	if not ValidEntity(wep) then return end
	local name = EntMeta.GetClass(wep)
	local f = Plugin.WeaponPredictTable[name]
	if f then
		return f(ply, target, pos, avglatency, iavglatency)
	end
end

Plugin.PrintInfo = function()
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return end
	
	local trace = PlyMeta.GetEyeTrace(lp)
	if not trace.Hit then return end
	local ent = trace.Entity
	PrintTable(ent:GetTable())
	
	for k,v in pairs(ent:GetTable()) do
		print(k,v)
	end
	
	
end

Plugin.PreCreateMove = function(cmd)
	//print(Plugin.PredictingThrowState)
	Plugin.PropKillEnd(cmd)
	if (Plugin.PredictingThrow or false) == false then return end
	
	local buttons = CmdMeta.GetButtons(cmd)
	buttons = buttons | IN_ATTACK
	CmdMeta.SetButtons(cmd, buttons)
	// Bitwise or, not + :V
end

Plugin.PredictNades = function(pl,cmd,args,is_repeat,is_retry)
	if is_repeat then // +attack, it never shots, this stops it shooting....
		Plugin.PredictingThrow = false
		return
	end
	
	if (Plugin.PredictingThrow or false) == true then return end
	
	local lp = LocalPlayer()
	local wep = PlyMeta.GetActiveWeapon(lp)
	
	if not ValidEntity(wep) or wep.detonate_timer == nil then
		local fin
		for k,v in pairs(PlyMeta.GetWeapons(lp)) do
			if v.detonate_timer then
				qq.Module.DoCommand("use " .. EntMeta.GetClass(v))
				fin = v
				break
			end
		end
		if not fin then return end
		timer.Simple((fin.DeploySpeed or 2) / 2, Plugin.PredictNades, nil,nil,nil,nil,true)
		return
	end
	local trace = PlyMeta.GetEyeTraceNoCursor(lp)
	if not trace.Hit then return end
	local dist = VecMeta.Length(trace.HitPos - PlyMeta.GetShootPos(lp))
	local timetoinpact = dist / 500

	local explodetime = wep.detonate_timer
	local time = explodetime - timetoinpact
	
	Plugin.PredictingThrow = true
	timer.Simple(time, Plugin.PredictNades, nil,nil,nil,true)
end


Plugin.On = function()
	Plugin.PropKillStart()
end
Plugin.Off = function()
	Plugin.ReleaseProp = true
end

Plugin.PropKillStart = function()
	local PluginFV = qq.Plugins["fakeview"]
	if not PluginFV then
		qq.Warn("TTT Propkill needs the \"Fake View\" plugin enabled!")
		return
	end
	Plugin.UpdateView = true
	
	
	Plugin.FakeViewWasEnabled = qq.Setting(PluginFV, "enabled")
	Plugin.AimBotOnlyWasEnabled = qq.Setting(PluginFV, "aimbotonly")
	
	qq.SetSetting(PluginFV, "enabled", true)
	qq.SetSetting(PluginFV, "aimbotonly", false)
end

Plugin.PropKillEnd = function(cmd)
	if Plugin.UpdateView then
		local curview = qq.View
		curview.y = math.NormalizeAngle(curview.y + 180)
		curview.p = 0
		Plugin.UpdateView = false
		qq.View = curview
		Plugin.PropKilling = true
	end
	if Plugin.PropKilling then
		// Invert the angle here
		local flippedview = qq.View
		flippedview.y = math.NormalizeAngle(flippedview.y + 180)
		flippedview.p = 0
		
		qq.DidAimThisCM = true
		CmdMeta.SetViewAngles(cmd, flippedview)
	end
	if Plugin.ReleaseProp then
		Plugin.PropKilling = false
		local PluginFV = qq.Plugins["fakeview"]
		if not PluginFV then
			qq.Warn("TTT Propkill needs the \"Fake View\" plugin enabled!")
			return
		end
		Plugin.ReleaseProp = false
		
		CmdMeta.SetViewAngles(cmd, qq.View) // This sets it to the fake view, the prop will be lauched
		
		qq.SetSetting(PluginFV, "enabled", Plugin.FakeViewWasEnabled)
		qq.SetSetting(PluginFV, "aimbotonly", Plugin.AimBotOnlyWasEnabled)
		qq.DidAimThisCM = true
	end
end

Plugin.Test = function()
	print(file.Read("../screenshots/freespace_revolution0000.jpg"))
end

Plugin.ConCommands = {
	printinfo = Plugin.PrintInfo,
	predict_nade = Plugin.PredictNades,
	test = Plugin.Test
}
Plugin.ConCommands["+stick"] = Plugin.On
Plugin.ConCommands["-stick"] = Plugin.Off

Plugin.Hooks = {
	IsValidTarget = Plugin.IsValidTarget,
	TTTBeginRound = Plugin.NewRound,
	HUDPaintEntity = Plugin.NadeESP,
	ThinkPlayer = Plugin.TestTraitor,
	ThinkEntity = Plugin.NullifyDroppedWeapons,
	PredictTargetProjectiles = Plugin.PredictProjectiles,
	QQShouldWallhack = Plugin.ShowUnidedBodies,
	PreCreateMove = Plugin.PreCreateMove
}

qq.RegisterPlugin(Plugin)