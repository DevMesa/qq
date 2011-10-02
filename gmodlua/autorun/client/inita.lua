
// original AutoAim by RabidToaster
// Re edit by C0BRA
if SERVER then return end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// this are required shit, no detouring!

include ( "includes/compat.lua" )
include ( "includes/util.lua" )
include ( "includes/util/sql.lua" )
require ( "concommand" )
require ( "saverestore" )
require ( "gamemode" )
require ( "weapons" )
require ( "hook" )
require ( "timer" )
require ( "schedule" )
require ( "scripted_ents" )
require ( "player_manager" )
require ( "numpad" )
//require ( "team" )
require ( "undo" )
require ( "cleanup" )
require ( "duplicator" )
require ( "constraint" )
require ( "construct" )	
require ( "filex" )
require ( "vehicles" )
require ( "usermessage" )
require ( "list" )
require ( "cvars" )
require ( "http" )
require ( "datastream" )
require ( "markup" )
require ( "effects" )
require ( "spawnmenu" )
require ( "controlpanel" )
require ( "cookie" )
require ( "draw" )
require ( "killicon" )
require ( "presets" )
include( "includes/util/model_database.lua" )
include( "includes/util/vgui_showlayout.lua" )
include( "includes/util/tooltips.lua" )	
include( "includes/util/client.lua" )

// end
require( "qq" )
require( "syshack" )
require( "sourcenet3" )



local SKIN = {}

local saturation = 90
local function QQColor(r, g, b)
	local h, s, v = ColorToHSV(Color(r,g,b))
	print(h)
	h = (h - saturation) % 360
	return HSVToColor(h,s,v)
end

SKIN.PrintName = "my dick v78326"
SKIN.Author = "my dick"
SKIN.DermaVersion = 1

SKIN.bg_QQColor = QQColor(50, 50, 50, 255)
SKIN.bg_QQColor_sleep = QQColor(40, 40, 40, 255)
SKIN.bg_QQColor_dark = QQColor(30, 30, 30, 255)
SKIN.bg_QQColor_bright = QQColor(80, 80, 80, 255)

SKIN.panel_transback = QQColor(85, 90, 85, 60)
SKIN.tooltip = QQColor(80, 220, 85, 255)

SKIN.QQColor_frame_background = QQColor(10, 10, 10, 255)
SKIN.QQColor_frame_border = QQColor(0, 80, 0, 255)

SKIN.control_QQColor = QQColor(40, 40, 40, 255)
SKIN.control_QQColor_dark = QQColor(25, 25, 25, 255)
SKIN.control_QQColor_active = QQColor(55, 75, 55, 255)
SKIN.control_QQColor_highlight = QQColor(50, 65, 50, 255)

SKIN.QQColor_textentry_background = QQColor(40, 40, 40, 255)
SKIN.QQColor_textentry_border = QQColor(70, 90, 70, 255)

SKIN.QQColor_purewhite = QQColor(255, 255, 255, 255)

SKIN.colButtonText = QQColor(240, 255, 240, 255)
SKIN.colButtonTextDisabled = QQColor(240, 255, 240, 55)
SKIN.colButtonBorder = QQColor(20, 25, 20, 255)
SKIN.colButtonBorderHighlight = QQColor(200, 210, 200, 50)
SKIN.colButtonBorderShadow = QQColor(0, 0, 0, 120)

SKIN.colMenuBG = QQColor(140, 150, 140, 200)
SKIN.colMenuBorder = QQColor(0, 0, 0, 200)

SKIN.colPropertySheet = QQColor(40, 40, 40, 255)
SKIN.colTab = SKIN.colPropertySheet
SKIN.colTabInactive = QQColor(25, 25, 25, 155)
SKIN.colTabShadow = QQColor(20, 30, 20, 255)
SKIN.colTabText	= QQColor(240, 255, 240, 255)
SKIN.colTabTextInactive	= QQColor(240, 255, 240, 120)

function SKIN:SchemeTreeNodeButton(panel)
	--DLabel.ApplySchemeSettings(panel)
	panel:SetTextColor(self.color_purewhite)
end

function SKIN:PaintFrame(panel)
	local wid, hei = panel:GetSize()
	surface.SetDrawColor(self.color_frame_background)
	surface.DrawRect(0, 0, wid, hei)
	self:DrawBorder(0, 0, wid, hei, self.color_frame_border)
end

function SKIN:DrawBorder(x, y, w, h, border)
	surface.SetDrawColor(border)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.SetDrawColor(border.r * 0.75, border.g * 0.75, border.b * 0.5, border.a)
	surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
	surface.SetDrawColor(border.r * 0.5, border.g * 0.5, border.b * 0.5, border.a)
	surface.DrawOutlinedRect(x + 2, y + 2, w - 4, h - 4)
end


function SKIN:PaintTextEntry(panel)
	if panel.m_bBackground then
		surface.SetDrawColor(self.color_textentry_background)
		surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
	end

	panel:DrawTextEntryText(panel.m_colText, panel.m_colHighlight, panel.m_colCursor)

	if panel.m_bBorder then
		self:DrawBorder(0, 0, panel:GetWide(), panel:GetTall(), self.color_textentry_border)
	end	
end

function SKIN:DrawGenericBackground( x, y, w, h, color )
	   
		surface.SetDrawColor( SKIN.colMenuBG )
		surface.DrawRect( x, y, w, h )
	   
		surface.SetDrawColor( 50, 50, 50, 200 )
		surface.DrawOutlinedRect( x, y, w, h )
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawOutlinedRect( x+1, y+1, w-2, h-2 )

end

function SKIN:SchemeTextEntry(panel)
	panel:SetTextColor(self.color_purewhite)
	panel:SetHighlightColor(self.color_purewhite)
	panel:SetCursorColor(self.color_purewhite)
end

derma.DefineSkin("QQ", "qq", SKIN)

local VPA = ang
local VPA_WHEN = 0
function _R.Player.ViewPunch(ang)
	VPA = ang
	VPA_WHEN = CurTime()
end
local function GetViewpunchAngle()
	return VPA
end


local VectorSpread = {}
 
local FireBullets = _R.Entity.FireBullets
_R.Entity.FireBullets = function( ent, bullet )
        VectorSpread[ent:GetClass()] = bullet.Spread
        return FireBullets( ent, bullet )
end

local wep, lastwep, cone, numshots

local function WeaponVector( value, typ, vec )
	if ( !vec ) then return tonumber( value ) end
	local s = ( tonumber( -value ) )
	
	if ( typ == true ) then
		s = ( tonumber( -value ) )
	elseif ( typ == false ) then
		s = ( tonumber( value ) )
	else
		s = ( tonumber( value ) )
	end
	return Vector( s, s, s )
end

local Cones	= {}
Cones.Weapons = {}
Cones.Weapons[ "weapon_pistol" ]			= WeaponVector( 0.0100, true, false )	// HL2 Pistol
Cones.Weapons[ "weapon_smg1" ]				= WeaponVector( 0.04362, true, false )	// HL2 SMG1
Cones.Weapons[ "weapon_ar2" ]				= WeaponVector( 0.02618, true, false )	// HL2 AR2
Cones.Weapons[ "weapon_shotgun" ]			= WeaponVector( 0.08716, true, false )	// HL2 SHOTGUN
Cones.Weapons[ "weapon_zs_zombie" ]			= WeaponVector( 0.0, true, false )		// REGULAR ZOMBIE HAND
Cones.Weapons[ "weapon_zs_fastzombie" ]		= WeaponVector( 0.0, true, false )		// FAST ZOMBIE HAND


Cones.NormalCones = { [ "weapon_cs_base" ] = true }
local function GetCone( w )
	if ( !w ) then return end
	local c = VectorSpread[w:GetClass()]
	
	if not c then
		c = w.Cone
	end
	
	if 	not c
		and type(w.Primary) == "table" 
		and type(w.Primary.Cone) == "number" 
			then 
				c = w.Primary && w.Primary.Cone
	end
	if not c then c = 0 end
	
	return c or 0
end

local function PredictSpread( ucmd, angle )
	local ply = LocalPlayer()
	
	local w = ply:GetActiveWeapon(); cone = 0
	if ( w && w:IsValid() && ( type( w.Initialize ) == "function" ) ) then
		cone = GetCone( w )
		
		if ( type( cone ) == "number" ) then
			cone = WeaponVector( cone, true, false )
		elseif ( type( cone ) == "Vector" ) then
			cone = cone * -1
		end
	else
		if ( w:IsValid() ) then
			local class = w:GetClass()
			if ( Cones.Weapons[ class ] ) then
				cone = Cones.Weapons[ class ]
			end
		end
	end
	return hack.CompensateWeaponSpread( ucmd, Vector( -cone, -cone, -cone ) || 0, angle:Forward() || ply:GetAimVector():Angle() ):Angle()
end

local function PredictSpreadP( ucmd, angle )
	local ply = LocalPlayer()
	
	local w = ply:GetActiveWeapon(); cone = 0
	if ( w && w:IsValid() && ( type( w.Initialize ) == "function" ) ) then
		cone = GetCone( w )
		
		if ( type( cone ) == "number" ) then
			cone = WeaponVector( cone, true, false )
		elseif ( type( cone ) == "Vector" ) then
			cone = cone * -1
		end
	else
		if ( w:IsValid() ) then
			local class = w:GetClass()
			if ( Cones.Weapons[ class ] ) then
				cone = Cones.Weapons[ class ]
			end
		end
	end
	return hack.CompensateWeaponSpread( ucmd, Vector( cone, cone, cone ) || 0, angle:Forward() || ply:GetAimVector():Angle() ):Angle()
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local qq = {}

timer.Simple(5, function()
	InitToTable(qq)
	InitToTable = nil
end)


local concommand = concommand
local cvars = cvars
local debug = debug
local ents = ents
local file = file
local hook = hook
local math = math
local spawnmenu = spawnmenu
local string = string
local surface = surface
local table = table
local timer = timer
local util = util
local vgui = vgui

local Angle = Angle
local CreateClientConVar = CreateClientConVar
local CurTime = CurTime
local ErrorNoHalt = ErrorNoHalt
local FrameTime = FrameTime
local GetConVarString = GetConVarString
local GetViewEntity = GetViewEntity
local include = include
local ipairs = ipairs
local LocalPlayer = LocalPlayer
local pairs = pairs
local pcall = pcall
local print = print
local RunConsoleCommand = RunConsoleCommand
local ScrH = ScrH
local ScrW = ScrW
local tonumber = tonumber
local type = type
local unpack = unpack
local ValidEntity = ValidEntity
local Vector = Vector


local MENU_GENERIC = 0
local MENU_AIMBOT = 1
local MENU_TTT = 3
local MENU_DEV = 4
local MENU_VISUALS = 5
local MENU_FRIENDS = 6


local UNLOADED = false

local hook_table = {}
local oldHookCall = hook.Call
function hook.Call(name, gm, ...)
	if UNLOADED then return oldHookCall(name, gm, ...) end
	for k,tbl in pairs(hook_table) do
		if tbl.name == name then
			if ... == nil then
				ret = tbl.func()
			//elseif type(...) == "table" then
			//	return tbl.func(unpack(arg))
			else
				ret = tbl.func(...)
			end
			if ret != nil then // this is so we dont always return a value, EG HUDPaint should not have a return unless overidden
				return ret
			end
		end
	end
	return oldHookCall(name, gm, ...)
end
local function hookAdd(name, id, func)
	hook_table[id] = {name=name, func=func}
	//hook.Add(name,id,func)
end


local cmd_table = {}
local oldCmdRun = concommand.Run
function concommand.Run( pl, name, ... )
	if UNLOADED then return oldCmdRun(pl, name, ...) end
	local tbl = cmd_table[name]
	if tbl != nil then
		return tbl.func(pl,name,...)
	else
		return oldCmdRun(pl, name, ...)
	end
end
local function concommandAdd(name, func, afunc, help)
	AddConsoleCommand(name,help)
	cmd_table[name] = {func=func,afunc=afunc,help=help}
	//concommand.Add(name,func,afunc,help)
end

local function RemoveDetours()
	UNLOADED = true
	hook.Call = oldHookCall
	hook_table = nil
	
	concommand.Run = oldCmdRun
	cmd_table = nil
end


local function RandomName()
	local random = ""
	for i = 1, math.random(4, 10) do
		local c = math.random(65, 116)
		if c >= 91 && c <= 96 then c = c + 6 end
		random = random .. string.char(c)
	end
	return random
end
do
	local hooks = {}
	local created = {}
	local function CallHook(self, name, args)
		if !hooks[name] then return end
		for funcName, _ in pairs(hooks[name]) do
			local func = self[funcName]
			if func then
				local ok, err = pcall(func, self, unpack(args or {}))
				if !ok then
					ErrorNoHalt(err .. "\n")
				elseif err then
					return err
				end
			end
		end
	end
	
	local function AddHook(self, name, funcName)
		// If we haven't got a hook for this yet, make one with a random name and store it.
		// This is so anti-cheats can't detect by hook name, and so we can remove them later.
		if !created[name] then
			local random = RandomName()
			hookAdd(name, random, function(...) return CallHook(self, name, {...}) end)
			created[name] = random
		end
		
		hooks[name] = hooks[name] or {}
		hooks[name][funcName] = true
	end
	
	local cvarhooks = {}
	local function GetCallbackTable(convar)
		local callbacks = cvars.GetConVarCallbacks(convar)
		if !callbacks then
			cvars.AddChangeCallback(convar, function() end)
			callbacks = cvars.GetConVarCallbacks(convar)
		end
		return callbacks
	end
			
	local function AddCVarHook(self, convar, funcName, ...)
		local hookName = "CVar_" .. convar
		if !cvarhooks[convar] then
			local random = RandomName()
			
			local callbacks = GetCallbackTable(convar)
			callbacks[random] = function(...)
				CallHook(self, hookName, {...})
			end
			
			cvarhooks[convar] = random
		end
		AddHook(self, hookName, funcName)
	end
	
	// Don't let other scripts remove our hooks.
	/*
	local oldRemove = hook.Remove
	function hook.Remove(name, unique)
		if created[name] == unique then return end
		oldRemove(name, unique)
	end
	*/
	// Removes all hooks, useful if reloading the script.
	local function RemoveHooks()
		RemoveDetours()
		for convar, unique in pairs(cvarhooks) do
			local callbacks = GetCallbackTable(convar)
			callbacks[unique] = nil
		end
	end
	
	// Add copies the script can access.
	qq.AddHook = AddHook
	qq.AddCVarHook = AddCVarHook
	qq.CallHook = CallHook
	qq.RemoveHooks = RemoveHooks
end

concommandAdd("qq_reload", function()
	qq:CallHook("Shutdown")
	print("Removing hooks...")
	qq:RemoveHooks()
	
	local info = debug.getinfo(1, "S")
	local str = string.Replace(info.short_src, "lua\\", "")
	if info && info.short_src then
		print("Reloading (" .. str .. ")...")
		include(str)
	else
		print("Cannot find AutoAim file, reload manually.")
	end
end)
print("AutoAim loaded.")

// ##################################################
// MetaTables
// ##################################################

local function GetMeta(name)
	return table.Copy(_R[name] or {})
end

local AngM = GetMeta("Angle")
local CmdM = GetMeta("CUserCmd")
local EntM = GetMeta("Entity")
local PlyM = GetMeta("Player")
local VecM = GetMeta("Vector")
local WepM = GetMeta("Weapon")

// ##################################################
// Settings
// ##################################################

do
	local settings = {}
	local function SettingVar(self, name)
		return (self.SettingPrefix or "") .. string.lower(name)
	end
	
	local function RandomName()
		local random = ""
		for i = 1, math.random(4, 10) do
			local c = math.random(65, 116)
			if c >= 91 && c <= 96 then c = c + 6 end
			random = random .. string.char(c)
		end
		return random
	end
	
	local function SetSetting(name, _, new)
		if !settings[name] then return end
		local info = settings[name]
		
		if info.Type == "number" then
			new = tonumber(new)
		elseif info.Type == "boolean" then
			new = (tonumber(new) or 0) > 0
		end
		
		info.Value = new
	end
	
	local function CreateSetting(self, section, name, desc, default, misc)
		local cvar = SettingVar(self, name)
		local info = {
			Section = section,
			Name = name,
			Desc = desc,
			CVar = cvar,
			Type = type(default),
			Value = default
		}
		
		for k, v in pairs(misc or {}) do
			if !info[k] then info[k] = v end
		end
		
		if type(default) == "function" then
			concommandAdd(cvar, default)
			settings[cvar] = info
			settings[#settings + 1] = info
		else
			// Convert default from boolean to number.
			if type(default) == "boolean" then
				default = default and 1 or 0
			end
			
			if !settings[cvar] then
				local tab = cvars.GetConVarCallbacks(cvar)
				if !tab then
					cvars.AddChangeCallback(cvar, function() end)
					tab = cvars.GetConVarCallbacks(cvar)
				end
				
				while true do
					local name = RandomName()
					if !tab[name] then
						tab[name] = SetSetting
						info.Callback = name
						break
					end
				end
			end
			
			settings[cvar] = info
			settings[#settings + 1] = info
			
			// Create the convar.
			CreateClientConVar(cvar, default, (info.Save != false), false)
			SetSetting(cvar, _, GetConVarString(cvar))
		end
	end
	local function GetSetting(self, name)
		local cvar = SettingVar(self, name)
		if !settings[cvar] then return end
		return settings[cvar].Value
	end
	local function Shutdown()
		print("Removing settings callbacks...")
		for _, info in ipairs(settings) do
			if info.CVar && info.Callback then
				local tab = cvars.GetConVarCallbacks(info.CVar)
				if tab then
					tab[info.Callback] = nil
				end
			end
		end
	end
	local function SettingsList()
		return table.Copy(settings)
	end
	local function BuildMenu(self, panel, section)
		for _, info in ipairs(settings) do
			if info.Show != false  and info.Section == section then
				if info.MultiChoice then
					local m = panel:MultiChoice(info.Desc or info.CVar, info.CVar)
					for k, v in pairs(info.MultiChoice) do
						m:AddChoice(k, v)
					end
				elseif info.Type == "number" then
					panel:NumberWang(info.Desc or info.CVar, info.CVar, info.Min or -1, info.Max or -1, info.Places or 0)
				elseif info.Type == "boolean" then
					panel:CheckBox(info.Desc or info.CVar, info.CVar)
				elseif info.Type == "string" then
					panel:TextEntry(info.Desc or info.CVar, info.CVar)
				elseif info.Type == "function" then
					panel:Button(info.Desc or info.CVar, info.CVar)
				end
			end
		end
	end
	
	qq.SettingPrefix = "qq_"
	qq.CreateSetting = CreateSetting
	qq.Setting = GetSetting
	qq.SettingsList = SettingsList
	qq.BuildMenu = BuildMenu
	
	qq.SettingsShutdown = Shutdown
	qq:AddHook("Shutdown", "SettingsShutdown")
end


// ##################################################
// Targetting - Positions
// ##################################################

qq.ModelTarget = {}
function qq:SetModelTarget(model, targ)
	self.ModelTarget[model] = targ
end
qq:CreateSetting(MENU_DEV, "hitbox", "Use Hitbox", false)
function qq:BaseTargetPosition(ent)
	// The eye attachment is a lot more stable than bones for players.
	if type(ent) == "Player" then
		local head = EntM.LookupAttachment(ent, "eyes")
		if head then
			local pos = EntM.GetAttachment(ent, head)
			if pos then
				return pos.Pos - (AngM.Forward(pos.Ang) * 2)
			end
		end	
	end
	
	// Check if the model has a special target assigned to it.
	local special = self.ModelTarget[string.lower(EntM.GetModel(ent) or "")]
	if special then
		// It's a string - look for a bone.
		if type(special) == "string" then
			local bone = EntM.LookupBone(ent, special)
			if bone then
				local pos = EntM.GetBonePosition(ent, bone)
				if pos then
					return pos
				end
			end
		// It's a Vector - return a relative position.
		elseif type(special) == "Vector" then
			return EntM.LocalToWorld(ent, special)
		// It's a function - do something fancy!
		elseif type(special) == "function" then
			local pos = pcall(special, ent)
			if pos then return pos end
		end
	end

	// Try and use the head bone, found on all of the player + human models.
	local bone = "ValveBiped.Bip01_Head1"
	local head = EntM.LookupBone(ent, bone)
	if head then
		local pos = EntM.GetBonePosition(ent, head)
		if pos then
			return pos
		end
	end

	// Give up and return the center of the entity.
	//return EntM.LocalToWorld(ent, EntM.OBBCenter(ent))
	return EntM.LocalToWorld(ent, Vector(0,0,0))
end
function qq:TargetPosition(ent)
	local targetPos = self:BaseTargetPosition(ent)
	
	local ply = LocalPlayer()
	if ValidEntity(ply) then
		targetPos = self:CallHook("TargetPrediction", {ply, ent, targetPos}) or targetPos
	end
	
	return targetPos
end

qq:SetModelTarget("models/crow.mdl", Vector(0, 0, 5))						// Crow.
qq:SetModelTarget("models/pigeon.mdl", Vector(0, 0, 5)) 					// Pigeon.
qq:SetModelTarget("models/seagull.mdl", Vector(0, 0, 6)) 					// Seagull.
qq:SetModelTarget("models/combine_scanner.mdl", "Scanner.Body") 				// Scanner.
qq:SetModelTarget("models/hunter.mdl", "MiniStrider.body_joint") 			// Hunter.
qq:SetModelTarget("models/combine_turrets/floor_turret.mdl", "Barrel") 		// Turret.
qq:SetModelTarget("models/dog.mdl", "Dog_Model.Eye") 						// Dog.
qq:SetModelTarget("models/vortigaunt.mdl", "ValveBiped.Head") 				// Vortigaunt.
qq:SetModelTarget("models/antlion.mdl", "Antlion.Body_Bone") 					// Antlion.
qq:SetModelTarget("models/antlion_guard.mdl", "Antlion_Guard.Body") 			// Antlion guard.
qq:SetModelTarget("models/antlion_worker.mdl", "Antlion.Head_Bone") 			// Antlion worker.
qq:SetModelTarget("models/zombie/fast_torso.mdl", "ValveBiped.HC_BodyCube") 	// Fast zombie torso.
qq:SetModelTarget("models/zombie/fast.mdl", "ValveBiped.HC_BodyCube") 		// Fast zombie.
qq:SetModelTarget("models/headcrabclassic.mdl", "HeadcrabClassic.SpineControl") // Normal headcrab.
qq:SetModelTarget("models/headcrabblack.mdl", "HCBlack.body") 				// Poison headcrab.
qq:SetModelTarget("models/headcrab.mdl", "HCFast.body") 						// Fast headcrab.
qq:SetModelTarget("models/zombie/poison.mdl", "ValveBiped.Headcrab_Cube1")	 // Poison zombie.
qq:SetModelTarget("models/zombie/classic.mdl", "ValveBiped.HC_Body_Bone")	 // Zombie.
qq:SetModelTarget("models/zombie/classic_torso.mdl", "ValveBiped.HC_Body_Bone") // Zombie torso.
qq:SetModelTarget("models/zombie/zombie_soldier.mdl", "ValveBiped.HC_Body_Bone") // Zombine.
qq:SetModelTarget("models/combine_strider.mdl", "Combine_Strider.Body_Bone") // Strider.
qq:SetModelTarget("models/combine_dropship.mdl", "D_ship.Spine1") 			// Combine dropship.
qq:SetModelTarget("models/combine_helicopter.mdl", "Chopper.Body") 			// Combine helicopter.
qq:SetModelTarget("models/gunship.mdl", "Gunship.Body")						// Combine gunship.
qq:SetModelTarget("models/lamarr.mdl", "HeadcrabClassic.SpineControl")		// Lamarr!
qq:SetModelTarget("models/mortarsynth.mdl", "Root Bone")						// Mortar synth.
qq:SetModelTarget("models/synth.mdl", "Bip02 Spine1")						// Synth.
qq:SetModelTarget("models/vortigaunt_slave.mdl", "ValveBiped.Head")			// Vortigaunt slave.


// ##################################################
// Targetting - General
// ##################################################

qq.NPCDeathSequences = {}
function qq:AddNPCDeathSequence(model, sequence)
	self.NPCDeathSequences = self.NPCDeathSequences or {}
	self.NPCDeathSequences[model] = self.NPCDeathSequences[model] or {}
	if !table.HasValue(self.NPCDeathSequences[model]) then
		table.insert(self.NPCDeathSequences[model], sequence)
	end
end

qq:AddNPCDeathSequence("models/barnacle.mdl", 4)
qq:AddNPCDeathSequence("models/barnacle.mdl", 15)
qq:AddNPCDeathSequence("models/antlion_guard.mdl", 44)
qq:AddNPCDeathSequence("models/hunter.mdl", 124)
qq:AddNPCDeathSequence("models/hunter.mdl", 125)
qq:AddNPCDeathSequence("models/hunter.mdl", 126)
qq:AddNPCDeathSequence("models/hunter.mdl", 127)
qq:AddNPCDeathSequence("models/hunter.mdl", 128)

qq:CreateSetting(MENU_GENERIC, "friendlyfire", "Target teammates", false)
qq:CreateSetting(MENU_TTT, "tttfriendlyfire", "Don't target teammates (TTT)", false)
qq:CreateSetting(MENU_TTT, "tttshoott", "Shoot Traitors (TTT)", false)
qq:CreateSetting(MENU_GENERIC, "ofriendlyfire", "Only target teammates", false)
qq:CreateSetting(MENU_GENERIC, "npc", "Target NPC's", false)
qq:CreateSetting(MENU_GENERIC, "frnd", "Dont Target Friends", false)
qq:CreateSetting(MENU_GENERIC, "spinhack", "Spin Hack", false)

local FreindList = {}

function qq:IsValidTarget(ent)
	// We only want players/NPCs.
	local typename = type(ent)
	if typename != "NPC" && typename != "Player" then return false end
	if ( EntM.GetMoveType(ent) == MOVETYPE_NONE ) then return false end
	if ( EntM.GetModel(ent) == "" ) then return false end
	// No invalid entities.
	if !ValidEntity(ent) then return false end
	if EntM.IsEFlagSet(ent, EFL_DORMANT) then return false end // Prevents ghosting
	//Entity:IsEFlagSet(EFL_DORMANT)
	
	// Go shoot yourself, emo kid.
	local ply = LocalPlayer()
	if ent == ply then return false end
	//if not EntM.Visible(pl, ent) then return false end
	
	
	if typename == "NPC" and not qq:Setting("npc") then return false end
	
	if typename == "Player" and qq:Setting("frnd") then
		if PlyM.GetFriendStatus(ent) == "friend" then return false end
	end
	
	if typename == "Player" then
		if !PlyM.Alive(ent) then return false end // Dead players FTL.
		local found = false
		local fltbl = FreindList or {}
		if #fltbl > 0 then
			local steam = PlyM.SteamID(ent)
			for k,v in pairs(fltbl) do
				if v.steam == steam then
					found = true
					break
				end
			end
			if qq:Setting("friends_isexplict") then
				return found
			end						// not them, not on the whitelist
			if found then return false end
		end
		
		
		if !self:Setting("friendlyfire") && PlyM.Team(ent) == PlyM.Team(ply) then return false end
		if self:Setting("ofriendlyfire") && PlyM.Team(ent) != PlyM.Team(ply) then return false end
		if self:Setting("tttfriendlyfire") then
			if ent:GetTraitor() then return false end
		end
		if self:Setting("tttshoott") then
			if ent.Traitor then return true end
			return false
		end
		if EntM.GetMoveType(ent) == MOVETYPE_OBSERVER then return false end // No spectators.
		if EntM.GetMoveType(ent) == MOVETYPE_NONE then return false end
		//if pl["Team(ent) == 1001 then return false end
	end
	
	if typename == "NPC" then
		if EntM.GetMoveType(ent) == MOVETYPE_NONE then return false end // No dead NPCs.

		// No dying NPCs.
		local model = string.lower(EntM.GetModel(ent) or "")
		if table.HasValue(self.NPCDeathSequences[model] or {}, EntM.GetSequence(ent)) then return false end
	end
end



qq:CreateSetting(MENU_GENERIC, "speedhack", "SpeedHack", 1, {Min = 1, Max = 15})
local function pSpeed()
	local speed = qq:Setting("speedhack")
	RunConsoleCommand("_timescale", speed)
end
local function mSpeed()
	RunConsoleCommand("_timescale", 1)
end
concommandAdd("+qq_speed", pSpeed)
concommandAdd("-qq_speed", mSpeed)


local PropKilling = false
local PropKillingAmm = 0
concommandAdd("-qq_propkill", function() PropKilling = false end)
concommandAdd("+qq_propkill", function() PropKilling = true PropKillingAmm = 0 end)

qq:CreateSetting(MENU_AIMBOT, "predictblocked", "Predict blocked (time)", 0.4, {Min = 0, Max = 1, Places = 2})
function qq:BaseBlocked(target, offset)
	local ply = LocalPlayer()
	if !ValidEntity(ply) then return end
	
	// Trace from the players shootpos to the position.
	local shootPos = PlyM.GetShootPos(ply)
	local targetPos = self:TargetPosition(target)
	
	if offset then targetPos = targetPos + offset end

	local trace = util.TraceLine({start = shootPos, endpos = targetPos, filter = {ply, target}, mask = MASK_SHOT})
	local wrongAim = self:AngleBetween(PlyM.GetAimVector(ply), VecM.GetNormal(targetPos - shootPos)) > 2

	// If we hit something, we're "blocked".
	if trace.Hit && trace.Entity != target then
		return true, wrongAim
	end

	// It is not blocked.
	return false, wrongAim
end
function qq:TargetBlocked(target)
	if !target then target = self:GetTarget() end
	if !target then return end
	
	local blocked, wrongAim = self:BaseBlocked(target)
	if self:Setting("predictblocked") > 0 && blocked then
		blocked = self:BaseBlocked(target, EntM.GetVelocity(target) * self:Setting("predictblocked"))
	end
	return blocked, wrongAim
end

function qq:PlaySoundOn()
	if qq:Setting("sound") then
		surface.PlaySound("vo/aperture_ai/ding_on.wav")
	end
end
function qq:PlaySoundOff()
	if qq:Setting("sound") then
		surface.PlaySound("vo/aperture_ai/ding_off.wav")
	end
end	
qq:AddHook("TargetLost", "PlaySoundOff")
qq:AddHook("TargetGained", "PlaySoundOn")
qq:AddHook("TargetChanged", "PlaySoundOn")
qq:CreateSetting(MENU_GENERIC, "disableonkill", "Disable after kill", false, {Save = true})

function qq:SetTarget(ent)
	if qq:Setting("disableonkill") then
		local t = self:GetTarget()
		if t and not PlyM.Alive(t) then
			qq:SetEnabled(false)
		end
	end
	if self.Target && !ent then
		self:CallHook("TargetLost")
	elseif !self.Target && ent then
		self:CallHook("TargetGained")
	elseif self.Target && ent && self.Target != ent then
		self:CallHook("TargetChanged")
	end

	self.Target = ent
end
function qq:GetTarget()
	if ValidEntity(self.Target) != false then
		return self.Target
	else
		return false
	end
end

qq:CreateSetting(MENU_DEV, "sounds", "Play Sounds", false, {Save = true})

qq:CreateSetting(MENU_AIMBOT, "maxangle", "Max angle", 30, {Min = 0, Max = 180})
qq:CreateSetting(MENU_AIMBOT, "targetblocked", "Don't check LOS", false)
qq:CreateSetting(MENU_AIMBOT, "holdtarget", "Hold targets", false)
function qq:FindTarget()
	if !self:Enabled() then return end

	local ply = LocalPlayer()
	if !ValidEntity(ply) then return end

	local maxAng = self:Setting("maxangle")
	local aimVec, shootPos = PlyM.GetAimVector(ply), PlyM.GetShootPos(ply)
	local targetBlocked = self:Setting("targetblocked")

	if self:Setting("holdtarget") then
		local target = self:GetTarget()
		if target then
			local targetPos = self:TargetPosition(target)
			local angle = self:AngleBetween(AngM.Forward(self:GetView()), VecM.GetNormal(targetPos - shootPos))
			local blocked = self:TargetBlocked(target)
			if angle <= maxAng && (!blocked || targetBlocked) then return end
		end
	end

	// Filter out targets.
	local targets = ents.GetAll()
	local c = #targets
	for k = 1, c do
		local ent = targets[k]
		if self:IsValidTarget(ent) == false then
			targets[k] = nil
		end
	end

	local closestTarget, lowestAngle = _, maxAng
	for _, target in pairs(targets) do
		if targetBlocked || !self:TargetBlocked(target) then
			local targetPos = self:TargetPosition(target)
			local angle = self:AngleBetween(AngM.Forward(self:GetView()), VecM.GetNormal(targetPos - shootPos))

			if angle < lowestAngle then
				lowestAngle = angle
				closestTarget = target
			end
		end
	end

	self:SetTarget(closestTarget)
	
end
qq:AddHook("Think", "FindTarget")

local PlyM_EQ_Spoof_Enabled = false
local PlyM_EQ_Old = PlyM.__eq
local function PlyM_EQ_Spoof(a, b)
	if ValidEntity(a) and ValidEntity(b) then
		if PlyM_EQ_Spoof_Enabled then PlyM_EQ_Spoof_Enabled = false return true end
		return EntM.EntIndex(a) == EntM.EntIndex(b)
	end
	return false
end
PlyM.__eq = PlyM_EQ_Spoof

function qq:TestT()
	local ROLE_TRAITOR = ROLE_TRAITOR or -1
	if ROLE_TRAITOR == -1 then return end
	if not qq:Setting("showterror") then return end
	
	local plys = player.GetAll()
	local count = #plys
	local v
	for k = 1, count do
		v = plys[k]
		//local w = v:GetActiveWeapon()
		PlyM_EQ_Spoof_Enabled = true
		for k,w in pairs(PlyM.GetWeapons(v)) do
			if not w.QQSCANNED then
				local tbl = w.CanBuy or {}
				PrintTable(tbl)
				if table.HasValue(w.CanBuy, ROLE_TRAITOR) and
					not table.HasValue(w.CanBuy, ROLE_INNOCENT) and
					not v:IsDetective() then
					v.StencilColor = Color(255,0,0)
					v.Traitor = true
				end
				w.QQSCANNED = true
			end
		end
		//SWEP.CanBuy = {ROLE_TRAITOR}
	end
end
qq:AddHook("Think", "TestT")


qq:CreateSetting(MENU_DEV, "spoofname", "Spoof Name", false)
qq:CreateSetting(MENU_TTT, "spoofname_antidet", "Spoof Name Anti Detection", false)

qq:CreateSetting(MENU_DEV, "discon_msg", "Disconnect Message", "disconnected by you", {Save = true})
local function Disconnect()
	local buf = CNetChan():GetReliableBuffer()
	
	local msg = qq:Setting("discon_msg")
	msg = string.Replace(msg, "\\n", "\n")
	
	buf:WriteUBitLong( net_Disconnect, 6 )
	buf:WriteString( msg )

	CNetChan():Transmit()
end
qq:CreateSetting(MENU_DEV, "discon_doit", "Disconnect with message", Disconnect)

local RealName = nil
local SpoofedName = ""
function qq:SpoofName()
	local pl = LocalPlayer()
	if RealName == nil then RealName = PlyM.Name(pl) end
	
	if qq:Setting("spoofname") then
		local plys = player.GetAll() or nil
		if plys == nil then return end
		SpoofedName = PlyM.Name( plys[math.random(1, #plys)] )
		
		if qq:Setting("spoofname_antidet") then
			local mod = CurTime() % 3 // 3 is the timer speed on the server
			if mod > 2.5 then
				SpoofedName = RealName
			end
		end
		qq.Module.DoCommand("name \"" .. SpoofedName .. " \"\n")
	else
		if SpoofedName != RealName then
			SpoofedName = RealName
			qq.Module.DoCommand("name \"" .. RealName .. " \"\n")
		end
	end
end
qq:AddHook("Think", "SpoofName")

function qq:NewRound()
	for k,v in pairs(player.GetAll()) do
		v.StencilColor = nil
		if qq:Setting("showterror") then
			if v:IsDetective() then
				v.StencilColor = Color(0,0,255)
			end
			if v:GetTraitor() then
				v.StencilColor = Color(255,0,0)
			end
		end
	end
end
qq:AddHook("TTTBeginRound", "NewRound")


// ##################################################
// Fake view
// ##################################################

qq.View = Angle(0, 0, 0)
function qq:GetView()
	return self.View * 1
end
function qq:KeepView()
	if !self:Enabled() then return end

	local ply = LocalPlayer()
	if !ValidEntity(ply) then return end

	self.View = EntM.EyeAngles(ply)
end
qq:AddHook("OnToggled", "KeepView")

local sensitivity = 0.022
function qq:RotateView(cmd)
	self.View.p = math.Clamp(self.View.p + (CmdM.GetMouseY(cmd) * sensitivity), -89, 89)
	self.View.y = math.NormalizeAngle(self.View.y + (CmdM.GetMouseX(cmd) * sensitivity * -1))
end
qq:AddHook("CreateMove", "RotateView")

qq:CreateSetting(MENU_DEV, "debug", "Debug", false, {Show = true})
function qq:FakeView(ply, origin, angles, FOV)
	if !self:Enabled() && !self.SetAngleTo then return end
	if GetViewEntity() != LocalPlayer() then return end
	if self:Setting("debug") then return end
	
	local base = GAMEMODE:CalcView(ply, origin, self.SetAngleTo or self.View, FOV) or {}
			base.angles = base.angles or (self.AngleTo or self.View)
			base.angles.r = 0 // No crappy screen tilting in ZS.
	return base
end
qq:AddHook("CalcView", "FakeView")

qq:CreateSetting(MENU_DEV, "bhop", "Bunny Hop", false, {Show = true})

function qq:BunnyHop(ucmd)
	if not qq:Setting("bhop") then return end
	local lp = LocalPlayer()
	if lp == nil or not ValidEntity(lp) then return end
	local buttons = CmdM.GetButtons(ucmd)
	local walking = EntM.GetMoveType(lp) == MOVETYPE_WALK
	local swimming = EntM.WaterLevel(lp) > 1
	if (buttons & IN_JUMP) == IN_JUMP and not swimming and walking then
		if EntM.OnGround(lp) then
			CmdM.SetButtons(ucmd, buttons | IN_JUMP)
		else
			CmdM.SetButtons(ucmd, buttons - IN_JUMP)
		end
	end
end

local function TargPredictMethod1(ply, target, targetPos)
	local div = 45
	return targetPos + (EntM.GetVelocity(target) / div - EntM.GetVelocity(ply) / div  ) 
end

local TickRate = 1 / 66
local function TargPredictMethod2(ply, target, targetPos)
	
	local ping = CNetChan():GetLatency( FLOW_OUTGOING ) * 1000
	return targetPos + (EntM.GetVelocity(target) * TickRate - EntM.GetVelocity(ply) * TickRate  ) 
end

local function TargPredictMethod3(ply, target, targetPos)
	local pos = EntM.GetPos(target)
	local self_pos = EntM.GetPos(ply)
	
	local lastpos = target.LastPos or pos
	local self_lastpos = ply.LastPos or self_pos
	
	target.LastPos = pos
	ply.LastPos = self_pos
	
	local delta = (pos - lastpos)
	local selfdelta = (self_pos - self_lastpos)
	
	return targetPos + (selfdelta - delta) * RealFrameTime()
end

local TargetPredictMethods = {
	TargPredictMethod1,
	TargPredictMethod2,
	TargPredictMethod3
}

function qq:TargetPrediction(ply, target, targetPos)
	local weap = PlyM.GetActiveWeapon(ply)
	if ValidEntity(weap) then
		local class = EntM.GetClass(weap)
		if class == "weapon_crossbow" then
			local dist = VecM.Length(targetPos - PlyM.GetShootPos(ply))
			local time = (dist / 3500) // About crossbow bolt speed.
			targetPos = targetPos + (EntM.GetVelocity(target) * time)
		end
		
		targetPos = TargetPredictMethods[qq:Setting("predictmethod")](ply, target, targetPos)
	end
	
	return targetPos
end
qq:AddHook("TargetPrediction", "TargetPrediction")

// ##################################################
// Aim
// ##################################################

function qq:SetAngle(ang)
	self.SetAngleTo = ang
end

qq:CreateSetting(MENU_AIMBOT, "smoothspeed", "Smooth aim speed (0 to disable)", 120, {Min = 0, Max = 360})
qq:CreateSetting(MENU_AIMBOT, "snaponfire", "Snap on fire", true)
qq:CreateSetting(MENU_AIMBOT, "snapgrace", "Snap on fire grace", 0.5, {Min = 0, Max = 3, Places = 1})
qq:CreateSetting(MENU_AIMBOT, "pingcorrection", "Ping Correction", true, {Save = true})
qq:CreateSetting(MENU_AIMBOT, "silentaim", "Silent Aim", false, {Save = true})
local WasSilentAimed = false
qq.LastAttack = 0
function qq:SetAimAngles(cmd)

	self:BunnyHop(cmd)
	self:TriggerBot(cmd)
	
	if not self:Enabled() and WasSilentAimed then
		WasSilentAimed = false
		CmdM.SetViewAngles(cmd, self:GetView())
	end
	if !self:Enabled() && !self.SetAngleTo then return end
	
	
	local ply = LocalPlayer()
	if !ValidEntity(ply) then return end

	// We're aiming with the view, normally.
	local targetAim = self:GetView()

	// If we have a target, aim at them!
	local targetPos = nil

	local target = self:GetTarget()
	if target then
		targetPos = self:TargetPosition(target)
	elseif qq:Setting("spinhack") then
		local buts = CmdM.GetButtons(cmd)
		local dontspin = (buts & IN_ATTACK) == IN_ATTACK || (buts & IN_ATTACK2) == IN_ATTACK2 || (buts & IN_USE) == IN_USE
		if not dontspin then
			targetPos =  PlyM.GetShootPos(ply) + Vector(math.cos(RealTime() * 15), math.sin(RealTime() * 15))
		end
	end

	if targetPos != nil then
		targetAim = VecM.Angle(targetPos - PlyM.GetShootPos(ply))
	end

	if PropKilling then
		targetAim.y = targetAim.y - (180 * PropKillingAmm)
		targetAim.p = targetAim.p * (-1 * PropKillingAmm)
		PropKillingAmm = PropKillingAmm + 0.02
		if(PropKillingAmm > 1.0) then
			PropKillingAmm = 1.0
		end
	else
		PropKillingAmm = 0
	end

	// We're following the view, until we fire.
	if self:Setting("snaponfire") then
		local time = CurTime()
		if PlyM.KeyDown(ply, IN_ATTACK) || PlyM.KeyDown(ply, IN_ATTACK2) || self:Setting("autoshoot") != false then
			self.LastAttack = time
		end
		if CurTime() - self.LastAttack > self:Setting("snapgrace") then
			targetAim = self:GetView()
		end
	end
	// We want to change to whatever was SetAngle'd.
	if self.SetAngleTo then
		targetAim = self.SetAngleTo
	end

	// Smooth aiming.
	local aim = nil
	local smooth = self:Setting("smoothspeed")
	if smooth > 0 then
		local current = CmdM.GetViewAngles(cmd)

		// Approach the target angle.
		current = self:ApproachAngle(current, targetAim, smooth * FrameTime())
		current.r = 0

		// If we're just following the view, we don't need to smooth it.
		if false then //if self.RevertingAim then
			local diff = self:NormalizeAngle(current - self:GetView())
			if math.abs(diff.p) < 1 && math.abs(diff.y) < 1 then self.RevertingAim = false end
		elseif targetAim == self:GetView() then
			current = targetAim
		end

		// Check if the angles are the same...
		if self.SetAngleTo then
			local diff = self:NormalizeAngle(current - self.SetAngleTo)
			if math.abs(diff.p) < 1 && math.abs(diff.y) < 1 then self.SetAngleTo = nil end
		end

		aim = current
	else
		aim = targetAim
		self.SetAngleTo = nil
	end
	
	if qq:Setting("nospread") then
		aim = PredictSpread(cmd, aim)
	end
	
	local times = 1
	if qq:Setting("silentaim") then
		WasSilentAimed = true
		times = -1
		aim.p = (aim.p - 180) * -1
		aim.y = aim.y + 180
	end
	
	// Set the angles.
	CmdM.SetViewAngles(cmd, aim)
	local sensitivity = 0.22
	local diff = aim - CmdM.GetViewAngles(cmd)
	CmdM.SetMouseX(cmd, diff.y / sensitivity)
	CmdM.SetMouseY(cmd, diff.p / sensitivity)


	// Change the players movement to be relative to their view instead of their aim.
	local move = Vector(CmdM.GetForwardMove(cmd), CmdM.GetSideMove(cmd), 0)
	local norm = VecM.GetNormal(move)
	local set = AngM.Forward(VecM.Angle(norm) + (aim - self:GetView())) * VecM.Length(move)
	CmdM.SetForwardMove(cmd, set.x)
	CmdM.SetSideMove(cmd, set.y * times)
	if self.ShouldShoot == true then
		CmdM.SetButtons( cmd, CmdM.GetButtons(cmd) | IN_ATTACK )
	end
end
qq:AddHook("CreateMove", "SetAimAngles")

function qq:TriggerBot(cmd)
	local nospread_tb = qq:Setting("nospread_tb")
	local ply = LocalPlayer()
	if nospread_tb and not PropKilling then
		local nospreadvec = PredictSpreadP(cmd,  CmdM.GetViewAngles(cmd))
		local tracedata = {}
		local sp =  PlyM.GetShootPos(ply)
		tracedata.start = sp
		tracedata.endpos = sp + (AngM.Forward(nospreadvec) * 16384)
		tracedata.filter = ply
		tracedata.mask = MASK_SHOT
		local trace = util.TraceLine(tracedata)
		local headshot = true
		if qq:Setting("nospread_tb_hs") then
			headshot = trace.HitGroup == HITGROUP_HEAD
		end
		if trace.Hit and headshot then
			local target = trace.Entity
			if ValidEntity(target) and self:IsValidTarget(target) != false then
				CmdM.SetButtons( cmd, CmdM.GetButtons(cmd) | IN_ATTACK )
				timer.Simple(0.05, qq.Module.DoCommand, "-attack\n")
				//CmdM.SetButtons( cmd, CmdM.GetButtons(cmd) | IN_ATTACK )
			end
		end
	end
end

function qq:RevertAim()
	self.RevertingAim = true
end
qq:AddHook("TargetLost", "RevertAim")
function qq:StopRevertAim()
	self.RevertingAim = false
end
qq:AddHook("TargetGained", "RevertAim")

// When we turn off the bot, we want our aim to go back to our view.
function qq:ViewToAim()
	if self:Enabled() then return end
	self:SetAngle(self:GetView())
end
qq:AddHook("OnToggled", "ViewToAim")


// ##################################################
// HUD
// ##################################################

local function GetTargetScreenCords(ent)
	local min,max = EntM.OBBMins(ent), EntM.OBBMaxs(ent)
    local corners = {
        Vector(min.x,min.y,min.z),
        Vector(min.x,min.y,max.z),
        Vector(min.x,max.y,min.z),
        Vector(min.x,max.y,max.z),
        Vector(max.x,min.y,min.z),
        Vector(max.x,min.y,max.z),
        Vector(max.x,max.y,min.z),
        Vector(max.x,max.y,max.z)
    }

    local minx,miny,maxx,maxy = ScrW() * 2,ScrH() * 2,0,0
    for _,corner in pairs(corners) do
        local screen = VecM.ToScreen( EntM.LocalToWorld(ent, corner) )
        minx,miny = math.min(minx,screen.x),math.min(miny,screen.y)
        maxx,maxy = math.max(maxx,screen.x),math.max(maxy,screen.y)
    end
    return minx,miny,maxx,maxy
end

local function Crosshair(x, y, time, length, gap)
	surface.DrawLine(
		x + (math.sin(math.rad(time)) * length),
		y + (math.cos(math.rad(time)) * length),
		x + (math.sin(math.rad(time)) * gap),
		y + (math.cos(math.rad(time)) * gap)
	)
end

// thanks for some gay swep for my crosshair and hud
qq:CreateSetting(MENU_VISUALS, "target_box", "Target Box", true, {Save = true})   
qq:CreateSetting(MENU_VISUALS, "crosshair", "Crosshair", true, {Save = true})   
local scale = 10 * 0.02
local gap = 30 * scale
local length = gap + 20 * scale
local off_col = Color(0,255,0)
local on_col = Color(255,0,0)

function qq:DrawTarget()
	if qq:Setting("crosshair") then
		if self:Enabled() then
			surface.SetDrawColor(off_col)
		else
			surface.SetDrawColor(off_col)
		end
		local w,h = ScrW()/2, ScrH()/2
		local time = CurTime() * -180     
		Crosshair(w, h, time, length, gap)
		Crosshair(w, h, time + 90, length, gap)
		Crosshair(w, h, time + 180, length, gap)
		Crosshair(w, h, time + 270, length, gap)
	end
	
	if !self:Enabled() then return end

	local target = self:GetTarget()
	if !target then return end

	if not self:Setting("target_box") then return end

	// Change colour on the block status.
	local blocked, aimOff = self:TargetBlocked()
	if blocked then
		surface.SetDrawColor(255, 0, 0, 255) // Red.
	elseif aimOff then
		surface.SetDrawColor(255, 255, 0, 255) // Yellow.
	else
		surface.SetDrawColor(0, 255, 0, 255) // Green.
	end

	// Get the onscreen coordinates for the target.
	local x1, y1, x2, y2 = GetTargetScreenCords(target)
	local edgesize = 6

	-- Top left.
	surface.DrawLine(x1,y1,math.min(x1 + edgesize,x2),y1)
	surface.DrawLine(x1,y1,x1,math.min(y1 + edgesize,y2))

	-- Top right.
	surface.DrawLine(x2,y1,math.max(x2 - edgesize,x1),y1)
	surface.DrawLine(x2,y1,x2,math.min(y1 + edgesize,y2))

	-- Bottom left.
	surface.DrawLine(x1,y2,math.min(x1 + edgesize,x2),y2)
	surface.DrawLine(x1,y2,x1,math.max(y2 - edgesize,y1))

	-- Bottom right.
	surface.DrawLine(x2,y2,math.max(x2 - edgesize,x1),y2)
	surface.DrawLine(x2,y2,x2,math.max(y2 - edgesize,y1))

	-- Bottom right.
	surface.DrawLine(x2,y2,math.max(x2,x1),y2)
	surface.DrawLine(x2,y2,x2,math.max(y2,y1))
end
qq:AddHook("HUDPaint", "DrawTarget")


qq.ScreenMaxAngle = {
	Length = 0,
	FOV = 0,
	MaxAngle = 0
}
qq:CreateSetting(MENU_VISUALS, "draw_maxangle", "Draw Max Angle", true)
function qq:DrawMaxAngle()
	if !self:Enabled() then return end

	// Check that we want to be drawing this...
	local show = qq:Setting("draw_maxangle")
	if !show then return end

	// We need a player for this to work...
	local ply = LocalPlayer()
	if !ValidEntity(ply) then return end

	local info = self.ScreenMaxAngle
	local maxang = qq:Setting("maxangle")
	
	local fov = PlyM.GetFOV(ply)
	if GetViewEntity() == ply && (maxang != info.MaxAngle || fov != info.FOV) then
		local view = self:GetView()
			view.p = view.p + maxang

		local screen = (PlyM.GetShootPos(ply) + (AngM.Forward(view) * 100))
		screen = VecM.ToScreen(screen)

		info.Length = math.abs((ScrH() / 2) - screen.y)

		info.MaxAngle = maxang
		info.FOV = fov
	end

	local length = info.Length

	local cx, cy = ScrW() / 2, ScrH() / 2
	for x = -1, 1 do
		for y = -1, 1 do
			if x != 0 || y != 0 then
				local add = VecM.GetNormal(Vector(x, y, 0)) * length
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect((cx + add.x) - 2, (cy + add.y) - 2, 5, 5)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect((cx + add.x) - 1, (cy + add.y) - 1, 3, 3)
			end
		end
	end

end
qq:AddHook("HUDPaint", "DrawMaxAngle")

// ##################################################
// Auto-shoot
// ##################################################

qq.ShouldShoot = false
function qq:SetShooting(bool)
	qq.ShouldShoot = bool
end

qq.NextShot = 0
function qq:DoShot(weap)
	// Check if it's time to shoot yet.
	if CurTime() < (self.NextShot or 0) then return end
	
	qq:SetShooting(true)
	timer.Simple(0.05, function() qq:SetShooting(false) end)
	self.NextShot = CurTime() + 0.1
end


qq:CreateSetting(MENU_AIMBOT, "autoshoot", "Auto Shoot", true, {Save = true})
local maxDist = 16384
function qq:Shoot()
	if !self:Enabled() then
		self:SetShooting(false)
		return
	end

	// Check we've got something to shoot at...
	local target = self:GetTarget()
	if !target then return end
	
	// Don't shoot until we can hit, you idiot!
	local blocked, wrongAim = self:TargetBlocked(target)
	if blocked || wrongAim then return end

	// We're gonna need the player object in a second.
	local ply = LocalPlayer()
	if !ValidEntity(ply) then return end
	
	// Check we're within our maximum distance.
	local targetPos = self:TargetPosition(target)
	local distance = VecM.Length(targetPos - ply:GetShootPos())
	
	if not qq:Setting("autoshoot") then return end
	
	if distance > maxDist && maxDist != -1 then return end

	// Check we got our weapon.
	local weap = PlyM.GetActiveWeapon(ply)
	if !ValidEntity(weap) then return end

	// Shoot!
	self:DoShot(weap)
end
qq:AddHook("Think", "Shoot")

qq:CreateSetting(MENU_AIMBOT, "predictmethod", "Prediction Method", 1, {Save = true, Min = 1, Max = 3})

// When we lose our target we stop shooting.
function qq:StopShooting()
	self:SetShooting(false)
end
qq:AddHook("TargetLost", "StopShooting")

// ##################################################
// Toggle
// ##################################################

qq.IsEnabled = false
function qq:Enabled() return self.IsEnabled end

function qq:SetEnabled(bool)
	if self.IsEnabled == bool then return end
	self.IsEnabled = bool

	local message = {[true] = "ON", [false] = "OFF"}

	local e = {[true] = "1", [false] = "0"}
	RunConsoleCommand("qq_enabled", e[self.IsEnabled])

	self:CallHook("OnToggled")
end

function qq:Toggle()
	self:SetEnabled(!self:Enabled())
end
concommandAdd("qq_toggle", function() qq:Toggle() end)

qq:CreateSetting(MENU_GENERIC, "nospread", "No Spread",false, {Save = true})
qq:CreateSetting(MENU_GENERIC, "nospread_tb", "No Spread Trigger Bot",false, {Save = true})
qq:CreateSetting(MENU_GENERIC, "nospread_tb_hs", "Triggerbot Headshot Only",false, {Save = true})
qq:CreateSetting(MENU_TTT, "showterror", "Attempt to find traitors", false, {Save = true})

qq:CreateSetting(MENU_VISUALS, "showspecs", "Show players spectating you", false, {Save = true})
function qq:ShowSpecers()
	local y = ScrH() - 30
	local x = ScrW() / 2
	
	local col = Color(255,255,255,255)
	local lp = LocalPlayer()
	
	local plys = player.GetAll()
	local count = #plys
	local v
	
	for k = 1, count do
		v = plys[k]
		local t = PlyM.GetObserverTarget(v)
		if t == lp then
			y = y - 15
			draw.SimpleText(PlyM.Name(v), "CloseCaption_Normal", x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
	
	draw.SimpleText("Spectators", "CloseCaption_Normal", x, y - 15, Color(127,127,127, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
qq:AddHook("HUDPaint", "ShowSpecers")

qq:CreateSetting(MENU_GENERIC, "enabled", "Enabled", false, {Save = false})
function qq:ConVarEnabled(_, old, val)
	if old == val then return end
	val = tonumber(val) or 0
	self:SetEnabled(val > 0)
end
qq:AddCVarHook("qq_enabled", "ConVarEnabled")

concommandAdd("+qq", function() qq:SetEnabled(true) end)
concommandAdd("-qq", function() qq:SetEnabled(false) end)

concommandAdd("+qq_tb", function() RunConsoleCommand("qq_nospread_tb", "1") end)
concommandAdd("-qq_tb", function() RunConsoleCommand("qq_nospread_tb", "0") end)

// ##################################################
// Menu
// ##################################################


qq:CreateSetting(-1, "friends_isexplict", "WhiteList", false)
local function BuildFreinds(qq, panel)
	local PlayerList = vgui.Create("DListView", panel)
	PlayerList:SetPos(5, 5)
	PlayerList:SetSize(190 - 3, 240)
	PlayerList:SetMultiSelect(false)
	PlayerList:AddColumn("Name")
	PlayerList:AddColumn("Admin")
	
	local plys = player.GetAll()
	
	for k,v in pairs(plys) do
		local warn = ""
		if v:IsAdmin() then warn = warn .. "Admin;" end
		PlayerList:AddLine(v:Nick(), warn)
	end
	
	local FreindLst = vgui.Create("DListView", panel)
	FreindLst:SetPos(5 + 190 + 3, 5)
	FreindLst:SetSize(190 - 3, 240)
	FreindLst:SetMultiSelect(false)
	FreindLst:AddColumn("Name")
	FreindLst:AddColumn("SteamID")
	
	for k,v in pairs(FreindList) do
		FreindLst:AddLine(v.name, v.steam)
	end
	
	PlayerList.DoDoubleClick = function(parent, index, lst)
			
			local pl = plys[index]
			local tbl = {
				name = pl:Name(),
				steam = pl:SteamID()
			}
			if not table.HasValue(FreindList, tbl) then
				table.insert(FreindList, tbl)
			end
			FreindLst:AddLine(tbl.name, tbl.steam)
		end
		
	FreindLst.DoDoubleClick = function(parent, index, lst)
			local steam = lst:GetValue(2)
			for k,v in pairs(FreindList) do
				if v.steam == steam then
					table.remove(FreindList, k)
				end
			end
			FreindLst:RemoveLine(index)
		end
	local CheckBoxThing = vgui.Create("DCheckBoxLabel", panel)
	CheckBoxThing:SetPos( 10,240 + 7)
	CheckBoxThing:SetText( "Explictly target friends" )
	CheckBoxThing:SetConVar( "qq_friends_isexplict" )
	CheckBoxThing:SetValue( qq:Setting("friends_isexplict") )
	CheckBoxThing:SizeToContents()
end

local function BuildTab(section, name, icon, qq, panel)
	local scroll = vgui.Create("DPanelList", panel)
	scroll:SetPos(5, 5)
	scroll:SetSize(390, 290)
	scroll:EnableVerticalScrollbar()

	if section == MENU_FRIENDS then
		BuildFreinds(qq, scroll)
	else
		local form = vgui.Create("DForm", menu)
		form:SetName("")
		form.Paint = function() end
		scroll:AddItem(form)
		qq:BuildMenu(form, section)
	end
	panel:AddSheet( name, scroll, icon)
	
	
end

function draw.RoundedOutline( border, x, y, w, h, col )
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	
	surface.DrawRect( x + border, y, w - border * 2, border )
	surface.DrawRect( x + border, y + h - border, w - border * 2, border )
	surface.DrawRect( x, y + border, border, h - border * 2 )
	surface.DrawRect( x + w - border, y + border, border, h - border * 2 )
	
	local a, c
	
	a = tex8
	
	if border > 8 then
		a = tex16
	end
	
	c = border / 2
	
	surface.SetTexture( a )
	
	surface.DrawTexturedRectRotated( x + c, y + c, border, border, 0 )
	surface.DrawTexturedRectRotated( x + w - c, y + c, border, border, 270 )
	surface.DrawTexturedRectRotated( x + w - c, y + h - c, border, border, 180 )
	surface.DrawTexturedRectRotated( x + c, y + h - c, border, border, 90 )
end

function qq:OpenMenu()
	local w, h = ScrW() / 3, ScrH() / 2

	local menu = vgui.Create("DFrame")
	menu:SetTitle("qq")
	menu:SetSize(410, 330)
	menu:Center()
	menu:SetSkin("QQ")
	menu:MakePopup()
	
	menu.Paint = function()
		draw.RoundedBox( 4, 0, 0, menu:GetWide(), menu:GetTall(), Color( 50, 50, 50, 100 ) )
		draw.RoundedOutline( 1, 0, 0, menu:GetWide(), menu:GetTall(), Color( 50, 50, 50, 255 ) )
		return true
	end
	
	local PropertySheet = vgui.Create( "DPropertySheet", menu )
	PropertySheet:SetPos( 5, 25 )
	PropertySheet:SetSize( 400, 300 )
	
	BuildTab(MENU_GENERIC, "Generic", "gui/silkicons/world", self, PropertySheet)
	BuildTab(MENU_AIMBOT, "Aimbot", "gui/silkicons/wrench", self, PropertySheet)
	BuildTab(MENU_VISUALS, "Visuals", "gui/silkicons/palette", self, PropertySheet)
	BuildTab(MENU_FRIENDS, "Friends", "gui/silkicons/user", self, PropertySheet)
	BuildTab(MENU_TTT, "TTT", "gui/silkicons/bomb", self, PropertySheet)
	BuildTab(MENU_DEV, "Dev", "gui/silkicons/shield", self, PropertySheet)
	

	if qq.Menu then qq.Menu:Remove() end
	qq.Menu = menu
end
concommandAdd("qq_menu", function() qq:OpenMenu() end)


// ##################################################
// Useful functions
// ##################################################

function qq:AngleBetween(a, b)
	return math.deg(math.acos(VecM.Dot(a, b)))
end

function qq:NormalizeAngle(ang)
	return Angle(math.NormalizeAngle(ang.p), math.NormalizeAngle(ang.y), math.NormalizeAngle(ang.r))
end

function qq:ApproachAngle(start, target, add)
	local diff = self:NormalizeAngle(target - start)

	local vec = Vector(diff.p, diff.y, diff.r)
	local len = VecM.Length(vec)
	vec = VecM.GetNormal(vec) * math.min(add, len)

	return start + Angle(vec.x, vec.y, vec.z)
end

local notAuto = {"weapon_pistol", "weapon_rpg", "weapon_357", "weapon_crossbow"}
function qq:IsSemiAuto(weap)
	if !ValidEntity(weap) then return end
	return (weap.Primary and not weap.Primary.Automatic) || table.HasValue(notAuto, EntM.GetClass(weap))
end


local function SetLocalToTraitor()
	local pl = LocalPlayer()
	pl:SetRole(ROLE_TRAITOR)
end
qq:CreateSetting(MENU_TTT, "maketraitor", "Make self traitor (antiban)", SetLocalToTraitor)

qq:CreateSetting(MENU_VISUALS, "noskybox", "No skybox", false, {Save = true})
function qq:SkyBox()
	if qq:Setting("noskybox") then return true end
end
qq:AddHook("PreDrawSkybox", "SkyBox")

qq:CreateSetting(MENU_VISUALS, "barrelhack", "Barrel Hack", false, {Save = true})

//WepM.SetNextPrimaryFire
function _R.Weapon.SetNextPrimaryFire(self, float)
	self.QQNextFire = float
	return WepM.SetNextPrimaryFire(self, float)
end

local bluelaser = Material("sprites/bluelaser1")
local laserdot = Material("Sprites/light_glow02_add_noz")
function qq:BarrelHack()
	if !qq:Setting("barrelhack") then return end
	local lp = LocalPlayer()
	local ep = EyePos()
	local ea = EyeAngles()
	
	local trace2 = {}
	trace2.start = ep
	trace2.endpos = nil
	trace2.filter = lp
	
	cam.Start3D(ep, ea)
		cam.IgnoreZ(false)
		for k, pl in pairs( player.GetAll() ) do
			if pl != lp and PlyM.Alive(pl) then
				local trace = PlyM.GetEyeTrace(pl)
				local col = team.GetColor(PlyM.Team(pl))
				trace2.endpos = trace.HitPos
				local trace2res = util.TraceLine(trace2)
				if trace2res.HitPos == trace.HitPos then // for some reasond depth testing doesnt work on this function :(
					render.SetMaterial(laserdot)
					render.DrawQuadEasy(trace.HitPos, VecM.GetNormal(ep - trace.HitPos), 20, 20, col, 0)
				end
				render.SetMaterial(bluelaser)
				render.DrawBeam(trace.StartPos, trace.HitPos, 3, 0, 0, col)
			end
		end
	cam.End3D()
end
qq:AddHook("RenderScreenspaceEffects", "BarrelHack")

local bones = {
        {"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Spine4"},
        {"ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_Spine2"},
        {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine"},
        {"ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_L_UpperArm"},
        {"ValveBiped.Bip01_Spine4", "ValveBiped.Bip01_R_UpperArm"},
        {"ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_R_Forearm"},
        {"ValveBiped.Bip01_L_UpperArm", "ValveBiped.Bip01_L_Forearm"},
        {"ValveBiped.Bip01_R_Forearm", "ValveBiped.Bip01_R_Hand"},
        {"ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand"},
        {"ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis"},
        {"ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_R_Thigh"},
        {"ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_L_Thigh"},
        {"ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf"},
        {"ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf"},
        {"ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Foot"},
        {"ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Foot"},
        {"ValveBiped.Bip01_R_Foot", "ValveBiped.Bip01_R_Toe0"},
        {"ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_L_Toe0"},
        }

qq:CreateSetting(MENU_VISUALS, "skel", "Draw Skelington", false, {Save = true})
function qq:Skel()
	if !qq:Setting("skel") then return end
	local plys = player.GetAll()
	for i = 1, #plys do
		local ent = plys[i]
		for _,bone in ipairs(bones) do
			local pos1 = VecM.ToScreen(EntM.GetBonePosition(ent, EntM.LookupBone(ent, bone[1])))
			local pos2 = VecM.ToScreen(EntM.GetBonePosition(ent, EntM.LookupBone(ent, bone[2])))
			surface.SetDrawColor(team.GetColor(PlyM.Team(ent)))
			surface.DrawLine( pos1.x, pos1.y, pos2.x, pos2.y )
		end
	end
end
qq:AddHook("HUDPaint", "Skel")

qq:CreateSetting(MENU_TTT, "c4nadeesp", "C4 + NADE ESP", false, {Save = true})
function qq:C4ESP()
	if not qq:Setting("c4nadeesp") then return end
	local col1 = Color(255,0,0,255)
	local col2 = Color(255,50,50,200)

	local size = nil
	// 10 - 5 = 5
	local e = ents.GetAll()
	local c = #e
	for k = 1, c do
		local v = e[k]
		if v and ValidEntity(v) then
			if EntM.GetClass(v) == "ttt_c4" and v:GetArmed() then
				local time = string.FormattedTime(math.max(0, v:GetExplodeTime() - CurTime()), "%02i:%02i")
				local vec = VecM.ToScreen( EntM.GetPos(v) )
				draw.SimpleText(time, "Default", vec.x, vec.y, col1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			if (v.Base or "") == "ttt_basegrenade_proj" then
				size = (v:GetExplodeTime() - CurTime()) * 15
				
				if size > 0 then
					local pos = VecM.ToScreen( EntM.GetPos(v) )
					surface.SetDrawColor(col2)
					surface.DrawRect(pos.x - (size/2), pos.y - 10, size, 5)
				end
			end
		end
	end
end
qq:AddHook("HUDPaint", "C4ESP")


qq:CreateSetting(MENU_VISUALS, "laser", "Laser On Gun", false, {Save = true})
function qq:Laser()
	if not qq:Setting("laser") then return end
	
	local lp = LocalPlayer()
	if not PlyM.Alive(lp) then return end
	
	
	local eyepos = EyePos()
	local eyeang = EyeAngles()
	
	local weap = PlyM.GetActiveWeapon(lp)
	if not weap or not ValidEntity(weap) then return end
	local nextfire = weap.QQNextFire or 0
	if nextfire > CurTime() then return end
	
	local vm = PlyM.GetViewModel(lp)
	if vm == nil or not EntM.IsValid(vm) then return end		
	
	local bone = EntM.LookupAttachment(vm, "muzzle")
	if bone == nil || bone == 0 then bone = EntM.LookupAttachment(vm, "1") end
	if bone == nil || bone == 0 then bone = EntM.LookupAttachment(vm, "laser") end
	if bone == nil || bone == 0 then bone = EntM.LookupAttachment(vm, "spark") end
	if bone == nil || bone == 0 then bone = EntM.LookupAttachment(vm, "0") end
	if bone == nil || bone == 0 then return end

	local col = team.GetColor(PlyM.Team(lp))
	local boneangpos = EntM.GetAttachment(vm, bone)
	
	if not boneangpos then return end
	
	local bonepos = boneangpos.Pos
	local hitpos = PlyM.GetEyeTrace(lp).HitPos
	cam.Start3D(eyepos, eyeang)
		render.SetMaterial(laserdot)
		render.DrawQuadEasy(hitpos, VecM.GetNormal(eyepos - hitpos), 20, 20, col, 0)
		render.SetMaterial(bluelaser)
		render.DrawBeam(bonepos, hitpos, 3, 0, 0, col)
	cam.End3D()
	
end
qq:AddHook("RenderScreenspaceEffects", "Laser")

local oldPlayerTraceAttack = nil
local function newPlayerTraceAttack(gm, pl, dmginfo, dir, trace)
	print( pl:Name() .. " attacked" )
	return oldPlayerTraceAttack( gm, pl, dmginfo, dir, trace )
end

function qq:HookTraceAttack()
	oldPlayerTraceAttack = GAMEMODE.PlayerTraceAttack
	GAMEMODE.PlayerTraceAttack = newPlayerTraceAttack
end
qq:AddHook("PostGamemodeLoaded", "HookTraceAttack")

local MaterialBlurX = Material( "pp/blurx" );
local MaterialBlurY = Material( "pp/blury" );
local MaterialWhite = CreateMaterial( "WhiteMaterial", "VertexLitGeneric", {
	 ["$basetexture"] = "color/white",
	 ["$vertexalpha"] = "1",
	 ["$model"] = "1",
} );
local MaterialComposite = CreateMaterial( "CompositeMaterial", "UnlitGeneric", {
	 ["$basetexture"] = "_rt_FullFrameFB",
	 ["$additive"] = "1",
} );
 
qq:CreateSetting(MENU_VISUALS, "wallhack", "Enable Wallhack", true, {Save = true})
qq:CreateSetting(MENU_VISUALS, "wallhack_names", "Enable Wallhack Names", false, {Save = true})
 
local RT1 = GetRenderTarget( "L4D1" );
local RT2 = GetRenderTarget( "L4D2" );


local function RenderToStencil( entity )
 
	// tell the stencil buffer we're going to write a value of one wherever the model
	 // is rendered
	 render.SetStencilEnable( true );
	 render.SetStencilFailOperation( STENCILOPERATION_KEEP );
	 render.SetStencilZFailOperation( STENCILOPERATION_KEEP );
	 render.SetStencilPassOperation( STENCILOPERATION_REPLACE );
	 render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS );
	 render.SetStencilWriteMask( 1 );
	 render.SetStencilReferenceValue( 1 );
	  
	 // this uses a small hack to render ignoring depth while not drawing color
	 // i couldn't find a function in the engine to disable writing to the color channels
	// i did find one for shaders though, but I don't feel like writing a shader for this.
	 cam.IgnoreZ( true );
		  render.SetBlend( 0 );
			local weap = nil
				if entity:IsPlayer() then
					if PlyM.GetActiveWeapon(entity) != nil then
						weap = PlyM.GetActiveWeapon(entity)
					end
				end
				SetMaterialOverride( MaterialWhite );
					EntM.DrawModel(entity);
					if qq:Setting("wallhack_names") then
						local vec = VecM.ToScreen( PlyM.GetShootPos(entity) + Vector(0,0,10) )
						surface.SetTextColor( team.GetColor(PlyM.Team(entity)) )
						surface.SetTextPos( vec.x, vec.y - 10 )
						surface.DrawText(PlyM.Name(entity))
					end
					if weap != nil and ValidEntity(weap) then
						EntM.DrawModel(weap);
					end
				SetMaterialOverride();
				 
		  render.SetBlend( 1 );
		  render.SetBlend( 1 );
	 cam.IgnoreZ( false );
	  
	 // don't need this for the next pass
	render.SetStencilEnable( false );
 
end
 
local function RenderToGlowTexture( entity )
	if not qq:Setting("wallhack")  then return end
	local w, h = ScrW(), ScrH();

	// draw into the white texture
	local oldRT = render.GetRenderTarget();
	render.SetRenderTarget( RT1 );
		render.SetViewPort( 0, 0, 512, 512 );
		
		cam.IgnoreZ( false );
			local weap = nil
			render.SuppressEngineLighting( true );
			if entity:IsPlayer() then
				local col = team.GetColor(PlyM.Team(entity))
				if entity.StencilColor != nil then
					col = entity.StencilColor
				end
				render.SetColorModulation( col.r/255, col.g/255, col.b/255);
				
				if PlyM.GetActiveWeapon(entity) != nil then
					weap = PlyM.GetActiveWeapon(entity)
				end
			else
				local col = Color(255,255,255)
				if entity.StencilColor != nil then
					col = entity.StencilColor
				end
				render.SetColorModulation( col.r/255, col.g/255, col.b/255);
			end
			
			SetMaterialOverride( MaterialWhite );
				EntM.DrawModel(entity);
				if qq:Setting("wallhack_names") then
					local vec = VecM.ToScreen( PlyM.GetShootPos(entity) + Vector(0,0,10) )
					surface.SetTextColor( team.GetColor(PlyM.Team(entity)) )
					surface.SetTextPos( vec.x, vec.y - 10 )
					surface.DrawText(PlyM.Name(entity))
				end
				if weap != nil and ValidEntity(weap) then
					EntM.DrawModel(weap);
				end
			SetMaterialOverride();
				
			render.SetColorModulation( 1, 1, 1 );
			render.SuppressEngineLighting( false );
			
		cam.IgnoreZ( false );
		
		render.SetViewPort( 0, 0, w, h );
	render.SetRenderTarget( oldRT );
end

local function DrawC4()
	if not qq:Setting("c4esp") then return end
	for k,v in pairs(ents.FindByClass("ttt_c4")) do
		v.StencilColor = Color(255,0,0)
		RenderToStencil( v )
		RenderToGlowTexture( v )
	end
end

local function DrawEnts()
	DrawC4()
	return
	/*
	for k,v in pairs(ents.GetAll()) do
		if v:IsNPC() then
			RenderToStencil( v )
			RenderToGlowTexture( v )
		end
	end
	*/
end
hookAdd( "PostDrawTranslucentRenderables", "DrawOtherEnts", DrawEnts );

local function RenderScene( Origin, Angles )
	if not qq:Setting("wallhack")  then return end
	local oldRT = render.GetRenderTarget();
	render.SetRenderTarget( RT1 );
	render.Clear( 0, 0, 0, 255, true );
	render.SetRenderTarget( oldRT );
end
hookAdd( "RenderScene", "ResetGlow", RenderScene );

 
local function RenderScreenspaceEffects( )
	if not qq:Setting("wallhack")  then return end
	MaterialBlurX:SetMaterialTexture( "$basetexture", RT1 );
	MaterialBlurY:SetMaterialTexture( "$basetexture", RT2 );
	MaterialBlurX:SetMaterialFloat( "$size", 2 );
	MaterialBlurY:SetMaterialFloat( "$size", 2 );
	
	local oldRT = render.GetRenderTarget();
	
	// blur horizontally
	render.SetRenderTarget( RT2 );
	render.SetMaterial( MaterialBlurX );
	render.DrawScreenQuad();
 
	// blur vertically
	render.SetRenderTarget( RT1 );
	render.SetMaterial( MaterialBlurY );
	render.DrawScreenQuad();
 
	render.SetRenderTarget( oldRT );
	
	// tell the stencil buffer we're only going to draw
	 // where the player models are not.
	render.SetStencilEnable( true );
	render.SetStencilReferenceValue( 0 );
	render.SetStencilTestMask( 1 );
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL );
	render.SetStencilPassOperation( STENCILOPERATION_ZERO );
	  
	// composite the scene
	MaterialComposite:SetMaterialTexture( "$basetexture", RT1 );
	render.SetMaterial( MaterialComposite );
	render.DrawScreenQuad();
 
	 // don't need this anymore
	render.SetStencilEnable( false );
 
end
hookAdd( "RenderScreenspaceEffects", "CompositeGlow", RenderScreenspaceEffects );

local function MakeNameInvis1()
	local name = "~ ~~" // string.char(2)
	qq.Module.DoCommand("name " .. name .. "\n")
end
qq:CreateSetting(MENU_DEV, "invisname1", "Make name invisible", MakeNameInvis1)

local function MakeNameInvis2()
	local name = string.char(2)
	qq.Module.DoCommand("name " .. name .. "\n")
end
qq:CreateSetting(MENU_DEV, "invisname2", "Make name invisible (Method 2)", MakeNameInvis2)

local function PostPlayerDraw( pl )
	if not qq:Setting("wallhack")  then return end
	// prevent recursion
	if( OUTLINING_PLAYER ) then return end
	OUTLINING_PLAYER = true
	
	RenderToStencil( pl )
	RenderToGlowTexture( pl )
	
	// prevents recursion time
	OUTLINING_PLAYER = false
	
	if( ScrW() == ScrH() ) then return end
end //PostDrawOpaqueRenderables
hookAdd( "PostPlayerDraw", "RenderGlow", PostPlayerDraw );

local function DoLua(pl, cmd, args)
	RunString(args[1])
end
concommandAdd("runlua", DoLua)