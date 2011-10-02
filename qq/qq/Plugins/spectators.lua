local qq = eqq // eqq = externel qq, it exists only a few cycles
local surface = qq.GlobalCopy.surface
local PlyMeta = qq.Meta.Ply

local Color = qq.GlobalCopy.Color--@Wizard, localizing
local OBS_MODE_IN_EYE = qq.GlobalCopy.OBS_MODE_IN_EYE
local OBS_MODE_CHASE = qq.GlobalCopy.OBS_MODE_CHASE

local Plugin = {
	Name = "Show Spectators",
	Alias = "showspectators"
}

Plugin.Init = function()
	// What section, Our plugin, Cmd Name, Discription, Default Value, Extra Info, Callback
	//qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Show Players Spectating You", true)
	local Choices = {
		None = "None",
		Top = "Top",
		Bottom = "Bottom"
	}
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "mode", "Show Spectators", "None", {MultiChoice = Choices})
end

Plugin.SpecNumber = 0

Plugin.SpecModeToCol = {}
Plugin.SpecModeToCol[OBS_MODE_IN_EYE] = Color(255,0,0)
Plugin.SpecModeToCol[OBS_MODE_CHASE] = Color(255,220,220)

Plugin.DrawSpectators = function(pl, count)
	Plugin.CurrentCount = count
	
	local mode = qq.Setting(Plugin, "mode")
	if mode == "None" then return end
	
	surface.SetFont("TabLarge")
	surface.SetTextColor(color_white)
	
	local name = PlyMeta.Name(pl)
	local Width,FontHeight = surface.GetTextSize(name)
	
	local x, y, add = 0
	x = qq.ScreenSize.x / 2 - Width / 2
	
	if count == 1 then
		local SpecText = "Spectators:"
		local sh,sw = surface.GetTextSize(SpecText)
		if Mode == "Top" then
			sh = 0
			y = qq.ScreenSize.y - sh
		else
			y = 0
		end
		
		surface.SetTextPos(qq.ScreenSize.x / 2 - sh / 2,y)
		surface.DrawText(SpecText)
		Plugin.SpecNumber = 0
	end
	
	if PlyMeta.GetObserverTarget(pl) ==  qq.GlobalCopy.LocalPlayer() then
		Plugin.SpecNumber = Plugin.SpecNumber + 1
		if mode == "Top" then
			y = 0
			add = Plugin.SpecNumber * FontHeight
		elseif mode == "Bottom" then
			istop = false
			y = qq.ScreenSize.y - FontHeight
			add = Plugin.SpecNumber * -FontHeight
		end
		local omode = PlyMeta.GetObserverMode(pl)
		surface.SetFont("TabLarge")--call these again or they get overrided
		surface.SetTextColor(Plugin.SpecModeToCol[omode])
		surface.SetTextPos(x, y + add)
		surface.DrawText(name)
	end
end

Plugin.Hooks = {
	HUDPaintPlayer = Plugin.DrawSpectators
}

qq.RegisterPlugin(Plugin)