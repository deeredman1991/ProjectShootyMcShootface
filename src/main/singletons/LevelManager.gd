extends Node


enum ROOM_TYPES {
	DEFAULT
	START
	BOSS
	TREASURE
	SECRET
	SHOP
	MINIBOSS
}

"""
var ROOM_ICONS = [
	null,
	load("res://assets/images/IconStart.png"),
	load("res://assets/images/IconBoss.png"),
	load("res://assets/images/IconTreasure.png"),
	load("res://assets/images/IconSecret.png"),
	load("res://assets/images/IconShop.png"),
	load("res://assets/images/IconMiniBoss.png")
]
"""

var DIRECTIONS = {
	NORTH = Vector2( 0, -1),
	EAST  = Vector2( 1,  0),
	SOUTH = Vector2( 0,  1),
	WEST  = Vector2(-1,  0)
}

var level_min_size = 7
var level_max_size = 20
var minimum_number_of_dead_ends = 5

onready var level_rng = RandomNumberGenerator.new()

var level = {}

var level_seed setget set_seed, get_seed

func set_seed(value: String = "") -> void:
	level_seed = value
	if level_seed == "":
		randomize()
		level_seed = str( randi() )
	level_rng.set_seed( hash( level_seed ) )
	print( "[Level Manager] Seed: %s" % str(level_seed) )

func get_seed() -> String:
	return level_seed

func get_random_direction():
	return DIRECTIONS[ DIRECTIONS.keys()[ level_rng.randi() % DIRECTIONS.size() ] ]

func _ready() -> void:
	#Fixed
	#set_seed("2637391100") #Seed for testing Boss Room Placement
	#set_seed("2882422216") #Seed for testing Boss Room Connections

	#Unfixed
	#set_seed("3376728561") #Boss Room Generates "out of bounds"
	#set_seed("1569505562") #All special rooms Generate next to the start room
	

	set_seed()
	level = LevelGenerator.generate(level_min_size, level_max_size, minimum_number_of_dead_ends)
