extends KinematicBody2D

var acceleration = 300
var max_speed = 100
var friction = 300

var velocity = Vector2.ZERO

var flying := false setget set_flying, get_flying

var current_room = null

export var projectile: PackedScene
export var global_cooldown := 0.35

func set_flying(value: bool) -> void:
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Flying, value )
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Walking, not value )
	flying = value

func get_flying() -> bool:
	return flying

func _ready() -> void:
	GameManager.player = self

func _physics_process(delta: float) -> void:
	if GameManager.game_is_paused:
		return

	_handle_movement(delta)
	_handle_arm_rotation()
	_handle_shooting()

func _get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO

	input_vector.x = Input.get_axis("KB_move_left", "KB_move_right")
	input_vector.y = Input.get_axis("KB_move_up", "KB_move_down")

	# We have to separate Joypad Controls from Keyboard Controls
	#	because joypad will randomly interupt keyboard if plugged in.
	if not input_vector:
		input_vector.x = Input.get_axis("JP_move_left", "JP_move_right")
		input_vector.y = Input.get_axis("JP_move_up", "JP_move_down")
		if input_vector:
			GameManager.input_type = "joypad"
	else:
		GameManager.input_type = "keyboard"

	if input_vector.length() > 1:
		input_vector = input_vector.normalized()

	return input_vector

func _handle_movement(delta: float) -> void:
	var input_vector = _get_input_vector()

	if input_vector:
		velocity = velocity.move_toward( input_vector * max_speed, acceleration * delta )
	else:
		velocity = velocity.move_toward( Vector2.ZERO, friction * delta )

	velocity = move_and_slide( velocity )

func _handle_arm_rotation():
	$Pivot.look_at( get_global_mouse_position() )

func _handle_shooting():
	if Input.is_action_pressed("shoot") and $GlobalCooldownTimer.is_stopped():
		var bullet: KinematicBody2D = projectile.instance()
		bullet.position = $Pivot/BulletSpawner.get_global_position()
		
		bullet.direction_vector = ( get_global_mouse_position() - bullet.position ).normalized()

		GameManager.Game.add_child(bullet)
		$GlobalCooldownTimer.start(global_cooldown)

func _on_RoomDetector_area_entered(area: Area2D) -> void:
	# Gets collision shape and size of room
	var collision_shape: CollisionShape2D = area.get_node("CollisionShape2D")
	var size: Vector2 = collision_shape.shape.extents * 2
 
	var target_room = area.get_parent() as YSort

	var plain_rooms = [
		LevelManager.ROOM_TYPES.DEFAULT,
		LevelManager.ROOM_TYPES.START
	]

	var do_fade = false
	if  ( target_room and not target_room.room_type in plain_rooms ) or \
		( current_room and not current_room.room_type in plain_rooms ):
		do_fade = true

	# Changes camera's current room and size. check camera script for more info
	GameManager.player_camera.change_room( collision_shape.global_position, size, do_fade )
	current_room = target_room


