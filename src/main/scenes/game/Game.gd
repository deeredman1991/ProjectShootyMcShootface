extends YSort


var is_paused := false setget set_paused, get_paused

func set_paused(value: bool) -> void:
	is_paused = value

func get_paused() -> bool:
	return is_paused

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
	return LevelManager.generate_level( 
			level_sizes[size].level_min_size, 
			level_sizes[size].level_max_size, 
			level_sizes[size].minimum_number_of_dead_ends
	)

func build_rooms(level):
	for room_pos in level:
		var room = level[room_pos]
		room.build_room()
		add_child(room)

func _ready() -> void:
	GameManager.Game = self
	var level = generate_level( 0 )
	build_rooms( level )
		
	
