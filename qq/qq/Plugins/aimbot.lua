local qq = eqq
local Plugin = {
	Name = "Aimbot",
	Alias = "aimbot"
}

local util = qq.GlobalCopy.util
local LocalPlayer = qq.GlobalCopy.LocalPlayer
local tonumber = qq.GlobalCopy.tonumber
local Vector = qq.GlobalCopy.Vector
local type = qq.GlobalCopy.type


local CmdMeta = qq.Meta.Cmd
local PlyMeta = qq.Meta.Ply
local EntMeta = qq.Meta.Ent
local AngMeta = qq.Meta.Ang
local VecMeta = qq.Meta.Vec

Plugin.SetViewBack = function(cvar,old,new)
	if not qq.GetView then return end
	
	local FakeViewPlugin = qq.Plugins["fakeview"]
	if not FakeViewPlugin then return end
	if not qq.Setting(FakeViewPlugin, "enabled") then return end
	
	if not new then
		qq.SetAngleTo = qq.GetView(true)
	elseif qq.Ucmd then
		qq.View = CmdMeta.GetViewAngles(qq.Ucmd)
	else
		//qq.View = VecMeta.Angle( PlyMeta.GetAimVector(LocalPlayer()) )
	end
end

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "enabled", "Aimbot Enabled", false, {Save = false}, Plugin.SetViewBack)
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "autoshoot", "Auto Shoot", false)
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "aimonshot", "Aim On Shoot", false)
	local choices = {
		["Default"] = true,
		["Head Bone"] = true,
		["fr1kins"] = true,
		["C0BRAs"] = true,
		Ping = true,
		["C0BRAs + ph0ne Remake"] = true
	}
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "predictmethod", "Method to predict a shot", "Default", {MultiChoice = choices})

	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "targetbox", "Draw Box Around Aimbot Target", true)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "drawfov", "Draw FOV", true)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "fov_col", "Circle Color", Color(255,255,255,255))
	
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "los", "Check Line of Sight", true)
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "holdtarget", "Hold Target", false)
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "holdtarget_lastpos", "Aim At Seen Last Pos", false)
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "holdtargetblockedtime", "Hold Target Blocked Threshold", 1, {Min = 0, Max = 10, Places = 1})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "maxang", "Max angle", 30, {Min = 0, Max = 180, Places = 1})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "boltspeed", "Bolts Speed", 3381)
	
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "prefer_angle", "Prefer Angle", 0, {Min = 0, Max = 1, Places = 2, Slider = true})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "prefer_distance", "Prefer Distance", 0, {Min = 0, Max = 1, Places = 2, Slider = true})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "prefer_danger", "Prefer Danger (Looking at you)", 0, {Min = 0, Max = 1, Places = 2, Slider = true})
	
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "waitping", "Wait Pings Time For Another Shot", false)
	
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "removeanim", "Remove Animations (Better Accuracy)", false)
end

qq.SetSequence = qq.SetSequence or _R.Entity.SetSequence

_R.Entity.SetSequence = function(ent, seq)
	if qq.Setting(Plugin, "removeanim") then
		--print("SEQ THING", ent, seq)		--print("LOL")
	end
	qq.SetSequence(ent, seq)
end



Plugin.On = function()
	qq.SetSetting(Plugin, "enabled", true)
end
Plugin.Off = function()
	qq.SetSetting(Plugin, "enabled", false)
end
Plugin.ConCommands = {}
Plugin.ConCommands["+enabled"] = Plugin.On
Plugin.ConCommands["-enabled"] = Plugin.Off

--[lua\qq\plugins\aimbot.lua:116] attempt to call field 'TargetPosition' (a nil value)

Plugin.ModelTarget = {}
function Plugin.SetModelTarget(model, targ)
	Plugin.ModelTarget[model] = targ
end


Plugin.SetModelTarget("models/crow.mdl", Vector(0, 0, 5))						// Crow.
Plugin.SetModelTarget("models/pigeon.mdl", Vector(0, 0, 5)) 					// Pigeon.
Plugin.SetModelTarget("models/seagull.mdl", Vector(0, 0, 6)) 					// Seagull.
Plugin.SetModelTarget("models/combine_scanner.mdl", "Scanner.Body") 				// Scanner.
Plugin.SetModelTarget("models/hunter.mdl", "MiniStrider.body_joint") 			// Hunter.
Plugin.SetModelTarget("models/combine_turrets/floor_turret.mdl", "Barrel") 		// Turret.
Plugin.SetModelTarget("models/dog.mdl", "Dog_Model.Eye") 						// Dog.
Plugin.SetModelTarget("models/vortigaunt.mdl", "ValveBiped.Head") 				// Vortigaunt.
Plugin.SetModelTarget("models/antlion.mdl", "Antlion.Body_Bone") 					// Antlion.
Plugin.SetModelTarget("models/antlion_guard.mdl", "Antlion_Guard.Body") 			// Antlion guard.
Plugin.SetModelTarget("models/antlion_worker.mdl", "Antlion.Head_Bone") 			// Antlion worker.
Plugin.SetModelTarget("models/zombie/fast_torso.mdl", "ValveBiped.HC_BodyCube") 	// Fast zombie torso.
Plugin.SetModelTarget("models/zombie/fast.mdl", "ValveBiped.HC_BodyCube") 		// Fast zombie.
Plugin.SetModelTarget("models/headcrabclassic.mdl", "HeadcrabClassic.SpineControl") // Normal headcrab.
Plugin.SetModelTarget("models/headcrabblack.mdl", "HCBlack.body") 				// Poison headcrab.
Plugin.SetModelTarget("models/headcrab.mdl", "HCFast.body") 						// Fast headcrab.
Plugin.SetModelTarget("models/zombie/poison.mdl", "ValveBiped.Headcrab_Cube1")	 // Poison zombie.
Plugin.SetModelTarget("models/zombie/classic.mdl", "ValveBiped.HC_Body_Bone")	 // Zombie.
Plugin.SetModelTarget("models/zombie/classic_torso.mdl", "ValveBiped.HC_Body_Bone") // Zombie torso.
Plugin.SetModelTarget("models/zombie/zombie_soldier.mdl", "ValveBiped.HC_Body_Bone") // Zombine.
Plugin.SetModelTarget("models/combine_strider.mdl", "Combine_Strider.Body_Bone") // Strider.
Plugin.SetModelTarget("models/combine_dropship.mdl", "D_ship.Spine1") 			// Combine dropship.
Plugin.SetModelTarget("models/combine_helicopter.mdl", "Chopper.Body") 			// Combine helicopter.
Plugin.SetModelTarget("models/gunship.mdl", "Gunship.Body")						// Combine gunship.
Plugin.SetModelTarget("models/lamarr.mdl", "HeadcrabClassic.SpineControl")		// Lamarr!
Plugin.SetModelTarget("models/mortarsynth.mdl", "Root Bone")						// Mortar synth.
Plugin.SetModelTarget("models/synth.mdl", "Bip02 Spine1")						// Synth.
Plugin.SetModelTarget("models/vortigaunt_slave.mdl", "ValveBiped.Head")			// Vortigaunt slave.

Plugin.Last = 0

Plugin.AvfFrametime = function()
	local r = (Plugin.Last + RealFrameTime()) / 2
	Plugin.Last = RealFrameTime()
	return r
end

Plugin.PredictMethods = {}
Plugin.PositionMethods = {}

Plugin.PredictMethods["Default"] = function(ply, target, pos)
	return pos - (EntMeta.GetVelocity(ply) / 45)
end

Plugin.PositionMethods["Eye Bone"] = function(ent)
	local head = EntMeta.LookupAttachment(ent, "eyes")
	if head then
		local pos = EntMeta.GetAttachment(ent, head)
		
		EntMeta.InvalidateBoneCache(ent)
		if pos then
			return pos.Pos - (AngMeta.Forward(pos.Ang) * 2)
		end
	end	
end

Plugin.PositionMethods["Head Bone"] = function(ent)
	local eye = EntMeta.EyeAngles(ent)
	
	local id = EntMeta.LookupBone(ent, "ValveBiped.Bip01_Head1")
	local pos , ang = EntMeta.GetBonePosition(ent, id)
	
	if eye.p > 89 or eye.p < -89 then // Anti anti aim
		pos = EntMeta.WorldToLocal(ent, pos)
		pos.x = -pos.x
		pos.y = -pos.y
		pos = EntMeta.LocalToWorld(ent, pos)
	end
	
	local angvec = AngMeta.Forward(ang)
	pos = pos + angvec * 4
	
	return pos
end

Plugin.PredictMethods["Head Bone"] = function(ply, target, pos)
	return pos + EntMeta.GetVelocity(target) / 66 - EntMeta.GetVelocity(ply) / 66
end

Plugin.PositionMethods["fr1kins"] = Plugin.PositionMethods["Head Bone"]
Plugin.PredictMethods["fr1kins"] = function(ply, target, pos)
	local tarFrames, plyFrames = ( RealFrameTime() / 25 ), ( RealFrameTime() / 66 )
	return pos + ( ( EntMeta.GetVelocity( target ) * ( tarFrames ) ) - ( EntMeta.GetVelocity( target ) * ( plyFrames ) ) )
		- ( ( EntMeta.GetVelocity( ply ) * ( tarFrames ) ) + ( EntMeta.GetVelocity( ply ) * ( plyFrames ) ) )
end

// Rather than calculating where they will be
Plugin.LastPositions = {}

Plugin.GetPosPly = function(pl, def, returnchange)
	local tbl = Plugin.LastPositions[pl] or {}
	
	tbl.pos = tbl.pos or def or EntMeta.GetPos(pl)
	
	local realtime = RealTime()
	if tbl.rt != realtime then
		tbl.rt = realtime
		tbl.pos = def or EntMeta.GetPos(pl)
	end
	
	Plugin.LastPositions[pl] = tbl
	if pl == LocalPlayer() then
		print("lp", tbl.pos, EntMeta.GetPos(pl), IsFirstTimePredicted())
	end
	
	
	if returnchange then
		return tbl.pos - EntMeta.GetPos(pl)
	end
	return tbl.pos
end

Plugin.PositionMethods["C0BRAs"] = Plugin.PositionMethods["Eye Bone"]
local BasePlugin
Plugin.PredictMethods["C0BRAs"] = function(pl, target, pos) // FPS and evrything independant
	if not BasePlugin then
		if not qq.Plugins.base then
			qq.Error("Base not enabled!")
			return
		end
		BasePlugin = qq.Plugins.base
	end
	local lp = LocalPlayer()
	/*
	return pos + (
		(Plugin.GetPosPly(target, pos) - pos)// + (Plugin.GetPosPly(lp) - EntMeta.GetPos(lp)) * 1.33
		- (EntMeta.GetVelocity(pl) / 45)
	)
	*/
	
	local _,out = qq.Module.GetLatency(0)
	local _,inl = qq.Module.GetLatency(1)
	local out = out + inl + qq.Interp() 
	
	local pos = pos or Vector(0,0,0) // IDK
	local delta = (BasePlugin.DeltaVelocity[target] or EntMeta.GetVelocity(target)) * out * -1
	local selfdelta = BasePlugin.DeltaVelocity[pl] or EntMeta.GetVelocity(pl)
	
	return  pos + (delta + selfdelta)
end


Plugin.PositionMethods["Ping"] = Plugin.PositionMethods["Head Bone"]
Plugin.PredictMethods["Ping"] = function(pl, target, pos) // FPS and evrything independant
	if not BasePlugin then
		if not qq.Plugins.base then
			qq.Error("Base not enabled!")
			return
		end
		BasePlugin = qq.Plugins.base
	end
	
	local delta = BasePlugin.DeltaVelocity[target] or EntMeta.GetVelocity(target)
	local _,out = qq.Module.GetLatency(0)
	local _,inl = qq.Module.GetLatency(0)
	out = out + inl + 0.1
	
	local ourdelta = BasePlugin.DeltaVelocity[pl] or EntMeta.GetVelocity(pl)
	
	delta = delta * out
	ourdelta = ourdelta * out
	//print(ourdelta)
	
	return pos + (delta - ourdelta)
end

Plugin.PositionMethods["C0BRAs + ph0ne Remake"] = Plugin.PositionMethods["Head Bone"]
Plugin.PredictMethods["C0BRAs + ph0ne Remake"] = function(pl, target, pos) // FPS and evrything independant
	local _,avgin = qq.Module.GetLatency(0)
	local _,avgout = qq.Module.GetLatency(1)
	
	local lat = avgin + avgout
	
	local vecdelta = Plugin.GetPosPly(target, pos, true)
	local vecdeltaself = Plugin.GetPosPly(pl, EntMeta.GetPos(pl), true)
	
	local deltatime = qq.Module.GetFloatFromOffset(target, 0x68) - qq.Module.GetFloatFromOffset(target, 0x6C)
	local deltatimeself = qq.Module.GetFloatFromOffset(pl, 0x68) - qq.Module.GetFloatFromOffset(pl, 0x6C)
	
	local timestuff 	=	2 * (deltatime / (qq.Module.IntervalPerTick() / FrameTime()))
	local timestuffself = 	2 * (deltatimeself / (qq.Module.IntervalPerTick() / FrameTime()))
	
	local velocity = vecdelta * timestuff
	local velself = vecdeltaself * timestuffself
	
	print(Plugin.GetPosPly(pl, EntMeta.GetPos(pl), true), Plugin.GetPosPly(target, pos, true))
	
	pos = pos + (velocity) * lat - (EntMeta.GetVelocity(pl) / 45)
end

Plugin.BaseTargetPosition = function(ent, skip)
	// The eye attachment is a lot more stable than bones for players.
	local mthd = qq.Setting(Plugin, "predictmethod")
	if not skip and type(ent) == "Player" and mthd != "Default" and Plugin.PositionMethods[mthd] != nil then
		return Plugin.PositionMethods[mthd](ent)
	end
	
	// Check if the model has a special target assigned to it.
	local special = Plugin.ModelTarget[string.lower(EntMeta.GetModel(ent) or "")]
	if special then
		// It's a string - look for a bone.
		if type(special) == "string" then
			local bone = EntMeta.LookupBone(ent, special)
			if bone then
				local pos = EntMeta.GetBonePosition(ent, bone)
				EntMeta.InvalidateBoneCache(ent)
				if pos then
					return pos
				end
			end
		// It's a Vector - return a relative position.
		elseif type(special) == "Vector" then
			return EntMeta.LocalToWorld(ent, special)
		// It's a function - do something fancy!
		elseif type(special) == "function" then
			local pos = pcall(special, ent)
			if pos then return pos end
		end
	end

	// Try and use the head bone, found on all of the player + human models.
	local bone = "ValveBiped.Bip01_Head1"
	local head = EntMeta.LookupBone(ent, bone)
	if head then
		local pos = EntMeta.GetBonePosition(ent, head)
		EntMeta.InvalidateBoneCache(ent)
		if pos then
			return pos
		end
	end

	// Give up and return the center of the entity.
	return EntMeta.LocalToWorld(ent, EntMeta.OBBCenter(ent)) //return EntMeta.LocalToWorld(ent, Vector(0,0,0))
end

Plugin.TargetPrediction = function(ply, target, pos)
	local weap = PlyMeta.GetActiveWeapon(ply)
	local latency, avglatency = qq.Module.GetLatency(0)
	local ilatency, iavglatency = qq.Module.GetLatency(1)
	local npos = qq.CallInternalHook("PredictTargetProjectiles", ply, target, pos, avglatency, iavglatency)
	if npos then
		return npos
	end
	
	local f = Plugin.PredictMethods[qq.Setting(Plugin, "predictmethod")]
	pos = f(ply, target, pos)
	
	return pos
end

Plugin.TargetPosition = function(ent)
	local TargetPos = Plugin.BaseTargetPosition(ent)
	
	local ply = LocalPlayer()
	if ValidEntity(ply) then
		TargetPos = qq.CallInternalHook("TargetPrediction", ply, ent, TargetPos) or TargetPos
	end
	
	return TargetPos
end


Plugin.BaseBlocked = function(target, offset)
	local lp = LocalPlayer()
	if !ValidEntity(lp) then return end
	
	// Trace from the players shootpos to the position.
	local ShootPos = PlyMeta.GetShootPos(lp)
	local TargetPos = Plugin.TargetPosition(target)
	
	if offset then TargetPos = TargetPos + offset end

	local trace = util.TraceLine({start = ShootPos, endpos = TargetPos, filter = {lp, target}, mask = qq.ShotMask})
	local AimVec = qq.AimVector or PlyMeta.GetAimVector(lp)
	//print(AimVec, qq.AimVector, PlyMeta.GetAimVector(lp))
	local WrongAim = qq.AngleBetween(AimVec, VecMeta.GetNormal(TargetPos - ShootPos)) > 2

	if trace.Hit and trace.Entity != target then
		return true, WrongAim
	end

	return false, WrongAim
end

Plugin.TargetBlocked = function(target)
	if !target then target = Plugin.GetTarget() end
	if !target then return end
	
	local Blocked, WrongAim = Plugin.BaseBlocked(target)
	if (qq.Setting(Plugin, "predictblocked") or 0) > 0 and Blocked then
		Blocked = Plugin.BaseBlocked(target, EntM.GetVelocity(target) * (RealFrameTime() + qq.Setting(Plugin, "predictblocked")))
	end
	return Blocked, WrongAim
end

Plugin.SetTarget = function(target)
	if Plugin.Target != target then
		qq.CallInternalHook("NewTarget", target)
	end
	Plugin.Target = target
end

Plugin.GetTarget = function()
	if Plugin.Target and ValidEntity(Plugin.Target) then
		return Plugin.Target
	end
	return nil
end

Plugin.AngleScore = function(Ent)
	local lp = LocalPlayer()
	local ShootPos = PlyMeta.GetShootPos(lp)
	
	local TargetPos = Plugin.TargetPosition(Ent)
	local Ang = qq.AngleBetween(AngMeta.Forward(qq.GetView()), VecMeta.GetNormal(TargetPos - ShootPos))
	local MaxAng = qq.Setting(Plugin, "maxang")
	return 1 - (Ang/MaxAng)
end

Plugin.DistanceScore = function(Ent)
	local max = 18000 // According to noPE, traces fuck up after this
	
	local lp = LocalPlayer()
	local ShootPos = PlyMeta.GetShootPos(lp)
	local TargetPos = Plugin.TargetPosition(Ent)
	local dist = VecMeta.Length(ShootPos - TargetPos)
	return math.max(0, 1 - dist / max)
end

Plugin.DangerScore = function(Ent)
	local lp = LocalPlayer()
	local ShootPos = PlyMeta.GetShootPos(lp)
	
	local TargetPos = Plugin.TargetPosition(Ent)
	
	return qq.AngleBetween(PlyMeta.GetAimVector(Ent), VecMeta.GetNormal(TargetPos - ShootPos)) / 180
end

Plugin.GetScore = function(Ent)
	if not ValidEntity(Ent) then return 0 end
	
	local asm, dsm, distsm = qq.Setting(Plugin, "prefer_angle"),qq.Setting(Plugin, "prefer_danger"),qq.Setting(Plugin, "prefer_distance")
	local score = 0
	
	if asm > 0 then
		score = score + (Plugin.AngleScore(Ent) * asm)
	end
	
	if dsm > 0 then
		score = score + (Plugin.DangerScore(Ent) * dsm)
	end
	
	if distsm > 0 then
		score = score + (Plugin.DistanceScore(Ent) * distsm)
	end
	
	if Plugin.FriendsPlugin and Plugin.FriendsPlugin.IsEnabled and type(Ent) == "Player" then
		if Plugin.FriendsPlugin.PlayerStates[PlyMeta.SteamID(Ent)] == Plugin.FriendsPlugin.STATE_ENEMY then
			score = score + 2
		end
	end
	
	return score
end

Plugin.FriendsPlugin = nil
Plugin.FindTarget = function()
	Plugin.FriendsPlugin = qq.Plugins["friends2"]
	
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return end
	
	local HoldTarg = qq.Setting(Plugin, "holdtarget")
	if not qq.Setting(Plugin, "enabled") and HoldTarg then
		Plugin.SetTarget(nil)
	end
	
	local MaxAng = qq.Setting(Plugin, "maxang")
	local AimVec = PlyMeta.GetAimVector(lp)
	local ShootPos = PlyMeta.GetShootPos(lp)
	
	local CheckLOS = qq.Setting(Plugin, "los")
	
	if HoldTarg then
		local Target = Plugin.GetTarget()
		if Target and qq.IsValidTarget(Target) then
			//if true then return end
			Plugin.HoldVerify = 0
			local TargPos = Plugin.TargetPosition(Target)
			local View = qq.GetView() -- If we're smothing, we should use AimVec
			local Ang = qq.AngleBetween(AngMeta.Forward(View), VecMeta.GetNormal(TargPos - ShootPos))
			local Blocked = Plugin.TargetBlocked(Target)
			
			local blockedtime = qq.Setting(Plugin, "holdtargetblockedtime")
			if blockedtime == 0 then
				if Ang <= MaxAng and (not Blocked or CheckLOS) then return end
			else
				local ct = CurTime()
				if not Blocked then
					Target.QQLastSeen = ct
				end
				if ct - (Target.QQLastSeen or ct) < blockedtime then
					if Ang <= MaxAng then return end
				end
			end
		end
	end
	
	local _,ping = qq.Module.GetLatency(0)
	local _2,ping2 = qq.Module.GetLatency(1)
	ping = ping + ping2
	// Filter out targets.
	local targets = ents.GetAll()
	local c = #targets
	for k = 1, c do
		local ent = targets[k]
		
		if qq.Setting(Plugin, "waitping") then
			local LastKillShotTook = ent.LastKillShotTook or 0
			if CurTime() - LastKillShotTook < ping then
				targets[k] = nil
				continue
			end
		end
		
		if not qq.IsValidTarget(ent) then
			targets[k] = nil
			continue
		end
	end

	local BestTarget, BestScore = nil, 0
	for _, target in pairs(targets) do
		if not CheckLOS or not Plugin.TargetBlocked(target) then
			local Score = Plugin.GetScore(target)
			if Score > BestScore then
				BestScore = Score
				BestTarget = target
			end
		end
	end
	
	// Here is where we set the targ
	Plugin.SetTarget(BestTarget)
end

Plugin.Aimbot = function(cmd)
	if Plugin.QuickShotAng then
		CmdMeta.SetViewAngles(cmd, Plugin.QuickShotAng)
		Plugin.QuickShotAng = nil
	end
	if not qq.Setting(Plugin, "enabled") and not qq.SetAngleTo and not (Plugin.DoQuickShot) then return end
	if Plugin.DoQuickShot then
		Plugin.DoQuickShot = false
		Plugin.QuickShotAng = CmdMeta.GetViewAngles(cmd)
		LocalPlayer():ChatPrint( qq.Module.CommandNumber(cmd) )
	end
	
	if qq.CallInternalHook("TempDisableAimbot") then return end
	
	local buttons = CmdMeta.GetButtons(cmd)
	if qq.Setting(Plugin, "aimonshot") and not qq.SetAngleTo then
		if (buttons & IN_ATTACK) != IN_ATTACK  then
			return
		else
			buttons = buttons - IN_ATTACK
			CmdMeta.SetButtons(cmd, buttons)
		end
	end
	
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return end
	
	local TargAim = qq.GetView()
	local TargetPos = nil
	
	
	local Target = Plugin.GetTarget()
	
	if Target then
		TargetPos = Plugin.TargetPosition(Target)
		
		if qq.Setting(Plugin, "holdtarget") then
			if qq.Setting(Plugin, "holdtarget_lastpos") then
				local Blocked, AimOff = Plugin.TargetBlocked()
				if Blocked then
					TargetPos = Target.QQLastPosSeen
				else
					Target.QQLastPosSeen = TargetPos
				end
			end
		end
		
		if TargetPos != nil then
			TargAim = VecMeta.Angle(TargetPos - PlyMeta.GetShootPos(lp))
		end
	end
	
	if qq.SetAngleTo then
		TargAim = qq.SetAngleTo
	end
	
	TargAim = qq.CallInternalHook("PreModifyAimbotAngle", cmd, TargAim) or TargAim
	
	if qq.SetAngleTo then
		local Current = CmdMeta.GetViewAngles(cmd)
		
		local diff = qq.NormalizeAngle(Current - qq.SetAngleTo)
		if math.abs(diff.p) < 1 && math.abs(diff.y) < 1 then
			qq.SetAngleTo = nil
		end
	end
	
	qq.DidAimThisCM = true
	TargAim = qq.NormalizeAngle(TargAim)
	qq.AimVector = AngMeta.Forward(TargAim)
	CmdMeta.SetViewAngles(cmd, TargAim)
	
	if Target then
		local Blocked, AimOff = Plugin.TargetBlocked()
		//AimOff = false
		if qq.Setting(Plugin, "autoshoot") and not Blocked and not AimOff then
			qq.ShootThisCreateMove = true
		end
		qq.CallInternalHook("FixSpread", cmd, true)
	end
	
	local final = qq.CallInternalHook("PostModifyAimbotAngle", cmd)
	if final then
		CmdMeta.SetViewAngles(cmd, final)
	end
end

Plugin.TraceAttack = function(pl, dmginfo, dir, trace)
	local dmg = dmginfo:GetDamage()
	
	//if dmg >= EntMeta.Health(enemy) then // They should now be dead, providing that the trace is correct..
	pl.LastKillShotTook = CurTime()
	//end
end

Plugin.GetTargetScreenCords = function(ent)
	local min,max = EntMeta.OBBMins(ent), EntMeta.OBBMaxs(ent)
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = VecMeta.ToScreen( EntMeta.LocalToWorld(ent, corner) )
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

Plugin.DrawFOV = function()
	if not qq.Setting(Plugin, "drawfov") then return end
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return end
	
	local fov = qq.Setting(Plugin, "maxang")
	
	local v = qq.GetView()
	v.p = v.p + fov
	
	local screen = (PlyMeta.GetShootPos(lp) + (AngMeta.Forward(v) * 100))
	screen = VecMeta.ToScreen(screen)
	
	local x = screen.x - qq.ScreenSize.x / 2
	local y = screen.y - qq.ScreenSize.y / 2
	local len = math.sqrt(x * x + y * y)
	
	surface.DrawCircle(qq.ScreenSize.x / 2, qq.ScreenSize.y / 2, len, qq.Setting(Plugin, "fov_col"))
end

Plugin.DrawTargetHUD = function()
	Plugin.DrawFOV()
	local target = Plugin.GetTarget()
	
	if not target then return end

	if not qq.Setting(Plugin, "targetbox") then return end

	// Change colour on the block status.
	local Blocked, AimOff = Plugin.TargetBlocked()
	if Blocked then
		surface.SetDrawColor(255, 0, 0, 255) // Red.
	elseif AimOff then
		surface.SetDrawColor(255, 255, 0, 255) // Yellow.
	else
		surface.SetDrawColor(0, 255, 0, 255) // Green.
	end

	// Get the onscreen coordinates for the target.
	local x1, y1, x2, y2 = Plugin.GetTargetScreenCords(target)
	local edgesize = 6

	-- Top left.
	surface.DrawLine(x1,y1,math.min(x1 + edgesize,x2),y1)
	surface.DrawLine(x1,y1,x1,math.min(y1 + edgesize,y2))

	-- Top right.
	surface.DrawLine(x2,y1,math.max(x2 - edgesize,x1),y1)
	surface.DrawLine(x2,y1,x2,math.min(y1 + edgesize,y2))

	-- Bottom left.
	surface.DrawLine(x1,y2,math.min(x1 + edgesize,x2),y2)
	surface.DrawLine(x1,y2,x1,math.max(y2 - edgesize,y1))

	-- Bottom right.
	surface.DrawLine(x2,y2,math.max(x2 - edgesize,x1),y2)
	surface.DrawLine(x2,y2,x2,math.max(y2 - edgesize,y1))

	-- Bottom right.
	surface.DrawLine(x2,y2,math.max(x2,x1),y2)
	surface.DrawLine(x2,y2,x2,math.max(y2,y1))
end

Plugin.QuickShot = function()
	Plugin.DoQuickShot = true
end

Plugin.ConCommands = {}
Plugin.ConCommands["+enabled"] = Plugin.On
Plugin.ConCommands["-enabled"] = Plugin.Off
Plugin.ConCommands["quick_shot"] = Plugin.QuickShot

Plugin.DangerLevel = function()
	local ret = 0
	local lp = LocalPlayer()
	local sp = PlyMeta.GetShootPos(lp)
	
	for k,v in pairs(player.GetAll()) do
		if v == lp or not qq.IsValidTarget(v) then continue end
		
		local blocked, _ = Plugin.BaseBlocked(v)
		local plpos = PlyMeta.GetShootPos(v)
		local score = qq.AngleBetween(PlyMeta.GetAimVector(v), VecMeta.GetNormal(plpos - sp)) / 180
		
		if blocked then
			score = score * 0.33
		end
		
		ret = math.max(ret, score)
	end
	
	return ret
end

Plugin.SetupInform = function(InformPlugin)
	qq.CreateSetting(qq.MENU_VISUALS, InformPlugin, "aimbot", "Show Aimbot Status", true)
	qq.CreateSetting(qq.MENU_VISUALS, InformPlugin, "dangerlevel", "Show Danger Level", true)
end

Plugin.Inform = function(InformPlugin)
	if qq.Setting(InformPlugin, "aimbot") then
		InformPlugin.InfoCreate("Aimbot Enabled", qq.Setting(Plugin, "enabled"))
	end
end
Plugin.InformLast = function(InformPlugin)
	if qq.Setting(InformPlugin, "dangerlevel") then
		InformPlugin.ProgressCreate("Danger Level", Plugin.DangerLevel()) // 33% of the 100% of the looking at you is if they can see you :V
	end
end



Plugin.Hooks = {
	CurCreateMove = Plugin.Aimbot,
	Think = Plugin.FindTarget,
	TargetPrediction = Plugin.TargetPrediction,
	HUDPaint = Plugin.DrawTargetHUD,
	PlayerTraceAttack = Plugin.TraceAttack,
	InformSetup = Plugin.SetupInform,
	InformDraw = Plugin.Inform,
	InformDrawLast = Plugin.InformLast
}

qq.RegisterPlugin(Plugin)