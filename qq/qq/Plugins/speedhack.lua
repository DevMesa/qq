local qq = eqq
// This plugin needs aah!

local Plugin = {
	Name = "Speedhack",
	Alias = "speedhack"
}

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "speed", "Speed", 1, {Min = 0, Max = 10, Places = 1, Slider = true})
end

Plugin.PlusSpeedhack = function()
	qq.Module.DoCommand("aah_setupspeedhack")
	qq.Module.DoCommand("_timescale " .. qq.Setting(Plugin, "speed"))
end

Plugin.MinusSpeedhack = function()
	qq.Module.DoCommand("_timescale " .. 1)
end

Plugin.ConCommands = {--@WIzard, changed table structure, looks better now.
	["+speed"] = Plugin.PlusSpeedhack,
	["-speed"] = Plugin.MinusSpeedhack
}


qq.RegisterPlugin(Plugin)