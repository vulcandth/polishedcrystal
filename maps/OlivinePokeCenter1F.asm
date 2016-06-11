const_value set 2
	const OLIVINEPOKECENTER1F_NURSE
	const OLIVINEPOKECENTER1F_FISHING_GURU
	const OLIVINEPOKECENTER1F_FISHER
	const OLIVINEPOKECENTER1F_TEACHER
	const OLIVINEPOKECENTER1F_BEAUTY

OlivinePokeCenter1F_MapScriptHeader:
.MapTriggers:
	db 0

.MapCallbacks:
	db 0

NurseScript_0x9c002:
	jumpstd pokecenternurse

FishingGuruScript_0x9c005:
	jumpstd happinesschecknpc

FisherScript_0x9c008:
	jumptextfaceplayer UnknownText_0x9c00e

TeacherScript_0x9c00b:
	jumptextfaceplayer UnknownText_0x9c086

BeautyCharlotteScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_BEAUTY_CHARLOTTE
	iftrue BeautyCharlotteAfterScript
	writetext BeautyCharlotteGreetingText
	yesorno
	iffalse BeautyCharlotteNoBattleScript
	writetext BeautyCharlotteSeenText
	waitbutton
	closetext
	winlosstext BeautyCharlotteWinText, 0
	setlasttalked OLIVINEPOKECENTER1F_BEAUTY
	loadtrainer BEAUTY, CHARLOTTE
	startbattle
	dontrestartmapmusic
	reloadmapafterbattle
	setevent EVENT_BEAT_BEAUTY_CHARLOTTE
	opentext
BeautyCharlotteAfterScript:
	writetext BeautyCharlotteAfterText
	waitbutton
	closetext
	end

BeautyCharlotteNoBattleScript:
	faceplayer
	opentext
	writetext BeautyCharlotteNoBattleText
	waitbutton
	closetext
	end

UnknownText_0x9c00e:
	text "The Sailor in the"
	line "Olivine Cafe next"

	para "door is really"
	line "generous."

	para "He taught my"
	line "#mon Strength."

	para "Now it can move"
	line "big boulders."
	done

UnknownText_0x9c086:
	text "There's a person"
	line "in Cianwood City"
	cont "across the sea."

	para "I heard him brag-"
	line "ging about his"
	cont "rare #mon."
	done

BeautyCharlotteGreetingText:
	text "Oh, are you a"
	line "Trainer?"

	para "You came at just"
	line "the right time!"

	para "My unique and"
	line "beautiful #mon"
	cont "is all healed."

	para "Do you want to"
	line "battle and be"
	cont "amazed by my"
	cont "#mon?"
	done

BeautyCharlotteNoBattleText:
	text "Oh, really? Talk"
	line "to me if you want"
	cont "to battle some"
	cont "time!"
	done

BeautyCharlotteSeenText:
	text "All right!"
	line "Here I come!"
	done

BeautyCharlotteWinText:
	text "Amazing battle!"
	done

BeautyCharlotteAfterText:
	text "How cool is it"
	line "to have such a"
	cont "special #mon?"
	done

OlivinePokeCenter1F_MapEventHeader:
	; filler
	db 0, 0

.Warps:
	db 3
	warp_def $7, $3, 1, OLIVINE_CITY
	warp_def $7, $4, 1, OLIVINE_CITY
	warp_def $7, $0, 1, POKECENTER_2F

.XYTriggers:
	db 0

.Signposts:
	db 0

.PersonEvents:
	db 5
	person_event SPRITE_NURSE, 1, 3, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, NurseScript_0x9c002, -1
	person_event SPRITE_FISHING_GURU, 4, 8, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 0, 1, -1, -1, 0, PERSONTYPE_SCRIPT, 0, FishingGuruScript_0x9c005, -1
	person_event SPRITE_FISHER, 3, 2, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_GREEN, PERSONTYPE_SCRIPT, 0, FisherScript_0x9c008, -1
	person_event SPRITE_TEACHER, 7, 7, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, PERSONTYPE_SCRIPT, 0, TeacherScript_0x9c00b, -1
	person_event SPRITE_BUENA, 1, 7, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, (1 << 3) | PAL_OW_BLUE, PERSONTYPE_SCRIPT, 0, BeautyCharlotteScript, -1
