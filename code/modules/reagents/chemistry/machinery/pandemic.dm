/// list of known advanced disease ids. If an advanced disease isn't here it will display as unknown disease on scanners
/// Initialized with the id of the flu and cold samples from the virologist's fridge
GLOBAL_LIST_INIT(known_advanced_diseases, list("4:origin", "25:origin"
))

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pandemic0"
	circuit = /obj/item/circuitboard/pandemic
	idle_power_consumption = 20
	resistance_flags = ACID_PROOF
	/// Amount of time it takes to analyze an advanced disease. units are 2 seconds
	var/analysisTime = -1
	/// Amount of time to add to the analysis time. resets upon successful analysis. units are 2 seconds
	var/accumulatedError = 0
	/// Whether the PANDEMIC is currently analyzing an advanced disease
	var/analyzing = FALSE
	/// ID of the disease being analyzed
	var/analyzed_ID = ""
	/// list of all symptoms. Gets filled in Initialize().
	var/symptomlist = list()
	var/temp_html = ""
	var/printing = null
	var/wait = null
	var/selected_strain_index = 1
	var/obj/item/reagent_containers/beaker = null

/obj/machinery/computer/pandemic/Initialize(mapload)
	. = ..()
	GLOB.pandemics |= src
	var/datum/symptom/S
	symptomlist += list("No Guess")
	for(var/i in GLOB.list_symptoms)
		//I don't know a way to access the names of types that have no instances.
		S = new i()
		symptomlist += list(S.name)
		qdel(S)

	update_icon()

/obj/machinery/computer/pandemic/Destroy()
	GLOB.pandemics -= src
	return ..()

/obj/machinery/computer/pandemic/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/computer/pandemic/proc/GetViruses()
	if(beaker && beaker.reagents)
		if(length(beaker.reagents.reagent_list))
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					return viruses

/obj/machinery/computer/pandemic/proc/GetVirusByIndex(index)
	var/list/viruses = GetViruses()
	if(viruses && index > 0 && index <= length(viruses))
		return viruses[index]

/obj/machinery/computer/pandemic/proc/GetResistances()
	if(beaker && beaker.reagents)
		if(length(beaker.reagents.reagent_list))
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["resistances"])
					var/list/resistances = BL.data["resistances"]
					return resistances

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(index)
	var/list/resistances = GetResistances()
	if(resistances && index > 0 && index <= length(resistances))
		return resistances[index]

/obj/machinery/computer/pandemic/proc/GetVirusTypeByIndex(index)
	var/datum/disease/D = GetVirusByIndex(index)
	if(D)
		return D.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(loc, 'sound/machines/ping.ogg', 30, 1)

/obj/machinery/computer/pandemic/update_icon_state()
	if(stat & BROKEN)
		icon_state = (beaker ? "pandemic1_b" : "pandemic0_b")
		return
	icon_state = "pandemic[(beaker)?"1":"0"][(has_power()) ? "" : "_nopower"]"

/obj/machinery/computer/pandemic/update_overlays()
	. = list()
	if(!wait)
		. += "waitlight"

/obj/machinery/computer/pandemic/proc/create_culture(name, bottle_type = "culture", cooldown = 50)
	var/obj/item/reagent_containers/glass/bottle/B = new/obj/item/reagent_containers/glass/bottle(loc)
	B.icon_state = "round_bottle"
	B.pixel_x = rand(-3, 3)
	B.pixel_y = rand(-3, 3)
	replicator_cooldown(cooldown)
	B.name = "[name] [bottle_type] bottle"
	return B

/obj/machinery/computer/pandemic/proc/find_analysis_time(datum/reagent/R)
	var/strains = 0
	var/stage_amount = 0
	var/list/stages = list()
	var/current_strain = ""
	var/stealth_init = FALSE
	var/stealth = 0
	for(var/datum/disease/advance/AD in R.data["viruses"])
		if(AD.GetDiseaseID() in GLOB.known_advanced_diseases)
			return
		if(AD.strain != current_strain || current_strain == "")
			strains++
			if(strains > 1)
				analysisTime = - 2
				SStgui.update_uis(src, TRUE)
				return
			current_strain = AD.strain

		if(!stealth_init)
			for(var/datum/symptom/S in AD.symptoms)
				stealth += S.stealth
			stealth_init = TRUE

		if(!(AD.stage in stages))
			stage_amount++
			stages += AD.stage

	analysisTime = (max(((max(stealth , 0) + 1.05) - stage_amount) , 0) MINUTES) + accumulatedError
	SStgui.update_uis(src, TRUE)


/obj/machinery/computer/pandemic/proc/stop_analysis()
	analysisTime = -1
	analyzing = FALSE
	analyzed_ID = ""

/obj/machinery/computer/pandemic/proc/analyze(disease_ID, symptoms)
	analyzing = TRUE
	analyzed_ID = disease_ID
	var/names = list()
	var/guesses = list()
	for(var/i in symptoms)
		names += list(i["name"])
		guesses += list(i["guess"])
	for(var/i in guesses)
		if(!i || i == "No Guess")
			continue
		if(i in names)
			analysisTime = max(0, analysisTime - 0.3 MINUTES)
		else
			analysisTime = max(0, analysisTime + 1 MINUTES)
			accumulatedError += 1 MINUTES


/obj/machinery/computer/pandemic/process()
	. = ..()
	if(analyzing)
		if(analysisTime < 0)
			analyzing = FALSE
			return

		if(analysisTime > 0)
			analysisTime -= clamp(1 , 0 , max(analysisTime , 0))

		if(analysisTime == 0)
			GLOB.known_advanced_diseases += analyzed_ID
			analyzing = FALSE
			analysisTime = -1
			SStgui.update_uis(src, TRUE)

/obj/machinery/computer/pandemic/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(inoperable())
		return


	. = TRUE

	switch(action)
		if("clone_strain")
			if(wait)
				atom_say("The replicator is not ready yet.")
				return

			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index))
				atom_say("Unable to respond to command.")
				return
			var/datum/disease/virus = GetVirusByIndex(strain_index)
			var/datum/disease/D = null
			if(!virus)
				atom_say("Unable to find requested strain.")
				return
			var/type = virus.GetDiseaseID()
			if(!ispath(type))
				var/datum/disease/advance/A = GLOB.archive_diseases[type]
				if(A)
					D = new A.type(0, A)
			else if(type)
				if(type in GLOB.diseases) // Make sure this is a disease
					D = new type(0, null)
			if(!D)
				atom_say("Unable to synthesize requested strain.")
				return
			var/default_name = ""
			if(D.name == "Unknown" || D.name == "")
				default_name = replacetext(beaker.name, new/regex(" culture bottle\\Z", "g"), "")
			else
				default_name = D.name
			var/name = tgui_input_text(usr, "Name:", "Name the culture", default_name, MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/reagent_containers/glass/bottle/B = create_culture(name)
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood", 20, list("viruses" = list(D)))
		if("clone_vaccine")
			if(wait)
				atom_say("The replicator is not ready yet.")
				return

			var/resistance_index = text2num(params["resistance_index"])
			if(isnull(resistance_index))
				atom_say("Unable to find requested antibody.")
				return
			var/vaccine_type = GetResistancesByIndex(resistance_index)
			var/vaccine_name = "Unknown"
			if(!ispath(vaccine_type))
				if(GLOB.archive_diseases[vaccine_type])
					var/datum/disease/D = GLOB.archive_diseases[vaccine_type]
					if(D)
						vaccine_name = D.name
			else if(vaccine_type)
				var/datum/disease/D = new vaccine_type(0, null)
				if(D)
					vaccine_name = D.name

			if(!vaccine_type)
				atom_say("Unable to synthesize requested antibody.")
				return

			var/obj/item/reagent_containers/glass/bottle/B = create_culture(vaccine_name, "vaccine", 200)
			B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
		if("eject_beaker")
			stop_analysis()
			eject_beaker()
			update_static_data(ui.user)
		if("destroy_eject_beaker")
			beaker.reagents.clear_reagents()
			eject_beaker()
			update_static_data(ui.user)
		if("print_release_forms")
			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index))
				atom_say("Unable to respond to command.")
				return
			var/type = GetVirusTypeByIndex(strain_index)
			if(!type)
				atom_say("Unable to find requested strain.")
				return
			var/datum/disease/advance/A = GLOB.archive_diseases[type]
			if(!A)
				atom_say("Unable to find requested strain.")
				return
			print_form(A, usr)
		if("name_strain")
			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index))
				atom_say("Unable to respond to command.")
				return
			var/type = GetVirusTypeByIndex(strain_index)
			if(!type)
				atom_say("Unable to find requested strain.")
				return
			var/datum/disease/advance/A = GLOB.archive_diseases[type]
			if(!A)
				atom_say("Unable to find requested strain.")
				return
			if(A.name != "Unknown")
				atom_say("Request rejected. Strain already has a name.")
				return
			var/new_name = tgui_input_text(usr, "Name the Strain", "New Name", max_length = MAX_NAME_LEN)
			if(!new_name)
				return
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in GLOB.active_diseases)
				AD.Refresh()
			update_static_data(ui.user)
		if("switch_strain")
			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index) || strain_index < 1)
				atom_say("Unable to respond to command.")
				return
			var/list/viruses = GetViruses()
			if(strain_index > length(viruses))
				atom_say("Unable to find requested strain.")
				return
			selected_strain_index = strain_index;
		if("analyze_strain")
			analyze(params["strain_id"], params["symptoms"])
		else
			return FALSE

/obj/machinery/computer/pandemic/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/pandemic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PanDEMIC", name)
		ui.open()

/obj/machinery/computer/pandemic/ui_data(mob/user)
	var/datum/reagent/blood/Blood = null
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break

	var/list/data = list(
		"synthesisCooldown" = wait ? TRUE : FALSE,
		"beakerLoaded" = beaker ? TRUE : FALSE,
		"beakerContainsBlood" = Blood ? TRUE : FALSE,
		"beakerContainsVirus" = length(Blood?.data["viruses"]) != 0,
		"selectedStrainIndex" = selected_strain_index,
		"analysisTime" = analysisTime,
		"analyzing" = analyzing,
		"sympton_names" = symptomlist,
	)

	return data

/obj/machinery/computer/pandemic/ui_static_data(mob/user)
	var/list/data = list()
	. = data

	var/datum/reagent/blood/Blood = null
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break

	var/list/strains = list()
	for(var/datum/disease/D in GetViruses())
		var/known = FALSE
		if(D.visibility_flags & HIDDEN_PANDEMIC)
			continue

		var/list/symptoms = list()
		var/datum/disease/advance/A = D
		if(istype(D, /datum/disease/advance))
			known = (A.GetDiseaseID() in GLOB.known_advanced_diseases)
			D = GLOB.archive_diseases[A.GetDiseaseID()]
			if(!D)
				CRASH("We weren't able to get the advance disease from the archive.")
			for(var/datum/symptom/S in A.symptoms)
				symptoms += list(list(
					"name" = S.name,
					"stealth" = known ? S.stealth : "UNKNOWN",
					"resistance" = known ? S.resistance : "UNKNOWN",
					"stageSpeed" = known ? S.stage_speed : "UNKNOWN",
					"transmissibility" = known ? S.transmittable : "UNKNOWN",
					"complexity" = known ? S.level : "UNKNOWN",
				))
		else
			known = TRUE
		strains += list(list(
			"commonName" = known ? D.name : "Unknown strain",
			"description" = known ? D.desc : "Unknown strain",
			"strainID" = istype(D, /datum/disease/advance) ? A.strain : D.name,
			"diseaseID" = istype(D, /datum/disease/advance) ? A.id : D.name,
			"sample_stage" = D.stage,
			"known" = known,
			"bloodDNA" = Blood.data["blood_DNA"],
			"bloodType" = Blood.data["blood_type"],
			"diseaseAgent" = D.agent,
			"possibleTreatments" = known ? D.cure_text : "Unknown strain",
			"transmissionRoute" = known ? D.spread_text : "Unknown strain",
			"symptoms" = symptoms,
			"isAdvanced" = istype(D, /datum/disease/advance),
		))
	data["strains"] = strains

	var/list/resistances = list()
	for(var/resistance in GetResistances())
		if(!ispath(resistance))
			var/datum/disease/D = GLOB.archive_diseases[resistance]
			if(D)
				resistances += list(D.name)
		else if(resistance)
			var/datum/disease/D = new resistance(0, null)
			if(D)
				resistances += list(D.name)
	data["resistances"] = resistances
	data["analysisTime"] = analysisTime

/obj/machinery/computer/pandemic/proc/eject_beaker()
	beaker.forceMove(loc)
	beaker = null
	icon_state = "pandemic0"
	selected_strain_index = 1

//Prints a nice virus release form. Props to Urbanliner for the layout
/obj/machinery/computer/pandemic/proc/print_form(datum/disease/advance/D, mob/living/user)
	D = GLOB.archive_diseases[D.GetDiseaseID()]
	if(!(printing) && D)
		var/reason = tgui_input_text(user,"Enter a reason for the release", "Write", multiline = TRUE)
		if(!reason)
			return
		reason += "<span class=\"paper_field\"></span>"
		var/english_symptoms = list()
		for(var/I in D.symptoms)
			var/datum/symptom/S = I
			english_symptoms += S.name
		var/symtoms = english_list(english_symptoms)


		var/signature
		if(tgui_alert(user, "Would you like to add your signature?", "Signature", list("Yes","No")) == "Yes")
			signature = "<font face=\"[SIGNFONT]\"><i>[user ? user.real_name : "Anonymous"]</i></font>"
		else
			signature = "<span class=\"paper_field\"></span>"

		printing = 1
		var/obj/item/paper/P = new /obj/item/paper(loc)
		visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

		P.info = "<U><font size=\"4\"><B><center> Releasing Virus </B></center></font></U>"
		P.info += "<HR>"
		P.info += "<U>Name of the Virus:</U> [D.name] <BR>"
		P.info += "<U>Symptoms:</U> [symtoms]<BR>"
		P.info += "<U>Spreads by:</U> [D.spread_text]<BR>"
		P.info += "<U>Cured by:</U> [D.cure_text]<BR>"
		P.info += "<BR>"
		P.info += "<U>Reason for releasing:</U> [reason]"
		P.info += "<HR>"
		P.info += "The Virologist is responsible for any biohazards caused by the virus released.<BR>"
		P.info += "<U>Virologist's sign:</U> [signature]<BR>"
		P.info += "If approved, stamp below with the Chief Medical Officer's stamp, and/or the Captain's stamp if required:"
		P.populatefields()
		P.updateinfolinks()
		P.name = "Releasing Virus - [D.name]"
		printing = null

/obj/machinery/computer/pandemic/proc/print_goal_orders()
	if(stat & (BROKEN|NOPOWER))
		return

	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	var/obj/item/paper/P = new /obj/item/paper(loc)
	P.name = "paper - 'Viral Samples Request'"

	var/list/info_text = list("<div style='text-align:center;'><img src='ntlogo.png'>")
	info_text += "<h3>Viral Sample Orders</h3></div><hr>"
	info_text += "<b>Viral Sample Orders for [station_name()]'s Virologist:</b><br><br>"

	for(var/datum/virology_goal/G in GLOB.virology_goals)
		info_text += G.get_report()
		info_text += "<hr>"
	info_text += "-Nanotrasen Virology Research"

	P.info = info_text.Join("")
	P.update_icon()

/obj/machinery/computer/pandemic/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/pandemic/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I, time = 4 SECONDS))
		power_change()
		return
	if((istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER)) && user.a_intent != INTENT_HARM)
		if(stat & (NOPOWER|BROKEN))
			return
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine!</span>")
			return
		if(!user.drop_item())
			return

		beaker =  I
		beaker.loc = src
		to_chat(user, "<span class='notice'>You add the beaker to the machine.</span>")
		SStgui.update_uis(src, TRUE)
		icon_state = "pandemic1"
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			if(R.id == "blood")
				find_analysis_time(R)
				break


	else
		return ..()

/obj/machinery/computer/pandemic/screwdriver_act(mob/user, obj/item/I)
	if(beaker)
		eject_beaker()
		return TRUE
	return ..()
