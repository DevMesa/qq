return--THIS IS NOT DONE!

local qq = eqq 

local Plugin = {
	Name = "Misc",
	Alias = "misc"
}


Plugin.Init = function()
	qq.RegisterTab("misc", "Misc", "gui/silkicons/group", Plugin.BuildTab)
end

local hGetTable = qq.GlobalCopy.hook.GetTable

local dgetinfo = debug.getinfo

local SortedPairs = SortedPairs

qq.pausedHooks = {}

local function buildHookList(listView)
	listView:Clear()
	for hookname, hooktbl in SortedPairs(hGetTable()) do
		for name, func in SortedPairs(hooktbl) do
			listView:AddLine(hookname, name, "Running", dgetinfo(func).short_src)
		end
	end
end

Plugin.BuildTab = function(Scroll)
	Scroll:Clear()
	
	local panel = vgui.Create("DPanel")

	local hookList = vgui.Create("DListView", panel)
	hookList:SetParent(DermaPanel)
	hookList:SetMultiSelect(false)
	hookList:AddColumn("Hook", "Name", "Defined", "State")
	self.hookList = hookList
	
	buildHookList(hookList)
	
	function hookList:OnRowRightClick(line)
		local menu = DermaMenu()
		menu:AddOption("Pause", function() end)
		menu:AddOption("Continue", function() end)
	end
	
	local refresh = vgui.Create("DButton", panel)
	refresh:SetText("Refresh list")
	function refresh:DoClick()
		buildHookList(hookList)
	end
	self.refresh = refresh
	
	function panel:PerformLayout()
		self.hookList:StretchToParent(5, 5, 5, 30)
		self.refresh:MoveBelow(self.hookList)
		self.refresh:CopyWidth(self.hookList)
		self.refresh:SetHeight(25)
	end
	
	Scroll:AddItem(panel)
end

qq.RegisterPlugin(Plugin)