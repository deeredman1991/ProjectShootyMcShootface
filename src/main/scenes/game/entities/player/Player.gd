extends KinematicBody2D


var acceleration = 300
var max_speed = 100
var friction = 300

var velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if GameManager.game_is_paused:
		return

	handle_movement(delta)

func handle_movement(delta: float) -> void:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("KB_move_left", "KB_move_right")
	input_vector.y = Input.get_axis("KB_move_up", "KB_move_down")

	# We have to separate Joypad Controls from Keyboard Controls
	#	because joypad will randomly interupt keyboard if plugged in.
	if input_vector == Vector2.ZERO:
		input_vector.x = Input.get_axis("JP_move_left", "JP_move_right")
		input_vector.y = Input.get_axis("JP_move_up", "JP_move_down")

	if input_vector.length() > 1:
		input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward( input_vector * max_speed, acceleration * delta )
	else:
		velocity = velocity.move_toward( Vector2.ZERO, friction * delta )

	velocity = move_and_slide( velocity )
