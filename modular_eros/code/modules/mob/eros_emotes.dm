/datum/emote/living/tilt
	key = "tilt"
	key_third_person = "tilts their head"
	message = "tilts their head."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/squint
	key = "squint"
	key_third_person = "squints their head"
	message = "squints their head."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/fart
	key = "fart"
	key_third_person = "farts"
	message = "farts out shitcode."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/fart/run_emote(mob/user, params, type_override, intentional)
	var/static/list/fart_emotes = list( //cope goonies
		" lets out a girly little 'toot' from their butt.",
		" farts loudly!",
		" lets one rip!",
		" farts! It sounds wet and smells like rotten eggs.",
		" farts robustly!",
		" farted! It smells like something died.",
		" farts like a muppet!",
		" defiles the station's air supply.",
		" farts a ten second long fart.",
		" groans and moans, farting like the world depended on it.",
		" breaks wind!",
		" expels intestinal gas through the anus.",
		" release an audible discharge of intestinal gas.",
		" is a farting motherfucker!!!",
		" suffers from flatulence!",
		" releases flatus.",
		" releases methane.",
		" farts up a storm.",
		" farts. It smells like Soylent Surprise!",
		" farts. It smells like pizza!",
		" farts. It smells like George Melons' perfume!",
		" farts. It smells like the kitchen!",
		" farts. It smells like medbay in here now!",
		" farts. It smells like the bridge in here now!",
		" farts like a pubby!",
		" farts like a goone!",
		" sharts! That's just nasty.",
		" farts delicately.",
		" farts timidly.",
		" farts very, very quietly. The stench is OVERPOWERING.",
		" farts egregiously.",
		" farts voraciously.",
		" farts cantankerously.",
		" fart in they own mouth. A shameful %OWNER.",
		" breaks wind noisily!",
		" releases gas with the power of the gods! The very station trembles!!",
		"<B>%OWNER <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>",
		" laughs! Their breath smells like a fart.",
		" farts, and as such, blob cannot evoulate.",
		" farts. It might have been the Citizen Kane of farts."
	)
	message = pick(fart_emotes)
	message = replacetext(message, "%OWNER", "[user]")
	. = ..()
	if(.)
		playsound(user, pick(\
			'modular_eros/sound/voice/farts/fart.ogg',\
			'modular_eros/sound/voice/farts/fart1.ogg',\
			'modular_eros/sound/voice/farts/fart2.ogg',\
			'modular_eros/sound/voice/farts/fart3.ogg',\
			'modular_eros/sound/voice/farts/fart4.ogg',\
			'modular_eros/sound/voice/farts/fart5.ogg',\
			'modular_eros/sound/voice/farts/fart6.ogg'\
		), 50, 1)
	