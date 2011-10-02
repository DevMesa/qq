local qq = eqq 
local lp = qq.GlobalCopy.LocalPlayer()

//qq.GlobalCopy.include("qq/sourcenet/sn3_base_gameevents.lua")

local PlyMeta = qq.Meta.Ply

local Plugin = {
	Name = "Friends",
	Alias = "friends2",
	PlayerStates = {}
}

Plugin.STATE_NONE = 0
Plugin.STATE_FRIEND = 1
Plugin.STATE_ENEMY = 2

Plugin.TextStates = {}
Plugin.TextStates[Plugin.STATE_NONE] = "None"
Plugin.TextStates[Plugin.STATE_FRIEND] = "Friend"
Plugin.TextStates[Plugin.STATE_ENEMY] = "Enemy"

Plugin.SaveState = function()
	local optimizedtbl = {}
	for k,v in pairs(Plugin.PlayerStates) do
		if v == Plugin.STATE_NONE then continue end
		optimizedtbl[k] = v
	end
	file.Write("qq_friends.txt", TableToKeyValues(optimizedtbl))
end

Plugin.LoadState = function()
	Plugin.PlayerStates = KeyValuesToTable(file.Read("qq_friends.txt") or "")
end

Plugin.BuildTab = function(Scroll)
	Scroll:Clear()
	
	local width,height = Scroll:GetWide(),Scroll:GetTall()

	local dlvPlys = vgui.Create("DListView", Scroll)
	dlvPlys:SetParent(DermaPanel)
	dlvPlys:SetPos(5, 5)
	dlvPlys:SetSize(width, height - 21)
	dlvPlys:SetMultiSelect(false)
	dlvPlys:AddColumn("Name")
	
	local relcol = dlvPlys:AddColumn("Relationship")
	relcol:SetMinWidth(100)
	relcol:SetMaxWidth(100)

	for k,v in pairs(player.GetAll()) do
		local ply = v
		local strstate = Plugin.TextStates[Plugin.PlayerStates[PlyMeta.SteamID(ply)] or Plugin.STATE_NONE]
		local line = dlvPlys:AddLine(PlyMeta.Name(ply), strstate)
		
		function line:OnMousePressed()
			local state = ((Plugin.PlayerStates[PlyMeta.SteamID(ply)] or Plugin.STATE_NONE) + 1) % 3
			Plugin.PlayerStates[PlyMeta.SteamID(ply)] = state
			Plugin.SaveState()
			line:SetValue(2, Plugin.TextStates[state])
		end
		
		//for i,col in pairs(line.Columns) do
		//	if not col then continue end
		//	print("SETTING TEXT COLOR")
		//	col:SetTextColor(Color(255,0,0))
		//	col.m_colText = Color(255,0,0)
		//end
	end
	Scroll:AddItem(dlvPlys)
	
end

Plugin.CreatedSetting = false
Plugin.Init = function()
	Plugin.LoadState()
	qq.CreateSetting(qq.MENU_AIMBOT, Plugin, "enable", "Dont Target Friends", true)
		
	qq.RegisterTab("friends2", "Friends", "gui/silkicons/group", Plugin.BuildTab)
end

Plugin.IsValidTarget = function(ent)
	if not qq.Setting(Plugin, "enable") then return end
	
	if not ValidEntity(ent) then return end
	if type(ent) != "Player" then return end
	
	if Plugin.PlayerStates[PlyMeta.SteamID(ent)] == Plugin.STATE_FRIEND then
		return false
	end
end

Plugin.StencilPlayers = function(pl)
	local WallhackPlugin = qq.Plugins["wallhack"]
	
	if not WallhackPlugin then return end
	
	if not CreatedSetting then
		CreatedSetting = true
		qq.CreateSetting(qq.MENU_VISUALS, WallhackPlugin, "showfriends", "Show Friends", true)
		qq.CreateSetting(qq.MENU_VISUALS, WallhackPlugin, "colorfriends", "Color Friends", Color(255,255,255,255))
	end
	
	if not qq.Setting(WallhackPlugin, "showfriends") then return end
	
	if PlyMeta.GetFriendStatus(pl) == "friend" then
		pl.StencilColor = qq.Setting(WallhackPlugin, "colorfriends")
	end
end

Plugin.PrintIP = function()
	for k,v in pairs(player.GetAll()) do
		if not ValidEntity(v) then continue end
		local ip = qq.Module.GetIP(v)
		qq.Inform("{1}\t\t\t{2}", PlyMeta.Name(v), ip)
	end
end

Plugin.PrintIPs = function()
	local tbl = KeyValuesToTable( file.Read("qq_ips.txt") or "" )
	local msg = "Saved IPs:\n"
	for k,v in pairs(tbl) do
		msg = msg .. qq.Format("{1} ({2}) = {3}", v.name, k, v.ip)
	end
	print(msg)
end

Plugin.LogIP = function(netchan, event)
	if event:GetName() != "player_connect" then return end
	
	local name = event:GetString( "name" )
	local steam = event:GetString( "networkid" )
	local ip = event:GetString( "address" )
		
	local tbl = KeyValuesToTable( file.Read("qq_ips.txt") or "" )
	
	local existing = tbl[steam]
	
	qq.Inform("New player IP logged: {1} ({2}) = {3}", name, steam, ip)
	if existing != nil and existing.name != name then
		qq.Warn("Skiddie detection: Player {1} has been seen before with the name {2} and ip {3}", name, existing.name, existing.ip)
	end
	
	tbl[steam] = {
		name = name,
		ip = ip
	}
	file.Write("qq_ips.txt", TableToKeyValues(tbl))
end

Plugin.ConCommands = {
	printip = Plugin.PrintIPs
}

Plugin.Hooks = {
	IsValidTarget = Plugin.IsValidTarget,
	ThinkPlayer = Plugin.StencilPlayers,
	ProcessGameEvent = Plugin.LogIP
}

qq.RegisterPlugin(Plugin)
