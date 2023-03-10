extends Node


var level_seed = ""

# For possibly supporting different tilesets in the future.
var tile_size = Vector2(16, 16)

# Maybe if people like the game we can load settings in from a file but HTML5 on itch.io does not 
#	support saving/loading so we would have to build for a different platform.
#	We should at least be somewhat prepared for that eventuality though.
func _ready() -> void:
	if level_seed == "":
		print( "[Options Manager] Set Random Seed" )
		#seed: 1308298547 - Boss Room Generates Far Away
		LevelManager.set_seed()

	yield(get_tree(), "idle_frame")

	GameManager.Game.get_node("TileMap").set_deferred("cell_size", tile_size)
