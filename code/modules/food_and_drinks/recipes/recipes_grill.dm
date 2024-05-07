
// /datum/recipe/grill

/datum/recipe/grill/bacon
	items = list(
		/obj/item/food/snacks/raw_bacon,
	)
	result = /obj/item/food/snacks/bacon

/datum/recipe/grill/telebacon
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/assembly/signaler
	)
	result = /obj/item/food/snacks/telebacon


/datum/recipe/grill/syntitelebacon
	items = list(
		/obj/item/food/snacks/meat/syntiflesh,
		/obj/item/assembly/signaler
	)
	result = /obj/item/food/snacks/telebacon

/datum/recipe/grill/friedegg
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/egg
	)
	result = /obj/item/food/snacks/friedegg

/datum/recipe/grill/birdsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/meat/chicken
	)
	result = /obj/item/food/snacks/meatsteak/chicken

/datum/recipe/grill/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/meatsteak

/datum/recipe/grill/salmonsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/salmonmeat
	)
	result = /obj/item/food/snacks/salmonsteak

/datum/recipe/grill/syntisteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/meat/syntiflesh
	)
	result = /obj/item/food/snacks/meatsteak

/datum/recipe/grill/waffles
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/waffles

/datum/recipe/grill/rofflewaffles
	reagents = list("psilocybin" = 5, "sugar" = 10)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/rofflewaffles

/datum/recipe/grill/grilledcheese
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/grilledcheese

/datum/recipe/grill/sausage
	items = list(
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/cutlet
	)
	result = /obj/item/food/snacks/sausage

/datum/recipe/grill/fishfingers
	reagents = list("flour" = 10)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/carpmeat
	)
	result = /obj/item/food/snacks/fishfingers

/datum/recipe/grill/fishfingers/make_food(obj/container)
	var/obj/item/food/snacks/fishfingers/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/grill/cutlet
	items = list(
		/obj/item/food/snacks/rawcutlet
	)
	result = /obj/item/food/snacks/cutlet

/datum/recipe/grill/omelette
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/omelette

/datum/recipe/grill/wingfangchu
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/food/snacks/monstermeat/xenomeat
	)
	result = /obj/item/food/snacks/wingfangchu

/datum/recipe/grill/human/kebab
	items = list(
		/obj/item/stack/rods,
		/obj/item/food/snacks/meat/human,
		/obj/item/food/snacks/meat/human
	)
	result = /obj/item/food/snacks/human/kebab

/datum/recipe/grill/syntikebab
	items = list(
		/obj/item/stack/rods,
		/obj/item/food/snacks/meat/syntiflesh,
		/obj/item/food/snacks/meat/syntiflesh
	)
	result = /obj/item/food/snacks/syntikebab

/datum/recipe/grill/meatkeb	// Do not put this above the other meat kebab variants or it will override them.
	items = list(
		/obj/item/stack/rods,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/meatkebab

/datum/recipe/grill/tofukebab
	items = list(
		/obj/item/stack/rods,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/tofu
	)
	result = /obj/item/food/snacks/tofukebab

/datum/recipe/grill/picoss_kebab
	reagents = list("vinegar" = 5)
	items = list(
		/obj/item/food/snacks/carpmeat,
		/obj/item/food/snacks/carpmeat,
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/grown/chili,
		/obj/item/stack/rods
	)
	result = /obj/item/food/snacks/picoss_kebab

/datum/recipe/grill/picoss_kebab/make_food(obj/container)
	var/obj/item/food/snacks/picoss_kebab/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/grill/sushi_Tamago
	reagents = list("sake" = 5)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/boiledrice,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Tamago

/datum/recipe/grill/sushi_Unagi
	reagents = list("sake" = 5)
	items = list(
		/obj/item/fish/electric_eel,
		/obj/item/food/snacks/boiledrice,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Unagi

/datum/recipe/grill/sushi_Ebi
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/boiled_shrimp,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Ebi

/datum/recipe/grill/sushi_Ikura
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/fish_eggs/salmon,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Ikura

/datum/recipe/grill/sushi_Inari
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/fried_tofu,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Inari

/datum/recipe/grill/sushi_Sake
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/salmonmeat,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Sake

/datum/recipe/grill/sushi_SmokedSalmon
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/salmonsteak,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_SmokedSalmon

/datum/recipe/grill/sushi_Masago
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/fish_eggs/goldfish,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Masago

/datum/recipe/grill/sushi_Tobiko
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/fish_eggs/shark,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Tobiko

/datum/recipe/grill/sushi_TobikoEgg
	items = list(
		/obj/item/food/snacks/sushi_Tobiko,
		/obj/item/food/snacks/egg,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_TobikoEgg

/datum/recipe/grill/sushi_Tai
	items = list(
		/obj/item/food/snacks/boiledrice,
		/obj/item/food/snacks/catfishmeat,
		/obj/item/stack/seaweed
	)
	result = /obj/item/food/snacks/sushi_Tai

/datum/recipe/grill/goliath
	items = list(/obj/item/food/snacks/monstermeat/goliath)
	result = /obj/item/food/snacks/goliath_steak

/datum/recipe/grill/shrimp_skewer
	items = list(
		/obj/item/food/snacks/shrimp,
		/obj/item/food/snacks/shrimp,
		/obj/item/food/snacks/shrimp,
		/obj/item/food/snacks/shrimp,
		/obj/item/stack/rods
	)
	result = /obj/item/food/snacks/shrimp_skewer

/datum/recipe/grill/fish_skewer
	reagents = list("flour" = 10)
	items = list(
		/obj/item/food/snacks/salmonmeat,
		/obj/item/food/snacks/salmonmeat,
		/obj/item/stack/rods
	)
	result = /obj/item/food/snacks/fish_skewer

/datum/recipe/grill/pancake
	items = list(
		/obj/item/food/snacks/cookiedough
	)
	result = /obj/item/food/snacks/pancake

/datum/recipe/grill/berry_pancake
	items = list(
		/obj/item/food/snacks/cookiedough,
		/obj/item/food/snacks/grown/berries
	)
	result = /obj/item/food/snacks/pancake/berry_pancake

/datum/recipe/grill/choc_chip_pancake
	items = list(
		/obj/item/food/snacks/cookiedough,
		/obj/item/food/snacks/choc_pile
	)
	result = /obj/item/food/snacks/pancake/choc_chip_pancake

/datum/recipe/grill/bbqribs
	reagents = list("bbqsauce" = 5)
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/bbqribs
