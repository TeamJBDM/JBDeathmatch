#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_functions>
#include <convars>

public Plugin myinfo =
{
    name = "JBMod Deathmatch (JBDM)",
    author = "stressedcatinabox, nafrayu, allinkdev",
    description = "Gives the pistol, gravity gun, grenades, and smg to players when they spawn in, as well as removing the physgun from them. Made for JBMod Deathmatch servers.\nHas some unique functions too, such as railgun mode, teamplay stuff, weapon_flaregun as a usable weapon, and the Annabelle . . . :fear:\nHappy fragging! :D",
    version = "1.4.1",
    url = "https://discord.gg/P6ZwJvCsG8"
}

new Handle:JBDMAnnabelleEnabled;
new Handle:TeamplayEnabled;
new Handle:MaxFrags;
new Handle:JBDMRailgunEnabled;
new Handle:SGGEnabled;
new Handle:SGGRange;
new Handle:GGRange;
new Handle:JBDMEnablePhysgun;
new Handle:JBDMFlaregunEnabled;
new Handle:JBDMTeamplayOverride;
new Handle:JBDMFlaregunDamage;

/// [PURPOSE:] Set up hook events and convars n stuff...
public void OnPluginStart()
{
    PrintToServer("Let's get fragging! Started the JBMod Deathmatch plugin successfully!");
    LoadTranslations("common.phrases.txt"); // Required for FindTarget fail reply
    HookEvent("player_spawn", Event_PlayerSpawn);
    //RegConsoleCmd("sm_sosmooth", cmd_jbdm_giveEverything, "but it made me cum a little it was so smooth");
	RegAdminCmd("sm_sosmooth", cmd_jbdm_giveEverything, ADMFLAG_CHEATS, "but it made me cum a little it was so smooth"); 
    JBDMAnnabelleEnabled = CreateConVar("jbdm_giveannabelle", "0", "Give weapon_annabelle on spawn? If 1 or higher, then yes");
    TeamplayEnabled = FindConVar("mp_teamplay")
    MaxFrags = FindConVar("mp_fraglimit")
	JBDMRailgunEnabled = CreateConVar("jbdm_railgunmode", "0", "Enable Rail-Gravity Gun mode? Enables Super Gravity Gun and increases direct damage and range. Weapons will not drop on death. If 1 or higher, then yes");
	SGGEnabled = FindConVar("physcannon_mega_enabled")
	SGGRange = FindConVar("physcannon_mega_tracelength")
	GGRange = FindConVar("physcannon_tracelength")
	JBDMEnablePhysgun = CreateConVar("jbdm_givephysgun", "0", "Give weapon_physgun on spawn? If 1 or higher, then yes");
	JBDMFlaregunEnabled = CreateConVar("jbdm_giveflaregun", "0", "Give weapon_flaregun on spawn? If 1 or higher, then yes (KINDA BROKEN RIGHT NOW, CAUSES CRASHES ON CONTACT WITH A FEW BRUSH ENTITIES)");
	JBDMTeamplayOverride = CreateConVar("jbdm_teamplayoverride", "0", "Force teamplay to enable? If 1 or higher, then yes (Doesn't affect mp_fraglimit)\nONLY UPDATES AFTER MAP CHANGES!!!");
	JBDMFlaregunDamage = CreateConVar("jbdm_plr_dmg_flare", "60.0", "Contact damage for flaregun flares (60 by default)", true);
}

/// Made by Allink 🤤
/// [PURPOSE:] Handle teamplay functionality. Automatically enables mp_teamplay and change mp_fraglimit to 75 if the server's on a JBDM teamplay map
public void OnMapInit(const char[] mapName) {
    if (StrContains(mapName, "jbdm_tp", false) != -1 || StrEqual(mapName, "jbdm_soccer") || (GetConVarInt(JBDMTeamplayOverride) >= 1)) {
        SetConVarBool(TeamplayEnabled, true, false, true);
		if (GetConVarInt(JBDMTeamplayOverride) < 1) {
		SetConVarInt(MaxFrags, 75, true, true);
		}
        return;
    }
	
    SetConVarBool(TeamplayEnabled, false, false, true);
    SetConVarInt(MaxFrags, 30, true, true);
}

/// [PURPOSE:] Do stuff when the player spawns in and respawns
public Event_PlayerSpawn(Handle: event, const String: name[], bool: dontBroadcast) {
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
	/// Thanks nafrayu!
	SetVariantInt(0);
	AcceptEntityInput(client, "IgniteLifetime", -1, -1, -1);
	///
		
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
		PrintToConsoleAll("hooked flaregun");
	}
	if (StrContains(classname, "item_health") != -1) {
		SDKHook(entity, SDKHook_StartTouch, OnHealingTouch);
		PrintToConsoleAll("hooked medkit");
	}
}

/// [PURPOSE:] Removes weapons from the player (physgun, crowbar*) and activate railgun settings
public Action OnWeaponEquip(client, weapon) {
    decl String:sWeapon[32];
    GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

/// [PURPOSE:] Unless physgun is allowed to spawn, KILL IT WITH HAMMERZ...
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

/// [PURPOSE:] Touching an env_flare (which is usually shot out by weapon_flaregun) will damage and ignite certain things.
/// These certain things are: Players, physics props, func_breakable specifically, and NPC's
/// The damage dealt by contact with the flare is configurable, but set to 60.0 by default.
/// Victims will be ignited for 5 seconds upon contact, too.
/// entity is the env_flare
/// other is the thing that entity touched
public Action OnFlareTouch(entity, other) {
    new String:cname[256];
    GetEntPropString(other, Prop_Data, "m_iClassname", cname, sizeof(cname));

    if(!IsValidEntity(other)) {
        return Plugin_Continue;
    }
	
    if (StrEqual(cname, "player") || StrContains(cname, "prop_physics") != -1 || StrEqual(cname, "func_breakable") || StrContains(cname, "npc_") != -1) {
        SDKHooks_TakeDamage(other, entity, entity, GetConVarFloat(JBDMFlaregunDamage), 8);
        IgniteEntity(other, 5.0);
		AcceptEntityInput(entity, "kill")
        return Plugin_Continue;
    }
	
    return Plugin_Continue;
}

/// [PURPOSE:] Touching a healthkit or healthvial will extinguish the player.
/// entity is the healthkit/healthvial
/// other is the thing that entity touched
public Action OnHealingTouch(entity, other) {
	if(!IsValidEntity(other)) {
		return Plugin_Continue;
	}
	new String:cname[256];
	GetEntPropString(other, Prop_Data, "m_iClassname", cname, sizeof(cname));
	if (StrEqual(cname, "player")) {
		SetVariantInt(0);
		AcceptEntityInput(other, "IgniteLifetime", -1, -1, -1);
		
		return Plugin_Continue;
	}
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
    /// thanks nafrayu!
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

/// [PURPOSE:] ONLY IF railgun mode is enabled, override damage done to things if the attacker is holding the gravity gun. Else, change nothing.
/// I just realized this doesn't check if the INFLICTOR is weapon_physcannon, just that the attacker has it equipped... erm what the flip!!
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