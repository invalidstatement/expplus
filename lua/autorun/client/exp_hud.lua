local barpos = 1
local x,y,w,h

if barpos == 0 then
	x,y,w,h = 10,40,ScrW()-20,20
elseif barpos == 1 then
	x,y,w,h = 35,ScrH()-120,200,20 
end

surface.CreateFont( "SpecialFont", {
	font = "Arial",
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

hook.Add("HUDPaint", "ExpHud", function()

	local exp = LocalPlayer():GetNWInt("Exp") 
	local cur = LocalPlayer():GetNWInt("CurLevel")
	local new = LocalPlayer():GetNWInt("NextLevel")
	local lvl = LocalPlayer():GetNWInt("LevelNum")
	
	if LocalPlayer():Alive() then
		
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(x,y,w,h)
	
		surface.SetDrawColor(200,0,0,255)
		surface.DrawRect(x+1.2,y+1.2,w*((exp-cur)/(new-cur))-2,h-2)
	
		draw.DrawText("Level "..lvl,"SpecialFont",x+w/2,y-20,Color(255,255,255,255),1)
		draw.DrawText(exp.."/"..new,"SpecialFont",x+w/2,y+1,Color(0,0,0,255),1)
	end

end)
