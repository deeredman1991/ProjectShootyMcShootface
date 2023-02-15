extends Node2D


var room_type = GameManager.ROOM_TYPES.DEFAULT

var connected_rooms = {
	GameManager.DIRECTIONS.NORTH: null,
	GameManager.DIRECTIONS.EAST:  null,
	GameManager.DIRECTIONS.SOUTH: null,
	GameManager.DIRECTIONS.WEST:  null,
}

func get_neighbors():
	var neighbors = {}
	
	for room_dir in connected_rooms:
		var room = connected_rooms[room_dir]
		if room != null:
			neighbors[room_dir] = room
	
	return neighbors

func get_num_connections():
	var connected_rooms_count = 0
	for room in connected_rooms.values():
		if room != null:
			connected_rooms_count += 1
	return connected_rooms_count

func is_dead_end():
	return get_num_connections() == 1
