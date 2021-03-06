/*
CONTAINS:

Deployable items
Barricades

for reference:

	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_genetics = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	access_court = 42
	access_clown = 43
	access_mime = 44

*/


//Barricades, maybe there will be a metal one later...
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	anchored = 1.0
	density = 1.0
	var/health = 60.0
	var/maxhealth = 60.0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/stack/sheet/wood))
			if (src.health < src.maxhealth)
				visible_message("<span class='warning'>[user] begins to repair the [src]!</span>")
				if(do_after(user, src,20))
					src.health = src.maxhealth
					W:use(1)
					visible_message("<span class='warning'>[user] repairs the [src]!</span>")
					return
			else
				return
			return
		else
			user.delayNextAttack(10)
			switch(W.damtype)
				if("fire")
					src.health -= W.force * 1
				if("brute")
					src.health -= W.force * 0.75
				else
			if (src.health <= 0)
				visible_message("<span class='danger'>The barricade is smashed apart!</span>")
				getFromPool(/obj/item/stack/sheet/wood, get_turf(src), 3)
				qdel(src)
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("<span class='danger'>The barricade is blown apart!</span>")
				qdel(src)
				return
			if(2.0)
				src.health -= 25
				if (src.health <= 0)
					visible_message("<span class='danger'>The barricade is blown apart!</span>")
					getFromPool(/obj/item/stack/sheet/wood, get_turf(src), 3)
					qdel(src)
				return

	blob_act()
		src.health -= 25
		if (src.health <= 0)
			visible_message("<span class='danger'>The blob eats through the barricade!</span>")
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
		if(air_group || (height==0))
			return 1
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		else
			return 0

/obj/structure/barricade/wooden/door //Used by the barricade kit when it is placed on doors

	icon = 'icons/policetape.dmi'
	icon_state = "wood_door"
	anchored = 1
	density = 1
	health = 50 //Can take a few hits
	maxhealth = 50

//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = 0.0
	density = 1.0
	icon_state = "barrier0"
	var/health = 140.0
	var/maxhealth = 140.0
	var/locked = 0.0
//	req_access = list(access_maint_tunnels)

	machine_flags = EMAGGABLE

/obj/machinery/deployable/barrier/New()
	..()

	src.icon_state = "barrier[src.locked]"

/obj/machinery/deployable/barrier/emag(mob/user)
	if (src.emagged == 0)
		src.emagged = 1
		src.req_access = 0
		user << "You break the ID authentication lock on the [src]."
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		desc = "A deployable barrier. Swipe your ID card to lock/unlock it. Seems like it's malfunctioning"
		return

/obj/machinery/deployable/barrier/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id/))
		if (src.allowed(user))
			src.locked = !src.locked
			src.anchored = !src.anchored
			src.icon_state = "barrier[src.locked]"
			if (src.locked == 1.0)
				user << "Barrier lock toggled on."
				return
			else if (src.locked == 0.0)
				user << "Barrier lock toggled off."
				return
		return
	else
		visible_message("<span class='danger'>[src] has been hit by [user] with [W]</span>") //I have to put this because atom/proc/attackby is not triggering. No idea why
		user.delayNextAttack(10)
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 1
			if("brute")
				src.health -= W.force * 0.75
		if (src.health <= 0)
			src.explode()
		..()

/obj/machinery/deployable/barrier/ex_act(severity)
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= 25
			if (src.health <= 0)
				src.explode()
			return

/obj/machinery/deployable/barrier/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(prob(50/severity))
		locked = !locked
		anchored = !anchored
		icon_state = "barrier[src.locked]"

/obj/machinery/deployable/barrier/blob_act()
	src.health -= 25
	if (src.health <= 0)
		src.explode()
	return

/obj/machinery/deployable/barrier/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/deployable/barrier/proc/explode()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/machinery/deployable/barrier/proc/explode() called tick#: [world.time]")
	visible_message("<span class='danger'>[src] blows apart!</span>")

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	explosion(src.loc,-1,-1,0)
	if(src)
		qdel(src)