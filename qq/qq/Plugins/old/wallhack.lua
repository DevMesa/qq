local qq = eqq -- eqq = externel qq, it exists only a few cycles

local PlyMeta = qq.Meta.Ply
local EntMeta = qq.Meta.Ent

local Plugin = {
	Name = "Wallhack",
	Alias = "wallhack"
}

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Wallhack", true, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons", "Weapons", true, {Save = true})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons_maxdmg", "Max Damage", 43, {Save = true, Min = 0, Max = 100})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons_starthue", "Start Damage Hue", 160, {Save = true, Min = 0, Max = 360})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "weapons_endhue", "End Damage Hue", 30, {Save = true, Min = 0, Max = 360})
	
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "blursize", "Blur Size", 2, {Min = 0, Max = 10, Places = 1})
end

local MaterialBlurX = Material( "pp/blurx" )
local MaterialBlurY = Material( "pp/blury" )
local MaterialWhite = CreateMaterial( "WhiteMaterial", "VertexLitGeneric", {
	 ["$basetexture"] = "color/white",
	 ["$vertexalpha"] = "1",
	 ["$model"] = "1",
} )
local MaterialComposite = CreateMaterial( "CompositeMaterial", "UnlitGeneric", {
	 ["$basetexture"] = "_rt_FullFrameFB",
	 ["$additive"] = "1",
} )
  
local RT1 = GetRenderTarget( "L4D1" )
local RT2 = GetRenderTarget( "L4D2" )


Plugin.RenderToStencil = function(entity)
	-- tell the stencil buffer we're going to write a value of one wherever the model
	-- is rendered
	render.SetStencilEnable( true )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	--STENCILOPERATION_INVERT
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilWriteMask( 1 )
	render.SetStencilReferenceValue( 1 )
	 
	-- this uses a small hack to render ignoring depth while not drawing color
	-- i couldn't find a function in the engine to disable writing to the color channels
	-- i did find one for shaders though, but I don't feel like writing a shader for this.
	cam.IgnoreZ( true )
	  render.SetBlend( 0 )
		local weap = nil
			if type(entity) == "Player" then
				if PlyMeta.GetActiveWeapon(entity) != nil then
					weap = PlyMeta.GetActiveWeapon(entity)
				end
			end
			SetMaterialOverride( MaterialWhite )
				EntMeta.DrawModel(entity)
				if weap != nil and ValidEntity(weap) then
					EntMeta.DrawModel(weap)
				end
			SetMaterialOverride()
			 
	  render.SetBlend( 1 )
	  render.SetBlend( 1 )
	cam.IgnoreZ( false )
	 
	-- don't need this for the next pass
	render.SetStencilEnable( false )
end
 
Plugin.RenderToGlowTexture = function(entity)
	if not qq.Setting(Plugin, "enabled") then return end
	local w, h = ScrW(), ScrH()
	local fogmode = render.GetFogMode()
	render.FogMode(MATERIAL_FOG_NONE)
	-- draw into the white texture
	local oldRT = render.GetRenderTarget()
	render.SetRenderTarget( RT1 )
		render.SetViewPort( 0, 0, 512, 512 )
				
		cam.IgnoreZ( false )
			local weap = nil
			render.SuppressEngineLighting( true )
			if type(entity) == "Player" then
				local col = team.GetColor(PlyMeta.Team(entity))
				if entity.StencilColor != nil then
					col = entity.StencilColor
				end
				render.SetColorModulation( col.r/255, col.g/255, col.b/255)
				if PlyMeta.GetActiveWeapon(entity) != nil then
					weap = PlyMeta.GetActiveWeapon(entity)
				end
			else
				local col = Color(255,255,255)
				if entity.StencilColor != nil then
					col = entity.StencilColor
				end
				render.SetColorModulation( col.r/255, col.g/255, col.b/255)
			end
			
			SetMaterialOverride( MaterialWhite )
				EntMeta.DrawModel(entity)
				if weap != nil and ValidEntity(weap) then
					EntMeta.DrawModel(weap)
				end
			SetMaterialOverride()
				
			render.SetColorModulation( 1, 1, 1 )
			render.SuppressEngineLighting( false )
			
		cam.IgnoreZ( false )
		
		render.SetViewPort( 0, 0, w, h )
	render.SetRenderTarget( oldRT )
	render.FogMode(fogmode)
end

Plugin.RenderScene = function( Origin, Angles )
	if not qq.Setting(Plugin, "enabled") then return end
	local oldRT = render.GetRenderTarget()
	render.SetRenderTarget( RT1 )
	render.Clear( 0, 0, 0, 255, true )
	render.SetRenderTarget( oldRT )
	
end

Plugin.Disabled = function()
	if Plugin.FakeModel and ValidEntity(Plugin.FakeModel) then
		Plugin.FakeModel:Remove()
	end
end
Plugin.Enabled = function()
	Plugin.FakeModel = ClientsideModel("models/props_c17/canister02a.mdl", RENDERGROUP_OPAQUE)
	Plugin.FakeModel:SetPos(Vector(0,0,-1000))
end

Plugin.SetupFakeModel = function(ent)
	EntMeta.SetModel(Plugin.FakeModel, "models/props_c17/canister02a.mdl")
	local mdl = EntMeta.GetModel(ent)
	if mdl == nil then return end
	EntMeta.SetModel(Plugin.FakeModel, mdl)

	EntMeta.SetPos(Plugin.FakeModel, EntMeta.GetPos(ent))
	EntMeta.SetAngles(Plugin.FakeModel, EntMeta.GetAngles(ent))
	
	Plugin.FakeModel.StencilColor = ent.StencilColor
end

Plugin.MoveFakeModel = function()
	EntMeta.SetPos(Plugin.FakeModel, Vector(0,0,-1000))
	Plugin.FakeModel.StencilColor = nil
end

Plugin.DrawOtherStuff = function()
	if not qq.Setting(Plugin, "enabled") then return end
		
	local entslist = ents.GetAll()
	local count = #entslist
	
	for i = 1, count do
		local ent = entslist[i]
		if not ValidEntity(ent) then continue end
		if type(ent) == "Player" then continue end
		if EntMeta.GetModel(ent) == "" then continue end
		
		local t = type(ent)
		local Draw = qq.CallInternalHook("QQShouldWallhack", ent, t)
		//print(EntMeta.GetModel(ent))
		if Draw and Draw > 0 then
			if Draw > 1 then
				Plugin.SetupFakeModel(ent)
				Plugin.OUTLINING = true
				
				Plugin.RenderToStencil( Plugin.FakeModel )
				Plugin.RenderToGlowTexture( Plugin.FakeModel )
				
				Plugin.OUTLINING = false
				Plugin.MoveFakeModel()
			else
				Plugin.OUTLINING = true
				
				Plugin.RenderToStencil( ent )
				Plugin.RenderToGlowTexture( ent )
				
				Plugin.OUTLINING = false
			end
		end
		
	end
end

Plugin.ShouldWallhackEnt = function(ent,typ)
	
	if typ == "NPC" then
		ent.StencilColor = Color(255,0,0)
		return 1
	elseif typ == "Weapon" and qq.Setting(Plugin, "weapons") then
		if not ValidEntity(ent.Owner) or ent.Owner == nil then
			local col = Color(255,255,255)
			if ent.Primary then
				local maxdmg = qq.Setting(Plugin, "weapons_maxdmg")
				local starthue = qq.Setting(Plugin, "weapons_starthue")
				local endhue = qq.Setting(Plugin, "weapons_endhue")
				
				local dmg = ent.Primary.Damage or 0
				dmg = math.max(0, 1 - (dmg / maxdmg))
				dmg = dmg * (starthue - endhue) + endhue
				
				//print(dmg, ent.Primary.Damage)
				col = HSVToColor(dmg, 1, 1)
			end
			ent.StencilColor = col
			return 2
		end
	end
end

Plugin.RenderScreenspaceEffects = function( )
	if not qq.Setting(Plugin, "enabled") then return end
	
	MaterialBlurX:SetMaterialTexture( "$basetexture", RT1 )
	MaterialBlurY:SetMaterialTexture( "$basetexture", RT2 )
	
	local BlurSize = qq.Setting(Plugin, "blursize") or 2
	
	MaterialBlurX:SetMaterialFloat( "$size", BlurSize ) // 2
	MaterialBlurY:SetMaterialFloat( "$size", BlurSize )
	
	local oldRT = render.GetRenderTarget()
	
	-- blur horizontally
	render.SetRenderTarget( RT2 )
	render.SetMaterial( MaterialBlurX )
	render.DrawScreenQuad()
 
	-- blur vertically
	render.SetRenderTarget( RT1 )
	render.SetMaterial( MaterialBlurY )
	render.DrawScreenQuad()
 
	render.SetRenderTarget( oldRT )
	
	-- tell the stencil buffer we're only going to draw
	 -- where the player models are not.
	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilTestMask( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	 
	-- composite the scene
	MaterialComposite:SetMaterialTexture( "$basetexture", RT1 )
	render.SetMaterial( MaterialComposite )
	render.DrawScreenQuad()
 
	 -- don't need this anymore
	render.SetStencilEnable( false )
end


Plugin.PostPlayerDraw = function( pl )
	if not qq.Setting(Plugin, "enabled") then return end
	-- prevent recursion
	if( Plugin.OUTLINING ) then return end
	Plugin.OUTLINING = true
	Plugin.RenderToStencil( pl )
	Plugin.RenderToGlowTexture( pl )
	-- prevents recursion time
	Plugin.OUTLINING = false
	if( ScrW() == ScrH() ) then return end
	return false // Prevent gay GMs doing shit to players too (like hats)
end --PostDrawOpaqueRenderables


Plugin.Hooks = {
	RenderScene = Plugin.RenderScene,
	RenderScreenspaceEffects = Plugin.RenderScreenspaceEffects,
	PostPlayerDraw = Plugin.PostPlayerDraw,
	PostDrawTranslucentRenderables = Plugin.DrawOtherStuff,
	QQShouldWallhack = Plugin.ShouldWallhackEnt
	//PostDrawTranslucentRenderables = Plugin.DrawOtherStuff
}

qq.RegisterPlugin(Plugin)