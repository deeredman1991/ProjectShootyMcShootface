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

onready var level_rng = RandomNumberGenerator.new()
var level = {}
var level_seed setget set_seed, get_seed

var room_size = Vector2( 15, 9 )

func set_seed(value: String = "") -> void:
	OptionsManager.level_seed = value
	if OptionsManager.level_seed == "":
		randomize()
		OptionsManager.level_seed = str( randi() )
	level_rng.set_seed( hash( OptionsManager.level_seed ) )
	print( "[Level Manager] Seed: %s" % str(OptionsManager.level_seed) )

func get_seed() -> String:
	return OptionsManager.level_seed

func generate_level(level_min_size, level_max_size, minimum_number_of_dead_ends):
	level = LevelGenerator.generate(level_min_size, level_max_size, minimum_number_of_dead_ends)
