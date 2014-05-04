local UP_RUN = 1 	// Increase run speed, set to 0 to disable
local UP_WALK = 1	// Increase walk speed
local UP_JUMP = 1	// Increase jump power
local UP_SWEPS = 1 	// Give different weapons
local UP_ARMOR = 1	// Increase armor
local UP_HP = 1		// Increase health

local regweapons = {
"weapon_physgun",
"weapon_stunstick",
"gmod_tool",
"gmod_camera",
}

local upweapons = {
{"weapon_pistol", "Pistol"},			// Level 2
{"weapon_357","357"},		// Level 3
{"weapon_smg1","smg1"},	// Level 4
{"weapon_shotgun","Buckshot"},	// Level 5
{"weapon_ar2","ar2"},		// Level 6
{"weapon_crossbow","XBowBolt"},	// Level 7
{"weapon_grenade","grenade"},			// Level 8
{"weapon_grenade","grenade"},		// Level 9
{"weapon_rpg","rpg"},			// Level 10
{"weapon_rpg","rpg"},			// Level 11
{"weapon_rpg","rpg"},			// Level 12
{"weapon_rpg","rpg"},			// Level 13
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
{"weapon_rpg","rpg"},			
}

hook.Add("PlayerSpawn","EXP_PowerupsSpawn",function(ply) 
	
	// Get the player's current level
	local lvl = 0
	for k,v in ipairs(levelups) do if v == ply:GetNWInt("CurLevel") then lvl = k-1 end end
	
	// Enhance their run/walk/jump speed
	if UP_RUN == 1 then ply:SetRunSpeed(230+lvl*100) end
	if UP_WALK == 1 then ply:SetWalkSpeed(155+lvl*20) end
	if UP_JUMP == 1 then ply:SetJumpPower(200+lvl*15) end
	if UP_ARMOR == 1 then ply:SetArmor(0+lvl*10) end
	if UP_HP == 1 then ply:SetHealth(100+lvl*10) end
	
end) 

hook.Add("PlayerLoadout","EXP_PowerupsLoad",function(ply)
	
	// Get the player's current level
	local lvl = 0
	for k,v in ipairs(levelups) do if v == ply:GetNWInt("CurLevel") then lvl = k-1 end end

	if UP_SWEPS == 1 then
		ply:StripWeapons()
		for _,v in ipairs(regweapons) do ply:Give(v) end
		for k,v in ipairs(upweapons) do 
			if lvl >= k then 
				ply:Give(v[1])
				if v[2] then ply:GiveAmmo(15*lvl,v[2],false) end
			end 
		end
		if lvl >= 7 then 
			ply:GiveAmmo(lvl-6,"SMG1_Grenade",false) 
			ply:GiveAmmo(lvl-6,"AR2AltFire",false)
		end
	end
	
	return true
end) 