local qq = eqq

local Plugin = {
	Name = "Smooth Aim",
	Alias = "smoothaim"
}

local cmdMetaGetViewAngles = qq.Meta.Cmd.GetViewAngles
local VecMeta = qq.Meta.Vec
local vecMetaGetNormal = qq.Meta.Vec.GetNormal
local vecMetaLength = qq.Meta.Vec.Length

local Vector = qq.GlobalCopy.Vector--@Wizard, localizing
local Angle = qq.GlobalCopy.Angle
local FrameTime = qq.GlobalCopy.FrameTime

local mmin = math.min
local mabs = math.abs

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "speed", "Smooth Aim", 120, {Min = 0, Max = 360})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "distancefactor", "Smooth Aim Distance Factor", 1, {Min = 0, Max = 1, Places = 2})
end

local diff
local vec
Plugin.ApproachAngle = function(start, target, add)
	diff = qq.NormalizeAngle(target - start)
	vec = Vector(diff.p, diff.y, diff.r)
	vec = vecMetaGetNormal(vec) * mmin(add, vecMetaLength(vec))
	return start + Angle(vec.x, vec.y, vec.z)
end

local smooth
local current
local multi_vec
Plugin.SmoothAim = function(cmd, TargAim)
	smooth = qq.Setting(Plugin, "speed")
	if smooth == 0 then return end
	
	current = cmdMetaGetViewAngles(cmd)

	// Approach the target angle.
	multi_vec = qq.NormalizeAngle(current - TargAim)
	
	current = Plugin.ApproachAngle(current, TargAim, smooth * FrameTime() * mabs((multi_vec.p + multi_vec.y) * qq.Setting(Plugin, "distancefactor")))
	current.r = 0

	return current
end

Plugin.Hooks = {
	PreModifyAimbotAngle = Plugin.SmoothAim
}

qq.RegisterPlugin(Plugin)