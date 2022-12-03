public Plugin:myinfo =
{
    name = "jbmod - disable canisters",
    author = "Nafrayu",
    description = "no description",
    version = "1.0",
    url = "nafrayu.com"
};
    
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <entity_prop_stocks>

#pragma semicolon 1


public OnPluginStart()
{
    AddCommandListener(fuck_it, "ent_create_cannister");
}


//just disallow command
public Action:fuck_it(client, const String:command[], argc) {
    if (client != 0) {
        PrintToConsole(client, "Canisters are disabled.");
    }
    
    return Plugin_Stop;
}