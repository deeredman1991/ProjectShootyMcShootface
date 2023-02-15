extends KinematicBody2D


var direction_vector := Vector2.ZERO
var speed := 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_and_slide( direction_vector * speed * 16 * delta)
