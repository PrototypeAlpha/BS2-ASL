state("Bioshock2")
{
	bool isSaving  : 0xF42EE8;
	bool isLoading : 0x10B8010, 0x278;
	byte lvl       : 0x10B8010, 0x258;
	byte area      : 0xF39948;
	bool endMain   : 0x10CC7E8, 0x48, 0x578, 0x70, 0x20;
	int  startDLC  : 0x006EFDC, 0xB8;
	int  startDLC2 : 0x04959A0, 0x140;
	bool endDLC    : 0x0DDDE88, 0xC, 0xC, 0x0, 0x28, 0x14, 0x2A0;
}

startup 
{
	vars.md=false;
	var gameName = timer.Run.GameName.ToLower();
	if(gameName.Contains("minerva")||gameName.Contains("md")||gameName.Contains("dlc"))
		vars.md=true;
	
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
			settings.SetToolTip(item, "Split when entering water section between FF parts");
			settings.Add("ffalt", false, "Split when reaching FF pt2 instead of leaving FF pt1", item);
			settings.SetToolTip("ffalt", "Splits when entering the hallway with the ADAM plants instead of leaving the upper airlock");
		}
		else if(i > 11)
			settings.Add(item, true, null, vars.lvls[11]);
		else
			settings.Add(item, true, null, vars.lvls[0]);
	}
}

init{timer.IsGameTimePaused=false; vars.prevLvl=0; vars.prevArea=0;}

exit{timer.IsGameTimePaused=true;}

start{
	vars.prevLvl=0;
	vars.prevArea=0;
	if(vars.md && current.lvl == 2)
	{
		if(current.area == 46)
			return !current.isLoading && old.isLoading;
		else
			return ( (current.startDLC == 1 && old.startDLC != 1) || (current.startDLC2 == 1 && old.startDLC2 != 1) );
	}
	else
		return current.lvl == 7 && !current.isLoading && old.isLoading;
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
	else if(!vars.md && current.lvl==27)
	{
		// Split on entering FF part 2 from lower airlock
		if(current.area == 53 && old.area == 54)
			return settings["Fontaine Futuristics 1"] && settings["ffalt"];
		// Split on entering water section from upper airlock
		else if(current.area == 49 && old.area == 50)
			return settings["Fontaine Futuristics 1"] && !settings["ffalt"];
	}
	// Split on entering final elevator
	else if(!vars.md && current.lvl==39 && current.area == 63 && current.endMain && !old.endMain)
			return settings["Inner Persephone"];
	// Minerva's Den splits
	else if(vars.md  && current.lvl== 0)
	{
		if(vars.prevLvl == 19 && vars.prevArea== 4 && current.area== 2 && current.isLoading)
			{vars.prevLvl=current.lvl;	return settings["Operations"];}
		else if(old.lvl== 0 && current.area== 22 && current.endDLC && !old.endDLC)
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
	
	//if(current.lvl != old.lvl) print("[ASL] lvl: "+old.lvl+" -> "+current.lvl);
	//if(current.area != old.area) print("[ASL] area: "+old.area+" -> "+current.area);
}
