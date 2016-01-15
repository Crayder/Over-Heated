#if defined Over_Heated_Credits

Welcome to the Craytive Craydonation! (Creative Cray-Nation :P)

Description:
					This script was designed for DM/TDM servers, well, the ones
				concerned about overuse of sparrows and sparrow abuse. It slowly
				destroys sparrow when the weapon is shot too much! It places a
				bar at the bottom of the screen when you enter the seasparrow.
				The more you shoot, the higher the bar goes, starts at green,
				then yellow, then red until it fills up. When it fills up, it
				takes longer to cool down so good luck to anyone dumb enough to
				push their limits! Thats all really, but if you would like to
				steal my key holding script that is included, go ahead, just
				credit me. Stealing this whole script is however another story.
				DON'T RE-PUBLISH THIS SCRIPT!
				
				P.S. - This script has not been fully tested, therefore it's
					titled (BETA Version 1.1).

Development Log:
				Wednesday, July 05, 2014; 7:31 PM | Eastern Time Zone (-5:00)
					- First release, no known bugs or fixes.

Special Thanks:
				Crayder(Me), for this script.
				Kalcor and dev team, SA:MP.
				Y-Less, foreach.
				Southclaw, his progress bars include.

#else

//	 __________/*==============*\___________
//	/__________Over Heated Script_________/
//			   \*==============*/

#endif

/*==============[Options]===============*/
#define DAMAGE_FIRE			62.6	// Damage done when firing while overheated.
#define DAMAGE_COOL			15.65	// Damage done when cooling while overheated.

#define DEATH_HEIGHT		true	// Destroy Sparrows when flying too high.
#define HEIGHT_MEDIUM		600.0	// Height at which damage will be begin being dealt.
#define HEIGHT_HIGH			750.0	// Height at which more damage will be begin being dealt.
#define HEIGHT_M_DAMAGE		0.5		// Damage done when flying above HEIGHT_MEDIUM.
#define HEIGHT_H_DAMAGE		5.0		// Damage done when flying above HEIGHT_HIGH.

#define DEATH_TAIL			false	// Destroy Sparrows by shooting their tail rotor.
/*======================================*/

#define FILTERSCRIPT

#include <a_samp>
#include <progress2>
#include <YSI\y_iterate>

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define GPKHOLDING(%0) (keys & (%0))

new pVehicle[MAX_PLAYERS],
	PlayerBar:SparrowHeatBar[MAX_PLAYERS],
	PlayerBar:SparrowHeightBar[MAX_PLAYERS],
	bool:HoldingKey[MAX_PLAYERS],
	SparrowHeat[MAX_VEHICLES],
	bool:CoolingSparrow[MAX_VEHICLES],
	SparrowCoolingTimer[MAX_VEHICLES],
	bool:IsInSparrow[MAX_PLAYERS];

new RGY[100] = {
	0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,
	0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x00FF00FF,0x03FF00FF,0x07FF00FF,
	0x0BFF00FF,0x0EFF00FF,0x12FF00FF,0x16FF00FF,0x19FF00FF,0x1DFF00FF,0x21FF00FF,0x25FF00FF,0x28FF00FF,0x2CFF00FF,
	0x30FF00FF,0x33FF00FF,0x37FF00FF,0x3BFF00FF,0x3FFF00FF,0x42FF00FF,0x46FF00FF,0x4AFF00FF,0x4DFF00FF,0x51FF00FF,
	0x55FF00FF,0x58FF00FF,0x5CFF00FF,0x60FF00FF,0x64FF00FF,0x67FF00FF,0x6BFF00FF,0x6FFF00FF,0x72FF00FF,0x76FF00FF,
	0x7AFF00FF,0x7EFF00FF,0x81FF00FF,0x85FF00FF,0x89FF00FF,0x8DFF00FF,0x91FF00FF,0x95FF00FF,0x99FF00FF,0x9DFF00FF,
	0xA1FF00FF,0xA5FF00FF,0xA9FF00FF,0xADFF00FF,0xB1FF00FF,0xB5FF00FF,0xB9FF00FF,0xBDFF00FF,0xC1FF00FF,0xC5FF00FF,
	0xC9FF00FF,0xCDFF00FF,0xD1FF00FF,0xD5FF00FF,0xD9FF00FF,0xDEFF00FF,0xE2FF00FF,0xE6FF00FF,0xEAFF00FF,0xEEFF00FF,
	0xF2FF00FF,0xF6FF00FF,0xFAFF00FF,0xFFFF00FF,0xFFEF00FF,0xFFDF00FF,0xFFCF00FF,0xFFBF00FF,0xFFAF00FF,0xFF9F00FF,
	0xFF8F00FF,0xFF7F00FF,0xFF6F00FF,0xFF5F00FF,0xFF4F00FF,0xFF3F00FF,0xFF2F00FF,0xFF1F00FF,0xFF0F00FF,0xFF0000FF
};

public OnFilterScriptExit()
{
	foreach(new playerid : Player) {
		if(HidePlayerProgressBar(playerid, SparrowHeatBar[playerid])) {
			DestroyPlayerProgressBar(playerid, SparrowHeatBar[playerid]);
			IsInSparrow[playerid] = false;
		}
		
		#if DEATH_HEIGHT
		if(HidePlayerProgressBar(playerid, SparrowHeightBar[playerid]))
			DestroyPlayerProgressBar(playerid, SparrowHeightBar[playerid]);
		#endif
		
		pVehicle[playerid] = INVALID_VEHICLE_ID;
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER) {
		new vehicleid = GetPlayerVehicleID(playerid);
		
		if(GetVehicleModel(vehicleid) == 447) {
			IsInSparrow[playerid] = true;
		
			SparrowHeatBar[playerid] = CreatePlayerProgressBar(playerid, 157.000000, 423.000000, 12.000000, 86.000000, RGY[0], 100.000000, BAR_DIRECTION_UP);
			ShowPlayerProgressBar(playerid, SparrowHeatBar[playerid]);
			
			#if DEATH_HEIGHT
			SparrowHeightBar[playerid] = CreatePlayerProgressBar(playerid, 33.000000, 423.000000, 12.000000, 86.000000, RGY[0], HEIGHT_HIGH, BAR_DIRECTION_UP);
			ShowPlayerProgressBar(playerid, SparrowHeightBar[playerid]);
			#endif
			
			if(SparrowHeat[vehicleid] > 0) {
				KillTimer(SparrowCoolingTimer[vehicleid]);
				SparrowCoolingTimer[vehicleid] = SetTimerEx("CoolSparrowHeat", 500, false, "i", vehicleid, playerid);
				CoolingSparrow[vehicleid] = true;
			}
		}
		
		pVehicle[playerid] = vehicleid;
	}
	else {
		if(HidePlayerProgressBar(playerid, SparrowHeatBar[playerid])) {
			DestroyPlayerProgressBar(playerid, SparrowHeatBar[playerid]);
			IsInSparrow[playerid] = false;
		}
		
		#if DEATH_HEIGHT
		if(HidePlayerProgressBar(playerid, SparrowHeightBar[playerid]))
			DestroyPlayerProgressBar(playerid, SparrowHeightBar[playerid]);
		#endif
		
		pVehicle[playerid] = INVALID_VEHICLE_ID;
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	SparrowHeat[vehicleid] = 0;
	CoolingSparrow[vehicleid] = false;
	KillTimer(SparrowCoolingTimer[vehicleid]);
	
	foreach(new i : Player) if(pVehicle[i] == vehicleid) 
		pVehicle[i] = INVALID_VEHICLE_ID;
		break;
	}
	return 1;
}

SetSparrowHeatBarLevel(playerid)
{
	SetPlayerProgressBarValue(playerid, SparrowHeatBar[playerid], float(SparrowHeat[pVehicle[playerid]]));
	SetPlayerProgressBarColour(playerid, SparrowHeatBar[playerid], RGY[SparrowHeat[pVehicle[playerid]] - 1]);
	return UpdatePlayerProgressBar(playerid, SparrowHeatBar[playerid]);
}

forward OnPlayerHoldingKey(playerid, key);
public OnPlayerHoldingKey(playerid, key)
{
	KillTimer(SparrowCoolingTimer[pVehicle[playerid]]);
	CoolingSparrow[pVehicle[playerid]] = false;
	if(key == KEY_ACTION && IsInSparrow[playerid]) {
		SparrowHeat[pVehicle[playerid]]++;
		if(SparrowHeat[pVehicle[playerid]] >= 100 && SparrowHeat[pVehicle[playerid]] % 25 == 0) {
			new Float:H; GetVehicleHealth(pVehicle[playerid], H);
			SetVehicleHealth(pVehicle[playerid], H - DAMAGE_FIRE);
		}
		SetSparrowHeatBarLevel(playerid);
	}
	return 1;
}

forward OnPlayerStopHoldingKey(playerid, key);
public OnPlayerStopHoldingKey(playerid, key)
{
	if(key == KEY_ACTION && IsInSparrow[playerid]) {
		SparrowCoolingTimer[pVehicle[playerid]] = SetTimerEx("CoolSparrowHeat", 500, false, "iu", pVehicle[playerid], playerid);
	}
	return 1;
}

forward CoolSparrowHeat(vehicleid, playerid);
public CoolSparrowHeat(vehicleid, playerid)
{
	if(SparrowHeat[vehicleid]-1 < 0)
		SparrowHeat[vehicleid] = 0;
	else
		SparrowHeat[vehicleid]--;
	
	if(SparrowHeat[vehicleid] > 0) {
		SparrowCoolingTimer[vehicleid] = SetTimerEx("CoolSparrowHeat", 500, false, "i", vehicleid, playerid);
		CoolingSparrow[vehicleid] = true;
	}
	if(SparrowHeat[vehicleid] > 100) {
		new Float:H;
		GetVehicleHealth(vehicleid, H);
		SetVehicleHealth(vehicleid, ((SparrowHeat[vehicleid] >= 200) ? 0.0 : H - DAMAGE_COOL));
	}
	else if(SparrowHeat[vehicleid] <= 0)
		CoolingSparrow[vehicleid] = false;
		
	SetSparrowHeatBarLevel(playerid);
}

forward IsPlayerHoldingKey(playerid, key);
public IsPlayerHoldingKey(playerid, key)
{
	new keys, ud, lr;
	GetPlayerKeys(playerid, keys, ud, lr);

	if(GPKHOLDING(key)) {
		HoldingKey[playerid] = true;
		CallLocalFunction("OnPlayerHoldingKey", "ui", playerid, key);
		SetTimerEx("IsPlayerHoldingKey", 50, false, "ui", playerid, key);
	}
	else {
		HoldingKey[playerid] = false;
		CallLocalFunction("OnPlayerStopHoldingKey", "ui", playerid, key);
	}
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_ACTION))
		return SetTimerEx("IsPlayerHoldingKey", 50, false, "ui", playerid, KEY_ACTION);
	
	return 1;
}

#if DEATH_HEIGHT

public OnPlayerUpdate(playerid)
{
	if(IsInSparrow[playerid]) {
		new Float:Z, Float:H; 
		GetVehiclePos(pVehicle[playerid], Z, Z, Z);
		GetVehicleHealth(pVehicle[playerid], H);
		
		H = (Z >= HEIGHT_HIGH) ? H - HEIGHT_H_DAMAGE : (Z >= HEIGHT_MEDIUM) ? H - HEIGHT_M_DAMAGE : H;
		SetVehicleHealth(pVehicle[playerid], (H < 0.0 ? 0.0 : H));
		
		SetPlayerProgressBarValue(playerid, SparrowHeightBar[playerid], Z);
		SetPlayerProgressBarColour(playerid, SparrowHeightBar[playerid], RGY[floatround((Z / HEIGHT_HIGH) * 100) - 1]);
		UpdatePlayerProgressBar(playerid, SparrowHeightBar[playerid]);
	}
	return 1;
}

#endif

//****************

#if defined Sparrow_Tail_Credits

Description:
					This script was designed for DM/TDM servers, well, the ones
				concerned about overuse of sparrows and sparrow abuse. It
				instantly destroys the sparrow when the tail rotor is shot!
				Stealing this whole script is prohibited.
				DON'T RE-PUBLISH THIS SCRIPT!

				P.S. - This script has not been fully tested, therefore it's
					titled (BETA Version 1.1).

Development Log:
				Wednesday, July 05, 2014; 7:31 PM | Eastern Time Zone (-5:00)
					- First release, no known bugs or fixes.

Special Thanks:
				Crayder(Me), for this script.
				Kalcor and dev team, SA:MP.
				Y-Less, foreach.
				Southclaw, his progress bars include.

#else

//	 _________/*===============*\___________
//	/_________Sparrow Tail Script_________/
//			  \*===============*/

#endif

#if DEATH_TAIL

new Float:SparrowTail[3] = {0.00, -6.50, 0.74};

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(	hittype == BULLET_HIT_TYPE_VEHICLE &&
		GetVehicleModel(hitid) == 447 &&
		fX >= SparrowTail[0] - 0.91 && fX <= SparrowTail[0] + 0.91 &&
		fY >= SparrowTail[1] - 0.91 && fY <= SparrowTail[1] + 0.91 &&
		fZ >= SparrowTail[2] - 0.92 && fZ <= SparrowTail[2] + 0.92)
		SetVehicleHealth(hitid, 0);
	
	return 1;
}

#endif
