/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "water"
	density = TRUE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	max_integrity = 300
	var/tank_volume = 1000 //In units, how much the dispenser can hold
	var/reagent_id = /datum/reagent/water //The ID of the reagent that the dispenser uses

/obj/structure/reagent_dispensers/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		if(tank_volume && (damage_flag == "bullet" || damage_flag == "laser"))
			boom()

/obj/structure/reagent_dispensers/attackby(obj/item/W, mob/user, params)
	if(W.is_refillable())
		return 0 //so we can refill them via their afterattack.
	else
		return ..()

/obj/structure/reagent_dispensers/Initialize()
	create_reagents(tank_volume, DRAINABLE | AMOUNT_VISIBLE)
	reagents.add_reagent(reagent_id, tank_volume)
	. = ..()

/obj/structure/reagent_dispensers/proc/boom()
	visible_message("<span class='danger'>\The [src] ruptures!</span>")
	chem_splash(loc, 5, list(reagents))
	qdel(src)

/obj/structure/reagent_dispensers/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			boom()
	else
		qdel(src)

///////////////
//Water Tanks//
///////////////

/obj/structure/reagent_dispensers/watertank
	name = "water tank"
	desc = "A water tank."
	icon_state = "water"

/obj/structure/reagent_dispensers/watertank/high
	name = "high-capacity water tank"
	desc = "A highly pressurized water tank made to hold gargantuan amounts of water."
	icon_state = "water_high" //I was gonna clean my room...
	tank_volume = 100000

/obj/structure/reagent_dispensers/foamtank
	name = "firefighting foam tank"
	desc = "A tank full of firefighting foam."
	icon_state = "foam"
	reagent_id = /datum/reagent/firefighting_foam
	tank_volume = 500

/obj/structure/reagent_dispensers/water_cooler
	name = "liquid cooler"
	desc = "A machine that dispenses liquid to drink."
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	anchored = TRUE
	tank_volume = 500
	var/paper_cups = 25 //Paper cups left from the cooler

/obj/structure/reagent_dispensers/water_cooler/examine(mob/user)
	..()
	if (paper_cups > 1)
		to_chat(user, "There are [paper_cups] paper cups left.")
	else if (paper_cups == 1)
		to_chat(user, "There is one paper cup left.")
	else
		to_chat(user, "There are no paper cups left.")

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!paper_cups)
		to_chat(user, "<span class='warning'>There aren't any cups left!</span>")
		return
	user.visible_message("<span class='notice'>[user] takes a cup from [src].</span>", "<span class='notice'>You take a paper cup from [src].</span>")
	var/obj/item/reagent_containers/food/drinks/sillycup/S = new(get_turf(src))
	user.put_in_hands(S)
	paper_cups--

//////////////
//Fuel Tanks//
//////////////

/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A tank full of industrial welding fuel. Do not consume."
	icon_state = "fuel"
	reagent_id = /datum/reagent/fuel

/obj/structure/reagent_dispensers/fueltank/high //Unused - Good for ghost roles
	name = "high-capacity fuel tank"
	desc = "A now illegal tank, full of highly pressurized industrial welding fuel. Do not consume or have a open flame close to this tank."
	icon_state = "fuel_high"
	tank_volume = 3000

/obj/structure/reagent_dispensers/fueltank/proc/explode()
	explosion(get_turf(src), 0, 1, 5, flame_range = 5)
	qdel(src)

/obj/structure/reagent_dispensers/fueltank/blob_act(obj/structure/blob/B)
	boom()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	explode()

/obj/structure/reagent_dispensers/fueltank/fire_act(exposed_temperature, exposed_volume)
	explode()

/obj/structure/reagent_dispensers/fueltank/tesla_act()
	..() //extend the zap
	boom()

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/item/projectile/P)
	..()
	if(!QDELETED(src)) //wasn't deleted by the projectile's effects.
		if(!P.nodamage && (P.damage_type == BURN))
			var/boom_message = "[ADMIN_LOOKUPFLW(P.firer)] triggered a fueltank explosion via projectile."
			GLOB.bombers += boom_message
			message_admins(boom_message)
			P.firer?.log_message("triggered a fueltank explosion via projectile.", LOG_ATTACK)
			explode()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weldingtool))
		if(!reagents.has_reagent(/datum/reagent/fuel))
			to_chat(user, "<span class='warning'>[src] is out of fuel!</span>")
			return
		var/obj/item/weldingtool/W = I
		if(!W.welding)
			if(W.reagents.has_reagent(/datum/reagent/fuel, W.max_fuel))
				to_chat(user, "<span class='warning'>Your [W.name] is already full!</span>")
				return
			reagents.trans_to(W, W.max_fuel)
			user.visible_message("<span class='notice'>[user] refills [user.p_their()] [W.name].</span>", "<span class='notice'>You refill [W].</span>")
			playsound(src, 'sound/effects/refill.ogg', 50, 1)
			W.update_icon()
		else
			var/turf/T = get_turf(src)
			if(!HAS_TRAIT(user, TRAIT_DUMB))
				to_chat(user, "<span class='warning'>That would be extremely stupid.</span>")
				message_admins("[ADMIN_LOOKUPFLW(user)] tried to trigger a fueltank explosion via welding tool at [ADMIN_VERBOSEJMP(T)].")
				return

			user.visible_message("<span class='warning'>[user] catastrophically fails at refilling [user.p_their()] [W.name]!</span>", "<span class='userdanger'>That was stupid of you.</span>")
			var/message_admins = "[ADMIN_LOOKUPFLW(user)] triggered a fueltank explosion via welding tool at [ADMIN_VERBOSEJMP(T)]."
			GLOB.bombers += message_admins
			message_admins(message_admins)

			user.log_message("triggered a fueltank explosion via welding tool.", LOG_ATTACK)
			explode()
		return
	return ..()

///////////////////
//Misc Dispenders//
///////////////////

/obj/structure/reagent_dispensers/peppertank
	name = "pepper spray refiller"
	desc = "Contains condensed capsaicin for use in law \"enforcement.\""
	icon_state = "pepper"
	anchored = TRUE
	density = FALSE
	reagent_id = /datum/reagent/consumable/condensedcapsaicin

/obj/structure/reagent_dispensers/peppertank/Initialize()
	. = ..()
	if(prob(1))
		desc = "IT'S PEPPER TIME, BITCH!"

/obj/structure/reagent_dispensers/virusfood
	name = "virus food dispenser"
	desc = "A dispenser of low-potency virus mutagenic."
	icon_state = "virus_food"
	anchored = TRUE
	density = FALSE
	reagent_id = /datum/reagent/consumable/virus_food

/obj/structure/reagent_dispensers/cooking_oil
	name = "vat of cooking oil"
	desc = "A huge metal vat with a tap on the front. Filled with cooking oil for use in frying food."
	icon_state = "vat"
	anchored = TRUE
	reagent_id = /datum/reagent/consumable/cooking_oil

////////
//Kegs//
////////

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "Beer is liquid bread, it's good for you..."
	icon_state = "beer"
	reagent_id = /datum/reagent/consumable/ethanol/beer

/obj/structure/reagent_dispensers/beerkeg/blob_act(obj/structure/blob/B)
	explosion(src.loc,0,3,5,7,10)
	if(!QDELETED(src))
		qdel(src)

/obj/structure/reagent_dispensers/keg
	name = "keg"
	desc = "A keg."
	icon = 'modular_citadel/icons/obj/objects.dmi'
	icon_state = "keg"

/obj/structure/reagent_dispensers/keg/mead
	name = "keg of mead"
	desc = "A keg of mead."
	icon_state = "orangekeg"
	reagent_id = /datum/reagent/consumable/ethanol/mead

/obj/structure/reagent_dispensers/keg/aphro
	name = "keg of aphrodisiac"
	desc = "A keg of aphrodisiac."
	icon_state = "pinkkeg"
	reagent_id = /datum/reagent/drug/aphrodisiac
	tank_volume = 150

/obj/structure/reagent_dispensers/keg/aphro/strong
	name = "keg of strong aphrodisiac"
	desc = "A keg of strong and addictive aphrodisiac."
	reagent_id = /datum/reagent/drug/aphrodisiacplus
	tank_volume = 120

/obj/structure/reagent_dispensers/keg/milk
	name = "keg of milk"
	desc = "It's not quite what you were hoping for."
	icon_state = "whitekeg"
	reagent_id = /datum/reagent/consumable/milk

/obj/structure/reagent_dispensers/keg/semen
	name = "keg of semen"
	desc = "Dear lord, where did this even come from?"
	icon_state = "whitekeg"
	reagent_id = /datum/reagent/consumable/semen

/obj/structure/reagent_dispensers/keg/gargle
	name = "keg of pan galactic gargleblaster"
	desc = "A keg of... wow that's a long name."
	icon_state = "bluekeg"
	reagent_id = /datum/reagent/consumable/ethanol/gargle_blaster
	tank_volume = 100
