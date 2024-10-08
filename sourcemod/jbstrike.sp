#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_functions>
#include <convars>

public Plugin myinfo =
{
	name = "JBStrike Weapon Remover",
	author = "TeamJBDM",
	description = "JBStrike stuff, y'know?",
	version = "1.0",
	url = "https://discord.gg/P6ZwJvCsG8"
};

public void OnPluginStart()
{
	PrintToServer("Hello world! JBStrike succesfully started.");
	LoadTranslations("common.phrases.txt"); // Required for FindTarget fail reply
}

public void OnMapStart()
{

ConVar mp_teamplay = FindConVar("mp_teamplay");
if (mp_teamplay && mp_teamplay.BoolValue)
{
	int entity_index = MaxClients + 1; // Skip all client indexs...

	while((entity_index = FindEntityByClassname(entity_index, "weapon_*")) != -1)
	{
		RemoveEntity(entity_index);
	}

	entity_index = MaxClients + 1; // Skip all client indexs...

	while((entity_index = FindEntityByClassname(entity_index, "item_*")) != -1)
	{
		RemoveEntity(entity_index);
	}
}
}