extends KinematicBody2D


var velocity = Vector2.ZERO
var speed = 64
var last_mouse_pos = null

var current_room = null

var flying := false setget set_flying, get_flying

export var projectile : PackedScene
export var global_cooldown := 0.35

func set_flying(value: bool) -> void:
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Flying, value )
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Walking, not value )
	flying = value

func get_flying() -> bool:
	return flying

func _input(event):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == 1:
		last_mouse_pos = get_global_mouse_position() - ( OptionsManager.tile_size/2 )

var path

#func _draw():
#	for point_index in range(path.size()):
#		if point_index - 1 < 0:
#			continue
#		var point = path[point_index]
#		var previous_point = path[point_index - 1]
#		var color = Color( randf(), randf(), randf() )
#
#		draw_line(to_local(previous_point), to_local(point), color, 1.0)

#	var point_index = 1
#	if point_index - 1 < 0 or point_index >= path.size():
#		return
#	var point = path[point_index]
#	var previous_point = path[point_index - 1]
#	var color = Color( randf(), randf(), randf() )
#	draw_line(previous_point, point, color, 1.0)
		

func _ready() -> void:
	path = [(global_position / OptionsManager.tile_size).floor() * OptionsManager.tile_size, (global_position / OptionsManager.tile_size).floor() * OptionsManager.tile_size ]

func _physics_process(_delta: float) -> void:
	update() # Updates the _draw method
	
	if GameManager.game_is_paused:
		return
	
	var start_position: Vector2 = get_global_transform().origin
	var end_position: Vector2 = GameManager.player.get_global_transform().origin
	var exception_units := [ GameManager.player ]

	path = GameManager.tilemap.get_astar_path_avoiding_obstacles_and_units(start_position, end_position, exception_units)
	
	var state = "obey"
	state = "sentry"
	
	var follow_distance = 1

	if state == "follow":
		if GameManager.player:
			var direction_vector
			if path.size() > 1:
				direction_vector = ( ( path[1] ) - ( global_position ) )
			else:
				direction_vector = Vector2.ZERO

			if direction_vector.length() < follow_distance:
				return

			velocity = move_and_slide( direction_vector.normalized() * speed )

	elif state == "obey":
		if last_mouse_pos:
			var direction_vector = ( last_mouse_pos - global_position )

			if direction_vector.length() < follow_distance:
				last_mouse_pos = null
				return

			velocity = move_and_slide( direction_vector.normalized() * speed )

	elif state == "sentry":
		if GameManager.player:
			$Pivot.look_at( GameManager.player.global_position )
			if $GlobalCooldownTimer.is_stopped():
				var bullet: KinematicBody2D = projectile.instance()
				bullet.position = $Pivot/BulletSpawner.get_global_position()
				
				bullet.direction_vector = ( GameManager.player.global_position - bullet.position ).normalized()
				GameManager.Game.add_child(bullet)
				$GlobalCooldownTimer.start(global_cooldown)

