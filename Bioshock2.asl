state("Bioshock2")
{
	bool 	isSaving	:	0xF42EE8;
	bool 	isLoading	:	0x10B8010, 0x278;
	byte	lvl			:	0x10B8010, 0x258;
	byte	area		:	0xF39948;
	bool	endMain		:	0x10CC7E8, 0x48, 0x578, 0x70, 0x20;
	bool	endDLC		:	0x0DDDE88, 0xC, 0xC, 0x0, 0x28, 0x14, 0x2A0;
}

startup 
{
	vars.md=false;
	var gameName = timer.Run.GameName.ToLower();
	if(gameName.Contains("minerva")||gameName.Contains("md")||gameName.Contains("dlc")){
		vars.md=true;
		vars.lvls=new string[]{"Minerva's Den", "Operations", "The Thinker",};
	}
	else{
		vars.lvls=new string[]{
		"Adonis Luxury Resort", "The Atlantic Express", "Ryan Amusements",
		"Pauper's Drop", "Siren Alley", "Dionysus Park",
		"Fontaine Futuristics", "Fontaine Futuristics 1",
		"Outer Persephone", "Inner Persephone",};
	}
	
	foreach(var item in vars.lvls)
	{
		if(item == "Fontaine Futuristics 1"){
			settings.Add(item, false, null,"Fontaine Futuristics");
			settings.SetToolTip(item, "Split when reaching Fontaine's Plasmid Research and Development (the part with huge tank)");
		}
		else settings.Add(item, true);
	}
}

init{timer.IsGameTimePaused=false; vars.prevLvl=0; vars.prevArea=0;}

exit{timer.IsGameTimePaused=true;}

start{vars.prevLvl=0; vars.prevArea=0; return !current.isLoading && old.isLoading && ((!vars.md && current.lvl == 7) || (vars.md && current.lvl == 2));}

isLoading{return current.isSaving || current.isLoading;}

split
{
	if(current.isLoading && current.lvl != old.lvl){
		if(current.lvl == 0 && old.lvl != 0) vars.prevLvl=old.lvl;
		print("[ASL] vars.prevLvl: "+vars.prevLvl+" | current.lvl: "+current.lvl);
		if(vars.md){
			if(current.area == 0 && old.area != 0) vars.prevArea=old.area;
			print("[ASL] vars.prevArea: "+vars.prevArea+" | current.area: "+current.area);
				 if(vars.prevLvl == 2 	&& current.lvl == 19)	{vars.prevLvl=current.lvl;	return settings["Minerva's Den"];}
		}
		else{
				 if(current.lvl == 0) return;
			else if(vars.prevLvl == 7 	&& current.lvl == 2)											{vars.prevLvl=current.lvl;	return settings["Adonis Luxury Resort"];}
			else if(vars.prevLvl == 2 	&& current.lvl == 16)											{vars.prevLvl=current.lvl;	return settings["The Atlantic Express"];}
			else if(vars.prevLvl == 16 	&& current.lvl == 39)											{vars.prevLvl=current.lvl;	return settings["Ryan Amusements"];}
			else if(vars.prevLvl == 39	&& current.lvl == 36)											{vars.prevLvl=current.lvl;	return settings["Pauper's Drop"];}
			else if(vars.prevLvl == 36	&& current.lvl == 25)											{vars.prevLvl=current.lvl;	return settings["Siren Alley"];}
			else if(vars.prevLvl == 25 	&& current.lvl == 27)											{vars.prevLvl=current.lvl;	return settings["Dionysus Park"];}
			else if(vars.prevLvl == 27 	&& current.lvl == 3)											{vars.prevLvl=current.lvl;	return settings["Fontaine Futuristics"];}
			else if(vars.prevLvl == 3 	&& current.lvl == 39)											{vars.prevLvl=current.lvl;	return settings["Outer Persephone"];}
		}
	}
	else if(!vars.md && current.lvl==27 && current.area == 53 && old.area == 54)													return settings["Fontaine Futuristics 1"];
	else if(!vars.md && current.lvl==39 && current.endMain && !old.endMain)															return settings["Inner Persephone"];
	else if(vars.md  && current.lvl== 0 && vars.prevLvl == 19 && vars.prevArea== 4 && current.area== 2){vars.prevLvl=current.lvl;	return settings["Operations"];}
	else if(vars.md  && current.lvl== 0 && old.lvl== 0 && current.area== 22 && current.endDLC && !old.endDLC)						return settings["The Thinker"];
}
