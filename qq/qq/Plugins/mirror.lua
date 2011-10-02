local qq = eqq

local Plugin = {
	Name = "Mirror",
	Alias = "mirror",
	Mirror = {--@Wizard, moved static vars into delcaration, less lookups per frame!
		y = 10, // don't need to subttract height
		w = 300,
		h = 100,
		znearviewmodel = 0,
		zfarviewmodel = 0,
		fov = 90,
		drawhud = false,--@Wizard, added these values to improve performence
		drawviewmodel = false
	},
	DrawingMirror = false
}

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Enabled", true)
end

local LocalPlayer = qq.GlobalCopy.LocalPlayer--@Wizard, localizing
local Angle = qq.GlobalCopy.Angle

local rRenderView = qq.GlobalCopy.render.RenderView

local plyMetaGetShootPos = qq.Meta.Ply.GetShootPos

local lp

Plugin.DrawMirror = function()
	if not qq.Setting(Plugin, "enabled") then return end
	
	lp = LocalPlayer()
	
	Plugin.Mirror.angles = Angle(0,qq.GetView(lp).y+180,0)
	Plugin.Mirror.origin = plyMetaGetShootPos(lp)
	Plugin.Mirror.x = (qq.ScreenSize.x / 2) - (300 /2)--@Wizard added braces and moved the widght here.
	Plugin.DrawingMirror = true
	rRenderView(Plugin.Mirror)
	Plugin.DrawingMirror = false
end

Plugin.Hooks = {
	HUDPaintPlayerStart = Plugin.DrawMirror,
}

qq.RegisterPlugin(Plugin)