local qq = eqq 

local PlyMeta = qq.Meta.Ply

local Plugin = {
	Name = "Inform",
	Alias = "inform"
}

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "info", "Show Info", true)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "admins", "Show Admins", true)
end


Plugin.InfoWidth = 150
Plugin.HeaderSize = 32
Plugin.SectionSize = 16

Plugin.IconSize = 14

Plugin.MaterialColorBar 	= Material("qq/qqInfoColorBar")
Plugin.MaterialColorUnlit 	= Material("qq/qqInfoColorBarUnlitFull")
Plugin.MaterialEnd 			= Material("qq/qqInfoEnd")
Plugin.MaterialHeader 		= Material("qq/qqInfoHeader")
Plugin.MaterialSection 		= Material("qq/qqInfoSection")

Plugin.MaterialToggleKnob	= Material("qq/qqInfoToggleSwitchKnob")
Plugin.MaterialActive		= Material("qq/qqInfoToggleSwitchActivePart")
Plugin.MaterialDeactive		= Material("qq/qqInfoToggleSwitchDeactivePart")

Plugin.MaterialTick 		= Material("gui/silkicons/check_on")
Plugin.MaterialCross 		= Material("gui/silkicons/check_off")

Plugin.ToggleHistory = {}
Plugin.ToggleCreate = function(text, advanceposition)
	local mx,my = gui.MousePos()
	
	Plugin.ToggleHistory[text] = Plugin.ToggleHistory[text] or {}
	
	local alpha = Plugin.ToggleHistory[text].Alpha or 0
	if mx < Plugin.InfoWidth and my > Plugin.Start and my < Plugin.Start + Plugin.SectionSize then
		change = (255 - alpha) * 0.4 + 1
	else
		change = (alpha - 255) * 0.1 - 1
	end
	alpha = math.Clamp(alpha + change, 0, 255)
	
	Plugin.ToggleHistory[text].Alpha = alpha
	
	if alpha == 0 then
		return
	end
	surface.SetDrawColor(255,255,255,alpha)
	
	// Background
	surface.SetMaterial(Plugin.MaterialActive)
	render.SetScissorRect(0, Plugin.Start, Plugin.InfoWidth - 10, Plugin.SectionSize + Plugin.Start, true)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.SectionSize)
	
	local percent = (math.cos(SysTime()) + 1.0) * 0.5
	percent = math.min(1, math.max(0, percent))
	
	local Start = 5
	local Width = 150 - 5 - 13
	local End = Start + (Width * percent)
	
	render.SetScissorRect(0, Plugin.Start, End, Plugin.SectionSize + Plugin.Start, true)

	surface.SetMaterial(Plugin.MaterialDeactive)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.SectionSize)
	
	render.SetScissorRect(0,0,0,0,false)
	surface.SetMaterial(Plugin.MaterialToggleKnob)
	surface.DrawTexturedRect(End - Plugin.SectionSize / 2, Plugin.Start, Plugin.SectionSize, Plugin.SectionSize)
	
	surface.SetDrawColor(255,255,255,255)
	
	if advanceposition then
		Plugin.Start = Plugin.Start + Plugin.SectionSize
	end
end

Plugin.InfoCreate = function(text, checked, col, center, changefunc)
	if not col then
		col = Color(255,255,255,255)
	end
	col.a = 255
	
	surface.SetMaterial(Plugin.MaterialSection)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.SectionSize)
	
	local w,h = surface.GetTextSize(text)
	local size = Plugin.SectionSize / 2
	
	surface.SetTextColor(col)
	if center then
		surface.SetTextPos(Plugin.InfoWidth / 2 - w / 2, Plugin.Start + size - h / 2)
	else
		surface.SetTextPos(10 + Plugin.IconSize, Plugin.Start + size - h / 2) //Plugin.Start + size + h / 2)
	end
	surface.DrawText(text)
	
	if checked != nil then
		if checked then
			surface.SetMaterial(Plugin.MaterialTick)
		else
			surface.SetMaterial(Plugin.MaterialCross)
		end
		surface.DrawTexturedRect(5, Plugin.Start + 2, Plugin.IconSize, Plugin.IconSize)
	end
	
	if changefunc then
		Plugin.ToggleCreate(text)
	end
	
	Plugin.Start = Plugin.Start + Plugin.SectionSize
end

Plugin.ProgressCreate = function(text, percent, checked)
	local hue = 120 - 120 * percent
	local col = HSVToColor(hue, 1, 1)
	Plugin.InfoCreate(text, checked, col, true)
	
	// Background
	surface.SetMaterial(Plugin.MaterialColorUnlit)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.SectionSize)
	
	percent = math.min(1, math.max(0, percent))
	
	local Start = 5
	local Width = 150 - 5 - 13
	local End = Start + (Width * percent)
	
	render.SetScissorRect(0, Plugin.Start, End, Plugin.SectionSize + Plugin.Start, true)

	surface.SetMaterial(Plugin.MaterialColorBar)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.SectionSize)
	
	render.SetScissorRect(0,0,0,0,false)
	
	Plugin.Start = Plugin.Start + Plugin.SectionSize
end

Plugin.First = true
Plugin.Info = function()
	if not qq.Setting(Plugin, "info") then return end
	
	if Plugin.First then
		Plugin.First = false
		qq.CallInternalHook("InformSetup", Plugin)
	end
	
	Plugin.Start = qq.ScreenSize.y / 4
	
	surface.SetMaterial(Plugin.MaterialHeader)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.HeaderSize)
	Plugin.Start = Plugin.Start + Plugin.HeaderSize
	
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetFont("TabLarge")
	
	qq.CallInternalHook("InformDraw", Plugin)
	qq.CallInternalHook("InformDrawLast", Plugin)
	//Plugin.InfoCreate("Aimbot Enabled", true)
	
	//Plugin.ProgressCreate("LOL", CurTime() % 1 / 1)
	
	//Plugin.ProgressCreate("Danger Level", 0.5)
	//Plugin.ProgressCreate("Danger Level", 1)
	
	
	surface.SetMaterial(Plugin.MaterialEnd)
	surface.DrawTexturedRect(0, Plugin.Start, Plugin.InfoWidth, Plugin.SectionSize)
	Plugin.Start = Plugin.Start + Plugin.SectionSize
	
end

Plugin.AdminCount = 0

Plugin.ChangeCallBackAdmin = function()

end

Plugin.InformAdmins = function()
	if not qq.Setting(Plugin, "admins") then return end
	Plugin.InfoCreate("Admins Online: " .. tostring(Plugin.AdminCount), Plugin.AdminCount != 0, nil, nil, Plugin.ChangeCallBackAdmin)
end

Plugin.CountAdmins = function(pl, count)
	if not qq.Setting(Plugin, "admins") then return end
	if count == 1 then
		Plugin.AdminCount = 0
	end
	if PlyMeta.IsAdmin(pl) or PlyMeta.IsSuperAdmin(pl) then
		Plugin.AdminCount = Plugin.AdminCount + 1
	end
end

Plugin.Hooks = {
	HUDPaintPlayerEnd = Plugin.Info,
	
	HUDPaintPlayer = Plugin.CountAdmins,
	InformDraw = Plugin.InformAdmins
}

qq.RegisterPlugin(Plugin)