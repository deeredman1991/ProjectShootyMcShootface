extends Node


var level_seed = ""

# Maybe if people like the game we can load settings in from a file but itch.io does not 
#	support saving/loading so we would have to target a different platform.
#	We should at least be somewhat prepared for that eventuality though.
func _ready() -> void:
	if level_seed == "":
		LevelManager.set_seed()
