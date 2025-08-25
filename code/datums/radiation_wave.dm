#define WRAP_INDEX(index, length)((index - 1) % length + 1)

/datum/radiation_wave
	/// The thing that spawned this radiation wave
	var/turf/source
	/// The type of particle emitted
	var/emission_type = ALPHA_RAD
	/// How strong the wave is
	var/intensity = 0
	/// Size of the radiation source
	var/source_radius = 0

/datum/radiation_wave/New(turf/_source, _intensity = 0, _emission_type = ALPHA_RAD, _source_radius = 0)

	source = _source
	intensity = _intensity
	emission_type = _emission_type
	source_radius = _source_radius
	START_PROCESSING(SSradiation, src)

/datum/radiation_wave/Destroy()
	. = QDEL_HINT_IWILLGC
	STOP_PROCESSING(SSradiation, src)
	..()


/// Deals with wave propagation. Radiation waves always expand in a 90 degree cone
/datum/radiation_wave/process()
	if(GLOB.rad_interact_components["[source.z]"])
		for(var/datum/component/rad_interact/interactor in GLOB.rad_interact_components["[source.z]"]["[emission_type]"])
			interactor.do_rad_pulse(source, emission_type, intensity, source_radius, TRUE)
	qdel(src)
