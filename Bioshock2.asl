state("Bioshock2")
{
	bool	isSaving	: 0xF42EE8;
	bool	isLoading	: 0x10B8010, 0x278;
	byte	lvl			: 0x10B8010, 0x258;
	byte	area		: 0xF39948;
	short	posX		: 0xF39966;
}

startup 
{
	vars.md = false;
	
	vars.lvls=new string[]{
	"Main Game",
	"Adonis Luxury Resort", "The Atlantic Express", "Ryan Amusements",
	"Pauper's Drop", "Siren Alley", "Dionysus Park",
	"Fontaine Futuristics", "Fontaine Futuristics 1",
	"Outer Persephone", "Inner Persephone",
	"Minerva's Den DLC",
	"Minerva's Den", "Operations", "The Thinker",};
	
	var i = -1;
	foreach(var item in vars.lvls)
	{
		i++;
		if(i == 0 || i == 11)
			settings.Add(item, true);
		else if(i == 8){
			settings.Add(item, false, null, vars.lvls[7]);
			settings.SetToolTip(item, "Splits when entering the hallway with the ADAM plants");
		}
		else if(i > 11)
			settings.Add(item, true, null, vars.lvls[11]);
		else
			settings.Add(item, true, null, vars.lvls[0]);
	}
}

init
{
	vars.gameName = timer.Run.GameName.ToLower();
	vars.md = (vars.gameName.Contains("minerva")||vars.gameName.Contains("md")||vars.gameName.Contains("dlc")) ? true : false;
	
	vars.prevLvl=0;
	vars.prevArea=0;
	
	byte[] exeBytes = new byte[0];
    using (var md5 = System.Security.Cryptography.MD5.Create())
    {
        using (var exe = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
        {
            exeBytes = md5.ComputeHash(exe); 
        }
    }
    var hash = exeBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
	
	print("Hash = "+hash);
	
	switch(hash)
    {
		case "7BE7454335543349786D1CDF7D4EB87D":
			version = "Steam 5.0.019";
			break;
		case "01182B9B2FA7B9232D3862D2E6F1E05A":
			version = "GOG 5.0.019";
			break;
		default:
			version = "Unknown";
			break;
	}
	print("Version = "+version);
	
	timer.IsGameTimePaused=false;
}

exit{timer.IsGameTimePaused=true;}

start{
	vars.prevLvl=0;
	vars.prevArea=0;
	if(vars.md && current.lvl == 2)
		return current.area == 46 && ((current.posX < -15054 && old.posX == -15054) || (!current.isLoading && old.isLoading));
	else
		return current.lvl == 7 && ((current.area == 35 && old.area == 40) || (!current.isLoading && old.isLoading));
}

isLoading{return current.isSaving || current.isLoading;}

split
{
	if(current.isLoading && current.lvl != old.lvl){
		//if(current.lvl == 0 && old.lvl != 0) vars.prevLvl=old.lvl;
		//print("[ASL] vars.prevLvl: "+vars.prevLvl+" | current.lvl: "+current.lvl);
		if(vars.md){
			//if(current.area == 0 && old.area != 0) vars.prevArea=old.area;
			//print("[ASL] vars.prevArea: "+vars.prevArea+" | current.area: "+current.area);
				 if(vars.prevLvl == 2 	&& current.lvl == 19)	{vars.prevLvl=current.lvl;	return settings["Minerva's Den"];}
		}
		else{
				 if(current.lvl == 0) return;
			else if(vars.prevLvl == 7 	&& current.lvl == 2)
				{vars.prevLvl=current.lvl;	return settings["Adonis Luxury Resort"];}
			else if(vars.prevLvl == 2 	&& current.lvl == 16)
				{vars.prevLvl=current.lvl;	return settings["The Atlantic Express"];}
			else if(vars.prevLvl == 16 	&& current.lvl == 39)
				{vars.prevLvl=current.lvl;	return settings["Ryan Amusements"];}
			else if(vars.prevLvl == 39	&& current.lvl == 36)
				{vars.prevLvl=current.lvl;	return settings["Pauper's Drop"];}
			else if(vars.prevLvl == 36	&& current.lvl == 25)
				{vars.prevLvl=current.lvl;	return settings["Siren Alley"];}
			else if(vars.prevLvl == 25 	&& current.lvl == 27)
				{vars.prevLvl=current.lvl;	return settings["Dionysus Park"];}
			else if(vars.prevLvl == 27 	&& current.lvl == 3)
				{vars.prevLvl=current.lvl;	return settings["Fontaine Futuristics"];}
			else if(vars.prevLvl == 3 	&& current.lvl == 39)
				{vars.prevLvl=current.lvl;	return settings["Outer Persephone"];}
		}
	}
	// Split on leaving FF lower airlock
	else if(!vars.md && current.lvl==27 && current.area == 53 && old.area == 54)
			return settings["Fontaine Futuristics 1"];
	// Split on entering final elevator
	else if(!vars.md && current.lvl==39 && current.area == 63 && old.posX < 17808 && current.posX > 17807)
			return settings["Inner Persephone"];
	// Minerva's Den splits
	else if(vars.md  && current.lvl== 0)
	{
		if(vars.prevLvl == 19 && vars.prevArea== 4 && current.area== 2 && current.isLoading)
			{vars.prevLvl=current.lvl;	return settings["Operations"];}
		else if(old.lvl== 0 && current.area== 22 && old.posX < 17675 && current.posX > 17674)
			return settings["The Thinker"];
	}
}

update
{
	if(current.isLoading)
	{
		if(current.lvl == 0 && old.lvl != 0) vars.prevLvl=old.lvl;
		if(current.area == 0 && old.area != 0) vars.prevArea=old.area;
	}
	
	//if(current.posX != old.posX) print("[ASL] posX: "+old.posX+" -> "+current.posX);
	//if(current.lvl != old.lvl) print("[ASL] lvl: "+old.lvl+" -> "+current.lvl);
	//if(current.area != old.area) print("[ASL] area: "+old.area+" -> "+current.area);
}
