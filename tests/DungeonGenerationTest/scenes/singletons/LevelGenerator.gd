extends Node


var room_scene = preload("res://scenes/map/Room.tscn")

var generation_chance = 20

func _ready() -> void:
	var level_min_size = 7
	var level_max_size = 20
	var minimum_number_of_dead_ends = 5
	var l
	for _i in range(1):
		LevelManager.set_seed()
		l = generate(level_min_size, level_max_size, minimum_number_of_dead_ends)
	print( "[Level Generator] Seed: %s" % str(LevelManager.level_seed) )
	#print(l)
	#print(len(l))
	display(l)
	
func display(level):
	for room_pos in level.keys():
		var room = level[room_pos]
		room.position = room_pos * 16
		
		if room.connected_rooms[ GameManager.DIRECTIONS.NORTH ] != null:
			room.get_node("Doors/N").show()
		if room.connected_rooms[ GameManager.DIRECTIONS.EAST ] != null:
			room.get_node("Doors/E").show()
		if room.connected_rooms[ GameManager.DIRECTIONS.SOUTH ] != null:
			room.get_node("Doors/S").show()
		if room.connected_rooms[ GameManager.DIRECTIONS.WEST ] != null:
			room.get_node("Doors/W").show()
			
		if room.room_type != GameManager.ROOM_TYPES.DEFAULT:
			var room_icon = room.get_node("Icon")
			room_icon.set_texture( GameManager.ROOM_ICONS[ room.room_type ] )
			room_icon.show()

		get_node("/root/Main").add_child(room)

func generate( min_number_rooms, max_number_rooms, minimum_num_dead_ends ):
	var size = LevelManager.rng.randi_range( min_number_rooms, max_number_rooms-1 )
	
	var level = {}
	while !is_valid(level, minimum_num_dead_ends):
		level = {}
		var first_room = room_scene.instance()
		first_room.room_type = GameManager.ROOM_TYPES.START
		level[ Vector2.ZERO ] = first_room

		while( len(level) < size ):
			for current_room_pos in level.keys():
				if LevelManager.rng.randi_range(0, 100) < generation_chance:
					var new_room_direction = GameManager.get_random_direction()
					var new_room_pos = current_room_pos + new_room_direction

					if !level.has(new_room_pos):
						level[new_room_pos] = room_scene.instance()
					if level[current_room_pos].connected_rooms[new_room_direction] == null:
						connect_rooms( level[current_room_pos], level[new_room_pos], new_room_direction )
	
	place_special_rooms(level)
	return level
	
func manhattan_distance(start_pos, end_pos):
	return (abs(end_pos.x) - abs(start_pos.x)) + (abs(end_pos.y) - abs(start_pos.y))
	
func heuristic(start_pos, end_pos):
	return manhattan_distance(start_pos, end_pos)


func get_shortest_path_AStar(start_room_pos, end_room_pos, level):
	assert(false, "Function Not Implemented!: get_shortest_path_AStar()" )
	var frontier = [start_room_pos] # Priority Queues get created here.
	var visited = frontier.duplicate() # Visited includes frontier nodes
	var parents = { start_room_pos: null }
	var cost_so_far = { start_room_pos: 0 }

	while frontier:
		var room_pos = frontier.pop_front()
		var room = level[room_pos]

		for neighbor_dir in room.get_neighbors():
			var neighbor_pos = room_pos + neighbor_dir
			var neighbor = level[neighbor_pos]
			cost_so_far[neighbor_pos] = cost_so_far[room_pos] + 1
			
			if neighbor_pos in visited: #Nodes get validated/invalidated here.
				continue
			parents[neighbor_pos] = room_pos
			
			var priority = cost_so_far[neighbor_pos] + heuristic(neighbor_pos, end_room_pos)
			
			if frontier:
				for index in frontier.size():
					if priority:
						pass
			else:
				frontier.append(neighbor_pos)
			"""
			if frontier:
				for index in frontier.size():
					if cost_so_far[ frontier[index] ] >= priority:
						frontier.insert( index-1, neighbor_pos) # Valid nodes get appended here.
						break
			else:
				frontier.append(neighbor_pos)
			"""
			visited.append(neighbor_pos)
			if neighbor_pos == end_room_pos: # If we find the end position BFS can terminate early.
				frontier = []
				break

	var path = [end_room_pos]
	
	assert( end_room_pos in parents ) # There should always be a path to every dead end.
	
	var current_node = parents[end_room_pos]
	while current_node != null:
		path.insert(0, current_node)
		current_node = parents[current_node]

	return path

func get_shortest_path_BFS(start_room_pos, end_room_pos, level):
	var frontier = [start_room_pos] # Priority Queues get created here.
	var visited = frontier.duplicate() # Visited includes frontier nodes
	var parents = { start_room_pos: null }

	while frontier:
		var room_pos = frontier.pop_front()
		var room = level[room_pos]

		for neighbor_dir in room.get_neighbors():
			var neighbor_pos = room_pos + neighbor_dir
			var neighbor = level[neighbor_pos]
			if neighbor_pos in visited: #Nodes get validated/invalidated here.
				continue
			parents[neighbor_pos] = room_pos
			frontier.append(neighbor_pos) # Valid nodes get appended here.
			visited.append(neighbor_pos)
			if neighbor_pos == end_room_pos: # If we find the end position BFS can terminate early.
				frontier = []
				break

	var path = [end_room_pos]
	
	assert( end_room_pos in parents ) # There should always be a path to every dead end.
	
	var current_node = parents[end_room_pos]
	while current_node != null:
		path.insert(0, current_node)
		current_node = parents[current_node]

	return path

func farthest_from(start_room_pos, potential_targets, level):
	var shortest_path = []
	for target_pos in potential_targets:
		var potential_shortest_path = get_shortest_path_BFS(start_room_pos, target_pos, level)
		if !shortest_path or len(shortest_path) < len(potential_shortest_path):
			shortest_path = potential_shortest_path

	return shortest_path[-1]

func get_dead_ends(level):
	var dead_ends = []
	for room_pos in level:
		var room = level[room_pos]
		if room.is_dead_end():
			dead_ends.append(room_pos)
	return dead_ends

#Boss room is always the farthest dead end away from the start node
#A Mini Boss room will generate in the room adjacent to the boss room if and 
#	only if it has exactly two connections
#Treasure, Shop, and Secret rooms will spawn randomly in the remaining dead ends.
func place_special_rooms(level):
	var dead_ends = get_dead_ends(level)
	
	var boss_room_pos = farthest_from(Vector2.ZERO, dead_ends, level)

	var boss_room = level[boss_room_pos]

	assert( len(boss_room.get_neighbors()) == 1, "level_seed: %s" % LevelManager.level_seed )
	
	boss_room.room_type = GameManager.ROOM_TYPES.BOSS
	
	var mini_boss_room = boss_room.get_neighbors().values()[0]
	
	if len(mini_boss_room.get_neighbors()) == 2:
		mini_boss_room.room_type = GameManager.ROOM_TYPES.MINIBOSS

	var remaining_special_rooms = [ GameManager.ROOM_TYPES.SECRET,
									GameManager.ROOM_TYPES.SHOP,
									GameManager.ROOM_TYPES.TREASURE
									]

	for room_pos in dead_ends:
		var room = level[room_pos]
		if room.room_type != GameManager.ROOM_TYPES.DEFAULT:
			continue
		if len(remaining_special_rooms) <= 0:
			break
		room.room_type = remaining_special_rooms.pop_front()

	assert(len(remaining_special_rooms) == 0, "level_seed: %s" % LevelManager.level_seed )

		

func connect_rooms(room1, room2, direction):
	room1.connected_rooms[direction] = room2
	room2.connected_rooms[-direction] = room1

# A level is considered not valid if it has less than the minimum number of dead ends
#     or a dead end spawns next to the start room.
func is_valid(level, minimum_num_dead_ends):
	if not level:
		return false

	var start_room = level[Vector2.ZERO]
	for start_room_neighbor in start_room.connected_rooms.values():
		if start_room_neighbor and start_room_neighbor.is_dead_end():
			return false

	var dead_end_count = 0
	for room_pos in level.keys():
		var room = level[room_pos]
		assert( room.get_num_connections() >= 1 , "level_seed: %s" % LevelManager.level_seed )
		if room.is_dead_end():
			dead_end_count += 1

	return dead_end_count >= minimum_num_dead_ends
