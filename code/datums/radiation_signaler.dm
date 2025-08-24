GLOBAL_LIST_EMPTY(radiation_signalers)
/// A (per Z) singleton that broadcasts a signal to all the rad_interact components whenever a radiation pulse happens
/datum/radiation_signaler

/datum/radiation_signaler/New(z, emission_type)
	. = ..()
	if(z == null || !emission_type)
		qdel(src)
		CRASH("Attempted creation of radiation signaler without parameters")
	if(GLOB.radiation_signalers["[z]"]["[emission_type]"])
		qdel(src)
		CRASH("Duplicate radiation signaler in Z level")

/proc/get_radiation_signaler(z, emission_type)
	if(!GLOB.radiation_signalers["[z]"])
		GLOB.radiation_signalers["[z]"] = list()
		GLOB.radiation_signalers["[z]"]["[ALPHA_RAD]"] = new /datum/radiation_signaler(z, ALPHA_RAD)
		GLOB.radiation_signalers["[z]"]["[BETA_RAD]"] = new /datum/radiation_signaler(z, BETA_RAD)
		GLOB.radiation_signalers["[z]"]["[GAMMA_RAD]"] = new /datum/radiation_signaler(z, GAMMA_RAD)
	return GLOB.radiation_signalers["[z]"]["[emission_type]"]
