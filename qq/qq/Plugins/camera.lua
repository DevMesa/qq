local Plugin = {
	Name = "Camera",
	Alias = "cam"
}
local qq = eqq

local plyMetaGetShootPos = qq.Meta.Ply.GetShootPos

local function cameraCallback(_, val)
	if val then
		local lp = LocalPlayer()
		if ValidEntity(lp) then
			Plugin.EyePos = plyMetaGetShootPos(lp)
		end
	end
end

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "noclipenabled", "Noclip Enabled", false, {Save = false}, cameraCallback)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "modaim", "Fix aiming", false, nil)
	qq.CreateSetting(qq.MENU_VISUALS, Plugin, "viewline", "Draw line of sight", false, nil)
end

local EyeAngles = EyeAngles

Plugin.CalcView = function(view)
	if not qq.Setting(Plugin, "noclipenabled") then return end
    view.origin = Plugin.EyePos
    --view.angles = EyeAngles() 
	view.Changed = true
    return view
end

local IN_FORWARD = qq.GlobalCopy.IN_FORWARD
local IN_BACK = qq.GlobalCopy.IN_BACK
local IN_MOVELEFT = qq.GlobalCopy.IN_MOVELEFT
local IN_MOVERIGHT = qq.GlobalCopy.IN_MOVERIGHT
local IN_JUMP = qq.GlobalCopy.IN_JUMP
local IN_DUCK = qq.GlobalCopy.IN_DUCK
local IN_SPEED = qq.GlobalCopy.IN_SPEED


local ang
local buttons
local speed
local movevec = Vector()
local vecUp = Vector(0,0,1)
local trace = {filter = LocalPlayer()}
local tr

local cmdMetaGetButtons = qq.Meta.Cmd.GetButtons
local cmdMetaSetButtons = qq.Meta.Cmd.SetButtons
local cmdMetaSetSideMove = qq.Meta.Cmd.SetSideMove
local cmdMetaSetForwardMove = qq.Meta.Cmd.SetForwardMove
local cmdMetaSetViewAngles = qq.Meta.Cmd.SetViewAngles

local angMetaForward = qq.Meta.Ang.Forward
local angMetaRight = qq.Meta.Ang.Right

local vecMetaGetNormalized = qq.Meta.Vec.GetNormalized
local vecMetaZero = qq.Meta.Vec.Zero
local vecMetaAdd = qq.Meta.Vec.Add
local vecMetaMul = qq.Meta.Vec.Mul
local vecMetaSub = qq.Meta.Vec.Sub

local uTraceLine = qq.GlobalCopy.util.TraceLine
local EyePos = qq.GlobalCopy.EyePos
local EyeVector = qq.GlobalCopy.EyeVector

Plugin.CM = function(cmd)
	if not qq.Setting(Plugin, "noclipenabled") then return end
	ang = qq.GetView()
	buttons = cmdMetaGetButtons(cmd)
	
	vecMetaZero(movevec)
	if buttons & IN_FORWARD == IN_FORWARD then
		movevec = movevec + angMetaForward(ang)
	end
	if buttons & IN_BACK == IN_BACK then
		movevec = movevec - angMetaForward(ang)
	end
	
	if buttons & IN_MOVELEFT == IN_MOVELEFT then
		movevec = movevec - angMetaRight(ang)
	end
	
	if buttons & IN_MOVERIGHT == IN_MOVERIGHT then
		movevec = movevec + angMetaRight(ang)
	end
	
	if buttons & IN_JUMP == IN_JUMP then
		movevec = movevec + vecUp
	end
	
	speed = 5
	if buttons & IN_DUCK == IN_DUCK then
		speed = 2
	end
	if buttons & IN_SPEED == IN_SPEED then
		speed = 10
	end
	movevec = vecMetaGetNormalized(movevec)
	vecMetaMul(movevec, speed)
	
	vecMetaAdd(Plugin.EyePos, movevec)
	
	cmdMetaSetButtons(cmd, buttons & (IN_ATTACK & IN_ATTACK2))--we can shot now :D
	cmdMetaSetSideMove(cmd, 0)
	cmdMetaSetForwardMove(cmd, 0)
	if(qq.Setting(Plugin, "modaim")) then
		trace.start = EyePos()
		trace.endpos = EyeVector()
		vecMetaMul(trace.endpos, 65536)
		vecMetaAdd(trace.endpos, trace.start)
		tr = uTraceLine(trace)
		vecMetaSub(tr.HitPos, plyMetaGetShootPos(LocalPlayer()))
		cmdMetaSetViewAngles(cmd, tr.HitPos:Angle())
	end
	if(qq.Setting(Plugin, "viewline")) then
		--draw line here later
	end
end

Plugin.SDLP = function()
	if qq.Setting(Plugin, "noclipenabled") then
		return true
	end
end

Plugin.Hooks = {
	BaseCalcView = Plugin.CalcView,
	CreateMove = Plugin.CM,
	ShouldDrawLocalPlayer = Plugin.SDLP
}

Plugin.On = function()
	qq.SetSetting(Plugin, "noclipenabled", true)
end

Plugin.Off = function()
	qq.SetSetting(Plugin, "noclipenabled", false)
end

Plugin.ConCommands = {
	["+noclipenabled"] = Plugin.On,
	["-noclipenabled"] = Plugin.Off
}

qq.RegisterPlugin(Plugin)