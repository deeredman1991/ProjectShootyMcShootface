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
	LevelManager.generate_level( 
			level_sizes[size].level_min_size, 
			level_sizes[size].level_max_size, 
			level_sizes[size].minimum_number_of_dead_ends
	)

func build_rooms():
	var level = LevelManager.level
	assert(level.size() > 0, "No rooms in level, did you mean to call 'generate_level'?")

	for room_pos in level:
		var room = level[room_pos]
		room.build_room()
		add_child(room)

func _enter_tree() -> void:
	GameManager.Game = self
	
func _ready() -> void:
	generate_level( 0 )
	build_rooms()
	GameManager.tilemap.update()
	
	SoundManager.start_beat()
