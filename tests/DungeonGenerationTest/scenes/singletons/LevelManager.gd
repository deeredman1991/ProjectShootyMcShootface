extends Node


onready var rng = RandomNumberGenerator.new()

var level = {}

var level_seed setget set_seed, get_seed

func set_seed(value: String = "") -> void:
	level_seed = value
	if level_seed == "":
		randomize()
		level_seed = str( randi() )
	rng.set_seed( hash( level_seed ) )
	

func get_seed() -> String:
	return level_seed
	
func _ready() -> void:
	#Fixed
	#set_seed("2637391100") #Seed for testing Boss Room Placement
	#set_seed("2882422216") #Seed for testing Boss Room Connections

	#Unfixed
	#set_seed("3376728561") #Boss Room Generates out of bounds
	#set_seed("1569505562") #All special rooms Generate next to the start room
	set_seed()
	#print( "[Level Manager] Seed: %s" % str(level_seed) )
	
