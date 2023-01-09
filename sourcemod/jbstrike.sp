#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_functions>
#include <convars>

public Plugin myinfo =
{
	name = "JBMod Deathmatch Weapons",
	author = "TeamJBDM",
	description = "JBStrike stuff, y'know?",
	version = "1.0",
	url = "https://discord.com/invite/NuYEEZFpBR"
};

public void OnPluginStart()
{
	PrintToServer("Hello world! JBStrike succesfully started.");
	LoadTranslations("common.phrases.txt"); // Required for FindTarget fail reply
}

public void OnMapStart()
{

command = FindConVar("mp_teamplay")
if(GetConVarBool(command) == 1)
{
	int entity_index = MaxClients + 1; // Skip all client indexs...

	while((entity_index = FindEntityByClassname(entity_index, "weapon_*")) != -1)
	{
		RemoveEntity(ent);
	}

	entity_index = MaxClients + 1; // Skip all client indexs...

	while((entity_index = FindEntityByClassname(entity_index, "item_*")) != -1)
	{
		RemoveEntity(ent);
	}
}
}