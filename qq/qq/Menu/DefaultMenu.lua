local qq = eqq
local Menu = {}

qq.Include("qq/Menu/QQDForm.lua")
qq.Include("qq/Menu/DefaultSkin.lua")

Menu.BuildItems = function(panel, section, Plugin)
	local ret = false
	for _, info in pairs(qq.SettingsOrdered) do
		if (info.Show or true) and info.Section == section and info.Plugin == Plugin then
			ret = true
			if (info.Misc or {}).MultiChoice then
				local m = panel:MultiChoice(info.Desc or info.CVar, info.CVar)
				m:SetEditable(false)
				for k, v in pairs(info.Misc.MultiChoice) do
					m:AddChoice(k, v)
				end
			elseif info.Type == "number" then
				if (info.Misc or {}).Slider then
					panel:NumSlider(info.Desc or info.CVar, info.CVar, (info.Misc or {}).Min or -1, (info.Misc or {}).Max or -1, (info.Misc or {}).Places or 0)
				else
					panel:NumberWang(info.Desc or info.CVar, info.CVar, (info.Misc or {}).Min or -1, (info.Misc or {}).Max or -1, (info.Misc or {}).Places or 0)
				end
			elseif info.Type == "boolean" then
				panel:CheckBox(info.Desc or info.CVar, info.CVar)
			elseif info.Type == "string" then
				panel:TextEntry(info.Desc or info.CVar, info.CVar)
			elseif info.Type == "function" then
				panel:Button(info.Desc or info.CVar, info.CVar)
			elseif info.Type == "table" then
				panel:ColorMixer(info.Desc or info.CVar, info.CVar)
			end
		end
	end
	return ret
end

local RegedTabs = {}
Menu.RegisterTab = function(id, name, icon, buildfunc)
	RegedTabs[id] = {
		Name = name,
		BuildFunc = buildfunc,
		Icon = icon,
	}
end

local function headerOverride(self, mcode)
	local pnl = self:GetParent();
	if (mcode == MOUSE_LEFT) then
		for _, v in pairs(pnl:GetParent():GetParent():GetItems()) do
			if(!v:GetExpanded()) then
				continue;
			end
			v:Toggle();
		end
		pnl:Toggle();
		return ;
	end
	return self:GetParent():OnMousePressed(mcode);
end

Menu.BuildTab = function(section, name, icon, panel)
	local scroll = vgui.Create("DPanelList", panel)
	scroll:SetPos(5, 5)
	scroll:SetSize(390, 290)
	scroll:EnableVerticalScrollbar()
	scroll:SetSpacing(2)
	scroll:SetSpacing(2)
	
	for k,v in pairs(qq.Plugins) do
		if type(k) == "number" then continue end
		local Cat = vgui.Create("DCollapsibleCategory")
		Cat:SetExpanded(0)
		Cat:SetLabel(v.Name)
		Cat.Header.OnMousePressed = headerOverride--@Wizard, close all other categories.
		local form = vgui.Create("QQDForm", menu)
		//local form = vgui.Create("DPanelList", menu)
		form.Paint = function() end
		form:SetPos(0,-10)
		//Cat:AddItem(form)
		Cat:SetContents(form)
		//scroll:AddItem(form)
		local HasSettingsForTab = Menu.BuildItems(form, section, v)
		if HasSettingsForTab then
			scroll:AddItem(Cat)
		else
			form:Remove()
			Cat:Remove()
		end
	end

	panel:AddSheet( name, scroll, icon)
end

function draw.RoundedOutline( border, x, y, w, h, col )
	surface.SetDrawColor( col.r, col.g, col.b, col.a )
	
	surface.DrawRect( x + border, y, w - border * 2, border )
	surface.DrawRect( x + border, y + h - border, w - border * 2, border )
	surface.DrawRect( x, y + border, border, h - border * 2 )
	surface.DrawRect( x + w - border, y + border, border, h - border * 2 )
	
	local a, c
	
	a = tex8
	
	if border > 8 then
		a = tex16
	end
	
	c = border / 2
	
	surface.SetTexture( a )
	
	surface.DrawTexturedRectRotated( x + c, y + c, border, border, 0 )
	surface.DrawTexturedRectRotated( x + w - c, y + c, border, border, 270 )
	surface.DrawTexturedRectRotated( x + w - c, y + h - c, border, border, 180 )
	surface.DrawTexturedRectRotated( x + c, y + h - c, border, border, 90 )
end

Menu.Create = function()
	local w, h = ScrW() / 3, ScrH() / 2
	
	local menuh = 330
	local menuw = 410
	
	local menu = vgui.Create("DFrame")
	menu:SetTitle("qq")
	menu:SetSize(menuw, menuh)
	menu:Center()
	menu:SetSkin("QQ")
	menu:SetDeleteOnClose(false)
	menu:MakePopup()
	
	menu.Paint = function()
		draw.RoundedBox( 4, 0, 0, menu:GetWide(), menu:GetTall(), Color( 50, 50, 50, 100 ) )
		draw.RoundedOutline( 1, 0, 0, menu:GetWide(), menu:GetTall(), Color( 50, 50, 50, 255 ) )
		return true
	end
	
	local PropertySheet = vgui.Create( "DPropertySheet", menu )
	PropertySheet:SetPos( 5, 25 )
	PropertySheet:SetSize( menuw - 10, menuh - 30 )

	Menu.BuildTab(qq.MENU_GENERIC, "Generic", "gui/silkicons/world", PropertySheet)
	Menu.BuildTab(qq.MENU_AIMBOT, "Aimbot", "gui/silkicons/wrench", PropertySheet)
	Menu.BuildTab(qq.MENU_VISUALS, "Visuals", "gui/silkicons/palette", PropertySheet)
	Menu.BuildTab(qq.MENU_GAMEMODE, "GM", "gui/silkicons/bomb", PropertySheet)
	
	for k,v in pairs(RegedTabs) do
		local scroll = vgui.Create("DPanelList", PropertySheet)
		scroll:SetPos(5, 5)
		scroll:SetSize(390, 290)
		scroll:EnableVerticalScrollbar()
		scroll:SetSpacing(2)
		scroll:SetSpacing(2)
		
		v.BuildFunc(scroll)
		
		PropertySheet:AddSheet(v.Name, scroll, v.Icon)
	end
	
	//Menu.BuildTab(qq.MENU_DEV, "Dev", "gui/silkicons/shield", PropertySheet)
	
	Menu.Menu = menu
end

Menu.Open = function()
	if Menu.Menu then
		return Menu.Menu:SetVisible(true)
	end
	Menu.Create()
end

qq.SetMenu(Menu)