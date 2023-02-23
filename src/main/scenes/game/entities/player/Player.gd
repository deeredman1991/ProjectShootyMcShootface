extends KinematicBody2D


export var speed:= 5

func _physics_process(_delta: float) -> void:
	if GameManager.game_is_paused:
		return

	handle_movement()

func handle_movement() -> void:
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("move_up", "move_down")

	var direction_vector = Vector2(x, y)
	
	if direction_vector.length() > 1:
		direction_vector = direction_vector.normalized()

	move_and_slide( direction_vector * speed * ((OptionsManager.tile_size.x + OptionsManager.tile_size.y)/2) )
