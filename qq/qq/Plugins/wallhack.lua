local qq = eqq -- eqq = externel qq, it exists only a few cycles

local Plugin = {
	Name = "Wallhack",
	Alias = "wallhack",
	Mode = "wf"
}

local RT1 = GetRenderTarget("L4D1")
local RT2 = GetRenderTarget("L4D2")

local MaterialWhite = CreateMaterial("WhiteMaterial", "VertexLitGeneric", {
	["$basetexture"] = "color/white",
	["$vertexalpha"] = "1",
	["$model"] = "1",
	["$ignorez"] = "1"
})

local MaterialComposite = CreateMaterial("CompositeMaterial", "UnlitGeneric", {
	["$basetexture"] = "_rt_FullFrameFB",--hack
	["$additive"] = "1",
})
MaterialComposite:SetMaterialTexture("$basetexture", RT1)

local MaterialBlurX = Material("qq/qqblurx")
local MaterialBlurY = Material("qq/qqblury")

MaterialBlurX:SetMaterialTexture("$basetexture", RT1)
MaterialBlurY:SetMaterialTexture("$basetexture", RT2)

local lookUpTable = {
	["Left 4 Dead"] = "l4d",
	Wireframe = "wf",
	Fullbright = "fullbr",
	["Team color"] = "tcol"
}

local matMetaSetMaterialFloat = qq.Meta.Mat.SetMaterialFloat

local function blurChangeCallback(_, old, val)--this is WAY more efficient than doing it every FUCKING frame bro
	matMetaSetMaterialFloat(MaterialBlurX, "$size", val)
	matMetaSetMaterialFloat(MaterialBlurY, "$size", val)
end


Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Wallhack", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons", "Weapons", true, {Save = true})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "mode", "Mode", "", {
		MultiChoice = {
			["Left 4 Dead"] = false,
			["Wireframe"] = false,
			["Fullbright"] = false,
			["Team color"] = false
		},
		Save = true
	}, function(name, val) Plugin.Mode = lookUpTable[qq.Setting(Plugin, "mode")] or "tcol" end)
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons_maxdmg", "Max Damage", 43, {Save = true, Min = 0, Max = 100})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons_starthue", "Start Damage Hue", 160, {Save = true, Min = 0, Max = 360})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons_endhue", "End Damage Hue", 30, {Save = true, Min = 0, Max = 360})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "blursize", "Blur Size", 2, {Save = true, Min = 0, Max = 10, Places = 1}, blurChangeCallback)
end


local STENCILOPERATION_KEEP = qq.GlobalCopy.STENCILOPERATION_KEEP
local STENCILOPERATION_REPLACE = qq.GlobalCopy.STENCILOPERATION_REPLACE
local STENCILCOMPARISONFUNCTION_ALWAYS = qq.GlobalCopy.STENCILCOMPARISONFUNCTION_ALWAYS
local STENCILCOMPARISONFUNCTION_EQUAL = qq.GlobalCopy.STENCILCOMPARISONFUNCTION_EQUAL
local STENCILOPERATION_ZERO = qq.GlobalCopy.STENCILOPERATION_ZERO

local MATERIAL_FOG_NONE = qq.GlobalCopy.MATERIAL_FOG_NONE


local rSetStencilEnable = qq.GlobalCopy.render.SetStencilEnable
local rSetStencilFailOperation = qq.GlobalCopy.render.SetStencilFailOperation
local rSetStencilZFailOperation = qq.GlobalCopy.render.SetStencilZFailOperation
local rSetStencilPassOperation = qq.GlobalCopy.render.SetStencilPassOperation
local rSetStencilCompareFunction = qq.GlobalCopy.render.SetStencilCompareFunction
local rSetStencilWriteMask = qq.GlobalCopy.render.SetStencilWriteMask
local rSetStencilReferenceValue = qq.GlobalCopy.render.SetStencilReferenceValue
local rSetBlend = qq.GlobalCopy.render.SetBlend
local rFogStart = qq.GlobalCopy.render.FogStart
local rFogEnd = qq.GlobalCopy.render.FogEnd
local rGetRenderTarget = qq.GlobalCopy.render.GetRenderTarget
local rSetRenderTarget = qq.GlobalCopy.render.SetRenderTarget
local rClear = qq.GlobalCopy.render.Clear
local rGetFogMode = qq.GlobalCopy.render.GetFogMode
local rFogMode = qq.GlobalCopy.render.FogMode
local rSetViewPort = qq.GlobalCopy.render.SetViewPort
local rSuppressEngineLighting = qq.GlobalCopy.render.SuppressEngineLighting
local rSetColorModulation = qq.GlobalCopy.render.SetColorModulation
local rDrawScreenQuad = qq.GlobalCopy.render.DrawScreenQuad
local rSetMaterial = qq.GlobalCopy.render.SetMaterial
local rSetStencilTestMask = qq.GlobalCopy.render.SetStencilTestMask

local cIgnoreZ = qq.GlobalCopy.cam.IgnoreZ
local cStart3D = qq.GlobalCopy.cam.Start3D
local cEnd3D = qq.GlobalCopy.cam.End3D

local mmax = qq.GlobalCopy.math.max

local tGetColor = qq.GlobalCopy.team.GetColor

local eGetAll = qq.GlobalCopy.ents.GetAll

local pairs = qq.GlobalCopy.pairs
local type = qq.GlobalCopy.type
local SetMaterialOverride = qq.GlobalCopy.SetMaterialOverride
local ValidEntity = qq.Meta.Ent.IsValid
local ScrW = qq.GlobalCopy.ScrW
local ScrH = qq.GlobalCopy.ScrH
local HSVToColor = qq.GlobalCopy.HSVToColor
local ClientsideModel = qq.GlobalCopy.ClientsideModel
local EyePos = qq.GlobalCopy.EyePos
local EyeAngles = qq.GlobalCopy.EyeAngles
local LocalPlayer = qq.GlobalCopy.LocalPlayer

local weap
local fogMode
local oldRT
local col
local oldW
local oldH
local dmg
local maxdmg
local starthue
local endhue

local entsToBeWallhacked = {};

local colWhite = Color(255, 255, 255, 255)
local colRed = Color(255, 0, 0, 255)


local plyMetaTeam = qq.Meta.Ply.Team
local plyMetaGetActiveWeapon = qq.Meta.Ply.GetActiveWeapon

local entMetaHealth = qq.Meta.Ent.Health
local entMetaDrawModel = qq.Meta.Ent.DrawModel
local entMetaGetPos = qq.Meta.Ent.GetPos
local entMetaSetPos = qq.Meta.Ent.SetPos
local entMetaGetAngles = qq.Meta.Ent.GetAngles
local entMetaSetAngles = qq.Meta.Ent.SetAngles
local entMetaRemove = qq.Meta.Ent.Remove
local entMetaSetupBones = qq.Meta.Ent.SetupBones
local entMetaGetModel = qq.Meta.Ent.GetModel
local entMetaSetModel = qq.Meta.Ent.SetModel

local qqMIsDormat = qq.Module.IsDormant;

local function shouldWallhack(ent,typ)
	if ent == LocalPlayer() then
		return false
	end
	if typ == "Player" then
		return entMetaHealth(ent) > 0 and not qqMIsDormat(ent)
	end
	if typ == "NPC" then
		ent.WallhackColor = colRed
		return true
	end
	if	typ == "Weapon" and qq.Setting(Plugin, "weapons") then
		if not ValidEntity(ent.Owner) then
			col = colRed
			if ent.Primary then
				endhue = qq.Setting(Plugin, "weapons_endhue")
				col = HSVToColor(mmax(0, 1 - ((ent.Primary.Damage or 0) / qq.Setting(Plugin, "weapons_maxdmg"))) * (qq.Setting(Plugin, "weapons_starthue") - endhue) + endhue, 1, 1)
			end
			ent.WallhackColor = col
			return true
		end
	end
end

Plugin.Disabled = function()
	if Plugin.FakeModel and ValidEntity(Plugin.FakeModel) then
		entMetaRemove(Plugin.FakeModel)
	end
end

Plugin.Enabled = function()
	Plugin.FakeModel = ClientsideModel("models/props_c17/canister02a.mdl", RENDERGROUP_OPAQUE)
	entMetaSetPos(Plugin.FakeModel, Vector(0,0,-1000));
end

local function l4dClearRT()
	oldRT = rGetRenderTarget()
	rSetRenderTarget(RT1)
	rClear(0, 0, 0, 255, true)
	rSetRenderTarget(oldRT)
end

local function drawFakeEnt(ent)
	if entMetaGetModel(ent) == nil then return end
	entMetaSetModel(Plugin.FakeModel,entMetaGetModel(ent))
	entMetaSetPos(Plugin.FakeModel, entMetaGetPos(ent))
	entMetaSetAngles(Plugin.FakeModel, entMetaGetAngles(ent))
	entMetaSetupBones(Plugin.FakeModel)
	entMetaDrawModel(Plugin.FakeModel)
end

local function l4dPrepareStencil()
	rSetStencilEnable(true)
	rSetStencilFailOperation(STENCILOPERATION_KEEP)
	rSetStencilZFailOperation(STENCILOPERATION_KEEP)
	rSetStencilPassOperation(STENCILOPERATION_REPLACE)
	rSetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	rSetStencilWriteMask(1)
	rSetStencilReferenceValue(1)
	rSetBlend(0)
		SetMaterialOverride(MaterialWhite)
			weap = nil
			for ent, typ in pairs(entsToBeWallhacked) do
				if(!typ) then
					continue
				end
				if typ == "Player" then
					if plyMetaGetActiveWeapon(ent) then
						weap = plyMetaGetActiveWeapon(ent)
					end
					if ValidEntity(weap) then
						entMetaDrawModel(weap)
					end
				end
				if(ent.Primary) then
					drawFakeEnt(ent)
					continue
				end
				entMetaDrawModel(ent)
			end
		SetMaterialOverride()
	rSetBlend(1)
	rSetStencilEnable(false)
end

local function l4dDrawToRT()
	oldW = ScrW()
	oldH = ScrH()
	fogMode = rGetFogMode()
	if(fogMode != MATERIAL_FOG_NONE) then
		rFogMode(MATERIAL_FOG_NONE)
	end
	oldRT = rGetRenderTarget()
	rSetRenderTarget(RT1)
		rSetViewPort(0, 0, 512, 512)
			rSuppressEngineLighting(true)
				SetMaterialOverride(MaterialWhite)
					weap = nil
					for ent, typ in pairs(entsToBeWallhacked) do
						if(!typ) then
							continue
						end
						if typ == "Player" then
							col = tGetColor(plyMetaTeam(ent))
							if ent.WallhackColor then
								col = ent.WallhackColor
							end
							rSetColorModulation(col.r/255, col.g/255, col.b/255)
							if plyMetaGetActiveWeapon(ent) then
								weap = plyMetaGetActiveWeapon(ent)
							end
							if ValidEntity(weap) then
								entMetaDrawModel(weap)
							end
						else
							col = colWhite
							if ent.WallhackColor then
								col = ent.WallhackColor
							end
							rSetColorModulation(col.r/255, col.g/255, col.b/255)
						end
						if(ent.Primary) then
							drawFakeEnt(ent)
							continue
						end
						entMetaDrawModel(ent)
					end
				SetMaterialOverride()
				rSetColorModulation(1, 1, 1)--general reset!
			rSuppressEngineLighting(false)	
		rSetViewPort(0, 0, oldW, oldH)
	rSetRenderTarget(oldRT)
	if(fogMode != MATERIAL_FOG_NONE) then
		rFogMode(MATERIAL_FOG_NONE)
	end
end

local function l4dDumpToScreen()
	oldRT = rGetRenderTarget()
	
	-- blur horizontally
	rSetRenderTarget(RT2)
	rSetMaterial(MaterialBlurX)
	rDrawScreenQuad()
 
	-- blur vertically
	rSetRenderTarget(RT1)
	rSetMaterial(MaterialBlurY)
	rDrawScreenQuad()
 
	rSetRenderTarget(oldRT)
	
	-- tell the stencil buffer we're only going to draw
	-- where the player models are not.
	rSetStencilEnable(true)
	rSetStencilReferenceValue(0)
	rSetStencilTestMask(1)
	rSetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	rSetStencilPassOperation(STENCILOPERATION_ZERO)
	
	-- composite the scene
	rSetMaterial(MaterialComposite)
	rDrawScreenQuad()
	-- don't need this anymore
	rSetStencilEnable(false)
end

local function drawL4DWallhack()
	l4dClearRT()
	cStart3D(EyePos(), EyeAngles())
		cIgnoreZ(true)
			l4dPrepareStencil()
			l4dDrawToRT()
		cIgnoreZ(false)
	cEnd3D()
	l4dDumpToScreen()
end

local wireFrameMat = Material("hlmv/debugmrmwireframe");

local function drawWireframeWallhack()
	cStart3D(EyePos(), EyeAngles())
		cIgnoreZ(true)
			SetMaterialOverride(wireFrameMat)
			weap = nil
			for ent, typ in pairs(entsToBeWallhacked) do
				if(!typ) then
					continue
				end
				if typ == "Player" then
					col = tGetColor(plyMetaTeam(ent))
					if ent.WallhackColor then
						col = ent.WallhackColor
					end
					rSetColorModulation(col.r/255, col.g/255, col.b/255)
					if plyMetaGetActiveWeapon(ent)  then
						weap = plyMetaGetActiveWeapon(ent)
					end
					if ValidEntity(weap) then
						entMetaDrawModel(weap)
					end
				else
					col = colWhite
					if ent.WallhackColor  then
						col = ent.WallhackColor
					end
					rSetColorModulation(col.r/255, col.g/255, col.b/255)
				end
				if(ent.Primary) then
					drawFakeEnt(ent)
					continue
				end
				entMetaDrawModel(ent)
			end
			SetMaterialOverride()
		cIgnoreZ(false)
	cEnd3D()
end

local function drawFullbrightWallhack()
	cStart3D(EyePos(), EyeAngles())
		cIgnoreZ(true)
			rSuppressEngineLighting(true)
				weap = nil
				for ent, typ in pairs(entsToBeWallhacked) do
					if(!typ) then
						continue
					end
					if typ == "Player" then
						if plyMetaGetActiveWeapon(ent)  then
							weap = plyMetaGetActiveWeapon(ent)
						end
						if ValidEntity(weap) then
							entMetaDrawModel(weap)
						end
					end
					if(ent.Primary) then
						drawFakeEnt(ent)
						continue
					end
					entMetaDrawModel(ent)
				end
			rSuppressEngineLighting(false)
		cIgnoreZ(false)
	cEnd3D()
end

local function drawTeamColWallhack()
	cStart3D(EyePos(), EyeAngles())
		cIgnoreZ(true)
			rSuppressEngineLighting(true)
				weap = nil
				SetMaterialOverride(MaterialWhite)
				for ent, typ in pairs(entsToBeWallhacked) do
					if(!typ) then
						continue
					end
					if typ == "Player" then
						col = tGetColor(plyMetaTeam(ent))
						if ent.WallhackColor then
							col = ent.WallhackColor
						end
						rSetColorModulation(col.r/255, col.g/255, col.b/255)
						if plyMetaGetActiveWeapon(ent)  then
							weap = plyMetaGetActiveWeapon(ent)
						end
						if ValidEntity(weap) then
							entMetaDrawModel(weap)
						end
					else
						col = colWhite
						if ent.WallhackColor  then
							col = ent.WallhackColor
						end
						rSetColorModulation(col.r/255, col.g/255, col.b/255)
					end
					if(ent.Primary) then
						drawFakeEnt(ent)
						continue
					end
					entMetaDrawModel(ent)
				end
				SetMaterialOverride()
			rSuppressEngineLighting(false)
		cIgnoreZ(false)
	cEnd3D()
end

local typ

Plugin.DrawWallHack = function()
	if not qq.Setting(Plugin, "enabled") or (qq.Plugins.mirror and qq.Plugins.mirror.DrawingMirror) then return end
	for _, ent in pairs(eGetAll()) do
		typ = type(ent)
		if(shouldWallhack(ent, typ) or qq.CallInternalHook("QQShouldWallhack", ent, typ)) then
			entsToBeWallhacked[ent] = typ
		else
			entsToBeWallhacked[ent] = nil
		end
	end
	
	for ent  in pairs(entsToBeWallhacked) do
		if(!ValidEntity(ent)) then
			entsToBeWallhacked[ent] = nil
			continue
		end
	end
	
	if(Plugin.Mode == "l4d") then
		drawL4DWallhack()
	elseif(Plugin.Mode == "wf") then
		drawWireframeWallhack()
	elseif(Plugin.Mode == "fullbr") then
		drawFullbrightWallhack()
	elseif(Plugin.Mode == "tcol") then
		drawTeamColWallhack()
	end
end
	
Plugin.PrePlayerDraw = function(pl)
	if(qq.Setting(Plugin, "enabled")) then
		return false
	end
end

Plugin.PostPlayerDraw = function(pl)
	if(qq.Setting(Plugin, "enabled")) then
		return false
	end
end

Plugin.Hooks = {
	RenderScreenspaceEffects = Plugin.DrawWallHack,
	PostPlayerDraw = Plugin.PostPlayerDraw,
	PrePlayerDraw = Plugin.PrePlayerDraw,
}

qq.RegisterPlugin(Plugin)
