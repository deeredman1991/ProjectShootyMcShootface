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

var DIRECTIONS = {
	NORTH = Vector2( 0, -1),
	EAST  = Vector2( 1,  0),
	SOUTH = Vector2( 0,  1),
	WEST  = Vector2(-1,  0)
}

onready var level_rng = RandomNumberGenerator.new()

var level = {}

var level_seed setget set_seed, get_seed

func set_seed(value: String = "") -> void:
	OptionsManager.level_seed = value
	if OptionsManager.level_seed == "":
		randomize()
		OptionsManager.level_seed = str( randi() )
	level_rng.set_seed( hash( OptionsManager.level_seed ) )
	print( "[Level Manager] Seed: %s" % str(OptionsManager.level_seed) )

func get_seed() -> String:
	return OptionsManager.level_seed

func get_random_direction():
	return DIRECTIONS[ DIRECTIONS.keys()[ level_rng.randi() % DIRECTIONS.size() ] ]

func generate_level(level_min_size, level_max_size, minimum_number_of_dead_ends, lv_seed = ""):
	level = LevelGenerator.generate(level_min_size, level_max_size, minimum_number_of_dead_ends)
	return level
