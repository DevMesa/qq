local logcvar = CreateConVar("aah_log", "0", FCVAR_ARCHIVE, false)   
local logpathcvar = CreateConVar("aah_logpath", "C:\\Dumps", FCVAR_ARCHIVE, false)   
CreateConVar("aah_blockac", "1", FCVAR_ARCHIVE, false)   
CreateConVar("aah_bypassse", "1", FCVAR_ARCHIVE, false)

local Keywords = {}
local filestr = file.Read("aah_keywords.txt") or ""
Keywords = string.Explode("\n", filestr)

Msg("[AAH] Loaded " .. tostring(#Keywords) .. " Keywords\n")

function SaveKeywords()
	local filecontents = table.concat(Keywords or {}, "\n")
	file.Write("aah_keywords.txt", filecontents)
end

function Reload()
	local info = debug.getinfo(1, "S")
	local str = string.Replace(info.short_src, "lua\\", "")
	include(str)
end

local fontmenu = "aahfont"

surface.CreateFont( "Tahoma", 23, 600, true, false, fontmenu, true, false )

if not AAH_REQ then // we only want the module to load once
	local AAH_REQ = true
	require("aah")
end

concommand.Add("aah_renamevar", function(p,cmd,args)
	local cvar = args[1]
	local cvar_new = args[2]
	local defaultval = args[3]
	RenameCVAR(cvar, cvar_new, -1, defaultval)
end)

concommand.Add("aah_renamecmd", function(p,cmd,args)
	local cmd = args[1]
	local cmd_new = args[2]
	RenameCONCMD(cmd, cmd_new)
end)

concommand.Add("aah_updatelogsettings", function()
	ShouldLogFiles(logcvar:GetBool())
	SetLogPath(logpathcvar:GetString())
	Msg("[AAH] Log settings updated\n")
end)

local function ScriptAllowed(strFileName, strFileContents, md5)
	if GetConVarNumber("aah_blockac") == 1 then
		for k,v in pairs(Keywords) do
			if string.find(strFileName, v) then
				Msg("[AAH] Blocking " .. strFileName .. "(AntiHack)(" .. md5 .. ")\n")
				return false
			end
		end
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
aahkeyword:SetText("Anti cheat name")


local aahkeywordlist = vgui.Create("DListView")
aahkeywordlist:SetParent(aahframe)
aahkeywordlist:SetPos(5 + 5, 360 + 21)
aahkeywordlist:SetSize(475, 125)
aahkeywordlist:AddColumn("Keyword")

for k,v in pairs(Keywords) do
	aahkeywordlist:AddLine(v)
end

function aahkeywordlist:DoDoubleClick(index, line)
	aahkeywordlist:RemoveLine(index)
	local key = line:GetValue(1)
	Msg("[AAH] Removing Keyword \"" .. key .. "\"\n")
	for k,v in pairs(Keywords) do
		if v == key then
			Keywords[k] = nil
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
	
	if not table.HasValue(Keywords, keyword) then  
		Msg("[AAH] Adding Keyword \"" .. keyword .. "\"\n")
		table.insert(Keywords, keyword)
		aahkeywordlist:AddLine(keyword)
		SaveKeywords()
		aahkeyword:SetText("")
	else 
		Derma_Message("Invalid keyword/New keyword", "Error!")
	end
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