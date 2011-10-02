local SKIN = {}


--@Wizard localizing
local ColorToHSV = ColorToHSV
local HSVToColor = HSVToColor
local Color = Color

local sDrawColor = surface.SetDrawColor
local sDrawRect = surface.DrawRect
local sSetDrawColor = surface.SetDrawColor;
local sDrawOutlinedRect = surface.DrawOutlinedRect

local saturation = 90
local function QQColor(r, g, b)
	local h, s, v = ColorToHSV(Color(r,g,b))
	return HSVToColor((h - saturation) % 360,s,v)
end

SKIN.PrintName = "my dick v78326"
SKIN.Author = "my dick"
SKIN.DermaVersion = 1

SKIN.bg_QQColor = QQColor(50, 50, 50, 255)
SKIN.bg_QQColor_sleep = QQColor(40, 40, 40, 255)
SKIN.bg_QQColor_dark = QQColor(30, 30, 30, 255)
SKIN.bg_QQColor_bright = QQColor(80, 80, 80, 255)

SKIN.panel_transback = QQColor(85, 90, 85, 60)
SKIN.tooltip = QQColor(80, 220, 85, 255)

SKIN.QQColor_frame_background = QQColor(10, 10, 10, 255)
//SKIN.QQColor_frame_border = QQColor(0, 80, 0, 255)
SKIN.QQColor_frame_border = Color(0, 80, 0, 255)

SKIN.control_QQColor = QQColor(40, 40, 40, 255)
SKIN.control_QQColor_dark = QQColor(25, 25, 25, 255)
SKIN.control_QQColor_active = QQColor(55, 75, 55, 255)
SKIN.control_QQColor_highlight = QQColor(50, 65, 50, 255)

SKIN.QQColor_textentry_background = QQColor(40, 40, 40, 255)
SKIN.QQColor_textentry_border = QQColor(70, 90, 70, 255)

SKIN.QQColor_purewhite = QQColor(255, 255, 255, 255)

SKIN.colButtonText = QQColor(240, 255, 240, 255)
SKIN.colButtonTextDisabled = QQColor(240, 255, 240, 55)
SKIN.colButtonBorder = QQColor(20, 25, 20, 255)
SKIN.colButtonBorderHighlight = QQColor(200, 210, 200, 50)
SKIN.colButtonBorderShadow = QQColor(0, 0, 0, 120)

SKIN.colMenuBG = QQColor(140, 150, 140, 200)
SKIN.colMenuBorder = QQColor(0, 0, 0, 200)

SKIN.colPropertySheet = QQColor(40, 40, 40, 255)
SKIN.colTab = SKIN.colPropertySheet
SKIN.colTabInactive = QQColor(25, 25, 25, 155)
SKIN.colTabShadow = QQColor(20, 30, 20, 255)
SKIN.colTabText	= QQColor(240, 255, 240, 255)
SKIN.colTabTextInactive	= QQColor(240, 255, 240, 120)

SKIN.color_purewhite = Color(255,255,255,255)

function SKIN:SchemeTreeNodeButton(panel)
	--DLabel.ApplySchemeSettings(panel)
	panel:SetTextColor(self.color_purewhite)
end

function SKIN:PaintFrame(panel)
	local wid, hei = panel:GetSize()
	sSetDrawColor(self.color_frame_background)
	sDrawRect(0, 0, wid, hei)
	self:DrawBorder(0, 0, wid, hei, self.color_frame_border)
end

function SKIN:DrawBorder(x, y, w, h, border)
	sSetDrawColor(border)
	sDrawOutlinedRect(x, y, w, h)
	//surface.SetDrawColor(border.r * 0.75, border.g * 0.75, border.b * 0.5, border.a)
	//surface.DrawOutlinedRect(x + 1, y + 1, w - 2, h - 2)
	//surface.SetDrawColor(border.r * 0.5, border.g * 0.5, border.b * 0.5, border.a)
	//surface.DrawOutlinedRect(x + 2, y + 2, w - 4, h - 4)
end


function SKIN:PaintTextEntry(panel)
	
	if panel.m_bBackground then
		sSetDrawColor(SKIN.QQColor_textentry_background)
		sDrawRect(0, 0, panel:GetSize())--@Wizard changed getwidth/getheight to getsize
	end
	
	panel:DrawTextEntryText(panel.m_colText, panel.m_colHighlight, panel.m_colCursor)

	if panel.m_bBorder then
		self:DrawBorder(0, 0, panel:GetWide(), panel:GetTall(), SKIN.QQcolor_textentry_border)
	end	
end


function SKIN:SchemeTextEntry(panel)
	panel:SetTextColor(self.color_purewhite)
	panel:SetHighlightColor(self.color_purewhite)
	panel:SetCursorColor(self.color_purewhite)
end

function SKIN:DrawGenericBackground( x, y, w, h, color )
   
	sSetDrawColor( self.colMenuBG )
	sDrawRect( x, y, w, h )
   
	sSetDrawColor( 50, 50, 50, 200 )
	sDrawOutlinedRect( x, y, w, h )
	sSetDrawColor( 50, 50, 50, 255 )
	sDrawOutlinedRect( x+1, y+1, w-2, h-2 )

end

derma.DefineSkin("QQ", "qq", SKIN)
