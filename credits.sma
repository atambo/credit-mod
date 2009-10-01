#define VER "1.0.4"
//Amount of credits new players get
#define numnewcredits 4
//Time Per Credit (in seconds)
#define credittime 900
//How much the passive upgrades cost
#define armorcost 1
#define hpcost 1
#define speedcost 1
#define gravitycost 1
#define stealthcost 1
#define multijumpcost 1
//How much the passive upgrades adds
#define armorperbuy 10
#define hpperbuy 10
#define speedperbuy 20
//eg. 0.05 it will take off 5% of the users gravity
#define gravityperbuy 0.1
//eg. (stealthperbuy = 60) times (stealthmaxlvl = 3) = 180 // the value must be lower than the defaultstealth
#define defaultstealth 200
#define stealthperbuy 20
//How much the passive upgrades Max Level
#define armormaxlvl 5
#define hpmaxlvl 10
#define speedmaxlvl 5
#define gravitymaxlvl 6
#define stealthmaxlvl 7
#define multijumpmaxlvl 5
//Item Upgrades
//max items
#define maxitems 6
//max credits spent per map
#define maxcredits 15
//First Aid Regeneration
#define regenerationrate 4.5
// health regeneration points
#define hpregenp 5
// armor regeneration points
#define apregenp 8
// First Aid cost
#define regenerationcost 1
//Battle Aura cost
#define hpscost 1
//Weapon Training cost
#define weapontrainingcost 2
//Jump Module cost
#define jumpmodulecost 1
//Climb Gear cost
#define climbgearcost 1
//Promotion cost
#define promocost 1
//Unlimited Ammo cost
#define unlacost 1
//Stealth Shoe cost
#define sshoecost 1
//C4 Wired Explosives
#define BOMBKILL_RANGE 350
#define wiredc4ecost 1
//E.S.P cost
#define espcost 2
//Laser Pointer
#define lasercost 1
//Super Grenade cost
#define sgrencost 1
//Crowbar cost
#define crowbarcost 1
//Flash Protection
#define flashcost 1
#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <cstrike>
#include <fun>
#include <vault>
#define BOMB_TASK 1234
new connecttime[33]
new lastplaytime[33]
new creditsspent[33]
new Armor[33]
new Health[33]
new Speed[33]
new Gravity[33]
new Stealth[33]
new hpstlr[33]
new regeneration[33]
new weapontraining[33]
new jumpmodule[33]
new climb[33]
new promotion[33]
new gHasuammo[33]
new sshoe[33]
new wired[33]
new esp[33]
new laser[33]
new sgrenade[33]
new crowbar[33]
new flash[33]
new multijump[33]
new jumpnum[33]
new itemcap[33]
new bool:dojump[33] = false
new bool:speed = true
new hudmsg[512]
new smoke, white, fire
public plugin_init()
{
	register_plugin("Credit Mod", VER, "atambo")
	register_cvar("amx_upgrades", "1")
	register_menu("Main Upgrades Menu", 1023, "MainMenuCommand")
	register_menu("Buy Credit Menu", 1023, "BuyMenu")
	register_menu("Passive Upgrade Menu", 1023, "actionMenu")
	register_menu("Item Upgrade Menu", 1023, "EUAMenu")
	register_menu("Item 2 Upgrade Menu", 1023, "EUA2Menu")
	register_clcmd("say", "handlesay")
	register_clcmd("say_team", "handlesay")
	register_clcmd("upgrade", "MainUpgradesMenu")
	register_concmd("amx_querycredits","queryall",ADMIN_CVAR," -displays <name> <credits>")
	register_concmd("amx_givecredits","givecredit",ADMIN_BAN," <name or #userid> <credits>")
	register_concmd("amx_removecredits","removecredit",ADMIN_BAN," <name or #userid> <credits>")
	register_event("ResetHUD","newRound","be")
	register_event("StatusValue","show_status","bd","1=2")
	register_event("DeathMsg", "death_event", "a")
	register_event("CurWeapon","update","be","1=1")
	register_event("Damage", "Event_Damage", "be", "2!0")
	register_event("ScreenFade","flashcheck","be","4=255","5=255","6=255","7>199")
	server_cmd("sv_maxspeed 1500")
}

public client_connected_msg(id)
{
	client_print(id, print_chat, "[AMXX] This server is running Credit Mod Version [%s]", VER)
	client_print(id, print_chat, "type /credits in chat to show your credits and /buy to spend them", VER)
}

public client_putinserver(id) 
{
	if(get_cvar_num("amx_upgrades") == 1)
		set_task(20.0, "client_connected_msg", id)
}

public flashcheck(id)
{
	if(flash[id] > 0)
	{
		message_begin(MSG_ONE,get_user_msgid("ScreenFade"),{0,0,0},id)
		write_short(~0)
		write_short(~0)
		write_short(1<<12)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		write_byte(0)
		message_end()
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public newRound(id)
{
	if(get_cvar_num("amx_upgrades") == 0)
	{
		itemcap[id] = 0
		Armor[id] = 0
		Health[id] = 0
		Speed[id] = 0
		Gravity[id] = 0
		Stealth[id] = 0
		hpstlr[id] = 0
		regeneration[id] = 0
		weapontraining[id] = 0
		jumpmodule[id] = 0
		climb[id] = 0
		promotion[id] = 0
		gHasuammo[id] = 0
		sshoe[id] = 0
		wired[id] = 0
		esp[id] = 0
		laser[id] = 0
		sgrenade[id] = 0
		crowbar[id] = 0
		creditsspent[id] = 0
		flash[id] = 0
		jumpnum[id] = 0
		multijump[id] = 0
		set_user_footsteps(id, 0)
		set_user_rendering(id,kRenderFxNone,0,0,0,kRenderNormal,0)
		return PLUGIN_CONTINUE
	}
	else
	{
		if(is_user_alive(id))
		{
			if(Armor[id] > 0)
			{
				new iap = (Armor[id] * armorperbuy)
				set_user_armor(id, 100 + iap)
			}
			if(Health[id] > 0)
			{
				new ihp = (Health[id] * hpperbuy)
				set_user_health(id, 100 + ihp)
			}
			if(promotion[id] > 0)
				cs_set_user_money(id, cs_get_user_money(id) * 2, 1)
			if(esp[id] > 0)
				set_task(3.0, "esploop", id, "", 0, "b")
			if(climb[id] > 0)
				set_task(0.1, "cwall", id, "", 0, "b")
			if(regeneration[id] > 0)
				firstaid(id)
			if(sgrenade[id] > 0)
			{
				sgrenade[id] = 0
				itemcap[id]--
			}
			if(wired[id] > 0)
			{
				wired[id] = 0
				itemcap[id]--
			}
		}
		show_all_upgrades(id)
		speed = false
		set_task(get_cvar_float("mp_freezetime"), "allow_speed", 0)
	}
	return PLUGIN_CONTINUE
}

public show_status(id)
{
	if(get_cvar_num("amx_upgrades") != 1)
		return PLUGIN_CONTINUE
	new target = read_data(2)
  	if(target != id && target != 0)
  	{
		new name[32]
   		get_user_name(target, name,31)
		new len = format(hudmsg, 511, "%s's^nPassive Upgrades:^n", name)
		len += format(hudmsg[len], 511-len, "*Armor %d/%d^n*Health %d/%d^n*Speed %d/%d^n*Gravity %d/%d^n*Stealth %d/%d^n*MultiJump %d/%d^n", Armor[target], armormaxlvl, Health[target], hpmaxlvl, Speed[target], speedmaxlvl, Gravity[target], gravitymaxlvl, Stealth[target], stealthmaxlvl, multijump[target], multijumpmaxlvl)
		len += format(hudmsg[len], 511-len, "^nItem Upgrades:^n")
		if(hpstlr[target] > 0) len += format(hudmsg[len], 511-len, "Battle Aura^n")
		if(regeneration[target] > 0) len += format(hudmsg[len], 511-len, "First Aid^n")
		if(weapontraining[target] > 0) len += format(hudmsg[len], 511-len, "Weapon Training^n")
		if(jumpmodule[target] > 0) len += format(hudmsg[len], 511-len, "Jump Module^n")
		if(climb[target] > 0) len += format(hudmsg[len], 511-len, "Climbing Gear^n")
		if(promotion[target] > 0) len += format(hudmsg[len], 511-len, "Promotion^n")
		if(gHasuammo[target] > 0) len += format(hudmsg[len], 511-len, "Unlimited Ammo^n")
		if(sshoe[target] > 0) len += format(hudmsg[len], 511-len, "Stealth Shoes^n")
		if(wired[target] > 0) len += format(hudmsg[len], 511-len, "Wired C4 Explosive^n")
		if(esp[target] > 0) len += format(hudmsg[len], 511-len, "E.S.P^n")
		if(laser[target] > 0) len += format(hudmsg[len], 511-len, "Laser Pointer^n")
		if(sgrenade[target] > 0) len += format(hudmsg[len], 511-len, "Super Grenade^n")
		if(crowbar[target] > 0) len += format(hudmsg[len], 511-len, "Crowbar^n")
		if(flash[target] > 0) len += format(hudmsg[len], 511-len, "Flash Protection^n")
		len += format(hudmsg[len], 511-len, "^nCredits: %i",connecttime[target]/credittime)
		set_hudmessage(255, 255, 255, 0.0, 0.2, 0, 6.0, 6.0, 0.5, 0.15, 1)
		show_hudmessage(id, hudmsg)
	}
	return PLUGIN_CONTINUE
}

public show_all_upgrades(id)
{
	new len = format(hudmsg, 511, "Passive Upgrades:^n")
	len += format(hudmsg[len], 511-len, "*Armor %d/%d^n*Health %d/%d^n*Speed %d/%d^n*Gravity %d/%d^n*Stealth %d/%d^n*MultiJump %d/%d^n", Armor[id], armormaxlvl, Health[id], hpmaxlvl, Speed[id], speedmaxlvl, Gravity[id], gravitymaxlvl, Stealth[id], stealthmaxlvl, multijump[id], multijumpmaxlvl)
	len += format(hudmsg[len], 511-len, "^nItem Upgrades:^n")
	if(hpstlr[id] > 0) len += format(hudmsg[len], 511-len, "Battle Aura^n")
	if(regeneration[id] > 0) len += format(hudmsg[len], 511-len, "First Aid^n")
	if(weapontraining[id] > 0) len += format(hudmsg[len], 511-len, "Weapon Training^n")
	if(jumpmodule[id] > 0) len += format(hudmsg[len], 511-len, "Jump Module^n")
	if(climb[id] > 0) len += format(hudmsg[len], 511-len, "Climbing Gear^n")
	if(promotion[id] > 0) len += format(hudmsg[len], 511-len, "Promotion^n")
	if(gHasuammo[id] > 0) len += format(hudmsg[len], 511-len, "Unlimited Ammo^n")
	if(sshoe[id] > 0) len += format(hudmsg[len], 511-len, "Stealth Shoes^n")
	if(wired[id] > 0) len += format(hudmsg[len], 511-len, "Wired C4 Explosive^n")
	if(esp[id] > 0) len += format(hudmsg[len], 511-len, "E.S.P^n")
	if(laser[id] > 0) len += format(hudmsg[len], 511-len, "Laser Pointer^n")
	if(sgrenade[id] > 0) len += format(hudmsg[len], 511-len, "Super Grenade^n")
	if(crowbar[id] > 0) len += format(hudmsg[len], 511-len, "Crowbar^n")
	if(flash[id] > 0) len += format(hudmsg[len], 511-len, "Flash Protection^n")
	len += format(hudmsg[len], 511-len, "^nCredits: %i",connecttime[id]/credittime)
	set_hudmessage(255, 255, 255, 0.0, 0.1, 0, 6.0, 6.0, 0.5, 0.15, 1)
	show_hudmessage(id, hudmsg)
}

public show_upgrades(id)
{
	new len = format(hudmsg, 511, "Passive Upgrades:^n")
	len += format(hudmsg[len], 511-len, "*Armor %d/%d^n*Health %d/%d^n*Speed %d/%d^n*Gravity %d/%d^n*Stealth %d/%d^n*MultiJump %d/%d", Armor[id], armormaxlvl, Health[id], hpmaxlvl, Speed[id], speedmaxlvl, Gravity[id], gravitymaxlvl, Stealth[id], stealthmaxlvl, multijump[id], multijumpmaxlvl)
	set_hudmessage(255, 255, 255, 0.0, 0.1, 0, 6.0, 6.0, 0.5, 0.15, 1)
	show_hudmessage(id, hudmsg)
}

public show_iupgrades(id)
{
	new len = format(hudmsg, 511, "Item Upgrades:^n")
	if(hpstlr[id] > 0) len += format(hudmsg[len], 511-len, "Battle Aura^n")
	if(regeneration[id] > 0) len += format(hudmsg[len], 511-len, "First Aid^n")
	if(weapontraining[id] > 0) len += format(hudmsg[len], 511-len, "Weapon Training^n")
	if(jumpmodule[id] > 0) len += format(hudmsg[len], 511-len, "Jump Module^n")
	if(climb[id] > 0) len += format(hudmsg[len], 511-len, "Climbing Gear^n")
	if(promotion[id] > 0) len += format(hudmsg[len], 511-len, "Promotion^n")
	if(gHasuammo[id] > 0) len += format(hudmsg[len], 511-len, "Unlimited Ammo^n")
	if(sshoe[id] > 0) len += format(hudmsg[len], 511-len, "Stealth Shoes^n")
	if(wired[id] > 0) len += format(hudmsg[len], 511-len, "Wired C4 Explosive^n")
	if(esp[id] > 0) len += format(hudmsg[len], 511-len, "E.S.P^n")
	if(laser[id] > 0) len += format(hudmsg[len], 511-len, "Laser Pointer^n")
	if(sgrenade[id] > 0) len += format(hudmsg[len], 511-len, "Super Grenade^n")
	if(crowbar[id] > 0) len += format(hudmsg[len], 511-len, "Crowbar^n")
	if(flash[id] > 0) len += format(hudmsg[len], 511-len, "Flash Protection^n")
	set_hudmessage(255, 255, 255, 0.0, 0.1, 0, 6.0, 6.0, 0.5, 0.15, 1)
	show_hudmessage(id, hudmsg)
}

public allow_speed()
{
	speed = true
	return PLUGIN_HANDLED
}

public death_event()
{
	new id = read_data(2)
	new enemy = read_data(1)
	remove_task(id)
	if(wired[id] > 0)
	{
		wired[id] = 0
		itemcap[id]--
	}
	if(sgrenade[enemy] > 0)
	{
		sgrenade[enemy] = 0
		itemcap[enemy]--
	}
	if(task_exists(BOMB_TASK + id))
		remove_task(BOMB_TASK + id)
	if(promotion[enemy] > 0)
		cs_set_user_money(enemy, cs_get_user_money(enemy) + 300, 1)
	return PLUGIN_CONTINUE
}

public client_disconnect(id)
{
	Armor[id] = 0
	Health[id] = 0
	Speed[id] = 0
	Gravity[id] = 0
	Stealth[id] = 0
	hpstlr[id] = 0
	regeneration[id] = 0
	weapontraining[id] = 0
	jumpmodule[id] = 0
	climb[id] = 0
	promotion[id] = 0
	gHasuammo[id] = 0
	sshoe[id] = 0
	wired[id] = 0
	esp[id] = 0
	laser[id] = 0
	sgrenade[id] = 0
	crowbar[id] = 0
	itemcap[id] = 0
	creditsspent[id] = 0
	lastplaytime[id] = 0
	flash[id] = 0
	jumpnum[id] = 0
	multijump[id] = 0
	remove_task(id)
	new authid[32]
	new playtime = (get_user_time(id) - lastplaytime[id])
	get_user_authid(id,authid,31)
	new tmp_vault_time,vault_time[21]
	get_vaultdata(authid,vault_time,20)
	tmp_vault_time = str_to_num(vault_time)
	tmp_vault_time += playtime
	num_to_str(tmp_vault_time,vault_time,20)
	set_vaultdata(authid,vault_time)
	return PLUGIN_CONTINUE
}

public handlesay(id)
{
	new arg[64], arg1[32], arg2[32]
	read_args(arg,63)
	remove_quotes(arg)
	strtok(arg,arg1,255,arg2,255,' ',1)
	trim(arg2)
	if(arg1[0] == '/')
	{
		if(equali(arg1, "/buy") == 1 || equali(arg1, "/upgrades") == 1 || equali(arg1, "/upgrade") == 1)
		{
			MainUpgradesMenu(id)
			return PLUGIN_CONTINUE
		}
		if(equali(arg1, "/credits") == 1 || equali(arg1, "/credit") == 1)
		{
			new authid[32]
			new playtime = (get_user_time(id) - lastplaytime[id])
			lastplaytime[id] = get_user_time(id)
			get_user_authid(id,authid,31)
			new tmp_vault_time,vault_time[21]
			get_vaultdata(authid,vault_time,20)
			tmp_vault_time = str_to_num(vault_time)
			tmp_vault_time += playtime
			connecttime[id] = tmp_vault_time
			num_to_str(tmp_vault_time,vault_time,20)
			set_vaultdata(authid,vault_time)
			new tmp_minutes = floatround(float(connecttime[id]/60),floatround_floor)
			new minutes = tmp_minutes % (credittime/60)
			client_print(id,print_chat,"You have %i credits (%i minutes remaining until next credit)",connecttime[id]/credittime,(credittime/60)-minutes)
			return PLUGIN_CONTINUE
		}
		if(equali(arg1,"/givecredits") == 1 || equali(arg1,"/givecredit") == 1)
		{
			new authid[32]
			new playtime = (get_user_time(id) - lastplaytime[id])
			lastplaytime[id] = get_user_time(id)
			get_user_authid(id,authid,31)
			new tmp_vault_time,vault_time[21]
			get_vaultdata(authid,vault_time,20)
			tmp_vault_time = str_to_num(vault_time)
			tmp_vault_time += playtime
			connecttime[id] = tmp_vault_time
			num_to_str(tmp_vault_time,vault_time,20)
			set_vaultdata(authid,vault_time)
			if(is_user_alive(id) == 0)
			{
				client_print(id,print_chat,"[AMXX] You must be alive to use this command")
				return PLUGIN_CONTINUE
			}
			new credits
			credits = str_to_num(arg2)
			if(credits <= 0)
			{
				client_print(id,print_chat,"[AMXX] You must specify a value of at least one credit")
				return PLUGIN_CONTINUE
			}
			new player, body, Float:dist = get_user_aiming(id,player,body,9999)
			if(player == 0 || player > 32 || is_user_connected(player) == 0 || is_user_alive(player) == 0)
			{
				client_print(id,print_chat,"[AMXX] Player is invalid or non-existant")
				return PLUGIN_CONTINUE
			}
			new classname[256]
			entity_get_string(player,EV_SZ_classname,classname,255)
			if(!equal(classname,"player"))
			{
				client_print(id,print_chat,"[AMXX] Player is invalid or non-existant")
				return PLUGIN_CONTINUE
			}
			if(dist > 512.0)
			{
				client_print(id,print_chat,"[AMXX] Player is too far away to give credits")
				return PLUGIN_CONTINUE
			}
			if(credits > connecttime[id]/credittime)
			{
				client_print(id,print_chat,"[AMXX] You do not have that amount of credits")
				return PLUGIN_CONTINUE
			}
			new givername[256], receivername[256]
			get_user_name(id,givername,255)
			get_user_name(player,receivername,255)
			decCredit(id,credits)
			addCredit(player,credits)
			client_print(id,print_chat,"[AMXX] You have given %i credits to %s",credits,receivername)
			client_print(player,print_chat,"[AMXX] You have received %i credits from %s",credits,givername)
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public MainUpgradesMenu(id)
{
	if(get_cvar_num("amx_upgrades") == 1)
	{
		new authid[32]
		new playtime = (get_user_time(id) - lastplaytime[id])
		lastplaytime[id] = get_user_time(id)
		get_user_authid(id,authid,31)
		new tmp_vault_time,vault_time[21]
		get_vaultdata(authid,vault_time,20)
		tmp_vault_time = str_to_num(vault_time)
		tmp_vault_time += playtime
		connecttime[id] = tmp_vault_time
		num_to_str(tmp_vault_time,vault_time,20)
		set_vaultdata(authid,vault_time)
		new tmp_minutes = floatround(float(connecttime[id]/60),floatround_floor)
		new minutes = tmp_minutes % (credittime/60)
		new keys
		new szMenuBody[255]
		new len = format(szMenuBody, 511, "\yMain Upgrades Menu:^n")
		len += format(szMenuBody[len], 511-len, "^n\w1. Passive Upgrades")
		len += format(szMenuBody[len], 511-len, "^n\w2. Item Upgrades")
		len += format(szMenuBody[len], 511-len, "^n\w3. Show all upgrades")
		len += format(szMenuBody[len], 511-len, "^n\w3. Buy a credit ($16000)")
		len += format(szMenuBody[len], 511-len, "^n\w4. Upgrade Help")
		len += format(szMenuBody[len], 511-len, "^n^n\w0.  Cancel")
		len += format(szMenuBody[len], 511-len, "^n^nCredits: %i (%i minutes remaining until next credit)",connecttime[id]/credittime,(credittime/60)-minutes)
		keys = (1<<0|1<<1|1<<2|1<<3|1<<9)
		show_menu(id, keys, szMenuBody, -1)
	}
	else
		client_print(id,print_chat,"[AMXX] Credit Mod is currently disabled")
	return PLUGIN_HANDLED
}

public MainMenuCommand(id, key)
{
	switch(key)
	{
		case 0: showMenu(id)
		case 1: EUMenu(id)
		case 2: show_all_upgrades(id)
		case 2: BuyMenu(id)
		case 3: UpgrHelp(id)
	}
	return PLUGIN_HANDLED
}

public BuyMenu(id)
{
	if(cs_get_user_money(id) < 16000)
		client_print(id, print_chat, "[AMXX] Insufficient funds (need $16000)")
	if(cs_get_user_money(id) >=16000)
	{
		cs_set_user_money(id,cs_get_user_money(id)-16000)
		addCredit(id, itemadd)
		client_print(id, print_chat, "[AMXX] You bought a credit!")
	}
	return PLUGIN_HANDLED
}

public EU2Menu(id)
{
	new authid[32]
	new playtime = (get_user_time(id) - lastplaytime[id])
	lastplaytime[id] = get_user_time(id)
	get_user_authid(id,authid,31)
	new tmp_vault_time,vault_time[21]
	get_vaultdata(authid,vault_time,20)
	tmp_vault_time = str_to_num(vault_time)
	tmp_vault_time += playtime
	connecttime[id] = tmp_vault_time
	num_to_str(tmp_vault_time,vault_time,20)
	set_vaultdata(authid,vault_time)
	new tmp_minutes = floatround(float(connecttime[id]/60),floatround_floor)
	new minutes = tmp_minutes % (credittime/60)
	new keys
	new szMenuBody[512]
	new len = format(szMenuBody, 511, "\yItem 2 Upgrade Menu:^n")
	len += format(szMenuBody[len], 511-len, "^n\w1. Wired C4 Explosive (Cost: %d Credit)", wiredc4ecost)
	len += format(szMenuBody[len], 511-len, "^n\w2. E.S.P (Cost: %d Credit)", espcost)
	len += format(szMenuBody[len], 511-len, "^n\w3. Laser Pointer (Cost: %d Credit)", lasercost)
	len += format(szMenuBody[len], 511-len, "^n\w4. Super Grenade (Cost: %d Credit)", sgrencost)
	len += format(szMenuBody[len], 511-len, "^n\w5. Crowbar (Cost: %d Credit)", crowbarcost)
	len += format(szMenuBody[len], 511-len, "^n\w6. Stealth Shoes (Cost: %d Credit)", sshoecost)
	len += format(szMenuBody[len], 511-len, "^n\w7. Flash Protection (Cost: %d Credit)", flashcost)
	len += format(szMenuBody[len], 511-len, "^n^n\w9.  Back")
	len += format(szMenuBody[len], 511-len, "^n\w0.  Cancel")
	len += format(szMenuBody[len], 511-len, "^n^nCredits: %i (%i minutes remaining until next credit)",connecttime[id]/credittime,(credittime/60)-minutes)
	keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<8|1<<9)
	show_menu(id, keys, szMenuBody, -1)
}

public EUA2Menu(id, key)
{
	switch(key)
	{
		case 0:
		{
			if(connecttime[id]/credittime < wiredc4ecost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(wired[id] == 1)
				client_print(id, print_chat, "[AMXX] You already have Wired C4 Explosive")
			if(!is_user_alive(id))
				client_print(id, print_chat, "[AMXX] You have to be alive")
			if(connecttime[id]/credittime >= wiredc4ecost && wired[id] == 0 && is_user_alive(id))
			{
				itemcap[id]++
				wired[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				decCredit(id,wiredc4ecost)
				client_print(id, print_chat, "[AMXX] Use your knife to turn it on")
			}
			EU2Menu(id)
		}
		case 1:
		{
			if(connecttime[id]/credittime < espcost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(esp[id] == 1)
				client_print(id, print_chat, "[AMXX] You already have E.S.P")
			if(connecttime[id]/credittime >= espcost && esp[id] == 0)
			{
				itemcap[id]++
				esp[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				set_task(3.0, "esploop", id, "", 0, "b")
				decCredit(id,espcost)
				client_print(id, print_chat, "[AMXX] E.S.P is now activated")
				creditsspent[id]++
			}
			EU2Menu(id)
		}
		case 2:
		{
			if(connecttime[id]/credittime < lasercost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(laser[id] == 1)
				client_print(id, print_chat, "[AMXX] You already have Laser Pointer")
			if(connecttime[id]/credittime >= lasercost && laser[id] == 0)
			{
				itemcap[id]++
				laser[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				decCredit(id,lasercost)
				client_print(id, print_chat, "[AMXX] Laser Activated, Battery life is 10 seconds")
				creditsspent[id]++
			}
			EU2Menu(id)
		}
		case 3:
		{
			if(connecttime[id]/credittime < sgrencost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(sgrenade[id] == 1)
				client_print(id, print_chat, "[AMXX] You already have Super Grenade")
			if(!is_user_alive(id))
				client_print(id, print_chat, "[AMXX] You have to be alive")
			if(connecttime[id]/credittime >= sgrencost && sgrenade[id] == 0 && is_user_alive(id))
			{
				itemcap[id]++
				sgrenade[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				give_item(id, "weapon_hegrenade")
				decCredit(id,sgrencost)
				client_print(id, print_chat, "[AMXX] This grenade has ALOT of damage")
			}
			EU2Menu(id)
		}
		case 4:
		{
			if(connecttime[id]/credittime < crowbarcost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(crowbar[id] == 1)
				client_print(id, print_chat, "[AMXX] You already have Crowbar")
			if(!is_user_alive(id))
				client_print(id, print_chat, "[AMXX] You have to be alive")
			if(connecttime[id]/credittime >= crowbarcost && crowbar[id] == 0 && is_user_alive(id))
			{
				itemcap[id]++
				crowbar[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				decCredit(id,crowbarcost)
				client_print(id, print_chat, "[AMXX] Crowbar 2x knife damage")
				creditsspent[id]++
			}
			EU2Menu(id)
		}
		case 5:
		{
			if(connecttime[id]/credittime < sshoecost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(sshoe[id] > 0)
				client_print(id, print_chat, "[AMXX] You already have Stealth Shoes")
			if(connecttime[id]/credittime >= sshoecost && sshoe[id] == 0)
			{
				itemcap[id]++
				sshoe[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				set_user_footsteps(id, 1)
				decCredit(id,sshoecost)
				client_print(id, print_chat, "[AMXX] No more footsteps")
				creditsspent[id]++
			}
			EUMenu(id)
		}
		case 6:
		{
			if(connecttime[id]/credittime < flashcost)
				client_print(id, print_chat, "[AMXX] Insufficient credits")
			if(sshoe[id] > 0)
				client_print(id, print_chat, "[AMXX] You already have Flash Protection")
			if(connecttime[id]/credittime >= flashcost && flash[id] == 0)
			{
				itemcap[id]++
				flash[id] = 1
				upgradelevelup(id)
				show_iupgrades(id)
				decCredit(id,flashcost)
				client_print(id, print_chat, "[AMXX] No more flashbangs")
				creditsspent[id]++
			}
			EUMenu(id)
		}
		case 8: EUMenu(id)
	}
	return PLUGIN_HANDLED
}

public EUMenu(id)
{
	if(get_cvar_num("amx_upgrades") == 1)
	{
		new authid[32]
		new playtime = (get_user_time(id) - lastplaytime[id])
		lastplaytime[id] = get_user_time(id)
		get_user_authid(id,authid,31)
		new tmp_vault_time,vault_time[21]
		get_vaultdata(authid,vault_time,20)
		tmp_vault_time = str_to_num(vault_time)
		tmp_vault_time += playtime
		connecttime[id] = tmp_vault_time
		num_to_str(tmp_vault_time,vault_time,20)
		set_vaultdata(authid,vault_time)
		new tmp_minutes = floatround(float(connecttime[id]/60),floatround_floor)
		new minutes = tmp_minutes % (credittime/60)
		new keys
		new szMenuBody[512]
		new len = format(szMenuBody, 511, "\yItem Upgrade Menu:^n")
		len += format(szMenuBody[len], 511-len, "^n\w1. Battle Aura (Cost: %d Credit)", hpscost)
		len += format(szMenuBody[len], 511-len, "^n\w2. First Aid (Cost: %d Credit)", regenerationcost)
		len += format(szMenuBody[len], 511-len, "^n\w3. Weapon Training (Cost: %d Credit)", weapontrainingcost)
		len += format(szMenuBody[len], 511-len, "^n\w4. Jump Module (Cost: %d Credit)", jumpmodulecost)
		len += format(szMenuBody[len], 511-len, "^n\w5. Climbing Gear (Cost: %d Credit)", climbgearcost)
		len += format(szMenuBody[len], 511-len, "^n\w6. Promotion (Cost: %d Credit)", promocost)
		len += format(szMenuBody[len], 511-len, "^n\w7. Unlimited Ammo (Cost: %d Credit)", unlacost)
		len += format(szMenuBody[len], 511-len, "^n^n\w8.  Next")
		len += format(szMenuBody[len], 511-len, "^n\w9.  Back")
		len += format(szMenuBody[len], 511-len, "^n\w0.  Cancel")
		len += format(szMenuBody[len], 511-len, "^n^nCredits: %i (%i minutes remaining until next credit)",connecttime[id]/credittime,(credittime/60)-minutes)
		keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9)
		show_menu(id, keys, szMenuBody, -1)
	}
}

public EUAMenu(id, key)
{
	if(itemcap[id] == maxitems)
		client_print(id, print_chat, "[AMXX] MAX items reached")
	if(creditsspent[id] == maxcredits)
		client_print(id, print_chat, "[AMXX] MAX credits spent per map")
	if(itemcap[id] < maxitems && creditsspent[id] < maxcredits)
	{
		switch(key)
		{
			case 0:
			{
				if(connecttime[id]/credittime < hpscost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(hpstlr[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have Battle Aura")
				if(connecttime[id]/credittime >= hpscost && hpstlr[id] == 0)
				{
					itemcap[id]++
					hpstlr[id] = 1
					upgradelevelup(id)
					show_iupgrades(id)
					decCredit(id,hpscost)
					client_print(id, print_chat, "[AMXX] Now you can steal enemy's health")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 1:
			{
				if(connecttime[id]/credittime< regenerationcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(regeneration[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have First Aid")
				if(connecttime[id]/credittime >= regenerationcost && regeneration[id] == 0)
				{
					itemcap[id]++
					regeneration[id] = 1
					firstaid(id)
					upgradelevelup(id)
					show_iupgrades(id)
					decCredit(id,regenerationcost)
					client_print(id, print_chat, "[AMXX] Now your health/armor will start to regenerate")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 2:
			{
				if(connecttime[id]/credittime < weapontrainingcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(weapontraining[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have Weapon Training")
				if(connecttime[id]/credittime >= weapontrainingcost && weapontraining[id] == 0)
				{
					itemcap[id]++
					weapontraining[id] = 1
					upgradelevelup(id)
					show_iupgrades(id)
					decCredit(id,weapontrainingcost)
					client_print(id, print_chat, "[AMXX] No more recoil")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 3:
			{
				if(connecttime[id]/credittime < jumpmodulecost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(jumpmodule[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have Jump Module")
				if(connecttime[id]/credittime >= jumpmodulecost && jumpmodule[id] == 0)
				{
					itemcap[id]++
					jumpmodule[id] = 1
					upgradelevelup(id)
					show_iupgrades(id)
					decCredit(id,jumpmodulecost)
					client_print(id, print_chat, "[AMXX] Now you can bunnyhop")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 4:
			{
				if(connecttime[id]/credittime < climbgearcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(climb[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have Climbing Gear")
				if(connecttime[id]/credittime >= climbgearcost && climb[id] == 0)
				{
					itemcap[id]++
					climb[id] = 1
					upgradelevelup(id)
					show_iupgrades(id)
					set_task(0.1, "cwall", id, "", 0, "b")
					decCredit(id,climbgearcost)
					client_print(id, print_chat, "[AMXX] Hold [Forward] or [Back] & [Jump] to climb walls")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 5:
			{
				if(connecttime[id]/credittime < promocost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(promotion[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have a Promotion")
				if(connecttime[id]/credittime >= promocost && promotion[id] == 0)
				{
					itemcap[id]++
					promotion[id] = 1
					upgradelevelup(id)
					show_iupgrades(id)
					decCredit(id,promocost)
					client_print(id, print_chat, "[AMXX] Now you get 2x more money")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 6:
			{
				if(connecttime[id]/credittime < unlacost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(gHasuammo[id] == 1)
					client_print(id, print_chat, "[AMXX] You already have a Unlimited Ammo")
				if(connecttime[id]/credittime >= unlacost && gHasuammo[id] == 0)
				{
					itemcap[id]++
					gHasuammo[id] = 1
					upgradelevelup(id)
					show_iupgrades(id)
					decCredit(id,unlacost)
					client_print(id, print_chat, "[AMXX] No more reloads")
					creditsspent[id]++
				}
				EUMenu(id)
			}
			case 7: EU2Menu(id)
			case 8: MainUpgradesMenu(id)
		}
	}
	return PLUGIN_HANDLED
}

public showMenu(id)
{
	if(get_cvar_num("amx_upgrades") == 1)
	{
		new authid[32]
		new playtime = (get_user_time(id) - lastplaytime[id])
		lastplaytime[id] = get_user_time(id)
		get_user_authid(id,authid,31)
		new tmp_vault_time,vault_time[21]
		get_vaultdata(authid,vault_time,20)
		tmp_vault_time = str_to_num(vault_time)
		tmp_vault_time += playtime
		connecttime[id] = tmp_vault_time
		num_to_str(tmp_vault_time,vault_time,20)
		set_vaultdata(authid,vault_time)
		new tmp_minutes = floatround(float(connecttime[id]/60),floatround_floor)
		new minutes = tmp_minutes % (credittime/60)
		new keys
		new szMenuBody[512]
		new len = format(szMenuBody, 511, "\yPassive Upgrade Menu:^n")
		len += format(szMenuBody[len], 511-len, "^n\w1. Armor (Cost: %d Credit)", armorcost)
		len += format(szMenuBody[len], 511-len, "^n\w2. Health (Cost: %d Credit)", hpcost)
		len += format(szMenuBody[len], 511-len, "^n\w3. Speed (Cost: %d Credit)", speedcost)
		len += format(szMenuBody[len], 511-len, "^n\w4. Gravity (Cost: %d Credit)", gravitycost)
		len += format(szMenuBody[len], 511-len, "^n\w5. Stealth (Cost: %d Credit)", stealthcost)
		len += format(szMenuBody[len], 511-len, "^n\w6. MultiJump (Cost: %d Credit)", multijumpcost)
		len += format(szMenuBody[len], 511-len, "^n^n\w9.  Back")
		len += format(szMenuBody[len], 511-len, "^n\w0.  Cancel")
		len += format(szMenuBody[len], 511-len, "^n^nCredits: %i (%i minutes remaining until next credit)",connecttime[id]/credittime,(credittime/60)-minutes)
		keys = (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<8|1<<9)
		show_menu(id, keys, szMenuBody, -1)
	}
	return PLUGIN_CONTINUE
}

public actionMenu(id, key)
{
	if(creditsspent[id] == maxcredits)
		client_print(id, print_chat, "[AMXX] MAX credits spent per map")
	if(creditsspent[id] < maxcredits)
	{
		switch(key)
		{
			case 0:
			{
				if(connecttime[id]/credittime < armorcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(Armor[id] == armormaxlvl)
					client_print(id, print_chat, "[AMXX] Max level reached")
				if(connecttime[id]/credittime >= armorcost && Armor[id] < armormaxlvl)
				{
					Armor[id]++
					UserArmor(id)
					upgradelevelup(id)
					show_upgrades(id)
					decCredit(id,armorcost)
					creditsspent[id]++
				}
				showMenu(id)
			}
			case 1:
			{
				if(connecttime[id]/credittime < hpcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(Health[id] == hpmaxlvl)
					client_print(id, print_chat, "[AMXX] Max level reached")
				if(connecttime[id]/credittime >= hpcost && Health[id] < hpmaxlvl)
				{
					Health[id]++
					UserHealth(id)
					upgradelevelup(id)
					show_upgrades(id)
					decCredit(id,hpcost)
					creditsspent[id]++
				}
				showMenu(id)
			}
			case 2:
			{
				if(connecttime[id]/credittime < speedcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(Speed[id] == speedmaxlvl)
					client_print(id, print_chat, "[AMXX] Max level reached")
				if(connecttime[id]/credittime >= speedcost && Speed[id] < speedmaxlvl)
				{
					Speed[id]++
					UserSpeed(id)
					upgradelevelup(id)
					show_upgrades(id)
					decCredit(id,speedcost)
					creditsspent[id]++
				}
				showMenu(id)
			}
			case 3:
			{
				if(connecttime[id]/credittime < gravitycost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(Gravity[id] == gravitymaxlvl)
					client_print(id, print_chat, "[AMXX] Max level reached")
				if(connecttime[id]/credittime >= gravitycost && Gravity[id] < gravitymaxlvl)
				{
					Gravity[id]++
					UserGravity(id)
					upgradelevelup(id)
					show_upgrades(id)
					decCredit(id,gravitycost)
					creditsspent[id]++
				}
				showMenu(id)
			}
			case 4:
			{
				if(connecttime[id]/credittime < stealthcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(Stealth[id] == stealthmaxlvl)
					client_print(id, print_chat, "[AMXX] Max level reached")
				if(connecttime[id]/credittime >= stealthcost && Stealth[id] < stealthmaxlvl)
				{
					Stealth[id]++
					UserStealth(id)
					upgradelevelup(id)
					show_upgrades(id)
					decCredit(id,stealthcost)
					creditsspent[id]++
				}
				showMenu(id)
			}
			case 5:
			{
				if(connecttime[id]/credittime < multijumpcost)
					client_print(id, print_chat, "[AMXX] Insufficient credits")
				if(multijump[id] == multijumpmaxlvl)
					client_print(id, print_chat, "[AMXX] Max level reached")
				if(connecttime[id]/credittime >= multijumpcost && multijump[id] < multijumpmaxlvl)
				{
					multijump[id]++
					upgradelevelup(id)
					show_upgrades(id)
					decCredit(id,multijumpcost)
					creditsspent[id]++
				}
				showMenu(id)
			}
			case 8: MainUpgradesMenu(id)
		}
	}
	return PLUGIN_HANDLED
}

public UserArmor(id)
{
	new iap = (Armor[id] * armorperbuy)
	set_user_armor(id, 100 + iap)
	return PLUGIN_CONTINUE
}

public UserHealth(id)
{
	new ihp = (Health[id] * hpperbuy)
	set_user_health(id, 100 + ihp)
	return PLUGIN_CONTINUE
}

public UserSpeed(id)
{
	if(speed == false)
		return PLUGIN_CONTINUE
	new ispeed = (Speed[id] * speedperbuy)
	set_user_maxspeed(id, 240.0 + ispeed)
	return PLUGIN_CONTINUE
}

public UserGravity(id)
{
	set_user_gravity(id, 1 - Gravity[id] * gravityperbuy)
	return PLUGIN_CONTINUE
}

public UserStealth(id)
{
	new istealth = (Stealth[id] * stealthperbuy)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, defaultstealth - istealth)
	return PLUGIN_CONTINUE
}

public firstaid(id)
{
	if(is_user_alive(id))
	{
		if(regeneration[id] > 0)
		{
			new Float:srate = regenerationrate
			set_task(srate, "starttheregen", id, "", 0, "b")
		}
	}
	return PLUGIN_CONTINUE
}

public starttheregen(id)
{
	if(is_user_alive(id))
	{
		if(regeneration[id] > 0)
		{
			new maxhp = (100 + Health[id] * hpperbuy)
			if(get_user_health(id) < maxhp)
			{
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), { 0, 0, 0 }, id)
				write_short(1<<10)
				write_short(1<<10)
				write_short(1<<12)
				write_byte(0)
				write_byte(0)
				write_byte(255)
				write_byte(50)
				message_end()
				new health = get_user_health(id)
				health += hpregenp
				set_user_health(id, health)
				if(get_user_health(id) >= maxhp)
				set_user_health(id, maxhp)
			}
			new maxap = (100 + Armor[id] * armorperbuy)
			if(get_user_armor(id) < maxap)
			{
				message_begin(MSG_ONE, get_user_msgid("ScreenFade"), { 0, 0, 0 }, id)
				write_short(1<<10)
				write_short(1<<10)
				write_short(1<<12)
				write_byte(0)
				write_byte(0)
				write_byte(255)
				write_byte(50)
				message_end()
				new armor = get_user_armor(id)
				armor += apregenp
				set_user_armor(id, armor)
				if(get_user_armor(id) >= maxap)
				set_user_armor(id, maxap)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public Event_Damage(id)
{
	new damage = read_data(2)
	new bodypart, weapon
	new enemy = get_user_attacker(id, weapon, bodypart)
	new hpgain = floatround(float(get_user_health(enemy)) + (float(damage) * 0.5))
	new maxhp = (100 + Health[enemy] * hpperbuy)
	if(is_user_alive(enemy) && hpstlr[enemy] > 0)
	{
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), { 0, 0, 0 }, enemy)
		write_short(1<<10)
		write_short(1<<10)
		write_short(1<<12)
		write_byte(0)
		write_byte(255)
		write_byte(0)
		write_byte(50)
		message_end()
		set_user_health(enemy, hpgain)
		if(get_user_health(enemy) >= maxhp)
			set_user_health(enemy, maxhp)
	}
	if(sgrenade[enemy] > 0 && weapon == CSW_HEGRENADE && is_user_alive(id))
	{
		new Xdamage = floatround(float(get_user_health(id)) - (float(damage) * 90.0))
		if(Xdamage < 1)
		{
			set_msg_block(get_user_msgid("DeathMsg"),BLOCK_ONCE)
			message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0, 0, 0}, 0)
			write_byte(enemy)
			write_byte(id)
			write_byte(0)
			write_string("grenade")
			message_end()
		}
		set_user_health(id, Xdamage)
		sgrenade[enemy] = 0
		itemcap[enemy]--
	}
	if(crowbar[enemy] > 0 && weapon == CSW_KNIFE && is_user_alive(id))
	{
		new KXdamage = floatround(float(get_user_health(id)) - (float(damage)))
		if(KXdamage < 1)
		{
			set_msg_block(get_user_msgid("DeathMsg"),BLOCK_ONCE)
			message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0, 0, 0}, 0)
			write_byte(enemy)
			write_byte(id)
			write_byte(0)
			write_string("knife")
			message_end()
			new frags, deaths
			frags = get_user_frags(enemy) + 1
			set_user_frags(enemy, frags)
			deaths = cs_get_user_deaths(id) + 1
			cs_set_user_deaths(id, deaths)
			frags = get_user_frags(id) + 1
			set_user_frags(id, frags)
		}
		set_user_health(id, KXdamage)
	}
	return PLUGIN_CONTINUE
}

public client_PreThink(id)
{
	if(is_user_alive(id) && get_cvar_num("amx_upgrades") == 1)
	{
		new buttons = get_user_button(id)
		new obut = get_user_oldbutton(id)
		if(jumpmodule[id] > 0)
		{
			entity_set_float(id, EV_FL_fuser2, 0.0)
			if(buttons & IN_JUMP)
			{
				new flags = entity_get_int(id, EV_INT_flags)
				if(flags | FL_WATERJUMP && entity_get_int(id, EV_INT_waterlevel) < 2 && flags & FL_ONGROUND)
				{
					new Float:velocity[3]
					entity_get_vector(id, EV_VEC_velocity, velocity)
					velocity[2] += 250.0
					entity_set_vector(id, EV_VEC_velocity, velocity)
					entity_set_int(id, EV_INT_gaitsequence, 6)
				}
			}
		}
		if(wired[id] > 0)
		{
			new temp[2]
			new currweapon = get_user_weapon(id, temp[0], temp[1])
			if(currweapon == CSW_KNIFE)
			{
				if(get_user_button(id) & IN_ATTACK)
				{
					set_task(0.5, "beep_sound", id)
					set_task(1.2, "c4bombertimer", id)
				}
			}
		}
		if(multijump[id] > 0)
		{
			if((buttons & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
			{
				if(jumpnum[id] < multijump[id])
				{
					dojump[id] = true
					jumpnum[id]++
					return PLUGIN_CONTINUE
				}
			}
			if((buttons & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
				jumpnum[id] = 0
		}
	}
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(is_user_alive(id) && get_cvar_num("amx_upgrades") == 1)
	{
		if(dojump[id] == true)
		{
			new Float:velocity[3]	
			entity_get_vector(id,EV_VEC_velocity,velocity)
			velocity[2] = random_float(265.0,285.0)
			entity_set_vector(id,EV_VEC_velocity,velocity)
			dojump[id] = false
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE
}

public beep_sound(id)
{
	if(wired[id] > 0)
		emit_sound(id, CHAN_ITEM, "buttons/blip2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public update(id)
{
	if(get_cvar_num("amx_upgrades") != 1)
		return PLUGIN_CONTINUE
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	set_user_gravity(id, 1 - Gravity[id] * gravityperbuy)
	if(speed != false)
		set_user_maxspeed(id, 240.0 + (Speed[id] * speedperbuy))
	if(weapontraining[id] > 0)
		entity_set_vector (id,EV_VEC_punchangle, Float:{0.0, 0.0, 0.0})
	new temp[2]
	new istealth = (Stealth[id] * stealthperbuy)
	if(Stealth[id] > 0)
	{
		if(get_user_weapon(id, temp[0], temp[1]) == CSW_KNIFE)
		{
			new astealth = istealth + 20
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, defaultstealth - astealth)
		}
		else
			set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, defaultstealth - istealth)
	}
	new wpnid = read_data(2)
	if(wired[id] > 0)
	{
		if(wpnid == CSW_KNIFE)
			switchmodel(id)
	}
	if(crowbar[id] > 0)
	{
		if(wpnid == CSW_KNIFE)
			switchmodel(id)
	}
	if(gHasuammo[id] > 0)
	{
		new clip = read_data(3)
		if(wpnid == CSW_C4 || wpnid == CSW_KNIFE || wpnid == CSW_HEGRENADE || wpnid == CSW_SMOKEGRENADE || wpnid == CSW_FLASHBANG)
			return PLUGIN_CONTINUE
		if(clip == 0)
		{
			new wpnname[32]
			get_weaponname(wpnid, wpnname, 31)
			give_item(id, wpnname)
      			engclient_cmd(id, wpnname)
		}
	}
	if(laser[id] > 0)
	{
		set_hudmessage(255, 0, 0, -1.0, -1.0, 0, 6.0, 10.0, 0.1, 0.1, 10)
		show_hudmessage(id, "o")
	}
	return PLUGIN_CONTINUE
}

public switchmodel(id)
{
	new temp[2], wpnid = get_user_weapon(id, temp[0], temp[1])
	if(is_user_alive(id))
	{
		if(wired[id] > 0)
		{
			if(wpnid == CSW_KNIFE)
			{
				entity_set_string(id, EV_SZ_viewmodel, "models/v_satchel_radio.mdl")
				entity_set_string(id, EV_SZ_weaponmodel, "models/p_satchel_radio.mdl")
			}
		}
		if(crowbar[id] > 0)
		{
			if(wpnid == CSW_KNIFE)
			{
				entity_set_string(id, EV_SZ_viewmodel, "models/v_crowbar.mdl")
				entity_set_string(id, EV_SZ_weaponmodel, "models/p_crowbar.mdl")
			}
		}
	}
}

public upgradelevelup(id)
{
	client_print(id, print_center, "***Bought Upgrade***")
	client_cmd(id, "spk weapons/pl_gun2.wav")
	return PLUGIN_CONTINUE
}

public cwall(id)
{
	new buttons = get_user_button(id)
	if(buttons & IN_ATTACK)
		return PLUGIN_HANDLED
	if(!is_user_connected(id))
		return PLUGIN_HANDLED
	if(speed == true)
	{
		if(climb[id] > 0)
		{
			new Float: velocity[3]
			entity_get_vector(id, EV_VEC_velocity, velocity)
			if(buttons & IN_JUMP && (buttons & IN_FORWARD || buttons & IN_BACK))
			{
				if(velocity[0] == 0.0 || velocity[1] == 0.0)
				{
					velocity[1] = 10.0
					velocity[2] = 220.0
					entity_set_vector(id, EV_VEC_velocity, velocity)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public c4bombertimer(id)
{
	if(wired[id] > 0)
	{
		wired[id] = 0
		itemcap[id]--
		emit_sound(id, CHAN_STATIC, "weapons/mine_charge.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		new param[2]
		param[0] = id
		set_task(3.8, "bombed", BOMB_TASK + id, param, 1)
	}
}

public bombed(param[])
{
	new id = param[0]
	new origin[3]
	get_user_origin(id, origin, 0)
   	for(new a = 1; a <= get_maxplayers(); a++)
	{
		new origin1[3]
 		get_user_origin(a, origin1, 0)
		if(is_user_alive(a))
		{
			if(!(origin[0] - origin1[0] > BOMBKILL_RANGE ||
			origin[0] - origin1[0] < - BOMBKILL_RANGE ||
			origin[1] - origin1[1] > BOMBKILL_RANGE ||
			origin[1] - origin1[1] < - BOMBKILL_RANGE ||
			origin[2] - origin1[2] > BOMBKILL_RANGE ||
			origin[2] - origin1[2] < - BOMBKILL_RANGE))
			{
				new bombguyfrags
				new name[33]
				get_user_name(id, name, 32)
				if((a != id))
				{
					bombguyfrags = get_user_frags(id)
					bombguyfrags += 1
					set_user_frags(id, bombguyfrags)
					set_msg_block(get_user_msgid("DeathMsg"),BLOCK_ONCE)
					message_begin(MSG_ALL, get_user_msgid("DeathMsg"), {0, 0, 0}, 0)
					write_byte(id)
					write_byte(a)
					write_byte(1)		
					write_string("")
					message_end()
					client_print(a, print_chat, "[AMXX] %s killed you with the c4 wired to his body", name)
				}
				user_kill(a, 1)
				explode(origin1)
			}
		}
	}
}

explode(vec1[3])
{
	   // blast circles
	   message_begin(MSG_BROADCAST,SVC_TEMPENTITY, vec1)
	   write_byte(21)
	   write_coord(vec1[0])
	   write_coord(vec1[1])
	   write_coord(vec1[2] + 16)
	   write_coord(vec1[0])
	   write_coord(vec1[1])
	   write_coord(vec1[2] + 1936)
	   write_short(white)
	   write_byte(0)//startframe 
	   write_byte(0)//framerate 
	   write_byte(3)//life 2
	   write_byte(20)//width 16 
	   write_byte(0)//noise 
	   write_byte(188)//r 
	   write_byte(220)//g 
	   write_byte(255)//b 
	   write_byte(255)//brightness
	   write_byte(0)//speed
	   message_end()
	   //Explosion2
	   message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	   write_byte(12)
	   write_coord(vec1[0])
	   write_coord(vec1[1])
	   write_coord(vec1[2])
	   write_byte(188)//byte (scale in 0.1's) 188
	   write_byte(10)//byte (framerate) 
	   message_end()
	   //TE_Explosion
	   message_begin(MSG_BROADCAST,SVC_TEMPENTITY,vec1)
	   write_byte(3)
	   write_coord(vec1[0])
	   write_coord(vec1[1])
	   write_coord(vec1[2])
	   write_short(fire)
	   write_byte(65)//byte (scale in 0.1's) 188
	   write_byte(10)//byte (framerate)
	   write_byte(0)//byte flags
	   message_end()
	   //Smoke
	   message_begin(MSG_BROADCAST,SVC_TEMPENTITY,vec1) 
	   write_byte(5)//5
	   write_coord(vec1[0])
	   write_coord(vec1[1])
	   write_coord(vec1[2])
	   write_short(smoke)
	   write_byte(50)//2
	   write_byte(10)//10
	   message_end()
}

public esploop(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	if(esp[id] > 0)
	{
		for(new a = 1; a <= get_maxplayers(); a++) 
		{
			if(is_user_alive(a))
			{
				if(cs_get_user_team(id) != cs_get_user_team(a))
				{
					if((a != id))
					{
						new vec1[3]
						get_user_origin(a, vec1, 0)
						message_begin(MSG_ONE, SVC_TEMPENTITY, vec1, id)
						write_byte(21)
						write_coord(vec1[0])
						write_coord(vec1[1])
						write_coord(vec1[2] - 35)
						write_coord(vec1[0])
						write_coord(vec1[1])
						write_coord(vec1[2] + credittime)
						write_short(white)
						write_byte(0)//startframe
						write_byte(1)//framerate
						write_byte(6)//3 life 2
						write_byte(8)//width 16
						write_byte(1)//noise
						write_byte(100)//r
						write_byte(100)//g
						write_byte(255)//b
						write_byte(192)//brightness
						write_byte(0)//speed
						message_end()
					}
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

public UpgrHelp(id) 
{
	new PUmotd[2048], title[64], dpos = 0
	format(title, 63, "AMXX CREDIT MOD Version: [%s] ", VER)
	dpos += format(PUmotd[dpos], 2047-dpos, "<html><head><style type=^"text/css^">pre{color:#FFB000;}body{background:#000000;margin-left:8px;margin-top:0px;}</style></head><pre><body>")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n^n<b>%s</b>^n^n",title)
	dpos += format(PUmotd[dpos], 2047-dpos, "^n^n-=--=--=--=--=--=--=--=--=--=-^n^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[*]Commands:^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "/buy - opens main menu^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "/credits - shows you how many credits/how long until your next credit^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "/givecredits x - gives x amount of credits to your target^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n^n-=--=--=--=--=--=--=--=--=--=-^n^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[*]Passive Upgrades Description:^n^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Armor] - Increase MAX Armor^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Health] - Increase MAX Health^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Speed]- Increase MAX Speed^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Gravity] - Decrease Gravity^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Stealth] - Decrease Visability^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[MultiJump] - Allows you to jump in the air^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n^n-=--=--=--=--=--=--=--=--=--=-^n^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[*]Item Upgrades Description:^n^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Battle Aura] - Steals enemy's health^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[First Aid] - HP/AP regeneration^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Weapon Training] - No recoil^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Jump Module] - Enables Bunny Hopping^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Climbing Gear] - Ability to climb walls^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Promotion] - 2x money intake^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Unlimited Ammo] - Give's no limition to ammunation^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Stealth Shoes] - Disable's Footstep sounds^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Wired C4 Explosive] - Kamikaze with remote^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[E.S.P] - Ability to know where your enemy is^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Laser Pointer] - Adds an extra crosshair for your weapons^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Super Grenade] - Killer grenade^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Crowbar] - 2x damage knife^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "[Flash Protection] - Removes blindness from flashbangs^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n^n-=--=--=--=--=--=--=--=--=--=-^n^n")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n***[NOTE] YOU WILL KEEP THESE UPGRADES EVEN IF YOU DIE***")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n***[NOTE] YOU WILL LOSE SUPER GRENADES AND C4 WHEN YOU DIE***")
	dpos += format(PUmotd[dpos], 2047-dpos, "^n***[NOTE] MAX ITEMS YOU CAN BUY: %i***",maxitems)
	dpos += format(PUmotd[dpos], 2047-dpos, "^n***[NOTE] MAX CREDITS YOU CAN SPEND PER MAP: %i***",maxcredits)
	show_motd(id, PUmotd, title)
}

public plugin_precache()
{
	precache_sound("weapons/pl_gun2.wav")
	precache_sound("buttons/blip2.wav")
	precache_sound("weapons/mine_charge.wav")
	precache_model("models/v_satchel_radio.mdl")
	precache_model("models/p_satchel_radio.mdl")
	precache_model("models/v_crowbar.mdl")
	precache_model("models/p_crowbar.mdl")
	smoke = precache_model("sprites/steam1.spr") 
	white = precache_model("sprites/white.spr")
	fire = precache_model("sprites/explode1.spr")
}

public queryall(id,level,cid) 
{
	if (!cmd_access(id,level,cid,1))
		return PLUGIN_HANDLED
	new maxslots = get_maxplayers()
	new query_name[32]
	for(new i = 1; i <= maxslots; ++i)
	{
		if (!is_user_connected(i) && !is_user_connecting(i)) continue
		get_user_name(i,query_name,31)
		client_print(id,print_console," %s 's credits = %i",query_name,connecttime[i]/credittime)
	}
	return PLUGIN_HANDLED
}

public client_authorized(id)
{
	new authid[32], vault_time[21]
	get_user_authid(id,authid,31)
	if(vaultdata_exists(authid))
	{
		get_vaultdata(authid,vault_time,20)
		connecttime[id] = str_to_num(vault_time)
	}
	else
	{
		connecttime[id] = numnewcredits * credittime
		num_to_str(connecttime[id],vault_time,20)
		set_vaultdata(authid,vault_time)
	}
	return PLUGIN_CONTINUE
}

public decCredit(id, itemcost)
{
	new cost = itemcost
	connecttime[id] = connecttime[id] - (credittime * cost)
	new authid[32], vault_time[21]
	get_user_authid(id,authid,31)
	num_to_str(connecttime[id],vault_time,20)
	set_vaultdata(authid,vault_time)
	return PLUGIN_HANDLED
}

public addCredit(id, itemadd)
{
	new addcredits = itemadd
	connecttime[id] = connecttime[id] + (credittime * addcredits)
	new authid[32], vault_time[21]
	get_user_authid(id,authid,31)
	num_to_str(connecttime[id],vault_time,20)
	set_vaultdata(authid,vault_time)
	return PLUGIN_HANDLED
}

public givecredit(id,level,cid)
{
	if(!cmd_access(id,level,cid,3))
        	return PLUGIN_HANDLED
	new target[32],credits[21]
    	read_argv(1,target,31)
    	read_argv(2,credits,20)
	new player = cmd_target(id,target,8)
    	if(!player) return PLUGIN_HANDLED 
	new admin_name [32], player_name[32]
    	get_user_name(id,admin_name,31)
    	get_user_name(player,player_name,31)
	new crednum = str_to_num(credits)
	addCredit(player,crednum)
	client_print(id,print_console,"[AMXX] You have added %i credits to %s's total credits",crednum,player_name)
	return PLUGIN_CONTINUE
}

public removecredit(id,level,cid)
{
	if(!cmd_access(id,level,cid,3))
        	return PLUGIN_HANDLED
	new target[32],credits[21]
    	read_argv(1,target,31)
    	read_argv(2,credits,20)
	new player = cmd_target(id,target,8)
    	if(!player) return PLUGIN_HANDLED 
	new admin_name [32], player_name[32]
    	get_user_name(id,admin_name,31)
    	get_user_name(player,player_name,31)
	new crednum = str_to_num(credits)
	decCredit(player,crednum)
	client_print(id,print_console,"[AMXX] You have removed %i credits from %s's total credits",crednum,player_name)
	return PLUGIN_CONTINUE
}