#define ALIEN_NEST_LOCKED_Y_OFFSET 6
//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/mob/alien.dmi'
	icon_state = "nest"
	var/health = 100

/obj/structure/bed/nest/manual_unbuckle(mob/user as mob)
	if(locked_atoms.len)
		var/mob/M = locked_atoms[1]
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[user.name] pulls [M.name] free from the sticky nest!</span>",\
				"<span class='notice'>[user.name] pulls you free from the gelatinous resin.</span>",\
				"<span class='notice'>You hear squelching...</span>")
			unlock_atom(M)
		else
			M.visible_message(\
				"<span class='warning'>[M.name] struggles to break free of the gelatinous resin...</span>",\
				"<span class='warning'>You struggle to break free from the gelatinous resin...</span>",\
				"<span class='notice'>You hear squelching...</span>")
			spawn(1200)
				if(user && M && user.locked_to == src)
					unlock_atom(M)
		src.add_fingerprint(user)

/obj/structure/bed/nest/buckle_mob(mob/M as mob, mob/user as mob)
	if (locked_atoms.len || !ismob(M) || (get_dist(src, user) > 1) || (M.loc != src.loc) || user.restrained() || usr.stat || M.locked_to || istype(user, /mob/living/silicon/pai) )
		return

	if(istype(M,/mob/living/carbon/alien))
		return
	if(!istype(user,/mob/living/carbon/alien/humanoid))
		return

	if(M == usr)
		return
	else
		M.visible_message(\
			"<span class='notice'>[user.name] secretes a thick vile goo, securing [M.name] into \the [src]!</span>",\
			"<span class='warning'>[user.name] drenches you in a foul-smelling resin, trapping you in \the [src]!</span>",\
			"<span class='notice'>You hear squelching...</span>")
	lock_atom(M)
	M.pixel_y = 6
	src.add_fingerprint(user)

/obj/structure/bed/nest/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	for(var/mob/M in viewers(src, 7))
		M.show_message("<span class='warning'>[user] hits [src] with [W]!</span>", 1)
	healthcheck()

/obj/structure/bed/nest/proc/healthcheck()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/structure/stool/bed/nest/proc/healthcheck() called tick#: [world.time]")
	if(health <= 0)
		density = 0
		qdel(src)

/obj/structure/bed/nest/lock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	AM.pixel_y += ALIEN_NEST_LOCKED_Y_OFFSET

/obj/structure/bed/nest/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	AM.pixel_y -= ALIEN_NEST_LOCKED_Y_OFFSET

#undef ALIEN_NEST_LOCKED_Y_OFFSET
