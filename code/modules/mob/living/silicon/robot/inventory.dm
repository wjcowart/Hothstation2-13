//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting stuff manually
//as they handle all relevant stuff like adding it to the player's screen and such

//Returns the thing in our active hand (whatever is in our active module-slot, in this case)
/mob/living/silicon/robot/get_active_hand()
	return module_active

/mob/living/silicon/robot/get_inactive_hand()
	return

/mob/living/silicon/robot/get_all_slots()
	return list(module_state_1, module_state_2, module_state_3)

//overridden from parent since they technically have no 'hands'
/mob/living/silicon/robot/get_equipped_items()
	return get_all_slots()

/mob/living/silicon/robot/proc/uneq_module(const/obj/item/module)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/uneq_module() called tick#: [world.time]")
	if(!istype(module))
		return 0

	if(istype(module, /obj/item/borg/sight))
		sight_mode &= ~module:sight_mode

	if(client)
		client.screen -= module

	contents -= module
	if(module)
		module.forceMove(src.module)
	hud_used.update_robot_modules_display()
	return 1

/mob/living/silicon/robot/proc/uneq_active()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/uneq_active() called tick#: [world.time]")
	if(isnull(module_active))
		return

	if(module_active:loc != src)
		if(!istype(module_active, /obj/item/weapon/reagent_containers/glass/beaker))
			src << "<span class='warning'>Can't store something you're not holding!</span>"
			return
		else
			var/obj/item/weapon/reagent_containers/glass/beaker/large/ourbeaker = module_active
			if(istype(ourbeaker.loc, /obj/machinery))
				ourbeaker.loc:detach()
				ourbeaker.loc = src
			else if(ismob(ourbeaker.loc))
				var/mob/living/L = ourbeaker.loc
				L.drop_item(ourbeaker)
				ourbeaker.loc = src
			else
				ourbeaker.loc = src
	if(module_state_1 == module_active)
		uneq_module(module_state_1)
		module_state_1 = null
		inv1.icon_state = "inv1"
	else if(module_state_2 == module_active)
		uneq_module(module_state_2)
		module_state_2 = null
		inv2.icon_state = "inv2"
	else if(module_state_3 == module_active)
		uneq_module(module_state_3)
		module_state_3 = null
		inv3.icon_state = "inv3"

	module_active = null
	updateicon()
	hud_used.update_robot_modules_display()

/mob/living/silicon/robot/proc/activate_module(var/obj/item/O)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/activate_module() called tick#: [world.time]")
	if(!(locate(O) in src.module.modules) && O != src.module.emag)
		return
	if(activated(O))
		src << "<span class='notice'>Already activated</span>"
		return
	if(!module_state_1)
		module_state_1 = O
		O.layer = 20
		O.screen_loc = inv1.screen_loc
		O.forceMove(src)
		if(istype(module_state_1,/obj/item/borg/sight))
			sight_mode |= module_state_1:sight_mode
	else if(!module_state_2)
		module_state_2 = O
		O.layer = 20
		O.screen_loc = inv2.screen_loc
		O.forceMove(src)
		if(istype(module_state_2,/obj/item/borg/sight))
			sight_mode |= module_state_2:sight_mode
	else if(!module_state_3)
		module_state_3 = O
		O.layer = 20
		O.screen_loc = inv3.screen_loc
		O.forceMove(src)
		if(istype(module_state_3,/obj/item/borg/sight))
			sight_mode |= module_state_3:sight_mode
	else
		src << "<span class='notice'>You need to disable a module first!</span>"

/mob/living/silicon/robot/proc/uneq_all()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/uneq_all() called tick#: [world.time]")
	module_active = null

	if(module_state_1)
		uneq_module(module_state_1)
		module_state_1 = null
		inv1.icon_state = "inv1"

	if(module_state_2)
		uneq_module(module_state_2)
		module_state_2 = null
		inv2.icon_state = "inv2"

	if(module_state_3)
		uneq_module(module_state_3)
		module_state_3 = null
		inv3.icon_state = "inv3"

	updateicon()

/mob/living/silicon/robot/proc/activated(obj/item/O)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/activated() called tick#: [world.time]")
	if(module_state_1 == O)
		return 1
	else if(module_state_2 == O)
		return 1
	else if(module_state_3 == O)
		return 1
	else
		return 0
	updateicon()

//Helper procs for cyborg modules on the UI.
//These are hackish but they help clean up code elsewhere.

//module_selected(module) - Checks whether the module slot specified by "module" is currently selected.
/mob/living/silicon/robot/proc/module_selected(var/module) //Module is 1-3
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/module_selected() called tick#: [world.time]")
	return module == get_selected_module()

//module_active(module) - Checks whether there is a module active in the slot specified by "module".
/mob/living/silicon/robot/proc/module_active(var/module) //Module is 1-3
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/module_active() called tick#: [world.time]")
	if(module < 1 || module > 3) return 0

	switch(module)
		if(1)
			if(module_state_1)
				return 1
		if(2)
			if(module_state_2)
				return 1
		if(3)
			if(module_state_3)
				return 1
	return 0

//get_selected_module() - Returns the slot number of the currently selected module.  Returns 0 if no modules are selected.
/mob/living/silicon/robot/proc/get_selected_module()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/get_selected_module() called tick#: [world.time]")
	if(module_state_1 && module_active == module_state_1)
		return 1
	else if(module_state_2 && module_active == module_state_2)
		return 2
	else if(module_state_3 && module_active == module_state_3)
		return 3

	return 0

//select_module(module) - Selects the module slot specified by "module"
/mob/living/silicon/robot/proc/select_module(var/module) //Module is 1-3
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/select_module() called tick#: [world.time]")
	if(module < 1 || module > 3) return

	if(!module_active(module)) return

	switch(module)
		if(1)
			if(module_active != module_state_1)
				inv1.icon_state = "inv1 +a"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3"
				module_active = module_state_1
				return
		if(2)
			if(module_active != module_state_2)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2 +a"
				inv3.icon_state = "inv3"
				module_active = module_state_2
				return
		if(3)
			if(module_active != module_state_3)
				inv1.icon_state = "inv1"
				inv2.icon_state = "inv2"
				inv3.icon_state = "inv3 +a"
				module_active = module_state_3
				return
	return

//deselect_module(module) - Deselects the module slot specified by "module"
/mob/living/silicon/robot/proc/deselect_module(var/module) //Module is 1-3
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/deselect_module() called tick#: [world.time]")
	if(module < 1 || module > 3) return

	switch(module)
		if(1)
			if(module_active == module_state_1)
				inv1.icon_state = "inv1"
				module_active = null
				return
		if(2)
			if(module_active == module_state_2)
				inv2.icon_state = "inv2"
				module_active = null
				return
		if(3)
			if(module_active == module_state_3)
				inv3.icon_state = "inv3"
				module_active = null
				return
	return

//toggle_module(module) - Toggles the selection of the module slot specified by "module".
/mob/living/silicon/robot/proc/toggle_module(var/module) //Module is 1-3
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/toggle_module() called tick#: [world.time]")
	if(module < 1 || module > 3) return

	if(module_selected(module))
		deselect_module(module)
	else
		if(module_active(module))
			select_module(module)
		else
			deselect_module(get_selected_module()) //If we can't do select anything, at least deselect the current module.
	return

//cycle_modules() - Cycles through the list of selected modules.
/mob/living/silicon/robot/proc/cycle_modules()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/silicon/robot/proc/cycle_modules() called tick#: [world.time]")
	var/slot_start = get_selected_module()
	if(slot_start) deselect_module(slot_start) //Only deselect if we have a selected slot.

	var/slot_num
	if(slot_start == 0)
		slot_num = 1
		slot_start = 2
	else
		slot_num = slot_start + 1

	while(slot_start != slot_num) //If we wrap around without finding any free slots, just give up.
		if(module_active(slot_num))
			select_module(slot_num)
			return
		slot_num++
		if(slot_num > 3) slot_num = 1 //Wrap around.

	return

/mob/living/silicon/robot/before_take_item(var/obj/item/W)
	..()
	if(W.loc == src.module)
		src.module.modules -= W //maybe fix the cable issues.