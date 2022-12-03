#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_functions>

public Plugin myinfo =
{
	name = "JBMod Deathmatch Weapons",
	author = "STRESSED CAT IN A BOX#5324",
	description = "Gives the pistol, gravity gun, grenades, and smg to players when they spawn in, as well as removing the physgun from them. Made for JBMod Deathmatch servers.",
	version = "1.0",
	url = "https://discord.com/invite/NuYEEZFpBR"
};

public void OnPluginStart()
{
	PrintToServer("Hello world! Started JBMod Deathmatch plugin successfully!");
	LoadTranslations("common.phrases.txt"); // Required for FindTarget fail reply
	HookEvent("player_spawn", Event_PlayerSpawn);
}


public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{

	new client = GetClientOfUserId(GetEventInt(event,	"userid"));
	GivePlayerItem(client,	"weapon_physcannon");
	GivePlayerItem(client,	"weapon_smg1");
	GivePlayerAmmo(client,	45, 4, true);
	GivePlayerItem(client,	"weapon_pistol");
	GivePlayerAmmo(client,	150, 3, true);
	GivePlayerItem(client,	"weapon_frag");
	GivePlayerAmmo(client,	2, 10, true);
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
} 

public Action OnWeaponEquip(client, weapon)
{
    decl String:sWeapon[32]; 
    GetEdictClassname(weapon, sWeapon, sizeof(sWeapon)); 
     
    if( StrEqual(sWeapon, "weapon_physgun") ) 
    { 
            AcceptEntityInput(weapon, "Kill");
            return Plugin_Handled; 
    }
    return Plugin_Continue;
}