local Plugin = {
	Name = "Development",
	Alias = "dev"
}
local qq = eqq

Plugin.Init = function()
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "test", "Test Dev Func", function()
		
		local test = {}
		local y = tostring(test)
		
		local x = string.Trim( string.Explode(':', y)[2] ) 
		print(x)
		
		local a = qq.Module.GetObjectFromPtr(x)
		print(a)
	end)
end

Plugin.Think = function()
	//local ply = player.GetAll()[2]
	//print( qq.Module.GetFloatFromOffset(ply, Plugin.Y) )
end

Plugin.Hooks = {
	//Think = Plugin.Think
}

qq.RegisterPlugin(Plugin)