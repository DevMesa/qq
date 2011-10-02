local qq = eqq 
local lp = qq.GlobalCopy.LocalPlayer()

local PlyMeta = qq.Meta.Ply

local Plugin = {
	Name = "Name Changer",
	Alias = "namechanger",
	Names = {},
}

Plugin.Init = function()	
	qq.CreateSetting(qq.MENU_GENERIC, Plugin, "name", "Name", "", {Save = false}, Plugin.UpdateName)
	qq.CreateSetting(-1, Plugin, "defaultname", "defname", "")
	--qq.CreateSetting(qq.MENU_DEV, Plugin, "stealname", "Steal Players Name", Plugin.StealName)
	// You can keep this, I guess it makes more sense this way
	qq.RegisterTab("namechanger", "Names", "gui/silkicons/group", Plugin.BuildTab)// this  is just to make it, can implement later when you add the new stuff to menu api
end

Plugin.BuildTab = function(Scroll)--This was called before Init...
	
	local saything = vgui.Create("DTextEntry", Scroll)--we will be using this so we need to make it first
	saything:SetPos(50,208)
	saything:SetSize(335, 20)
	
	local namething = vgui.Create("DTextEntry", Scroll)
	namething:SetPos(200,238)
	namething:SetSize(145, 20)
	namething:SetText(qq.Setting(Plugin, "defaultname") or "")--had a fuckup here!
	
	local listnames = vgui.Create("DListView", Scroll)
	listnames:SetPos(5,5)
	listnames:SetSize(380,200)
	listnames:SetMultiSelect(false)
	listnames:AddColumn("Players (Double Click one!)")
	for k,v in pairs(player.GetAll()) do
		if v != lp then
			listnames:AddLine(PlyMeta.Name(v))
		end
	end

	listnames.DoDoubleClick = function(parent, index, list)
		local options = DermaMenu()
		
		options:AddOption("Steal", function()
			qq.SetSetting(Plugin, "name", string.char(03) ..  list:GetValue(1))
		end)
			options:AddOption("Say", function()
			local RealName = namething:GetValue()
			qq.SetSetting(Plugin, "name", string.char(03) .. list:GetValue(1))
			timer.Simple(0.5, qq.Module.DoCommand, "say " .. saything:GetValue())
			timer.Simple(1, qq.SetSetting, Plugin, "name", RealName)
		end)
		options:Open()
	end


	local blank = vgui.Create("DButton", Scroll)
	blank:SetPos(5, 238)
	blank:SetSize(70,blank:GetTall())
	blank:SetText("Blank")
	blank.DoClick = function()
		qq.SetSetting(Plugin, "name", "\3")--@Wizard changed string.char(03) to "\3"
	end
	
	local sweep = vgui.Create("DButton", Scroll)
	sweep:SetPos(80, 238)
	sweep:SetSize(70,sweep:GetTall())
	sweep:SetText("Sweep")
	sweep.DoClick = function()
		Plugin.SweepEnabled = not Plugin.SweepEnabled
		if Plugin.SweepEnabled then
			qq.Inform("Name sweeping on")
		else
			qq.Inform("Name sweeping off")
		end
	end

	local saytext = vgui.Create("DLabel", Scroll)
	saytext:SetPos(5,210)
	saytext:SetFont("TabLarge")
	saytext:SetText("To Say:")
	saytext:SizeToContents(true)
	
	local nametext = vgui.Create("DLabel", Scroll)
	nametext:SetPos(160,240)
	nametext:SetFont("TabLarge")
	nametext:SetText("Name:")
	nametext:SizeToContents(true)
	
	local nameset = vgui.Create("DButton", Scroll)
	nameset:SetPos(350, 238)
	nameset:SetSize(35, 20)
	nameset:SetText("Set")
	nameset.DoClick = function()
		qq.SetSetting(Plugin, "name",  namething:GetValue())
	end
	
end

Plugin.UpdateName = function(cvar,old,new)
	if not new or new == "" then return end
	
	qq.DebugMsg("Setting name to {1}", new)
	qq.Module.DoCommand("name " .. new)
end

Plugin.SweepEnabled = false
Plugin.LastSweep = CurTime()
Plugin.LastIndex = 0
Plugin.Tick = function()
	if not Plugin.SweepEnabled then return end
	if CurTime() - Plugin.LastSweep < 0.1 then return end
	Plugin.LastSweep = CurTime()
	
	local plys = player.GetAll()
	local count = #plys
	
	if count == 0 then return end
	Plugin.LastIndex = (Plugin.LastIndex + 1) % count + 1
	
	local pl = plys[Plugin.LastIndex]
	qq.SetSetting(Plugin, "name", "\3" .. PlyMeta.Name(pl))--@Wizard changed string.char(03) to "\3"
end

Plugin.Hooks = {
	Tick = Plugin.Tick
}

qq.RegisterPlugin(Plugin)