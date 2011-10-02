local qq = eqq

local CmdMeta = qq.Meta.Cmd
local EntMeta = qq.Meta.Ent
local PlyMeta = qq.Meta.Ply

local Plugin = {
	Name = "Prop Kill",
	Alias = "propkill"
}

Plugin.PEnabled = false

Plugin.Init = function()
	Plugin.PushCount = Plugin.TicksToDo + 1
	qq.CreateSetting(-1, Plugin, "prop", "Prop", "models/props_c17/Lockers001a.mdl")
end

Plugin.EnableCMD = function()
	Plugin.PEnabled = true
	qq.Module.DoCommand("gm_spawn " .. qq.Setting(Plugin, "prop"))
end

Plugin.DisableCMD = function()
	Plugin.PEnabled = false
end

Plugin.TicksToDoBase = 15
Plugin.TicksToDo = Plugin.TicksToDoBase

Plugin.CreateMove = function(cmd)
	Plugin.TicksToDo = Plugin.TicksToDoBase + Plugin.TicksToDoBase * qq.Module.GetLoss(1)
	if not Plugin.PEnabled and (Plugin.PushCount or 0) > Plugin.TicksToDo then return end
	local buttons = CmdMeta.GetButtons(cmd)
	
	if buttons & IN_ATTACK == 0 then
		buttons = buttons | IN_ATTACK
	end
	
	if Plugin.PEnabled then
		Plugin.PushCount = 0
	else
		Plugin.PushCount = (Plugin.PushCount or 0) + 1
		local ent = PlyMeta.GetEyeTrace(LocalPlayer()).Entity
		if ent and ValidEntity(ent) and EntMeta.GetVelocity(ent):Length() > 100 then
			if Plugin.PushCount > Plugin.TicksToDo - 5 then
				buttons = buttons - IN_ATTACK // This helps in lag
			end
		else
			//Plugin.PushCount = 0
		end
		if buttons & IN_WEAPON1 == 0 then
			buttons = buttons | IN_WEAPON1
		end
	end
	
	CmdMeta.SetButtons(cmd, buttons)
end

qq.OriginalSetClipboardText = qq.OriginalSetClipboardText or SetClipboardText
Plugin.ClipboardTest = false
Plugin.Clipboard = ""
SetClipboardText = function(str, ...)
	if Plugin.ClipboardTest then
		Plugin.Clipboard = str
		return
	end
	return qq.OriginalSetClipboardText(str, ...)
end

qq.OriginalDermaMenu = qq.OriginalDermaMenu or DermaMenu

DermaMenu = function(...)
	local ret = qq.OriginalDermaMenu(...)
	local oldAO = ret.AddOption
	ret.AddOption = function(self, name, func, ...)
		if name == "Copy to Clipboard" then
			Plugin.ClipboardTest = true
			func()
			Plugin.ClipboardTest = false
			
			oldAO(self, "qq - Set Propkill Model", function()
				qq.SetSetting(Plugin, "prop", Plugin.Clipboard)
			end)
		end
		return oldAO(self, name, func, ...)
	end
	return ret
end

Plugin.Hooks = {
	PreCreateMove = Plugin.CreateMove
}

Plugin.ConCommands = {
	["+enabled"] = Plugin.EnableCMD,--@Wizard, table structure!
	["-enabled"] = Plugin.DisableCMD
}

qq.RegisterPlugin(Plugin)