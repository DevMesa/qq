local qq = eqq

local Plugin = {
	Name = "Illumination",
	Alias = "illumination",
}

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Enable", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "localplayer", "Use on self", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "size", "Localplayer light size", 256, {Save = true, Min = 128, Max = 2048, Places = 0, Slider = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "bright", "Localplayer light brightness", 2, {Save = true, Min = 0.1, Max = 10, Places = 1, Slider = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "others", "Use on others", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "othersize", "Others light size", 5, {Save = true, Min = 128, Max = 2048, Places = 0, Slider = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "otherbright", "Others light brightness", 2, {Save = true, Min = 0.1, Max = 10, Places = 1, Slider = true})
	--qq.CreateSetting(qq.MENU_VISUALS, Plugin, "loffset", "Light offset", 5, {Save = true, Min = 0, Max = 50, Places = 0, Slider = true})
	
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "smartlight", "Use smartlight", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "smartlightmin", "Minimum light for smartlight", 0.4, {Save = true, Min = 0, Max = 1, Places = 2, Slider = true})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "constrastadj", "Automatically adjust contrast", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "constrastmul", "Constrast multiplicator", 1, {Save = true, Min = 0, Max = 1, Places = 2, Slider = true})
end

local rGetLightColor = qq.GlobalCopy.render.GetLightColor

local tGetColor = qq.GlobalCopy.team.GetColor

local pGetAll = qq.GlobalCopy.player.GetAll
local ValidEntity = qq.GlobalCopy.ValidEntity
local ipairs = qq.GlobalCopy.ipairs
local CurTime = qq.GlobalCopy.CurTime
local LocalPlayer = qq.GlobalCopy.LocalPlayer
local DynamicLight = qq.GlobalCopy.DynamicLight

local plyMetaTeam = qq.Meta.Ply.Team
local entMetaGetPos = qq.Meta.Ent.GetPos
local entMetaGetEntIndex = qq.Meta.Ent.EntIndex
local vecMetaLength = qq.Meta.Vec.Length


local dlight
local col
local lp
local others
local localp
local pos
local othersize
local otherbright
local curtime
local dodraw
local function DrawLights()
	dodraw = !dodraw--only every second frame
	if(dodraw) then
		if(qq.Setting(Plugin, "enabled")) then
			lp = LocalPlayer()
			others = qq.Setting(Plugin, "others")
			curtime = CurTime()
			if(others) then
				othersize = qq.Setting(Plugin, "othersize")
				otherbright = qq.Setting(Plugin, "otherbright")
			end
			localp = qq.Setting(Plugin, "localplayer")
			
			for idx, ply in ipairs(pGetAll()) do
				if(others and ply != lp) then
					dlight = DynamicLight(entMetaGetEntIndex(ply))
					if(!dlight) then continue end
					dlight.Pos = entMetaGetPos(ply)
					col = tGetColor(plyMetaTeam(ply))
					dlight.r = col.r
					dlight.g = col.g
					dlight.b = col.b
					dlight.Brightness = otherbright
					dlight.Size = othersize
					dlight.Decay = 0
					dlight.DieTime = curtime + 0.1
				elseif(localp and ply == lp) then
					pos = entMetaGetPos(ply)
					col = rGetLightColor(pos)
					if(qq.Setting(Plugin, "smartlight") and vecMetaLength(col) >= qq.Setting(Plugin, "smartlightmin")) then
						continue
					end
					dlight = DynamicLight(entMetaGetEntIndex(ply))
					if(!dlight) then continue end
					dlight.Pos = pos
					dlight.r = 255
					dlight.g = 255
					dlight.b = 255
					dlight.Brightness = qq.Setting(Plugin, "bright")
					dlight.Size = qq.Setting(Plugin, "size")
					dlight.Decay = 0
					dlight.DieTime = curtime + 0.1
				end
			end
		end
	end
end

local colMat = Material("qq/qqcolormod")

local matMetaSetMaterialFloat = qq.Meta.Mat.SetMaterialFloat

matMetaSetMaterialFloat(colMat, "$pp_colour_addr", 0)
matMetaSetMaterialFloat(colMat, "$pp_colour_addg", 0)
matMetaSetMaterialFloat(colMat, "$pp_colour_addb", 0)
matMetaSetMaterialFloat(colMat, "$pp_colour_brightness", 0)
matMetaSetMaterialFloat(colMat, "$pp_colour_contrast", 1)
matMetaSetMaterialFloat(colMat, "$pp_colour_colour", 1)
matMetaSetMaterialFloat(colMat, "$pp_colour_mulr", 0)
matMetaSetMaterialFloat(colMat, "$pp_colour_mulg", 0)
matMetaSetMaterialFloat(colMat, "$pp_colour_mulb", 0)

local rUpdateScreenEffectTexture = qq.GlobalCopy.render.UpdateScreenEffectTexture
local rSetMaterial = qq.GlobalCopy.render.SetMaterial
local rDrawScreenQuad = qq.GlobalCopy.render.DrawScreenQuad

local mmax = qq.GlobalCopy.math.max

local Lerp = qq.GlobalCopy.Lerp

local lastLen = 1
local function ContrastAdjust()
	if(qq.Setting(Plugin, "constrastadj")) then
		col = rGetLightColor(entMetaGetPos(LocalPlayer()))
		lastLen = Lerp(0.1, lastLen, vecMetaLength(col))
		rUpdateScreenEffectTexture()
		matMetaSetMaterialFloat(colMat, "$pp_colour_contrast", mmax(1,1 + (1 - lastLen)*9*qq.Setting(Plugin, "constrastmul")))
		rSetMaterial(colMat)
		rDrawScreenQuad()
	end
end

Plugin.Hooks = {
	PostDrawOpaqueRenderables = DrawLights,
	RenderScreenspaceEffects = ContrastAdjust
}

qq.RegisterPlugin(Plugin)