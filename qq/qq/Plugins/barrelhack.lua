local qq = eqq

local Plugin = {
	Name = "Barrel Hack",
	Alias = "barrelhack"
}

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "enabled", "Barrel Hack", false, {Save = true})
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "selflaser", "Self Laser", false, {Save = true})
end

local PlyMeta = qq.Meta.Ply
local EntMeta = qq.Meta.Ent
local VecMeta = qq.Meta.Vec

local render = qq.GlobalCopy.render
local cam = qq.GlobalCopy.cam

local bluelaser = Material("sprites/bluelaser1")
local laserdot = Material("Sprites/light_glow02_add_noz")

Plugin.SWEPSWithHL2Models = {}
Plugin.InARow = 0
Plugin.BarrelHack = function()
	local lp = LocalPlayer()
	if  qq.Setting(Plugin, "selflaser") then
		if not PlyMeta.Alive(lp) then return end
		
		local eyepos = EyePos()
		local eyeang = EyeAngles()
		
		local weap = PlyMeta.GetActiveWeapon(lp)
		if not weap or not ValidEntity(weap) then return end
		
		local vm = PlyMeta.GetViewModel(lp)
		if vm == nil or not EntMeta.IsValid(vm) then return end		
		
		local bone = EntMeta.LookupAttachment(vm, "muzzle")
		if bone == nil || bone == 0 then bone = EntMeta.LookupAttachment(vm, "1") end
		if bone == nil || bone == 0 then bone = EntMeta.LookupAttachment(vm, "laser") end
		if bone == nil || bone == 0 then bone = EntMeta.LookupAttachment(vm, "spark") end
		if bone == nil || bone == 0 then bone = EntMeta.LookupAttachment(vm, "0") end
		if bone == nil || bone == 0 then return end

		local col = team.GetColor(PlyMeta.Team(lp))
		local boneangpos = EntMeta.GetAttachment(vm, bone)
		
		if not boneangpos then return end
		
		local bonepos = boneangpos.Pos
		--local hitpos = PlyMeta.GetEyeTrace(lp).HitPos
		local check = weap.ViewModelFlip
		local hitpos
		// credits to wizard
		if qq.IsReloading() or qq.CanFire() then
			local class = EntMeta.GetClass(weap)
			
			local IsHL2ViewModel = table.HasValue(Plugin.SWEPSWithHL2Models, class)
			
			if not IsHL2ViewModel then
				local ang = boneangpos.Ang
				local pythag = math.sqrt(ang.p * ang.p + ang.y * ang.yaw)
				
				if math.Round(pythag) == 10 then
					Plugin.InARow = Plugin.InARow + 1
					if Plugin.InARow == 2 then // This is just for safty!
						Plugin.SWEPSWithHL2Models[class] = class
						qq.Debug("{1} is a HL2 Viewmodel!", class)
						IsHL2ViewModel = true
				
					end
				end
			end
			if check == true then--css flipped
				boneangpos.Ang.p = boneangpos.Ang.r + 270
				boneangpos.Ang.y = boneangpos.Ang.y + 90
				boneangpos.Ang.r = boneangpos.Ang.p
				hitpos = util.QuickTrace(boneangpos.Pos, boneangpos.Ang:Forward() * 20000).HitPos
			elseif check == false then--css unflipped
				hitpos = util.QuickTrace(boneangpos.Pos, boneangpos.Ang:Up() * 20000).HitPos
			elseif check == nil then--hl2 nil
				hitpos = util.QuickTrace(boneangpos.Pos, boneangpos.Ang:Forward() * 20000).HitPos
			end
		else 
			hitpos = PlyMeta.GetEyeTrace(lp).HitPos
		end
	
		
		cam.Start3D(eyepos, eyeang)
			render.SetMaterial(laserdot)
			render.DrawQuadEasy(hitpos, VecMeta.GetNormal(eyepos - hitpos), 20, 20, col, 0)
			render.SetMaterial(bluelaser)
			render.DrawBeam(bonepos, hitpos, 3, 0, 0, col)
		cam.End3D()
	end
	if not qq.Setting(Plugin, "enabled") then return end
	local ep = EyePos()
	local ea = EyeAngles()
	
	local trace2 = {}
	trace2.start = ep
	trace2.endpos = nil
	trace2.filter = lp
	
	cam.Start3D(ep, ea)
		cam.IgnoreZ(false)
		for k, pl in pairs( player.GetAll() ) do
			if pl != lp and PlyMeta.Alive(pl) then
				local trace = PlyMeta.GetEyeTrace(pl)
				local col = team.GetColor(PlyMeta.Team(pl))
				trace2.endpos = trace.HitPos
				local trace2res = util.TraceLine(trace2)
				if trace2res.HitPos == trace.HitPos then // for some reasond depth testing doesnt work on this function :(
					render.SetMaterial(laserdot)
					render.DrawQuadEasy(trace.HitPos, VecMeta.GetNormal(ep - trace.HitPos), 20, 20, col, 0)
				end
				render.SetMaterial(bluelaser)
				render.DrawBeam(trace.StartPos, trace.HitPos, 3, 0, 0, col)
			end
		end
	cam.End3D()
end

Plugin.Hooks = {
	RenderScreenspaceEffects = Plugin.BarrelHack
}

qq.RegisterPlugin(Plugin)