require("glon")

if not AAH_REQ then // we only want the module to load once, bad detours and cba to fix
	local AAH_REQ = true
	require("aah")
end

local logcvar = CreateConVar("aah_log", "0", FCVAR_ARCHIVE, false)   
local logpathcvar = CreateConVar("aah_logpath", "C:\\Dumps", FCVAR_ARCHIVE, false)   
CreateConVar("aah_blockac", "1", FCVAR_ARCHIVE, false)   
CreateConVar("aah_bypassse", "1", FCVAR_ARCHIVE, false)

FoolAC = {}
FoolACList = {}

local filestr = file.Read("aah_keywords.txt") or ""
pcall( function() FoolAC = glon.decode(filestr) end )

FoolAC = FoolAC or {}

Msg("[AAH] Loaded " .. tostring( table.Count(FoolAC) ) .. " Keywords\n")
local RealTime = 0
local GameJoined = false
function FoolAntiCheats()
	RealTime = RealTime + 1
	for k, tbl in pairs(FoolACList) do
		for _, v in pairs(tbl.Commands) do
			local LastRun = v.LastRun or RealTime
			local Delay = v.Delay or 0
			if v.Delay == 0 and not v.Ran then
				v.Ran = true
				
				local command = v.Command or ""
				local sargs = v.Args or ""
				local args = string.Explode(" ", sargs)
				
				RunConsoleCommand(command, unpack(args))
				Msg("[AAH] Ran command " .. command .. "!\n")
			elseif RealTime - LastRun > v.Delay then
				local command = v.Command or ""
				local sargs = v.Args or ""
				local args = string.Explode(" ", sargs)
				
				RunConsoleCommand(command, unpack(args))
				Msg("[AAH] Ran command " .. command .. "!\n")
			end
		end
	end
end
timer.Create("aah_fool_ac", 1, 0, FoolAntiCheats)

function SaveKeywords()
	local str = glon.encode(FoolAC)
	file.Write("aah_keywords.txt", str)
end

function FoolACMenu(index)
	local tbl = FoolAC[index]
	local foolframe = vgui.Create("DFrame")
	foolframe:SetTitle("AAH - FoolAC - " .. tbl.Keyword)
	foolframe:SetDraggable(true)
	foolframe:SetSize(250, 200)
	foolframe:Center()
	foolframe:MakePopup()
	
	local commandentry = vgui.Create("DTextEntry", foolframe)
	commandentry:SetText("")
	commandentry:SetPos(5, 21 + 5)
	commandentry:SetWide(100)
	
	local argentry = vgui.Create("DTextEntry", foolframe)
	argentry:SetText("")
	argentry:SetPos(5 + 101, 21 + 5)
	argentry:SetWide(50)
	
	local delay = vgui.Create("DNumberWang", foolframe)
	delay:SetPos(150 + 15, 21 + 5)
	delay:SetMin(0)
	delay:SetMax(30)
	delay:SetDecimals(0)
	delay:SetWide(40)
	
	local addb = vgui.Create("DButton", foolframe)
	addb:SetText("Add")
	addb:SetPos(155 + 55, 21 + 5)
	addb:SetWide(35)
	addb:SetHeight(20)
	
	local lv = vgui.Create("DListView", foolframe)
	lv:SetPos(5, 21 + 20 + 10)
	lv:SetSize(240, 200 - (21 + 20 + 10) - 5)
	lv:AddColumn("Command")
	lv:AddColumn("Args")
	lv:AddColumn("Delay")
	
	tbl.Commands = tbl.Commands or {}
	for k,v in pairs(tbl.Commands) do
		lv:AddLine(v.Command, v.Args, v.Delay)
	end
	
	function addb:DoClick()
		local command = {}
		command.Command = commandentry:GetValue()
		command.Args = argentry:GetValue()
		command.Delay = delay:GetValue()
		FoolAC[index].Commands = FoolAC[index].Commands or {}
		table.insert(FoolAC[index].Commands, command)
		lv:AddLine(command.Command, command.Args, command.Delay)
		SaveKeywords()
	end
	
	function lv:DoDoubleClick(ind, line)
		lv:RemoveLine(ind)
		local value = line:GetValue(1)
		local args = line:GetValue(2)
		local delay = line:GetValue(3)
		FoolAC[index].Commands = FoolAC[index].Commands or {}
		for k,v in pairs(FoolAC[index].Commands) do
			if v.Command == value and delay == v.Delay and args == v.Args then
				FoolAC[index].Commands[k] = nil
				SaveKeywords()
				break
			end
		end
	end
	//DNumberWang
end

function Reload()
	local info = debug.getinfo(1, "S")
	local str = string.Replace(info.short_src, "lua\\", "")
	include(str)
end

local fontmenu = "aahfont"

surface.CreateFont( "Tahoma", 23, 600, true, false, fontmenu, true, false )

concommand.Add("aah_renamevar", function(p,cmd,args)
	local cvar = args[1]
	local cvar_new = args[2]
	local defaultval = args[3]
	aah.RenameCVAR(cvar, cvar_new, -1, defaultval)
end)

concommand.Add("aah_renamecmd", function(p,cmd,args)
	local cmd = args[1]
	local cmd_new = args[2]
	aah.RenameCONCMD(cmd, cmd_new)
end)

concommand.Add("aah_updatelogsettings", function()
	aah.ShouldLogFiles(logcvar:GetBool())
	aah.SetLogPath(logpathcvar:GetString())
	Msg("[AAH] Log settings updated\n")
end)

SpeedDone = false // not local!

concommand.Add("aah_setupspeedhack", function()
	//if true then return end // Debug
	if SpeedDone then return end

	aah.RenameCVAR("sv_cheats", "_cheats", -1, "0")
	aah.RenameCVAR("host_framerate", "_framerate", -1, "0")
	aah.RenameCVAR("host_timescale", "_timescale", -1, "1")
	aah.RenameCVAR("net_showevents", "_showevents", -1, "0")
	
	RunConsoleCommand("_showevents", 2)
	RunConsoleCommand("_cheats", 1)
	SpeedDone = true

end)

local function ScriptAllowed(strFileName, strFileContents, md5)
	if string.find(strFileContents, "datastream.StreamToServer") then return false end
	if string.find(strFileContents, "JChat by JohnnyThunders") then return false end // Fuck off chatbox
	if string.find(strFileContents, "HeX's") then return false end

	if GetConVarNumber("aah_blockac") == 1 then
		local ret = nil
		for k,v in pairs(FoolAC) do
			if string.find(strFileName, v.Keyword) then
				if v.Commands != nil then
					table.insert(FoolACList, v)
				end
				
				Msg("[AAH] Blocking " .. strFileName .. "(AntiHack)(" .. md5 .. ")\n")
				ret = false
			end
		end
		return ret
	end
end
hook.Add("ScriptAllowed", "seal", ScriptAllowed)

local function ScriptEnforcerIsActive()
	if GetConVarNumber("aah_bypassse") == 1 then
		return false
	end	
end
hook.Add("SEIsActive", "seia", ScriptEnforcerIsActive)


////////////menu////////////////

local renamedcvars = {}
local renamednewcvars = {}
local renamedvalcvars = {}

local aahframe = vgui.Create("DFrame")
aahframe:SetTitle("AAH")
aahframe:SetDeleteOnClose(false)
aahframe:SetDraggable(true)
aahframe:SetSize(494, 540)
aahframe:SetPos(200, 130)
aahframe:SetVisible(false)
aahframe:Center()
aahframe:MakePopup()

/*
aahframe.Paint = function() 
draw.RoundedBox(2, 2, 2, aahframe:GetWide(), aahframe:GetTall(), Color(70, 70, 70, 255))
end
*/
aahlabel1 = vgui.Create("DLabel")
aahlabel1:SetParent(aahframe)
aahlabel1:SetPos(5 + 6, 2 + 21)
aahlabel1:SetText("Path To Log:")
aahlabel1:SizeToContents()

local aahpath = vgui.Create("DTextEntry")
aahpath:SetParent(aahframe)
aahpath:SetSize(405, 20)
aahpath:SetPos(5 + 5, 20 + 21)
aahpath:SetConVar("aah_logpath")
aahpath:SetText("C:\\Path")

local aahsetlogbutton = vgui.Create("DButton")
aahsetlogbutton:SetParent(aahframe)
aahsetlogbutton:SetSize(60, 20)
aahsetlogbutton:SetPos(5 + 415, 20 + 21)
aahsetlogbutton:SetText("Update")
function aahsetlogbutton:DoClick()
	RunConsoleCommand("aah_updatelogsettings")
end

aahpathcat = vgui.Create("DCheckBoxLabel")
aahpathcat:SetParent(aahframe)
aahpathcat:SetPos(5 + 5, 45 + 21)
aahpathcat:SetText("Log Server Files")
aahpathcat:SetConVar("aah_log")
aahpathcat:SetValue(false)
aahpathcat:SizeToContents()

aahlabel2 = vgui.Create("DLabel")
aahlabel2:SetParent(aahframe)
aahlabel2:SetPos(5 + 6, 75 + 21)
aahlabel2:SetText("CVar Name:")
aahlabel2:SizeToContents()

local aahcvar = vgui.Create("DTextEntry")
aahcvar:SetParent(aahframe)
aahcvar:SetSize(200, 20)
aahcvar:SetPos(5 + 5, 95 + 21)
aahcvar:SetText("Feed Me CVars")

aahlabel3 = vgui.Create("DLabel")
aahlabel3:SetParent(aahframe)
aahlabel3:SetPos(5 + 210, 75 + 21)
aahlabel3:SetText("CVar New Name:")
aahlabel3:SizeToContents()

local aahnewcvar = vgui.Create("DTextEntry")
aahnewcvar:SetParent(aahframe)
aahnewcvar:SetSize(200, 20)
aahnewcvar:SetPos(5 + 210, 95 + 21)
aahnewcvar:SetText("Feed Me Creative Names")

aahlabel4 = vgui.Create("DLabel")
aahlabel4:SetParent(aahframe)
aahlabel4:SetPos(5 + 415, 75 + 21)
aahlabel4:SetText("Default Value:")
aahlabel4:SizeToContents()

aahcvarval = vgui.Create("DNumberWang")
aahcvarval:SetParent(aahframe)
aahcvarval:SetPos(5 + 415, 95 + 21)
aahcvarval:SetDecimals(0)
aahcvarval:SetMinMax(0, 100)

local aahcvarlist = vgui.Create("DListView")
aahcvarlist:SetParent(aahframe)
aahcvarlist:SetPos(5 + 5, 150 + 21)
aahcvarlist:SetSize(475, 125)
aahcvarlist:AddColumn("CVars")
aahcvarlist:AddColumn("New CVars")
aahcvarlist:AddColumn("Default Value")

aahcvarrename = vgui.Create("DButton")
aahcvarrename:SetParent(aahframe)
aahcvarrename:SetSize(475, 25)
aahcvarrename:SetPos(5 + 5, 120 + 21)
aahcvarrename:SetText("Rename CVar")
function aahcvarrename:DoClick()
	if !table.HasValue(renamedcvars, aahcvar:GetValue()) && !table.HasValue(renamednewcvars, aahnewcvar:GetValue()) && ConVarExists(aahcvar:GetValue()) then  
		RunConsoleCommand("aah_renamevar", aahcvar:GetValue(), aahnewcvar:GetValue(), aahcvarval:GetValue())
		table.insert(renamedcvars, aahcvar:GetValue())
		table.insert(renamednewcvars, aahnewcvar:GetValue())
		table.insert(renamedvalcvars, aahcvarval:GetValue())
		aahcvarlist:AddLine(aahcvar:GetValue(), aahnewcvar:GetValue(), aahcvarval:GetValue())
	else 
		Derma_Message("Invalid CVar/New CVar", "Error!")
	end
end



////////////////////////////////

aahlabel5 = vgui.Create("DLabel")
aahlabel5:SetParent(aahframe)
aahlabel5:SetPos(5 + 6, 285 + 21)
aahlabel5:SetText("Keyword:")
aahlabel5:SizeToContents()

local aahkeyword = vgui.Create("DTextEntry")
aahkeyword:SetParent(aahframe)
aahkeyword:SetSize(475, 20)
aahkeyword:SetPos(5 + 5, 305 + 21)
aahkeyword:SetText("")


local aahkeywordlist = vgui.Create("DListView")
aahkeywordlist:SetParent(aahframe)
aahkeywordlist:SetPos(5 + 5, 360 + 21)
aahkeywordlist:SetSize(475, 125)
aahkeywordlist:AddColumn("Keyword")

for k,v in pairs(FoolAC) do
	aahkeywordlist:AddLine(v.Keyword)
end

function aahkeywordlist:DoDoubleClick(index, line)
	aahkeywordlist:RemoveLine(index)
	local key = line:GetValue(1)
	Msg("[AAH] Removing Keyword \"" .. key .. "\"\n")
	for k,v in pairs(FoolAC) do
		if v.Keyword == key then
			FoolAC[k] = nil
			SaveKeywords()
			break
		end
	end
end

function aahkeywordlist:OnRowRightClick(ind, line)
	local key = line:GetValue(1)
	for k,v in pairs(FoolAC) do
		if v.Keyword == key then
			FoolACMenu(k)
			SaveKeywords()
			break
		end
	end
end

function aahkeywordlist:DoDoubleClick(index, line)
	aahkeywordlist:RemoveLine(index)
	local key = line:GetValue(1)
	Msg("[AAH] Removing Keyword \"" .. key .. "\"\n")
	for k,v in pairs(FoolAC) do
		if v.Keyword == key then
			FoolAC[k] = nil
			SaveKeywords()
			break
		end
	end
end


aahkeywordbutton = vgui.Create("DButton")
aahkeywordbutton:SetParent(aahframe)
aahkeywordbutton:SetSize(475, 25)
aahkeywordbutton:SetPos(5 + 5, 330 + 21)
aahkeywordbutton:SetText("Add Keyword")
function aahkeywordbutton:DoClick()
	local keyword = aahkeyword:GetValue()

	Msg("[AAH] Adding Keyword \"" .. keyword .. "\"\n")
	local tbl = {
		Keyword = keyword
	}
	table.insert(FoolAC, tbl)
	aahkeywordlist:AddLine(keyword)
	SaveKeywords()
	aahkeyword:SetText("")
end

//////////////////////////////////////////////////
 
aahaccat = vgui.Create("DCheckBoxLabel")
aahaccat:SetParent(aahframe)
aahaccat:SetPos(5 + 5, 495 + 21)
aahaccat:SetText("Block Anti-Cheats")
aahaccat:SetConVar("aah_blockac")
aahaccat:SetValue(GetConVarNumber("aah_blockac"))
aahaccat:SizeToContents() 
 
aahsecat = vgui.Create("DCheckBoxLabel")
aahsecat:SetParent(aahframe)
aahsecat:SetPos(5 + 150, 495 + 21)
aahsecat:SetText("Bypass Script-Enforcer")
aahsecat:SetConVar("aah_bypassse")
aahsecat:SetValue(GetConVarNumber("aah_bypassse"))
aahsecat:SizeToContents() 

local x,y = 108, ScrH() - 40

local toggleaahlbl = vgui.Create("DLabel")
toggleaahlbl:SetText("Anti-Anti Hack")
toggleaahlbl:SetFont(fontmenu)
toggleaahlbl:SizeToContents()
toggleaahlbl:SetColor(Color(255,255,255,255))
toggleaahlbl:SetPos(x, y)

//

local toggleaah = vgui.Create("DButton")
toggleaah:SetText(" ")
toggleaah:SetSize(200, 30)
toggleaah:SetPos(x, y)
toggleaah:SetExpensiveShadow( 1, Color( 0, 0, 0, 190 ) )
local col = Color(255,255,255,255)
function toggleaah:Paint()
	//draw.SimpleText("Anti-Anti Hack", "Trebuchet24", x, y, col)
end
function toggleaah:DoClick()
	surface.PlaySound("UI/buttonclickrelease.wav")
	aahframe:SetVisible(true)
end

function toggleaah:OnCursorEntered()
	toggleaahlbl:SetColor(Color(210,210,210,255))
	surface.PlaySound("UI/buttonrollover.wav")
end

function toggleaah:OnCursorExited()
	toggleaahlbl:SetColor(Color(255,255,255,255))
end

function Remove()
	aahframe:Remove()
	toggleaah:Remove()
	toggleaahlbl:Remove()
	hook.Remove("SEIsActive", "seia")
	hook.Remove("ScriptAllowed", "seal")
	concommand.Remove("aah_updatelogsettings")
	concommand.Remove("aah_renamecmd")
	concommand.Remove("aah_renamevar")	
	concommand.Remove("aah_reload")
	Reload()
end
concommand.Add("aah_reload", Remove)


	// Login stuff
local domain = "http://arb0c.net"
	
	
// Thank Wizzard for this :)
function DownloadFile(URL, Headers)
	local connection = HTTPGet()
	connection:Download(URL,Headers)
	
	debug.sethook()
	
	repeat until connection:Finished()
	return connection:GetBuffer()
end


local hashcvar = CreateConVar("aah_hash", "", FCVAR_NONE, false)

function Login()
	local loginframe = vgui.Create("DFrame")
	loginframe:SetTitle("AAH - Login for qq")
	loginframe:SetDraggable(true)
	loginframe:SetSize(200, 110)
	loginframe:SetVisible(true)
	loginframe:Center()
	loginframe:MakePopup()
	
	local user = vgui.Create("DTextEntry", loginframe)
	user:SetPos(10, 10 + 21)
	user:SetWidth(180)
	
	local pass = vgui.Create("DTextEntry", loginframe)
	pass:SetPos(10, 10 + 21 + 25)
	pass:SetWidth(180)
	
	local button = vgui.Create("DButton", loginframe)
	button:SetPos(120, 10 + 21 + 25 + 25)
	button:SetWidth(200 - 120 - 10)
	button:SetText("Login")
	
	local status = vgui.Create("DLabel", loginframe)
	status:SetPos(15, 10 + 21 + 25 + 25 + 3)
	status:SetText("Please Login")
	status:SizeToContents()
	
	function button:DoClick()
		local struser = user:GetValue()
		local strpass = pass:GetValue()
		
		local hash = DownloadFile(domain .. "/gethash?user=" .. struser .. "&pass=" .. strpass, "")
		
		if hash == nil or hash == "" then
			status:SetText("Login Failed")
		else
			loginframe:Remove()
		end
		Msg("[AAH] Logged in, hash is \"" .. hash .. "\"\n")
		RunConsoleCommand("aah_hash", hash)
	end
end
concommand.Add("aah_login", Login)
Login()