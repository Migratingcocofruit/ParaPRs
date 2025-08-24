GLOBAL_LIST_EMPTY(radiation_signalers)
/// A (per Z) singleton that broadcasts a signal to all the rad_interact components whenever a radiation pulse happens
/datum/radiation_signaler

/datum/radiation_signaler/New(z)
	. = ..()
	if(GLOB.radiation_signalers["[z]"])
		qdel(src)
		CRASH("Duplicate radiation signaler in Z level")

/proc/get_radiation_signaler(z)
	if(!GLOB.radiation_signalers["[z]"])
		GLOB.radiation_signalers["[z]"] = new /datum/radiation_signaler()
	return GLOB.radiation_signalers["[z]"]
