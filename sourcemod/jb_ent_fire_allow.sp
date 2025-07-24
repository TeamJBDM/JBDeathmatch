public Plugin:myinfo =
{
	name = "jbmod - allow ent_fire",
	author = "Nafrayu",
	description = "allows everyone to use the ent_fire command",
	version = "1.0",
	url = ""
};


#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <sdktools_tempents>
#include <sdktools_sound>
#include <sdkhooks>
#include <entity_prop_stocks>


#pragma semicolon 1


public OnEventShutdown()
{
	UnhookEvent("player_activate", ev_player_activate);
}


public OnPluginStart()
{
	HookEvent("player_activate", ev_player_activate, EventHookMode_Post);
}


public Action:ev_player_activate(Handle:event, const String:name[], bool:dontBroadcast)
{
	new iUserId = GetEventInt(event, "userid");
	// new client = GetClientOfUserId(iUserId);
	
	ServerCommand("mp_disable_autokick %i", iUserId);
}

