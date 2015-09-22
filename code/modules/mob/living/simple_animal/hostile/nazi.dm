/mob/living/simple_animal/hostile/nazi
	name = "Nazi Soldier"
	desc = "Space nazis, oh man."
	icon_state = "nazi"
	icon_living = "nazi"
	icon_dead = "nazi_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	a_intent = I_HURT
	var/obj/effect/landmark/corpse/corpse = /obj/effect/landmark/corpse/clown
	var/weapon1
	var/weapon2
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "nazi"
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/syndicate/Die()
	..()
	if(corpse)
		corpse = new corpse(loc)
		corpse.createCorpse()
	if(weapon1)
		new weapon1 (get_turf(src))
	if(weapon2)
		new weapon2 (get_turf(src))
	qdel(src)
	return

///////////////Commando////////////

/mob/living/simple_animal/hostile/nazi/ranged
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "nazicommando"
	icon_living = "nazicommando"
	projectilesound = 'sound/weapons/laser.ogg'
	projectiletype = /obj/item/projectile/energy/plasma/MP40k

	weapon1 = /obj/item/weapon/gun/energy/plasma/MP40k