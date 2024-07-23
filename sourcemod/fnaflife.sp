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
    // PowerlvlHP
    // GetEntPropString(entity, Prop_Data, "m_iName", buffer, size);
}


public void OutputHook(const char[] name, int caller, int activator, float delay)
{
    // char callerClassname[64];
    // if (caller >= 0 && IsValidEntity(caller)) {
        // GetEntityClassname(caller, callerClassname, sizeof(callerClassname));
    // }

    // char activatorClassname[64];
    // if (activator >= 0 && IsValidEntity(activator)) {
        // GetEntityClassname(activator, activatorClassname, sizeof(activatorClassname));
    // }
    
    // PrintToChatAll("[ENTOUTPUT] %s (caller: %d/%s, activator: %d/%s)", name, caller, callerClassname, activator, activatorClassname);
    
    // PrintToConsoleAll("%d", powerlvlent);
    
    int health = GetEntProp(caller, Prop_Data, "m_iHealth");
    PrintCenterTextAll("Power: %i", health/10);
}