extends YSort


var room_assets = {
	"wall": preload( "res://main/scenes/game/room/wall/Wall.tscn" ),
	"door": preload( "res://main/scenes/game/room/door/Door.tscn" )
}

var room_rect = Rect2( Vector2.ZERO, LevelManager.room_size )

var room_type = LevelManager.ROOM_TYPES.DEFAULT

var neighbors = {
	Vector2.UP: null,
	Vector2.DOWN: null,
	Vector2.LEFT:  null,
	Vector2.RIGHT:  null
}

var doors = []

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

func open_doors():
	for door in doors:
		door.open_door()

func close_doors():
	for door in doors:
		door.close_door()

func _build_room_tiles(room_half_size, room_pos, room_width, room_height, tilemap) -> void:
	for y in range(-room_half_size.y, room_half_size.y+1):
		for x in range(-room_half_size.x, room_half_size.x+1):
			#If is on the border.
			if y == -room_half_size.y or x == -room_half_size.x or y == room_half_size.y or x == room_half_size.x:
				#Add Door
				if (y == 0 or x == 0) and neighbors[ Vector2(x, y).normalized() ]:
					var door_pos = Vector2(
						room_pos.x * room_width + x, 
						room_pos.y * room_height + y )
					tilemap.set_cellv( 
						door_pos,
						GameManager.TILES.DOOR )
				else: #Add Wall
					var wall_pos = Vector2(
						room_pos.x * room_width + x, 
						room_pos.y * room_height + y )
					tilemap.set_cellv( 
						wall_pos,
						GameManager.TILES.WALL )
			else:
				#Add Foor
				var floor_pos = Vector2(
					room_pos.x * room_width + x, 
					room_pos.y * room_height + y )
				if tilemap.get_cellv(floor_pos) == tilemap.INVALID_CELL:
					tilemap.set_cellv( 
						floor_pos,
						GameManager.TILES.FLOOR )

func _replace_tiles_with_static_bodies(tilemap, room_pos) -> void:
	for cellpos in tilemap.get_used_cells():
		var cell = tilemap.get_cellv(cellpos)

		if cell == GameManager.TILES.DOOR:
			var new_door = room_assets.door.instance()
			new_door.position = tilemap.map_to_world(cellpos) * tilemap.scale
			new_door.room = self
			doors.append( new_door )
			add_child(new_door)
			tilemap.set_cellv( cellpos, GameManager.TILES.FLOOR )

func build_room():
	var tilemap = GameManager.Game.get_node("TileMap")

	var room_pos = room_rect.position
	var room_size = room_rect.size
	var room_width = room_size.x
	var room_height = room_size.y

	var room_half_size = Vector2( floor(room_width/2), floor(room_height/2) )

	# Set the Camera Trigger's position and size
	self.get_node("CameraTrigger").set_position( 
		Vector2( 
			room_pos.x * OptionsManager.tile_size.x * room_width,
			room_pos.y * OptionsManager.tile_size.y * room_height
		)
	)
	self.get_node("CameraTrigger/CollisionShape2D").shape.set_extents( Vector2( 
		(room_half_size.x + 0.5) * OptionsManager.tile_size.x,
		(room_half_size.y + 0.5) * OptionsManager.tile_size.y
	) )
	
	_build_room_tiles(room_half_size, room_pos, room_width, room_height, tilemap)
	_replace_tiles_with_static_bodies(tilemap, room_pos)

