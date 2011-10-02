local qq = eqq
local Plugin = {
	Name = "Projectiles And Trajectories",
	Alias = "projectiles"
}

local CmdMeta = qq.Meta.Cmd
local PlyMeta = qq.Meta.Ply
local EntMeta = qq.Meta.Ent
local AngMeta = qq.Meta.Ang
local VecMeta = qq.Meta.Vec

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "drawpredictedtrajectory_time", "Draw Predicted Trajectory", 0, {Min = 0, Max = 2, Places = 1, Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "drawpredictedtrajectory_res", "Draw Predicted Trajectory Resolution", 10, {Min = 0, Max = 100, Save = true})
end

Plugin.HUDPaintPlayer = function(pl)
	local time = qq.Setting(Plugin, "drawpredictedtrajectory_time")
	if time == 0 then return end
	
	if not qq.IsValidTarget(pl) then return end
	
	local col = pl.WallhackColor or team.GetColor(PlyMeta.Team(pl))
	surface.SetDrawColor(col)
	
	local step = time / qq.Setting(Plugin, "drawpredictedtrajectory_res")
	local lastpos = PlyMeta.GetShootPos(pl)
	for i = 0, time, step do
		local pos = PlyMeta.GetShootPos(pl)
		pos = Plugin.PredictPlayerPos(pl, pos, i)
		
		if VecMeta.Length(pos - lastpos) < 5 then
			continue // no point drawing
		end
		
		local xy1 = VecMeta.ToScreen(pos)
		local xy2 = VecMeta.ToScreen(lastpos)
		
		surface.DrawLine(xy1.x, xy1.y, xy2.x, xy2.y)
		lastpos = pos
	end
end


Plugin.BallisticTimeToImpact = function(Distance, flProjectileSpeed) // This not mine, and doesn't seem to work
	local flGravity =  GetConVar("sv_gravity"):GetFloat()

	local flConstA = flGravity * 0.05 * 0.5;
	local flSquaredProjSpeed = flProjectileSpeed * flProjectileSpeed;
	local flSquaredConst = flConstA * flConstA;
	local flMinus1 = flProjectileSpeed - math.sqrt( flSquaredProjSpeed - 4 * flSquaredConst * Distance);
	local flPlus1 = flProjectileSpeed + math.sqrt( flSquaredProjSpeed - 4 * flSquaredConst * Distance);

	local flResult;

	if flMinus1 < 0 then
		flResult = math.sqrt( flPlus1 / ( 2 * flSquaredConst ) );
	else
		flResult = math.sqrt( flMinus1 / ( 2 * flSquaredConst ) );
	end

	return flResult;
end

Plugin.PredictPlayerPos = function(pl, pos, time, vel)
	vel = vel or EntMeta.GetVelocity(pl)
	local grav = GetConVarNumber("sv_gravity")
	
	if EntMeta.OnGround(pl) or EntMeta.GetMoveType(pl) != MOVETYPE_WALK then
		return pos + (vel * time)
	end
	
	local offset = pos - EntMeta.GetPos(pl)
	
	// Trace to the ground, make sure nothing is obstucting us, if there is, aim where they will land instead
	local newpos = pos + (time * vel) + time * time * Vector(0,0,-grav) * 0.5
	
	local tracedata = {}				
	tracedata.start = pos //- offset + Vector(0,0,10)
	tracedata.endpos = newpos - offset
	tracedata.filter = pl
	local trace = util.TraceLine(tracedata)
	
	if trace.Hit then
		// Only setting the Z
		newpos.z = trace.HitPos.z + offset.z
	end
	return newpos
end
/*
local t = nil
local calc = nil
hook.Add("Think", "lol", function()
	if not t or not ValidEntity(t) then
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "crossbow_bolt" and not v.done then
				t = v
				v.StartPos = LocalPlayer():GetShootPos()
				v.StartTime = CurTime()
			end
		end
	end
	
	if (not t or not ValidEntity(t)) or (calc and t:GetVelocity():Length() < 3400 and t.StartTime - CurTime() > 0.5) then
		if not calc then return end
		print(calc, GetConVarNumber("sv_gravity"))
		print(GetConVarNumber("sv_gravity") / calc / calc)
		print(GetConVarNumber("sv_gravity") / calc)
		filex.Append("res3.txt", GetConVarNumber("sv_gravity") .. "\t\t" ..  tostring(calc) .. "\n")
		calc = nil
		
		if t and ValidEntity(t) then
			t.done = true
			t = nil
		end
		
		RunConsoleCommand("inc_g")
		
		RunConsoleCommand("+attack")
		timer.Simple(0.2, RunConsoleCommand, "-attack")
		return
	end
	
	local distance = (t.StartPos - t:GetPos()):Length()
	local time = CurTime() - t.StartTime
	local drop = t.StartPos.z - t:GetPos().z
	
	calc = drop / distance / distance
	local y = drop / time / time
	//print(x, " | ", y, " FROM ", distance, time, drop)
end)
*/

Plugin.BoldDrop = function(Distance)
	local gravity = GetConVar("sv_gravity"):GetFloat()
	local const2 = (gravity * gravity) * 0.0000000008
	local const = gravity * 0.00000000205
	return Distance * Distance * const// + const2
end

Plugin.CrossbowPrediction = function(ply, target, pos, outlatency, inlatncy)
	
	local sp = PlyMeta.GetShootPos(ply)
	local dist = VecMeta.Length(pos - sp)
	
	local Speed = 3500
	local interp = qq.Interp()// GetConVarNumber("cl_interp")
	
	local time = (dist / Speed) + outlatency + inlatncy + interp// + RealFrameTime()
	local vel =  EntMeta.GetVelocity(target)
	
	local postmp = Plugin.PredictPlayerPos(target, pos, time)
	
	dist = VecMeta.Length(postmp - PlyMeta.GetShootPos(ply)) // Recalculate this for the new pos
	local newtime = dist / Speed + outlatency + inlatncy + interp// + RealFrameTime()
	
	local err = newtime - time // This isn't 100%, but it's a good guess
	
	pos = Plugin.PredictPlayerPos(target, pos, time + err)
	
	dist = VecMeta.Length(postmp - PlyMeta.GetShootPos(ply)) // Recalculate this for the drop... again
	local drop = Plugin.BoldDrop(dist)
	local ang = qq.AngleBetween(VecMeta.GetNormal(pos - sp), VecMeta.GetNormal((pos + Vector(0,0, drop)) - sp))
	
	if ang > 45 then
		pos = pos - Vector(0,0,-1000000000) // Make sure that the aimbot doesn't target them - HACK
	end
	
	return pos + Vector(0,0, drop)
end

Plugin.SMGNadePrediction = function(ply, target, pos, outlatency, inlatncy)
	if not (qq.UCmd != nil and (CmdMeta.GetButtons(qq.UCmd) & IN_ATTACK2) == IN_ATTACK2) then return end
	
	local sp = PlyMeta.GetShootPos(ply)
	local dist = VecMeta.Length(pos - sp)
	
	local DropX = 0.0002304877
	local TimeX = 0.0000000836034
	
	local Time = dist * dist * TimeX
	local Time = Time * 12.5
	
	local car
	if type(target) == "Player" then
		car = PlyMeta.GetVehicle(target)
	end
	
	if car and ValidEntity(car) then
		pos = pos + (EntMeta.GetVelocity(car) * Time)
	else
		local vel = EntMeta.GetVelocity(target)
		vel.z = 0
		pos = EntMeta.GetPos(target) + (vel * Time)
	end
	
	local dist = VecMeta.Length(pos - sp)
	local Drop = dist * dist * DropX
	
	local RemotePlugin = qq.Plugins["nospread"] or {}
	RemotePlugin.DontNospreadThisMove = true
	
	return pos + Vector(0,0, Drop)
end

Plugin.Types = {
	weapon_crossbow = Plugin.CrossbowPrediction,
	weapon_smg1 = Plugin.SMGNadePrediction
}

Plugin.TargetPrediction = function(ply, target, pos, outlatency, inlatncy)
	local wep = PlyMeta.GetActiveWeapon(ply)
	if not ValidEntity(wep) then return end
	local func = Plugin.Types[EntMeta.GetClass(wep)]
	if func then
		local ret = func(ply, target, pos, outlatency, inlatncy)
		if ret != nil then return ret end
	end
end

Plugin.Hooks = {
	PredictTargetProjectiles = Plugin.TargetPrediction,
	HUDPaintPlayer = Plugin.HUDPaintPlayer
}

qq.RegisterPlugin(Plugin)