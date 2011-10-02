local qq = eqq

local CmdMeta = qq.Meta.Cmd
local PlyMeta = qq.Meta.Ply
local WepMeta = qq.Meta.Wep
local EntMeta = qq.Meta.Ent
local VecMeta = qq.Meta.Vec
local AngMeta = qq.Meta.Ang

local util = qq.GlobalCopy.util
local LocalPlayer = qq.GlobalCopy.LocalPlayer
local tonumber = qq.GlobalCopy.tonumber
local Vector = qq.GlobalCopy.Vector
local type = qq.GlobalCopy.type

local Plugin = {
	Name = "No Spread",
	Alias = "nospread"
}
Plugin.VectorSpread = {}


--syk asked me to fix its not letting me do local qq.lol for some reason, im tired atm, comented out the way it was before 
qq.OldFireBullets = qq.OldFireBullets or _R.Entity.FireBullets

_R.Entity.FireBullets = function( ent, bullet )
	Plugin.VectorSpread[EntMeta.GetClass(ent)] = bullet.Spread
	return qq.OldFireBullets( ent, bullet )
end
local wep, lastwep, cone, numshots

local function WeaponVector( value, typ, vec )
	if ( !vec ) then return tonumber( value ) end
	local s = ( tonumber( -value ) )
	
	if ( typ == true ) then
		s = ( tonumber( -value ) )
	elseif ( typ == false ) then
		s = ( tonumber( value ) )
	else
		s = ( tonumber( value ) )
	end
	return Vector( s, s, s )
end

local Cones	= {}
Cones.Weapons = {}
Cones.Weapons[ "weapon_pistol" ]			= WeaponVector( 0.0100, true, false )	// HL2 Pistol
Cones.Weapons[ "weapon_smg1" ]				= WeaponVector( 0.04362, true, false )	// HL2 SMG1
Cones.Weapons[ "weapon_ar2" ]				= WeaponVector( 0.02618, true, false )	// HL2 AR2
Cones.Weapons[ "weapon_shotgun" ]			= WeaponVector( 0.08716, true, false )	// HL2 SHOTGUN
Cones.Weapons[ "weapon_zs_zombie" ]			= WeaponVector( 0.0, true, false )		// REGULAR ZOMBIE HAND
Cones.Weapons[ "weapon_zs_fastzombie" ]		= WeaponVector( 0.0, true, false )		// FAST ZOMBIE HAND


Cones.NormalCones = { [ "weapon_cs_base" ] = true }
Plugin.GetCone = function( w )
	if ( !w ) then return end
	local c = Plugin.VectorSpread[EntMeta.GetClass(w)]
	if not c then
		c = w.Cone
	end
	if not c
			and type(w.Primary) == "table" 
			and type(w.Primary.Cone) == "number" 
			then 
		c = w.Primary and w.Primary.Cone
	end
	if not c then c = 0 end
	return c or 0
end

Plugin.PredictSpread = function(ucmd,angle)
	local ply = LocalPlayer()
	
	local w = PlyMeta.GetActiveWeapon(ply)
	cone = 0
	
	local WepIsValid = EntMeta.IsValid(w)
	
	local IsViewPunchAffected = false
	
	if w and WepIsValid and type(w.Initialize) == "function" then
		cone = Plugin.GetCone(w)
		
		if type(cone) == "number" then
			cone = WeaponVector( cone, true, false )
		elseif type(cone) == "Vector" then
			cone = cone * -1
		end
	elseif WepIsValid then
		local class = EntMeta.GetClass(w)
		if ( Cones.Weapons[ class ] ) then
			IsViewPunchAffected = true
			cone = Cones.Weapons[ class ]
		end
	end
	
	local ret = VecMeta.Angle(qq.Module.PredictSpread(ucmd, AngMeta.Forward(angle), Vector(-cone,-cone,-cone) or Vector()))
	
	if IsViewPunchAffected then
		local vp = PlyMeta.GetPunchAngle(ply)
		ret = ret - vp
	end
	
	ret.p = math.NormalizeAngle( ret.p )
	ret.y = math.NormalizeAngle( ret.y )
	ret.r = 0
	return ret
end


Plugin.PredictSpreadInvert = function(ucmd,angle)
	local ply = LocalPlayer()
	
	local w = PlyMeta.GetActiveWeapon(ply)
	cone = 0
	
	local WepIsValid = EntMeta.IsValid(w)
	
	local IsViewPunchAffected = false
	
	if w and WepIsValid and type(w.Initialize) == "function" then
		cone = Plugin.GetCone(w)
		
		if type(cone) == "number" then
			cone = WeaponVector( cone, true, false )
		elseif type(cone) == "Vector" then
			cone = cone * -1
		end
	elseif WepIsValid then
		local class = EntMeta.GetClass(w)
		if ( Cones.Weapons[ class ] ) then
			IsViewPunchAffected = true
			cone = Cones.Weapons[ class ]
		end
	end
	
	local ret = VecMeta.Angle(qq.Module.PredictSpread(ucmd, AngMeta.Forward(angle), Vector(cone,cone,cone) or Vector()))
	
	if IsViewPunchAffected then
		local vp = PlyMeta.GetPunchAngle(ply)
		ret = ret + vp
	end
	
	ret.p = math.NormalizeAngle( ret.p )
	ret.y = math.NormalizeAngle( ret.y )
	ret.r = 0
	
	return ret
end


Plugin.Init = function()
	local Choices = {}
	Choices["Off"] = "Off"
	Choices["Aimbot Only"] = "Aimbot Only"
	Choices["All"] = "All"
	Choices["Shoot"] = "Shoot"
	
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "mode", "No Spread Mode", "Off", {MultiChoice = Choices}, {Save = true})
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "triggerbot", "Trigger Bot", false, {Save = false})
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "triggerbotheadshot", "Trigger Bot Headshot", false, {Save = true})
end

Plugin.TriggerBot = function(cmd)
	if not qq.Setting(Plugin, "triggerbot") then return end
	local _,ping = qq.Module.GetLatency(0)
	
	local ang = CmdMeta.GetViewAngles(cmd)
	local ply = LocalPlayer()
	local nospreadvec = Plugin.PredictSpreadInvert(cmd, ang)
	local tracedata = {}
	local sp = PlyMeta.GetShootPos(ply) + EntMeta.GetVelocity(ply) * RealFrameTime()
	
	tracedata.start = sp
	tracedata.endpos = sp + (AngMeta.Forward(nospreadvec) * 16384)
	tracedata.filter = ply
	tracedata.mask = qq.ShotMask

	local trace = util.TraceLine(tracedata)
	local headshot = true
	if qq.Setting(Plugin, "triggerbotheadshot") then
		headshot = trace.HitGroup == HITGROUP_HEAD
	end
	if trace.Hit and headshot then
		local target = trace.Entity
		if ValidEntity(target) and qq.IsValidTarget(target) then
			qq.ShootThisCreateMove = true
		end
	end
end

Plugin.ResetVar = function()
	Plugin.DontNospreadThisMove = false
end

Plugin.FixSpread = function(cmd, aimbot)
	
	local mode = qq.Setting(Plugin, "mode")
	if mode == "Off" then return end
	if mode == "Aimbot Only" and aimbot == nil then return end
	if mode == "Shoot" and (CmdMeta.GetButtons(cmd) & IN_ATTACK) != IN_ATTACK then return end
	if mode == "All" and aimbot then return end
	
	if Plugin.DontNospreadThisMove then return end
	
	local Ang = qq.GetView()
	if aimbot then
		Ang = CmdMeta.GetViewAngles(cmd)
	end
	Ang = Plugin.PredictSpread(cmd, Ang)
	
	CmdMeta.SetViewAngles(cmd, Ang)
	qq.DidAimThisCM = true
	// Fix the spread!
end

Plugin.PlusTriggerbot = function()
	qq.SetSetting(Plugin, "triggerbot", true)
end

Plugin.MinusTriggerbot = function()
	qq.SetSetting(Plugin, "triggerbot", false)
end

Plugin.ConCommands = {}
Plugin.ConCommands["+triggerbot"] = Plugin.PlusTriggerbot
Plugin.ConCommands["-triggerbot"] = Plugin.MinusTriggerbot


Plugin.SetupInform = function(InformPlugin)
	qq.CreateSetting(qq.MENU_VISUALS, InformPlugin, "triggerbot", "Show Triggerbot Status", true)
end
Plugin.Inform = function(InformPlugin)
	if not qq.Setting(InformPlugin, "triggerbot") then return end
	InformPlugin.InfoCreate("Triggerbot Enabled", qq.Setting(Plugin, "triggerbot"))
end

Plugin.Hooks = {
	FixSpread = Plugin.FixSpread,
	PostCreateMove = Plugin.FixSpread,
	LastCreateMove = Plugin.TriggerBot,
	PreCreateMove = Plugin.ResetVar,
	
	InformSetup = Plugin.SetupInform,
	InformDraw = Plugin.Inform
}

qq.RegisterPlugin(Plugin)