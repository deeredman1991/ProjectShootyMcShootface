extends Camera2D
 
# Amount of smoothing used to follow the player value is from 0 to 1
export var follow_smoothing: float = 0.1
 
# The amount of smoothing used by the code
var smoothing: float
var camera_smoothing_enabled := true
 
var target_position: Vector2
var current_room_center: Vector2
var current_room_size: Vector2
 
onready var view_size: Vector2 = get_viewport_rect().size
var zoom_view_size: Vector2

var disabled := false

#TODO: Create proper debug utilities
""" Ctrl + K on this line to enable/disable
#Debug Camera Code
func _input(event: InputEvent) -> void:
	var key = event as InputEventKey
	
	if key and key.is_pressed():
		if key.get_scancode() == KEY_UP:
			disabled = true
			position += Vector2.UP * OptionsManager.tile_size.y
		if key.get_scancode() == KEY_DOWN:
			disabled = true
			position += Vector2.DOWN * OptionsManager.tile_size.y
		if key.get_scancode() == KEY_LEFT:
			disabled = true
			position += Vector2.LEFT * OptionsManager.tile_size.x
		if key.get_scancode() == KEY_RIGHT:
			disabled = true
			position += Vector2.RIGHT * OptionsManager.tile_size.x
#"""

func _ready() -> void:
	GameManager.player_camera = self
	# Sets smoothing to 1 and back to follow_smoothing
	# I do this so the camera appears as if it starts at the first room not at (0, 0)
	smoothing_enabled = false
	smoothing = 1
	yield(get_tree().create_timer(0.1),"timeout")
	smoothing = follow_smoothing

	# Initialize Transition Effects Component
	var camera_effects_component = $TransitionEffectsComponent
	var camera_effects_animation_player = camera_effects_component.get_node("AnimationPlayer")

	camera_effects_animation_player.play("RESET")
	camera_effects_component.show()

func _physics_process(_delta: float) -> void:
	assert( smoothing_enabled == false, "Camera Script replaces default smoothing, did you mean 'camera_smoothing_enabled'" )
	if disabled:
		return
	# Get view size considering camera zoom
	zoom_view_size = view_size * zoom
 
	# Get target position
	target_position = calculate_target_position(current_room_center, current_room_size)

	if camera_smoothing_enabled:
		# Interpolate(lerp) camera position to target position by the smoothing
		position = lerp(position, target_position, smoothing)
	else:
		position = target_position

func calculate_target_position(room_center: Vector2, room_size: Vector2) -> Vector2:
	# The distance from the center of the room to the camera boundary on one side.
	# When the room is the same size as the screen the x and y margin are zero
	var x_margin: float = (room_size.x - zoom_view_size.x) / 2
	var y_margin: float = (room_size.y - zoom_view_size.y) / 2

	var return_position: Vector2 = Vector2.ZERO
 
	# if the zoom_view_size >= room_size the camera position should just be room center
	if x_margin <= 0:
		return_position.x = room_center.x
	# Clamps the return position to the left and right limits if the x_margin is positive
	else:
		var left_limit: float = room_center.x - x_margin
		var right_limit: float = room_center.x + x_margin
		return_position.x = clamp( GameManager.player.position.x, left_limit, right_limit )
 
 
	if y_margin <= 0:
		return_position.y = room_center.y
	else:
		var top_limit: float = room_center.y - y_margin
		var bottom_limit: float = room_center.y + y_margin
		return_position.y = clamp( GameManager.player.position.y, top_limit, bottom_limit )
 
	return return_position

func change_room(room_position: Vector2, room_size: Vector2, fade := false, fade_time := 0.2) -> void:
	room_position = room_position - OptionsManager.tile_size/2
	
	GameManager.player.velocity = Vector2.ZERO

	if fade == true:
		var camera_effects_component = $TransitionEffectsComponent
		var camera_effects_animation_player = camera_effects_component.get_node("AnimationPlayer")

		camera_effects_animation_player.play("fade_out")

		yield( get_tree().create_timer( camera_effects_animation_player.get_animation("fade_out").length  + fade_time ),"timeout" )

		camera_smoothing_enabled = false
		current_room_center = room_position
		current_room_size = room_size

		if camera_effects_animation_player.assigned_animation == "fade_out":
			camera_effects_animation_player.play("fade_in")

		yield( get_tree().create_timer( camera_effects_animation_player.get_animation("fade_in").length ),"timeout" )

	else:
		camera_smoothing_enabled = true
		current_room_center = room_position
		current_room_size = room_size

		GameManager.game_is_paused = true
		
		while true:
			yield(get_tree().create_timer( 0.01 ),"timeout")

			if get_camera_screen_center().distance_to( target_position ) < (OS.window_size.x + OS.window_size.y) / 20:
				GameManager.game_is_paused = false
				break
