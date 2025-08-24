

/// A component that casts a ray from a rad source to something that could be affected by rads
/datum/component/rad_interact
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/emission_types = list()

/datum/component/rad_interact/Initialize(list/_emission_types)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	emission_types = _emission_types.Copy()
	var/atom/thing = parent
	RegisterSignal(thing, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(change_z))
	for(var/emission in emission_types)
		var/datum/radiation_signaler = get_radiation_signaler(thing.z, emission)
		RegisterSignal(radiation_signaler, COMSIG_RAD_PULSE, PROC_REF(do_rad_pulse))


/datum/component/rad_interact/proc/change_z(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER // COMSIG_MOVABLE_Z_CHANGED
	for(var/emission in emission_types)
		var/datum/radiation_signaler/rad_signaler = get_radiation_signaler(old_turf.z, emission)
		UnregisterSignal(rad_signaler, COMSIG_RAD_PULSE)

		rad_signaler = get_radiation_signaler(new_turf.z, emission)
		RegisterSignal(rad_signaler, COMSIG_RAD_PULSE, PROC_REF(do_rad_pulse))

/datum/component/rad_interact/proc/do_rad_pulse(datum/source, atom/rad_source, emission_type, intensity, source_radius)
	SIGNAL_HANDLER // COMSIG_RAD_PULSE
	var/atom/thing = parent
	var/turf/start = get_turf(rad_source)
	var/turf/end = get_turf(thing)
	var/dx = abs(end.x - start.x)
	var/dy = abs(end.y - start.y)

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
		var/turf/curr_turf = locate(x, y, thing.z)
		var/list/turf_atoms = list(curr_turf)
		if(length(curr_turf.contents))
			if(i == dx + dy)
				turf_atoms = get_rad_contents(curr_turf, emission_type)
			else
				intensity *= turf_rad_block(curr_turf, emission_type)

		for(var/atom/blocker in turf_atoms)
			if(QDELETED(blocker))
				continue
			// Atoms from the tile are listed by priority so we need to stop blocking if we reached ourselves
			if(i == dx + dy && blocker.UID() == thing.UID())
				break
			intensity *= rad_insulate(emission_type, blocker)
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

	thing.rad_act(rad_source, intensity, emission_type)
