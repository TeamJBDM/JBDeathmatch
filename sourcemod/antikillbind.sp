public Plugin:myinfo =
{
    name = "jbmod - stop killing yourself...",
    author = "STRESSED CAT IN A BOX",
    description = "no description",
    version = "1.0",
    url = "https://discord.gg/P6ZwJvCsG8"
};
    
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <entity_prop_stocks>

#pragma semicolon 1


public OnPluginStart()
{
    AddCommandListener(fuck_it, "kill");
    AddCommandListener(fuck_it, "explode");
}


//just disallow command
public Action:fuck_it(client, const String:command[], argc) {
    if (client != 0) {
        PrintToConsole(client, "Killbinds are blocked.");
    }
    
    return Plugin_Stop;
}