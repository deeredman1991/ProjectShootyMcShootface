extends KinematicBody2D


var velocity = Vector2.ZERO
var speed = 64
var last_mouse_pos = null

var current_room = null

var flying := false setget set_flying, get_flying

func set_flying(value: bool) -> void:
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Flying, value )
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.Walking, not value )
	flying = value

func get_flying() -> bool:
	return flying

func _input(event):
	var mouse_event = event as InputEventMouseButton
	if mouse_event and mouse_event.button_index == 1:
		last_mouse_pos = get_global_mouse_position() - (OptionsManager.tile_size/2)

func _physics_process(_delta: float) -> void:
	if GameManager.game_is_paused:
		return

	if last_mouse_pos:
		var direction_vector = ( last_mouse_pos - global_position )

		if direction_vector.length() <= 0.5:
			last_mouse_pos = null
			return

		velocity = move_and_slide( direction_vector.normalized() * speed )
