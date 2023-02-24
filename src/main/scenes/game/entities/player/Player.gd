extends KinematicBody2D


var acceleration = 300
var max_speed = 100
var friction = 300

var velocity = Vector2.ZERO

var flying := false setget set_flying, get_flying

func set_flying(value: bool) -> void:
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Flying, value )
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Walking, not value )
	flying = value

func get_flying() -> bool:
	return flying

func _physics_process(delta: float) -> void:
	if GameManager.game_is_paused:
		return

	_handle_movement(delta)

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
