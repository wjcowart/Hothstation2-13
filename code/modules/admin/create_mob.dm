/var/create_mob_html = null
/datum/admins/proc/create_mob(var/mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/admins/proc/create_mob() called tick#: [world.time]")
	if (!create_mob_html)
		var/mobjs = null
		mobjs = list2text(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(replacetext(create_mob_html, "/* ref src */", "\ref[src]"), "window=create_mob;size=425x520")