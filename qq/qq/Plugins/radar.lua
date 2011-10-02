local qq = eqq
local Plugin = {
	Name = "Radar",
	Alias = "radar"
}

local RadarTex = GetRenderTarget("Radar");
local RadarMaterial = CreateMaterial("RadarMaterial", "UnlitGeneric", {
	["$basetexture"] = RadarTex:GetName(),
	["$ignorez"] = "1",
	["$nolod"] = "1",
	["$vertexalpha"] = "1",
	["$vertexcolor"] = "1"
});

local radarPosX = ScrW()-260;
local radarPosY = ScrH()-260;

local msin, mcos, mrad = math.sin,math.cos,math.rad; --Only needed when you constantly calculate a new polygon, it slightly increases the speed.
local function GeneratePoly(x,y,radius,quality)
	local circle = {};
	local tmp = 0;
	local s,c;
	for i=1,quality do
		tmp = mrad(i*360)/quality;
		s = msin(tmp);
		c = mcos(tmp);
		circle[i] = {x = x + c*radius,y = y + s*radius,u = (c+1)/2,v = (s+1)/2};
	end
	return circle;
end

local radarPoly;

local function setupRadar()
	radarPoly = GeneratePoly(radarPosX, radarPosY, 256, qq.Setting(Plugin, "quality"));
end

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Radar", false, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "updateRate", "Update Rate", false, {Save = true, Slider = true, Min = 1, Max = 300, Places = 0}, setupRadar)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "round", "Circle", false, {Save = true}, setupRadar)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "quality", "Quality", false, {Save = true, Slider = true, Min = 8, Max = 64, Places = 0}, setupRadar)
end

local rGetRenderTarget = qq.GlobalCopy.render.GetRenderTarget
local rSetRenderTarget = qq.GlobalCopy.render.SetRenderTarget
local rClear = qq.GlobalCopy.render.Clear
local rSetViewPort = qq.GlobalCopy.render.SetViewPort

local oldRT;
local oldW;
local oldH;
local function updateRadar()
	oldRT = rGetRenderTarget();
	oldW = ScrW();
	oldH = ScrH();
	rSetRenderTarget(RadarTex);
		rClear(0, 0, 0, 255);
		rSetViewPort(0, 0, 512, 512);
			cStart2D();
				--render stuff
			cEnd2D();
		rSetViewPort(0, 0, oldW, oldH);
	rSetRenderTarget(oldRT);
end
		
local frameCount = 1;
Plugin.HUDPaint = function()
	surface.SetDrawColor(255, 255, 255, 255);
	surface.SetMaterial(RadarMaterial);
	if(qq.Setting(Plugin, "round")) then
		surface.DrawPoly(radarPoly);
	else
		surface.DrawTexturedRect(radarPosX, radarPosY, 256,256);
	end
	if(frameCount == qq.Setting(Plugin, "updateRate")) then
		frameCount = 0;
		updateRadar();
	end
	frameCount = frameCount + 1;
end