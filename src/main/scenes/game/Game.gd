extends Node2D


var level_sizes = [
	{
		"level_min_size": 7,
		"level_max_size": 20,
		"minimum_number_of_dead_ends": 5
	},
	{
		"level_min_size": 10,
		"level_max_size": 25,
		"minimum_number_of_dead_ends": 5
	}
]

func generate_level( size ):
	LevelManager.generate_level( 
			level_sizes[size].level_min_size, 
			level_sizes[size].level_max_size, 
			level_sizes[size].minimum_number_of_dead_ends
	)

func _ready() -> void:
	generate_level( 0 )
		
	for room_pos in LevelManager.level:
		var room = LevelManager.level[room_pos]
		room.build_room()
		add_child(room)
