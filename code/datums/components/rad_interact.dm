GLOBAL_LIST_EMPTY(rad_interact_components)

/// A component that casts a ray from a rad source to something that could be affected by rads
/datum/component/rad_interact
	var/list/emission_types = list()
	var/my_z
/// Same component but we can only get this via our reagents datum
/datum/component/rad_interact/reagents


/datum/component/rad_interact/Initialize(list/_emission_types, source = "self")
	if(!parent || !isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/thing = parent
	var/turf/ground = get_turf(parent)
	my_z = ground.z
	if(!ground)
		return COMPONENT_INCOMPATIBLE

	emission_types = _emission_types.Copy()
	RegisterSignal(thing, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(change_z))
	if(!GLOB.rad_interact_components["[ground.z]"])
		GLOB.rad_interact_components["[ground.z]"] = list()
	for(var/emission in emission_types)
		GLOB.rad_interact_components["[ground.z]"]["[emission]"] += list(src)



/datum/component/rad_interact/proc/change_z(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER // COMSIG_MOVABLE_Z_CHANGED
	if(!GLOB.rad_interact_components["[new_turf.z]"])
		GLOB.rad_interact_components["[new_turf.z]"] = list()

	for(var/emission in emission_types)
		GLOB.rad_interact_components["[old_turf.z]"]["[emission]"] -= list(src)
		GLOB.rad_interact_components["[new_turf.z]"]["[emission]"] |= list(src)

	my_z = new_turf.z


/datum/component/rad_interact/Destroy(force, silent)
	for(var/emission in emission_types)
		GLOB.rad_interact_components["[my_z]"]["[emission]"] -= list(src)
		GLOB.rad_interact_components["[my_z]"]["[emission]"] |= list(src)
	return ..()

/datum/component/rad_interact/proc/do_rad_pulse(turf/rad_source, emission_type, intensity, source_radius, sync = TRUE)
	if(!parent)
		return
	var/atom/thing = parent
	var/turf/end = get_turf(thing)
	var/dx = abs(end.x - rad_source.x)
	var/dy = abs(end.y - rad_source.y)

	var/x_step = thing.x > rad_source.x ? 1 : -1
	var/y_step = thing.y > rad_source.y ? 1 : -1

	var/x = rad_source.x
	var/y = rad_source.y

	// distance to next vertical grid line - distance to next horizontal grid line
	// On a line of length dx * dy (in arbitrary units)
	// dt / dx = dy and dt / dy = dx
	var/diff = dx - dy

	// Intensity decays linearly with distance from source because we are in 2D space
	// This makes balancing rad collectors much easier, especially for singulo
	if(dx + dy)
		intensity /= 2 * PI * ((dx ** 2 + dy ** 2) ** 0.5)

	// If we decayed enough we can stop
	if(intensity < RAD_BACKGROUND_RADIATION)
		return


	// Using this loop style so i can be incremented mid loop
	for(var/i = 0; i < (1 + dx + dy); i++)

		//visit
		var/turf_mod = 1
		var/turf/curr_turf = locate(x, y, thing.z)
		GLOB.rad_visited++

		// When we reach our own tile we check it against a different cache, one containing a list of the atom rather than a calculated final value. This is so we can take priority into account
		if(i == dx + dy)
			var/list/turf_atoms = list()
			if(!sync || !GLOB.rad_item_cache["[emission_type]"][curr_turf])
				turf_atoms = get_rad_contents(curr_turf, emission_type)
				if(sync)
					GLOB.rad_item_cache["[emission_type]"][curr_turf] = turf_atoms.Copy()
					GLOB.rad_item_cache_miss++
			else
				turf_atoms = GLOB.rad_item_cache[curr_turf]
				GLOB.rad_item_cache_hit++
			for(var/atom/blocker in turf_atoms)
				if(QDELETED(blocker))
					continue
				// Atoms from the tile are listed by priority so we need to stop blocking if when we reach ourselves
				if(blocker.UID() == thing.UID())
					break
				intensity *= rad_insulate(emission_type, blocker)
				// If we decayed enough we can stop
				if(intensity < RAD_BACKGROUND_RADIATION)
					return

		else if(!sync || !GLOB.rad_insul_turf_cache["[emission_type]"][curr_turf])
			turf_mod = turf_rad_block(curr_turf, emission_type)
			if(sync)
				GLOB.rad_insul_turf_cache["[emission_type]"][curr_turf] = turf_mod
				GLOB.rad_cache_miss++
		else
			turf_mod = GLOB.rad_insul_turf_cache["[emission_type]"][curr_turf]
			GLOB.rad_cache_hit++

		intensity *= turf_mod

		// If we decayed enough we can stop
		if(intensity < RAD_BACKGROUND_RADIATION)
			return

		if(diff > 0)
			x += x_step
			diff -= dy
		else if(diff < 0)
			y += y_step
			diff += dx
		else
			x += x_step
			y += y_step
			i++
			diff += (dx - dy)

	thing.base_rad_act(rad_source, intensity, emission_type)
