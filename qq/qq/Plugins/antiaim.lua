local qq = eqq

local CmdMeta = qq.Meta.Cmd
local PlyMeta = qq.Meta.Ply
local Angle = qq.GlobalCopy.Angle--@Wizard removed RealTime , replaced with Angle

local IN_ATTACK = IN_ATTACK
local IN_ATTACK2 = IN_ATTACK2
local IN_USE = IN_USE

local Plugin = {
	Name = "Anti Aim",
	Alias = "antiaim"
}

Plugin.Init = function()
	local Choices = {
		None = "None",
		Random = "Random",
		Spin = "Spin"
	}
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "mode", "Anti Aim Mode", "None", {MultiChoice = Choices})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "spinspeed", "Spin Speed", 50, {Min = 1, Max = 10, Places = 2})
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "aaifcantshoot", "AntiAim If Can't Shoot", true)
end

Plugin.Last = 0

local Ang
local mode
local buttons
local setting
local TempAng
Plugin.AntiAim = function(cmd)
	mode = qq.Setting(Plugin, "mode")
	if mode == "None" then return end
	
	buttons = CmdMeta.GetButtons(cmd)
	
	if (buttons & IN_ATTACK) == IN_ATTACK
			or (buttons & IN_ATTACK2) == IN_ATTACK2
			or (buttons & IN_USE) == IN_USE
			or qq.ShootThisCreateMove then
		setting = qq.Setting(Plugin, "aaifcantshoot")
		if setting then
			if qq.Plugins["base"] then
				if qq.Plugins["base"].CanFire() then
					return
				end
			end
		else
			return
		end
		
	end
	
	qq.SetAngleTo = nil
	qq.DidAimThisCM = true
	
	 Ang = cmd.GetViewAngles(cmd)
	
	if mode == "Spin" then
		
		Ang.y = ((Plugin.Last or 0) + qq.Setting(Plugin, "spinspeed")) % 360
		Plugin.Last = Ang.y
		Ang.p = 0
		
		CmdMeta.SetViewAngles(cmd, Ang)
	else
		qq.Module.AntiAim(cmd, 1)
		TempAng = qq.GetView() //CmdMeta.GetViewAngles(cmd)
		Ang = Angle(TempAng.p,TempAng.y,TempAng.r)
		Ang.p = -150
		//-89
		Ang.p = (Ang.p - 180) //* -1
		Ang.y = Ang.y + 180
		
		CmdMeta.SetViewAngles(cmd, Ang)
	end
end

Plugin.Hooks = {
	PostCreateMove = Plugin.AntiAim
}

qq.RegisterPlugin(Plugin)