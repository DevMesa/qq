local qq = eqq -- eqq = externel qq, it exists only a few cycles

local vecMetaDot = qq.Meta.Vec.Dot
local vecMetaSub = qq.Meta.Vec.Sub
local vecMetaMul = qq.Meta.Vec.Mul

local plyMetaGetShootPos = qq.Meta.Ply.GetShootPos
local plyMetaGetEyeTrace = qq.Meta.Ply.GetEyeTrace

local entMetaGetAngles = qq.Meta.Ent.GetAngles
local entMetaGetPos = qq.Meta.Ent.GetPos

local LocalPlayer = qq.GlobalCopy.LocalPlayer

local rStartBeam = qq.GlobalCopy.render.StartBeam
local rAddBeam = qq.GlobalCopy.render.AddBeam
local rEndBeam = qq.GlobalCopy.render.EndBeam
local rSetMaterial = qq.GlobalCopy.render.SetMaterial
local rDrawSprite = qq.GlobalCopy.render.DrawSprite

local uTraceLine = util.TraceLine

local cIgnoreZ = qq.GlobalCopy.cam.IgnoreZ

local Plugin = {
	Name = "AR2 Predictor",
	Alias = "ar2predic",
}

local reflc;

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Enable", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "reflections", "Reflections", 5, {Save = true, Min = 1, Max = 20, Places = 0, Slider = true})
	reflc = qq.Setting(Plugin, "reflections")
end


--[[
local function reflectedVector(vec, normal)
	return vec - 2 * (vecMetaDot(normal, vec) * normal);
end
]]

local function reflectedVector(vec, normal)
	vecMetaMul(normal, vecMetaDot(normal, vec)*2)
	vecMetaSub(vec, normal)
	vecMetaMul(vec, 65536)
	return vec
end

local start
local norm
local tr = {}
local trace = {
	start = Vector(),
	endpos = Vector(),
	filter = nil
}
local traces = {}
local lastAngles
local lastPos
local pos
local ang
local lp
local wasCalculated = false
local reflected

Plugin.CalculateFlight = function()
	if(!qq.Setting(Plugin, "enabled")) then return end
	lp = LocalPlayer()
	pos = entMetaGetPos(lp)
	ang = entMetaGetAngles(lp)
	if(lastPos == pos and lastAng == ang) then
		return
	end
	lastPos = pos
	lastAngles = ang
	trace.start = plyMetaGetShootPos(lp)
	trace.endpos = plyMetaGetEyeTrace(lp).HitPos
	trace.filter = lp
	tr = uTraceLine(trace)
	reflc = qq.Setting(Plugin, "reflections")+1
	for i = 1, reflc do
		traces[i] = tr.HitPos 
		if(i != reflc) then
			trace.start = tr.HitPos
			reflected = reflectedVector(tr.Normal ,tr.HitNormal)
			reflected:Add(tr.HitPos)
			trace.endpos = reflected
			tr = uTraceLine(trace)
		end
	end
	wasCalculated = true
end


local beamMat = Material("sprites/bluelaser1")
local beamHit = Material("sprites/gmdm_pickups/light")
local red = Color(255, 255, 255, 255)
Plugin.DrawPrediction = function()
	if(!wasCalculated or !qq.Setting(Plugin, "enabled")) then return end
	cIgnoreZ(true)
		rSetMaterial(beamMat)
		rStartBeam(reflc);
		for i = 1, reflc do
			rAddBeam(traces[i], 4, 0, red)
		end
		rEndBeam()
		rSetMaterial(beamHit)
		for i = 1, reflc do
			rDrawSprite(traces[i],4, 4, red)
		end
	cIgnoreZ(false)
end
Plugin.Hooks = {
	PostDrawOpaqueRenderables = Plugin.DrawPrediction,
	Think = Plugin.CalculateFlight
}

qq.RegisterPlugin(Plugin)
