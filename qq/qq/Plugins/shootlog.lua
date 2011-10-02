local qq = eqq 

local Plugin = {
	Name = "Shoot log",
	Alias = "shootlog",
}


local sPlaySound = qq.GlobalCopy.surface.PlaySound
local tinsert = qq.GlobalCopy.table.insert
local tremove = qq.GlobalCopy.table.remove
local tGetColor = team.GetColor

local getTeam = qq.Meta.Ply.Team

local EyePos = qq.GlobalCopy.EyePos
local ipairs = qq.GlobalCopy.ipairs
local ValidEntity = qq.GlobalCopy.ValidEntity
local RealTime = qq.GlobalCopy.RealTime
local IsFirstTimePredicted = qq.GlobalCopy.IsFirstTimePredicted
local LocalPlayer = qq.GlobalCopy.LocalPlayer
local type = qq.GlobalCopy.type
local ScrW = qq.GlobalCopy.ScrW
local ScrH = qq.GlobalCopy.ScrH

local msin = qq.GlobalCopy.math.sin
local mcos = qq.GlobalCopy.math.cos

local cIgnoreZ = qq.GlobalCopy.cam.IgnoreZ
local cStart3D2D = qq.GlobalCopy.cam.Start3D2D
local cEnd3D2D = qq.GlobalCopy.cam.End3D2D

local rSetMaterial = qq.GlobalCopy.render.SetMaterial
local rDrawBeam = qq.GlobalCopy.render.DrawBeam
local rDrawSprite = qq.GlobalCopy.render.DrawSprite

local sSetTextPos = qq.GlobalCopy.surface.SetTextPos
local sSetTextColor = qq.GlobalCopy.surface.SetTextColor
local sDrawText = qq.GlobalCopy.surface.DrawText
local sSetFont = qq.GlobalCopy.surface.SetFont
local sSetMaterial = qq.GlobalCopy.surface.SetMaterial
local sGetTextSize = qq.GlobalCopy.surface.GetTextSize
local sDrawTexturedRect = qq.GlobalCopy.surface.DrawTexturedRect
local sSetDrawColor = qq.GlobalCopy.surface.SetDrawColor
local sDrawTexturedRect = qq.GlobalCopy.surface.DrawTexturedRect
local sDrawTexturedRectRotated = qq.GlobalCopy.surface.DrawTexturedRectRotated

local uTraceLine = util.TraceLine

local startpos
local endpos
local victimTeamCol
local ang

local count
local bullettraces = {}

local AngMeta = qq.Meta.Ang
local VecMeta = qq.Meta.Vec
local PlyMeta = qq.Meta.Ply

Plugin.ShotWhen = -100
Plugin.ShotName = ""
Plugin.ShotPos = Vector()
Plugin.ShotWarnMat = Material("qq/qqWarnShot")
Plugin.ShotWarnWidth = 512
Plugin.ShotWarnWidthD2 = 512 / 2
Plugin.ShotWarnHeight = 128
Plugin.ShotWarnHeightD2 = 128 / 2

Plugin.AngMat = Material("qq/qqWarnShotAng")

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Enable", true, {Save = true})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "warn", "Warn when someone shoots at me", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "warnsign", "Warn Sign", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "fadetimewarn", "Fade Time For Warning", 2, {Save = true, Min = 0, Max = 10, Places = 1, Slider = true})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "self", "Self", false, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "logSize", "Maximum log size", 20, {Save = true, Min = 1, Max = 20, Places = 0, Slider = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "fadetime", "Fade Time", 2, {Save = true, Min = 0, Max = 20, Places = 1, Slider = true})
end

Plugin.HUDPaint = function()
	if Plugin.ShotWhen + qq.Setting(Plugin, "fadetimewarn") < RealTime() then return end
	
	local alpha = (1 - (RealTime() - Plugin.ShotWhen) / qq.Setting(Plugin, "fadetimewarn"))*255
	
	local lp = LocalPlayer()
	sSetMaterial(Plugin.AngMat)
	sSetDrawColor(255,255,255,alpha)
	
	local ang = VecMeta.Angle(PlyMeta.GetAimVector(lp)).y - VecMeta.Angle(Plugin.ShotPos - PlyMeta.GetShootPos(lp)).y
	
	ang = 180 - ang
	local angrad = ang * 3.14158 / 180
	local x,y = ScrW()/2,ScrH()/2
	
	x = x + msin(angrad) * 64
	y = y + mcos(angrad) * 64
	
	sDrawTexturedRectRotated(x,y,64,64, ang+45+180)
	
	// Now the warning
	if not qq.Setting(Plugin, "warnsign") then return end
	
	x = ScrW() * 0.5 - Plugin.ShotWarnWidthD2
	y = ScrH() * 0.66
	
	sSetMaterial(Plugin.ShotWarnMat)
	sDrawTexturedRect(x,y,Plugin.ShotWarnWidth,Plugin.ShotWarnHeight)
	
	sSetTextColor(255,255,255,alpha)
	sSetFont("HUDNumber")
	local w,h = sGetTextSize(Plugin.ShotName)
	
	x = ScrW() * 0.5 - w * 0.5
	y = y + Plugin.ShotWarnHeight * 0.66  - h*0.5
	
	sSetTextPos(x, y)
	sDrawText(Plugin.ShotName)
end

local tracedata = {mask = qq.ShotMask}
Plugin.ImpactEffect = function(self, tr, ...)
	local lp = LocalPlayer()
	if not qq.Setting(Plugin, "self") and self.Owner == lp then return end // Nope
	if self.Owner != lp and not qq.IsValidTarget(self.Owner) then return end // Nope
	
	local name
	local pl
	
	if type(tr.Entity) == "Player" then
		pl = tr.Entity
	end
	
	if self.Owner != lp then
		
		if qq.AngleBetween(VecMeta.Normalize(tr.StartPos - tr.HitPos), VecMeta.GetNormal(tr.StartPos - PlyMeta.GetShootPos(lp))) < 3 then
			tracedata.start = tr.StartPos
			tracedata.endpos = PlyMeta.GetShootPos(lp)
			tracedata.filter = {self.Owner,lp}
			
			
			if not uTraceLine(tracedata).Hit then
				Plugin.ShotName = PlyMeta.Name(self.Owner)
				Plugin.ShotWhen = RealTime()
				Plugin.ShotPos = tr.StartPos
			end
		end
	end
	
	if pl then
		name = pl:Name()
	end
	
	tinsert(bullettraces,{tr.StartPos, tr.HitPos, name, tGetColor(self.Owner), RealTime()})
	count = #bullettraces or 0
	if count > qq.Setting(Plugin, "logSize") then
		for i=1,count-qq.Setting(Plugin, "logSize") do
			tremove(bullettraces,i)
		end
	end
end


local beammat = Material("tripmine_laser")
if not beammat then
	beammat = Material("sprites/bluelaser1")
end
/*
if(!beammat) then
	beammat = CreateMaterial("tripmine_laser", "UnlitGeneric", {
		["$basetexture"] = "laser",
		["$additive"] = "1",
		["$vertexcolor"] = "1",
		["$vertexalpha"	] = "1"
	});
end
*/
local hitmat = Material("sprites/gmdm_pickups/light");

Plugin.DrawBulletTracing = function()
	if qq.Setting(Plugin, "enabled") then
		//cIgnoreZ(true)
		for k,tbl in ipairs(bullettraces) do
			startpos = tbl[1]
			endpos = tbl[2]
			victimTeamCol = tbl[4]
			
			//1 - ( 20 + 5 - 17 - 5) / 5
			// 1 - (ct - st) / 5
			if tbl[5] + qq.Setting(Plugin, "fadetime") < RealTime() then
				tremove(bullettraces,k)
				continue
			end
			victimTeamCol.a = (1 - (RealTime() - tbl[5]) / qq.Setting(Plugin, "fadetime")) * 255
			if victimTeamCol.a < 1 then continue end

			rSetMaterial(beammat)
			rDrawBeam(startpos,endpos,2,1,2,victimTeamCol)
			rSetMaterial(hitmat)
			//rDrawSprite(startpos,8,8,victimTeamCol)
			
			rDrawSprite(endpos,8,8,victimTeamCol)
			ang = (endpos-EyePos()):Angle()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 90)
			if tbl[3] != nil then
				cStart3D2D(endpos,ang,0.3)
					sSetFont("HUDNumber")
					sSetTextPos(0,0)
					sSetTextColor(victimTeamCol)
					sDrawText(tbl[3])
				cEnd3D2D()
			end
		end
		//cIgnoreZ(false)
	end
end

Plugin.Hooks = {
	//PlayerTraceAttack = Plugin.RecordShoots,
	PostDrawOpaqueRenderables = Plugin.DrawBulletTracing,
	ImpactEffect = Plugin.ImpactEffect,
	HUDPaint = Plugin.HUDPaint
}

qq.RegisterPlugin(Plugin)
