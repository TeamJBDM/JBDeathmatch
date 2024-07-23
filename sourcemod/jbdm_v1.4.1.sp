#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_functions>
#include <convars>

public Plugin myinfo =
{
    name = "JBMod Deathmatch Weapons",
    author = "stressedcatinabox, nafrayu, allinkdev",
    description = "Gives the pistol, gravity gun, grenades, and smg to players when they spawn in, as well as removing the physgun from them. Made for JBMod Deathmatch servers.",
    version = "1.4.1",
    url = "https://discord.gg/P6ZwJvCsG8"
}

new Handle:JBDMAnnabelleEnabled;
new Handle:TeamplayEnabled;
new Handle:MaxFrags;
new Handle:JBDMRailgunEnabled
new Handle:SGGEnabled
new Handle:SGGRange
new Handle:GGRange
new Handle:JBDMEnablePhysgun
new Handle:JBDMFlaregunEnabled;

public void OnPluginStart()
{
    PrintToServer("Hello world! Started JBMod Deathmatch plugin successfully!");
    LoadTranslations("common.phrases.txt"); // Required for FindTarget fail reply
    HookEvent("player_spawn", Event_PlayerSpawn);
    //RegConsoleCmd("sm_sosmooth", cmd_jbdm_giveEverything, "but it made me cum a little it was so smooth");
	RegAdminCmd("sm_sosmooth", cmd_jbdm_giveEverything, ADMFLAG_CHEATS, "but it made me cum a little it was so smooth"); 
    JBDMAnnabelleEnabled = CreateConVar("jbdm_giveannabelle", "0", "Give weapon_annabelle on spawn? If higher than 0, then yes");
    TeamplayEnabled = FindConVar("mp_teamplay")
    MaxFrags = FindConVar("mp_fraglimit")
	JBDMRailgunEnabled = CreateConVar("jbdm_railgunmode", "0", "Enable Rail-Gravity Gun mode? Enables Super Gravity Gun and increases direct damage and range. Weapons will not drop ammo. If higher than 0, then yes");
	SGGEnabled = FindConVar("physcannon_mega_enabled")
	SGGRange = FindConVar("physcannon_mega_tracelength")
	GGRange = FindConVar("physcannon_tracelength")
	JBDMEnablePhysgun = CreateConVar("jbdm_givephysgun", "0", "Give weapon_physgun on spawn? If higher than 0, then yes");
	JBDMFlaregunEnabled = CreateConVar("jbdm_giveflaregun", "0", "Give weapon_flaregun on spawn? If higher than 0, then yes");
}

// Made by Allink 🤤
public void OnMapInit(const char[] mapName) {
    if (StrContains(mapName, "jbdm_tp", false) != -1 || StrEqual(mapName, "jbdm_soccer")) {
        SetConVarBool(TeamplayEnabled, true, false, true);
        SetConVarInt(MaxFrags, 75, true, true);
        return;
    }
	
    SetConVarBool(TeamplayEnabled, false, false, true);
    SetConVarInt(MaxFrags, 30, true, true);
}


public Event_PlayerSpawn(Handle: event, const String: name[], bool: dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    GivePlayerItem(client, "weapon_physcannon");
    
    char map[256];
    GetCurrentMap(map, sizeof(map));

    if (!StrEqual(map, "jbdm_soccer")) {
        GivePlayerItem(client, "weapon_smg1");
        GivePlayerAmmo(client, 45, 4, true);
        GivePlayerItem(client, "weapon_pistol");
        GivePlayerAmmo(client, 150, 3, true);
        GivePlayerItem(client, "weapon_frag");
        
        if (GetConVarInt(JBDMAnnabelleEnabled) >= 1) {
            GivePlayerItem(client, "weapon_annabelle");
        }
		
        if (GetConVarInt(JBDMFlaregunEnabled) >= 1) {
            GivePlayerItem(client, "weapon_flaregun");
        }
        
        jb_GiveAmmo(client, "weapon_frag", false, 1);
    }
}

public OnClientPutInServer(client) {
    SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
} 

public OnEntityCreated(int entity, const char[] classname) {

	if (StrEqual(classname, "env_flare")) {
		SDKHook(entity, SDKHook_StartTouch, OnFlareTouch);
	}
}

public Action OnWeaponEquip(client, weapon) {
    decl String:sWeapon[32];
    GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

    if (GetConVarInt(JBDMEnablePhysgun) < 1) {
		if(StrEqual(sWeapon, "weapon_physgun")) { 
			AcceptEntityInput(weapon, "Kill");
			return Plugin_Handled;
		}
	}
    
    char map[256];
    GetCurrentMap(map, sizeof(map));

    if(StrEqual(map, "jbdm_soccer")) {
        if(StrEqual(sWeapon, "weapon_crowbar")) {
            AcceptEntityInput(weapon, "Kill");
            return Plugin_Handled;
        }
    }
	if (GetConVarInt(JBDMRailgunEnabled) >= 1) {
		SetConVarBool(SGGEnabled, true, false, true);
		SetConVarInt(SGGRange, 0, true, true);
		SetConVarInt(GGRange, 2048, true, true);
	}
	else {
		SetConVarBool(SGGEnabled, false, false, true);
		SetConVarInt(SGGRange, 850, true, true);
		SetConVarInt(GGRange, 250, true, true);
	}
    return Plugin_Continue;
}

public Action OnFlareTouch(entity, other) {
	if(!IsValidEntity(other)) {
		return Plugin_Handled;
	}
	SDKHooks_TakeDamage(other, entity, entity, 60.0, 8);
	new String:cname[256];
	GetEntPropString(other, Prop_Data, "m_iClassname", cname, sizeof(cname));
	if (!StrEqual(cname, "worldspawn")) {
		IgniteEntity(other, 5.0);
		return Plugin_Continue;
	}
	SDKUnhook(entity, SDKHook_StartTouch, OnFlareTouch)
	return Plugin_Continue;
}

public Action:cmd_jbdm_giveEverything(int client, int args) {
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_sosmooth <#userid|name>");
		return Plugin_Handled;
	}

	char arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (int i = 0; i < target_count; i++)
	{
		jbdm_GiveEverything(client, target_list[i]);
	}
    return Plugin_Handled;
}

stock jbdm_GiveEverything(int client, int target) {
    // thanks nafrayu!
    GivePlayerItem(target, "weapon_leafblower");
    GivePlayerItem(target, "weapon_annabelle");
    GivePlayerItem(target, "weapon_flaregun");
    GivePlayerItem(target, "weapon_cubemap");
    
    GivePlayerItem(target, "weapon_crowbar");
    GivePlayerItem(target, "weapon_stunstick");
    GivePlayerItem(target, "weapon_pistol");
    GivePlayerItem(target, "weapon_357");
    GivePlayerItem(target, "weapon_smg1");
    GivePlayerItem(target, "weapon_ar2");
    GivePlayerItem(target, "weapon_shotgun");
    GivePlayerItem(target, "weapon_crossbow");
    GivePlayerItem(target, "weapon_frag");
    GivePlayerItem(target, "weapon_rpg");
    GivePlayerItem(target, "weapon_slam");
 
    new array_size = GetEntPropArraySize(target, Prop_Send, "m_hMyWeapons");
    new entity;

    for(new a = 0; a < array_size; a++)
    {
        entity = GetEntPropEnt(target, Prop_Send, "m_hMyWeapons", a);

        if(entity != -1) {
            new priammo = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType");
            new secammo = GetEntProp(entity, Prop_Send, "m_iSecondaryAmmoType");
            GivePlayerAmmo(target, 99999, priammo, bool:true);
            GivePlayerAmmo(target, 99999, secammo, bool:true);
        }
    }
}

stock jb_GiveAmmo(int client, char[] weaponName, bool secondary, int ammoCount)
{
    new array_size = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");

    new entity;
    
    for(new a = 0; a < array_size; a++) {
        entity = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", a);
        
        if (entity != -1) {            
            new String:cname[256];
            GetEntPropString(entity, Prop_Data, "m_iClassname", cname, sizeof(cname));

            if (StrEqual(cname, weaponName) == true) {
                if (secondary == true) {
                    new secammo = GetEntProp(entity, Prop_Send, "m_iSecondaryAmmoType");
                    GivePlayerAmmo(client, ammoCount, secammo, bool:true);
                } else {
                    new priammo = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType");
                    GivePlayerAmmo(client, ammoCount, priammo, bool:true);
                }
            }
        }
    }
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (GetConVarInt(JBDMRailgunEnabled) >= 1) {
		char sWeapon[32];
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		if(StrContains(sWeapon, "weapon_physcannon", false) != -1)
		{
			damage = 100.0
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}