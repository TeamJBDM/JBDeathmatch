#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <sdktools_tempents>
#include <sdktools_sound>
#include <sdkhooks>

#pragma newdecls required
#pragma semicolon 1


public Plugin myinfo = 
{
name        = "Fnaf-Life 2: JBMod Edition",
author      = "STRESSED CAT IN A BOX, Nafrayu",
description = "Plugin so that fnaf-life's newest releases will work properly in JBMod :)",
version     = "1.0",
url         = "https://discord.gg/P6ZwJvCsG8"
};


public void OnPluginStart()
{
    HookEntityOutput("func_breakable", "OnHealthChanged", OutputHook);
}


public void OutputHook(const char[] name, int caller, int activator, float delay)
{
	char map[256];
    GetCurrentMap(map, sizeof(map));
    
    int health = GetEntProp(caller, Prop_Data, "m_iHealth");
	if (StrEqual(map, "jb_fnaf_1")) 
	{
	PrintCenterTextAll("Power: %i", health/20);
	}
	else
	{
    PrintCenterTextAll("Power: %i", health/10);
	}
}