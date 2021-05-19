/*
 * =============================================================================
 * File:		  fire_custom
 * Type:		  Base
 * Description:   Plugin's base file.
 *
 * Copyright (C)   Anubis Edition. All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 */
#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#pragma newdecls required

// Silly gibberish
#define FOLDER "particles/"

#define PLUGIN_NAME           "Custom fire particle system evildoer"
#define PLUGIN_AUTHOR         "Chester the Cheetah, Anubis Edition"
#define PLUGIN_DESCRIPTION    "Precachescustom fire particles to make the server look fancy."
#define PLUGIN_VERSION        "1.3"
#define PLUGIN_URL            "https://github.com/Stewart-Anubis"

// Cvar bullshit
ConVar g_cCvar_CustomFireIgnite = null;
ConVar g_cCvar_CustomFireInferno = null;

bool g_bLateLoad = true;
bool g_bIgniteLoad = false;
bool g_bInfernoLoad = false;

char g_sIgniteName[128];
char g_sInfernoName[128];

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public void OnPluginStart()
{ 
	HookEvent("round_start", OnRoundStart);

	g_cCvar_CustomFireIgnite = CreateConVar("sm_fire_ignite_name", "burning_fx_sblue", "Defines the particle system file to be used for the ignite particles.");
	g_cCvar_CustomFireInferno = CreateConVar("sm_fire_inferno_name", "inferno_fx_alt", "Defines the particle system file to be used for the inferno particles.");

	// Hook cvar changes. The particles must be precached before they're active, so the safest bet is at round start

	g_cCvar_CustomFireIgnite.AddChangeHook(OnConVarChanged);
	g_cCvar_CustomFireInferno.AddChangeHook(OnConVarChanged);

	if(g_bLateLoad)
	{
		g_bLateLoad = false;
		OnMapStart();
	}
}

public void OnConVarChanged(ConVar CVar, const char[] oldVal, const char[] newVal)
{
	if (CVar == g_cCvar_CustomFireIgnite)
	{
		g_cCvar_CustomFireIgnite.GetString(g_sIgniteName, sizeof(g_sIgniteName));
		PrintToChatAll(" \x01 Ignite particle system changed from '%s' to '%s'. Changes will be applied next round. ", oldVal, newVal);
		g_bIgniteLoad = true;
	}
	if (CVar == g_cCvar_CustomFireInferno)
	{
		g_cCvar_CustomFireInferno.GetString(g_sInfernoName, sizeof(g_sInfernoName));
		PrintToChatAll(" \x01 Inferno particle system changed from '%s' to '%s'. Changes will be applied next round. ", oldVal, newVal);
		g_bInfernoLoad = true;
	}

}

public Action OnRoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if(g_bIgniteLoad)
	{
		loadIgnite();
	}

	if(g_bInfernoLoad)
	{
		loadInferno();
	}
}

public void OnMapStart()
{
	// Load both when the map starts
	loadIgnite();
	loadInferno();
}

public void loadIgnite()
{
	char igniteSystem[PLATFORM_MAX_PATH];

	FormatEx(igniteSystem, sizeof(igniteSystem), "%s%s.pcf", FOLDER, g_sIgniteName);

	if(FileExists(igniteSystem))
	{
		AddFileToDownloadsTable(igniteSystem);
		PrecacheGeneric(igniteSystem, true);
	}	
}

public void loadInferno()
{
	char infernoSystem[PLATFORM_MAX_PATH];

	FormatEx(infernoSystem, sizeof(infernoSystem), "%s%s.pcf", FOLDER, g_sInfernoName);

	if(FileExists(infernoSystem))
	{
		AddFileToDownloadsTable(infernoSystem);
		PrecacheGeneric(infernoSystem, true);
	}	
}
