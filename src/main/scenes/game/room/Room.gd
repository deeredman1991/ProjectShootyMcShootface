extends Node2D


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
