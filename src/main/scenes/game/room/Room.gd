extends Node2D


var room_assets = {
	"wall": preload( "res://main/scenes/game/room/wall/Wall.tscn" )
}

export var room_rect = Rect2( Vector2.ZERO, Vector2(15, 9) )

var room_type = LevelManager.ROOM_TYPES.DEFAULT

var neighbors = {
	LevelManager.DIRECTIONS.NORTH: null,
	LevelManager.DIRECTIONS.EAST:  null,
	LevelManager.DIRECTIONS.SOUTH: null,
	LevelManager.DIRECTIONS.WEST:  null
}

func get_neighbors():
	var valid_neighbors = {}

	for room_dir in neighbors:
		var room = neighbors[room_dir]
		if room != null:
			valid_neighbors[room_dir] = room

	return valid_neighbors

func get_num_neighbors():
	var neighbors_count = 0
	for room in neighbors.values():
		if room != null:
			neighbors_count += 1
	return neighbors_count

func is_dead_end():
	return get_num_neighbors() == 1
	
func build_room():
	var room_pos = room_rect.position
	var room_width = room_rect.size.x
	var room_height = room_rect.size.y

	print('oi!')

	var room_offset = Vector2( floor(room_width/2), floor(room_height/2) )

	for y in range(-room_offset.y, floor(room_height)/2+1):
		for x in range(-room_offset.x, floor(room_width)/2+1):
			if y == -room_offset.y or x == -room_offset.x or y == room_offset.y or x == room_offset.x:
				var new_wall = room_assets.wall.instance()
				new_wall.position = Vector2( 
					(x * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x, 
					(y * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y
				)
				add_child(new_wall)
