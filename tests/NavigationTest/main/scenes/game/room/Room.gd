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

func build_room():
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
	
	# Draw Navigation Polygon.
	var navigation_polygon = $NavigationPolygonInstance.get_navigation_polygon()

	var new_polygon := PoolVector2Array()

	new_polygon.append( Vector2( 
		#(x * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x
		#(y * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y
		(  (-room_half_size.x + 0) * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x, 
		(  (-room_half_size.y + 0) * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y ) )
	new_polygon.append( Vector2( 
		(  ( room_half_size.x + 0.999) * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x, 
		(  (-room_half_size.y + 0) * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y) )
	new_polygon.append( Vector2( 
		(  ( room_half_size.x + 0.999) * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x,  
		(  ( room_half_size.y + 0.999) * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y) )
	new_polygon.append( Vector2( 
		(  (-room_half_size.x + 0) * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x,  
		(  ( room_half_size.y + 0.999) * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y) )

	#Generate Room
	for y in range(-room_half_size.y, room_half_size.y+1):
		for x in range(-room_half_size.x, room_half_size.x+1):
			if y == -room_half_size.y or x == -room_half_size.x or y == room_half_size.y or x == room_half_size.x:
				if (y == 0 or x == 0) and neighbors[ Vector2(x, y).normalized() ]:
					var new_door = room_assets.door.instance()
					doors.append(new_door)
					new_door.room = self
					new_door.direction = Vector2(x, y).normalized()
					new_door.global_position = Vector2( 
						(x * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x, 
						(y * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y
					)
					add_child(new_door)
					
					var polygon_transform = new_door.get_node("CollisionShape2D").get_global_transform()
					var polygon_bp = new_door.get_node("CollisionShape2D").get_shape()
					
#					for vertex in polygon_bp:
#						new_polygon.append( polygon_transform.xform(vertex) )
					
					
					
				else:
					var new_wall = room_assets.wall.instance()
					new_wall.global_position = Vector2( 
						(x * OptionsManager.tile_size.x) + room_pos.x * room_width * OptionsManager.tile_size.x, 
						(y * OptionsManager.tile_size.y) + room_pos.y * room_height * OptionsManager.tile_size.y
					)
					add_child(new_wall)
					
					var polygon_transform = new_wall.get_node("CollisionShape2D").get_global_transform()
					var polygon_bp = new_wall.get_node("CollisionShape2D").get_shape()
					
#					for vertex in polygon_bp:
#						new_polygon.append( polygon_transform.xform(vertex) )
		
	navigation_polygon.add_outline( new_polygon )			
	navigation_polygon.make_polygons_from_outlines()
	$NavigationPolygonInstance.set_navigation_polygon( navigation_polygon )
