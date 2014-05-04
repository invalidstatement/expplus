/*********************************** TODO: Text data? More Powerups? Other player's EXP on screen? More damage?  *******************************************/


local EXP_INC = 1 			// The experience gained on every shot
local EXP_USENPC = 2 			// 0 = Players as exp objects, 1 = NPCs as exp objects, 2 = both
local EXP_DEATHLOSS = 0.1 		// The percentage of exp you lose on death (3 percent in this case)
local EXP_STOPATMAX = 0		// Whether or not player's stop gaining exp at the maximum level (1 for they do)
local EXP_USETXT = 1		// Whether or not to use SQL or .txt files to store the data (1 using .txt)


// Let's make the files so we can store the exp
sql.Query("CREATE TABLE IF NOT EXISTS exp_pdata('steam' TEXT NOT NULL, 'exp' INTEGER NOT NULL, 'curlevel' INTEGER NOT NULL, 'nextlevel' INTEGER NOT NULL, 'levelnum' INTEGER NOT NULL, PRIMARY KEY('steam'));")
if not file.Exists("exp_store.txt","DATA") and EXP_USETXT == 1 then file.Write("exp_store.txt","") end

// Just a quick function to print things into everyone's chat
local function PrintAll(msg)
	for _,v in ipairs(player.GetAll()) do
		v:ChatPrint(msg)
	end
end

// Some writing/reading functions if you're using text files: still a work in progress
local function WriteData(ply) 
	local lines = string.Explode("\n",file.Read("exp_store.txt","DATA"))
	local towrite = ""
	for k,v in ipairs(lines) do 
		local values = string.Explode(" ",v)
		if values[1] != ply:SteamID() then towrite = towrite..v
		else end
	end
	local file_store = file.Read("exp_store.txt","DATA")
	local data = file_store..ply:SteamID().." "..ply:GetNWInt("Exp").." "..ply:GetNWInt("CurLevel").." "..ply:GetNWInt("NextLevel").." "..ply:GetNWInt("LevelNum").."\n"
	file.Write("exp_store.txt", data)
end

local function LoadData(ply)
	local lines = string.Explode("\n",file.Read("exp_store.txt","DATA"))
	for _,v in ipairs(lines) do
		local values = string.Explode(" ",v)
		if values[1] == ply:SteamID() then
			ply:SetNWInt("Exp",values[2])
			ply:SetNWInt("CurLevel",values[3])
			ply:SetNWInt("NextLevel",values[4])
			ply:SetNWInt("LevelNum",values[5])
		end
	end
end

// The markers at which you gain a level (always leave the 0, don't go negative or put something before 0)
levelups = {
0,
5,
15,
40,
90,
150,
300,
450,
600,
750,
900,
1050,
1200,
1350,
1500,
1650,
1800,
1950,
2150,
2350,
2550,
2750,
2950,
3200,
3450,
3700,
3950,
4300,
4650,
5000,
5500,
6000,
6850,
7700,
8550,
9400,
10250,
11300,
12350,
13400,
15050,
16700,
18350,
20000,
23000,
26000,
29000,
33000,
39000,
50000,}

/*********************************************************** GAMEMODE HOOKS ****************************************************************/

// Give experience/level up on hit an npc or player
function AddEXP( ply, hitgroup, dmginfo )
	local attacker = dmginfo:GetAttacker()
	if attacker:IsPlayer() then
		if EXP_STOPATMAX == 1 and attacker:GetNWInt("CurLevel") == levelups[table.Count(levelups)] then return end
		attacker:SetNWInt("Exp",attacker:GetNWInt("Exp")+EXP_INC)
		
		if table.HasValue(levelups,attacker:GetNWInt("Exp")) then
			local leveln = 1
			for k,v in ipairs(levelups) do if v == attacker:GetNWInt("Exp") then leveln = k end end
			if leveln == table.Count(levelups) then PrintAll(attacker:Name().." has reached the maximum level!") 
			else PrintAll(attacker:GetName().." has now reached level "..leveln.."!") end
			attacker:SetNWInt("NextLevel",levelups[leveln+1])
			attacker:SetNWInt("CurLevel",levelups[leveln])
			attacker:SetNWInt("LevelNum",leveln)
			attacker:SendLua("surface.PlaySound(\"achievements/achievement_earned.mp3\")")
		end
		
	end
end


// Check if we want to use NPCs or Players as the object of exp	
if EXP_USENPC == 1 then hook.Add("ScaleNPCDamage","NPCExp",AddEXP)
elseif EXP_USENPC == 2 then
	hook.Add("ScaleNPCDamage","NPCExp",AddEXP)
	hook.Add("ScalePlayerDamage","PlayerExp",AddEXP) 
else hook.Add("ScalePlayerDamage","PlayerExp",AddEXP) end

// Take away experience on death
hook.Add("PlayerDeath","DownEXP",function(ply,wep,killer)
	local exp = ply:GetNWInt("Exp")
	local loss = math.Round(exp-exp*EXP_DEATHLOSS)
	if loss < 0 then ply:SetNWInt("Exp",0)
	elseif loss < ply:GetNWInt("CurLevel") then ply:SetNWInt("Exp",ply:GetNWInt("CurLevel"))
	else ply:SetNWInt("Exp",loss) end
end)

// Save the values in the SQL on disconnect
hook.Add("PlayerDisconnected","UpdateEXP",function(ply)
	local exp = ply:GetNWInt("Exp") 
	local cur = ply:GetNWInt("CurLevel")
	local new = ply:GetNWInt("NextLevel")
	local lvl = ply:GetNWInt("LevelNum")
	if EXP_USETXT == 1 then
		WriteData(ply)
	else
		sql.Begin()
		sql.Query("UPDATE exp_pdata SET exp = "..exp.." WHERE steam = "..sql.SQLStr(ply:SteamID())..";") 
		sql.Query("UPDATE exp_pdata SET curlevel = "..cur.." WHERE STEAM = "..sql.SQLStr(ply:SteamID())..";")
		sql.Query("UPDATE exp_pdata SET nextlevel = "..new.." WHERE STEAM = "..sql.SQLStr(ply:SteamID())..";")
		sql.Query("UPDATE exp_pdata SET levelnum = "..lvl.." WHERE STEAM = "..sql.SQLStr(ply:SteamID())..";")
		sql.Commit()
	end
end)


// Load or create the player's values on initial connection
hook.Add("PlayerInitialSpawn","RegisterEXP",function(ply)
	if EXP_USETXT == 1 then
		LoadData(ply)
	elseif not tonumber(sql.QueryValue("SELECT exp FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")) then
		sql.Query("INSERT INTO exp_pdata VALUES("..sql.SQLStr(ply:SteamID())..",".. 0 ..",".. 0 ..","..levelups[2]..",".. 1 ..");")
		ply:SetNWInt("Exp",0)
		ply:SetNWInt("CurLevel",0)
		ply:SetNWInt("NextLevel",levelups[2])
		ply:SetNWInt("LevelNum",1)
	else
		sql.Begin()
		ply:SetNWInt("Exp",tonumber(sql.QueryValue("SELECT exp FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
		ply:SetNWInt("CurLevel",tonumber(sql.QueryValue("SELECT curlevel FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
		ply:SetNWInt("NextLevel",tonumber(sql.QueryValue("SELECT nextlevel FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
		ply:SetNWInt("LevelNum",tonumber(sql.QueryValue("SELECT levelnum FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
		sql.Commit()
	end
end)

/********************************************************** CONCOMMANDS **********************************************************************/

local chatcommands = {}

// Allow admins to change the exp level of players
concommand.Add("exp_setlevel",function(ply,cmd,args)
	if ply:IsAdmin() then
		leveln = tonumber(args[2])
		local tar
		for _,v in ipairs(player.GetAll()) do if string.match(v:Name(),args[1]) then tar = v end end
		
		if not tar then ply:ChatPrint("Please use a valid target! (format <player name> <level>") return end
		if leveln < 1 or leveln > (table.Count(levelups)+1) then ply:ChatPrint("Please select a valid level between 1 - ".. table.Count(levelups) .. ".") return end
		
		tar:SetNWInt("Exp",levelups[leveln])
		tar:SetNWInt("CurLevel",levelups[leveln])
		if leveln == table.Count(levelups) then tar:SetNWInt("NextLevel",levelups[leveln])
		else tar:SetNWInt("NextLevel",levelups[leveln+1]) end
		ply:SetNWInt("LevelNum",leveln)
		
		ply:ChatPrint("You set "..tar:Name().."'s level to "..leveln..".")
	end
end)
table.insert(chatcommands,{"setlevel","exp_setlevel"})


// Allow admins to change the exp increment per hit via console
concommand.Add("exp_setinc",function(ply,cmd,args) 
	if ply:IsAdmin() then 
		local inc = tonumber(args[1])
		if inc < 1 then ply:ChatPrint("Please use a positive integer above zero.") return end
		EXP_INC = tonumber(args[1]) 
	end 
end)
table.insert(chatcommands,{"setinc","exp_setinc"})

// Allow anyone to check their current level
concommand.Add("exp_curlevel",function(ply,cmd,args)
	for k,v in ipairs(levelups) do if ply:GetNWInt("CurLevel") == v then ply:ChatPrint("You are on level "..k..".") end end
end)
table.insert(chatcommands,{"curlevel","exp_curlevel"})


// Allow admins to save everyone's data in the SQL
concommand.Add("exp_savedata",function(ply,cmd,args)
	if ply:IsAdmin() then
		sql.Begin()
		for _,v in pairs(player.GetAll()) do
			local exp = v:GetNWInt("Exp") 
			local cur = v:GetNWInt("CurLevel")
			local new = v:GetNWInt("NextLevel")
			local lvl = v:GetNWInt("LevelNum")
			if EXP_USETXT == 1 then WriteData(v)
			else
				sql.Query("UPDATE exp_pdata SET exp = "..exp.." WHERE steam = "..sql.SQLStr(ply:SteamID())..";") 
				sql.Query("UPDATE exp_pdata SET curlevel = "..cur.." WHERE STEAM = "..sql.SQLStr(ply:SteamID())..";")
				sql.Query("UPDATE exp_pdata SET nextlevel = "..new.." WHERE STEAM = "..sql.SQLStr(ply:SteamID())..";")
				sql.Query("UPDATE exp_pdata SET levelnum = "..lvl.." WHERE STEAM = "..sql.SQLStr(ply:SteamID())..";")
			end
		end
		sql.Commit()
		ply:ChatPrint("Data saved!")
	end
end)
table.insert(chatcommands,{"savedata","exp_savedata"})


// Just in case the SQL fails, let's check why
concommand.Add("exp_debug",function(ply,cmd,args) if sql.LastError() then ply:ChatPrint(sql.LastError()) else ply:ChatPrint("No SQL errors!") end end)
table.insert(chatcommands,{"debug","exp_debug"})


// Get the data from the last save
concommand.Add("exp_printsql",function(ply,cmd,args)
	ply:ChatPrint("Data from previous save...")
	ply:ChatPrint("Experience: "..tonumber(sql.QueryValue("SELECT exp FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
	ply:ChatPrint("Base Level Experience: "..tonumber(sql.QueryValue("SELECT curlevel FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
	ply:ChatPrint("Next Level: "..tonumber(sql.QueryValue("SELECT nextlevel FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
	ply:ChatPrint("Level Number: "..tonumber(sql.QueryValue("SELECT levelnum FROM exp_pdata WHERE steam =  "..sql.SQLStr(ply:SteamID())..";")))
end)
table.insert(chatcommands,{"printsql","exp_printsql"})


// Get the data from right now
concommand.Add("exp_printnw",function(ply,cmd,args)
	ply:ChatPrint("Data at this moment...")
	ply:ChatPrint("Experience: "..ply:GetNWInt("Exp"))
	ply:ChatPrint("Base Level Experience: "..ply:GetNWInt("CurLevel"))
	ply:ChatPrint("Next Level: "..ply:GetNWInt("NextLevel"))
	ply:ChatPrint("Level Number: "..ply:GetNWInt("LevelNum"))
end)
table.insert(chatcommands,{"printnw","exp_printnw"})


/******************************************************** CHAT COMMANDS **********************************************************************/


// So the chatcommands will work
hook.Add("PlayerSay","EXP_Chat",function(ply,str,toall)
	if string.Left(str,2) != "**" then return str end
	local cmd = string.Explode(" ",string.sub(str,3,string.len(str)))
	local cmdstr = ""
	for k,v in ipairs(cmd) do if k != 1 then cmdstr = cmdstr .. " ".. v end end
	for _,v in ipairs(chatcommands) do
		if cmd[1] == v[1] then ply:ConCommand(v[2].." "..cmdstr) end
	end
	return ""
end)
