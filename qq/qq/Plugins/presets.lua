local qq = eqq

require("glon")

local Plugin = {
	Name = "Presets",
	Alias = "presets",
	LoadedPresets = {}
}
Plugin.Recurse = false



--I DON'T CARE IF ITS JUST RUN LIKE 1 OR 2 TIMES!

local slen = qq.GlobalCopy.string.len
local fwrite = qq.GlobalCopy.file.Write
local fRead = qq.GlobalCopy.file.Read

local TableToKeyValues = qq.GlobalCopy.TableToKeyValues
local KeyValuesToTable = qq.GlobalCopy.KeyValuesToTable
local pairs = qq.GlobalCopy.pairs

local preset
Plugin.ChangePreset = function(cvar, old, new)
	if Plugin.Recurse then
		Plugin.Recurse = false
		return
	end
	
	preset = Plugin.LoadedPresets[new]
	if new == "" then
		return
	elseif not preset then
		qq.Warn("Failed to set preset {1}", new)
		Plugin.Recurse = true
		qq.SetSetting(Plugin, "preset", "")
		return
	end
	
	for k,info in pairs(preset) do
		if info.PluginAlias == "internal" then continue end
		if info.PluginAlias == "preset" then continue end
		
		qq.SetSetting(qq.Plugins[info.PluginAlias], info.Name, info.Value)
	end
	qq.Inform("Loaded preset {1}", new)
end

local name
local NewPreset
Plugin.CreatePreset = function()
	name = qq.Setting(Plugin, "newpresetname") or ""
	if slen(name) == 0 then return end
	qq.SetSetting(Plugin, "newpresetname", "")
	
	NewPreset = {}
	
	for k,v in pairs(qq.Settings) do // We don't want to save it all, just what we need
		NewPreset[k] = {
			PluginAlias = v.Plugin.Alias,
			Name = v.Name,
			Value = v.Value
		}
	end
	
	Plugin.LoadedPresets[name] = NewPreset
	fwrite("qq_presets.txt", TableToKeyValues(Plugin.LoadedPresets))
end

Plugin.Init = function()
	Plugin.LoadedPresets = KeyValuesToTable(fRead("qq_presets.txt") or "")
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "preset", "Preset", "", {MultiChoice = Plugin.LoadedPresets}, Plugin.ChangePreset)
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "newpresetname", "New Preset Name", "", {Save = false})
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "createpreset", "Create Preset", Plugin.CreatePreset)
end

qq.RegisterPlugin(Plugin)