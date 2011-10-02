local qq = eqq

local Plugin = {
	Name = "Base",
	Alias = "base"
}

qq.ShotMask = CONTENTS_SOLID | CONTENTS_MOVEABLE | CONTENTS_MONSTER | CONTENTS_WINDOW | CONTENTS_DEBRIS | CONTENTS_HITBOX
//CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_DEBRIS // MASK_SHOT //- CONTENTS_WINDOW
qq.TriggerShotMask = MASK_SHOT // CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_DEBRIS // MASK_SHOT // Players are shot mask????

local LocalPlayer = qq.GlobalCopy.LocalPlayer
local table = qq.GlobalCopy.table
local player = qq.GlobalCopy.player
local type = qq.GlobalCopy.type
local ValidEntity = qq.GlobalCopy.ValidEntity

local CmdMeta = qq.Meta.Cmd
local PlyMeta = qq.Meta.Ply
local WepMeta = qq.Meta.Wep
local EntMeta = qq.Meta.Ent
local VecMeta = qq.Meta.Vec
local AngMeta = qq.Meta.Ang

Plugin.DeltaVelocity = {} // Stores it for each player
Plugin.LastPositions = {} // Stores it for each player
Plugin.LastPosUpdate = 0

Plugin.UpdateDeltaVelocityTP = function(v)
	if Plugin.LastPosUpdate == RealTime() then return end
	Plugin.LastPosUpdate = RealTime()
	
	for k,v in pairs(player.GetAll()) do
		if not ValidEntity(v) then continue end
		if qq.Module.IsDormant(v) then continue end
		
		local lastpos = Plugin.LastPositions[v] or EntMeta.GetPos(v)
		Plugin.DeltaVelocity[v] = lastpos - EntMeta.GetPos(v)
		Plugin.LastPositions[v] = EntMeta.GetPos(v)
	end
end

Plugin.CanFire = function()
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return false end
	
	local wep = PlyMeta.GetActiveWeapon(lp)
	if not wep then return false end
	
	if qq.IsReloading() then return false end
	
	if ((wep.Primary or {}).Automatic or false) or not qq.CanFire() then
		return true
	end
	return false
end

Plugin.BaseCreateMove = function(cmd)
	qq.DidAimThisCM = false
	qq.UCmd = cmd
	qq.AimAngle = CmdMeta.GetViewAngles(cmd)
	qq.AimVector = AngMeta.Forward(qq.AimAngle)
	qq.ShootThisCreateMove = false
	qq.CallInternalHook("PreCreateMove", cmd)
	qq.CallInternalHook("CurCreateMove", cmd)
	qq.CallInternalHook("PostCreateMove", cmd)
	qq.CallInternalHook("LastCreateMove", cmd)
	if qq.ShootThisCreateMove then
		if Plugin.CanFire() then
			local buttons = CmdMeta.GetButtons(cmd)
			buttons = buttons | IN_ATTACK
			CmdMeta.SetButtons(cmd, buttons)
		end
		qq.ShootThisCreateMove = false
	end
end

qq.Interp = function()
	local interp = GetConVarNumber("cl_interp")
	return interp
end


Plugin.BaseHUDPaint = function()
	qq.CallInternalHook("HUDPaintPlayerStart")
	local entss = ents.GetAll()
	local count = #entss
	local plycount = 0
	for i = 1, count do
		local e = entss[i]
		if ValidEntity(e) then
			if type(e) == "Player" then
				plycount = plycount + 1
				qq.CallInternalHook("HUDPaintPlayer", e, plycount)
			end
			qq.CallInternalHook("HUDPaintEntity", e, i)
		end
	end
	qq.CallInternalHook("HUDPaintPlayerEnd")
end

Plugin.HandelEvents = function()
	if true then return end
	while true do
		event = qq.Module.GetTopEvent()
		if not event then return end
		
		qq.Debug("Got event {1}", event.EventName)
		qq.CallInternalHook("qq_Event", event)
		qq.CallInternalHook("qq_Event_" .. event.EventName, event)
	end
end

Plugin.BaseThink = function()
	qq.CallInternalHook("ThinkStart")
	local entss = ents.GetAll()
	local count = #entss
	local plycount = 0
	for i = 1, count do
		local e = entss[i]
		if ValidEntity(e) then
			if type(e) == "Player" then
				plycount = plycount + 1
				qq.CallInternalHook("ThinkPlayer", e, plycount)
			end
			qq.CallInternalHook("ThinkEntity", e, i)
		end
	end
	qq.CallInternalHook("ThinkEnd")
	Plugin.HandelEvents()
end

Plugin.BaseCalcView = function(...)
	local base = GAMEMODE:CalcView(...) or {}
	qq.CallInternalHook("BaseCalcView", base)
	if base.Changed then

		return base
	end
end

if not qq.InpactEffect then
	qq.InpactEffect = function(self, tr, ...)
		if not self.Owner then return end
			
		qq.CallInternalHook("ImpactEffect", self, tr, ...)
		
		return self.DoImpactEffect_O(tr, ...)
	end
end

Plugin.PostInit = function()
	//Lets create the detours
	for k, v in pairs(weapons.GetList()) do
		v.DoImpactEffect_O = v.DoImpactEffect_O or v.DoImpactEffect
		v.DoImpactEffect = qq.InpactEffect
	end
end

Plugin.Hooks = {
	CreateMove = Plugin.BaseCreateMove,
	HUDPaint = Plugin.BaseHUDPaint,
	LastCreateMove = Plugin.DoShots,
	Think = Plugin.BaseThink,
	CalcView = Plugin.BaseCalcView,
	Tick = Plugin.UpdateDeltaVelocityTP,
	InitPostEntity = Plugin.PostInit
}
/*
local qq.WepM.SetNextPrimaryFire = qq.WepM.SetNextPrimaryFire or _R.Weapon.SetNextPrimaryFire
function _R.Weapon.SetNextPrimaryFire(self, float)
	qq.NextFireTime = float
	return WepM.SetNextPrimaryFire(self, float)
end
*/
qq.CanFire = function()
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return false end
	local Wep = PlyMeta.GetActiveWeapon(lp)
	if not ValidEntity(Wep) then return false end
	return CurTime() < WepMeta.GetNextPrimaryFire(Wep)
end

qq.IsReloading = function()
	local lp = LocalPlayer()
	if not ValidEntity(lp) then return false end
	local Wep = PlyMeta.GetActiveWeapon(lp)
	if not ValidEntity(Wep) then return false end
	
	return WepMeta.Clip1(Wep) == 0
end


// Returns ENEMY,TEAM,NPC
Plugin.TargetChoices = {}
Plugin.TargetChoices["Enemies"] 		= {true,false,false}
Plugin.TargetChoices["Enemies & Team"] 	= {true,true,false}
Plugin.TargetChoices["Enemies & NPC"] 	= {true,false,true}
Plugin.TargetChoices["Team"] 			= {false,true,false}
Plugin.TargetChoices["Team & NPC"] 		= {false,true,true}
Plugin.TargetChoices["NPC"] 		= {false,false,true}
Plugin.TargetChoices["All"] 			= {true,true,true}

Plugin.TargetsWhom = function()
	local ret = Plugin.TargetChoices[qq.Setting(Plugin,"targetwhom")]
	if ret == nil then
		ret = {true,false,false}
	end
	return ret
end

Plugin.NPCDeathSequences = {}
function Plugin.AddNPCDeathSequence(model, sequence)
	Plugin.NPCDeathSequences = Plugin.NPCDeathSequences or {}
	Plugin.NPCDeathSequences[model] = Plugin.NPCDeathSequences[model] or {}
	if not table.HasValue(Plugin.NPCDeathSequences[model]) then
		table.insert(Plugin.NPCDeathSequences[model], sequence)
	end
end

Plugin.Init = function()
	Plugin.AddNPCDeathSequence("models/barnacle.mdl", 4)
	Plugin.AddNPCDeathSequence("models/barnacle.mdl", 15)
	Plugin.AddNPCDeathSequence("models/antlion_guard.mdl", 44)
	Plugin.AddNPCDeathSequence("models/hunter.mdl", 124)
	Plugin.AddNPCDeathSequence("models/hunter.mdl", 125)
	Plugin.AddNPCDeathSequence("models/hunter.mdl", 126)
	Plugin.AddNPCDeathSequence("models/hunter.mdl", 127)
	Plugin.AddNPCDeathSequence("models/hunter.mdl", 128)
	
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "targetwhom", "Target Whom", "Enemies", {Save = true, MultiChoice = Plugin.TargetChoices})
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "donttargsteamfreinds", "Don't Target Steam Friends", true, {Save = true})
end

qq.IsValidTarget = function(ent, DontCallHook)
	// No invalid entities.
	if !ValidEntity(ent) then return false end
	local res = qq.CallInternalHook("IsValidTarget", ent) // If this returns anything, it overides the below!
	if res != nil and not DontCallHook then // Don't call the hook is for if you wan't a base decisition on whether to target it or not
		return res
	end
	local Enemy, Team, NPC = unpack(Plugin.TargetsWhom())
	
	// We only want players/NPCs.
	local typename = type(ent)
	if typename != "NPC" and typename != "Player" then return false end
	if ( EntMeta.GetMoveType(ent) == MOVETYPE_NONE ) then return false end
	if ( EntMeta.GetModel(ent) == "" ) then return false end

	if qq.Module.IsDormant(ent) then return false  end // Prevents ghosting
	
	// Go shoot yourself, emo kid.
	local ply = LocalPlayer()
	if ent == ply then return false end
	
	if typename == "NPC" and not NPC then return false end
	if typename == "Player" and qq.Setting(Plugin, "donttargsteamfreinds") then
		if PlyMeta.GetFriendStatus(ent) == "friend" then return false end
	end
	if typename == "Player" then
		if not PlyMeta.Alive(ent) then return false end
		if not Team and PlyMeta.Team(ent) == PlyMeta.Team(ply) then return false end
		if (not Enemy and Team) and PlyMeta.Team(ent) != PlyMeta.Team(ply) then return false end
		if EntMeta.GetMoveType(ent) == MOVETYPE_OBSERVER then return false end // No spectators.
		if EntMeta.GetMoveType(ent) == MOVETYPE_NONE then return false end
	end
	
	if typename == "NPC" then
		if EntMeta.GetMoveType(ent) == MOVETYPE_NONE then return false end // No dead NPCs.

		// No dying NPCs.
		local model = string.lower(EntMeta.GetModel(ent) or "")
		if table.HasValue(Plugin.NPCDeathSequences[model] or {}, EntMeta.GetSequence(ent)) then return false end
	end
	return true
end

Plugin.NPCAlive = function(ent)
	local model = string.lower(EntMeta.GetModel(ent) or "")
	if table.HasValue(Plugin.NPCDeathSequences[model] or {}, EntMeta.GetSequence(ent)) then return false end
	return true
end

eqq.RegisterPlugin(Plugin)