extends Node


onready var Game : YSort = null

var game_is_paused = false setget set_paused_status, get_paused_status

func set_paused_status(value) -> void:
	Game.is_paused = value
	
func get_paused_status() -> bool:
	return Game.is_paused

var input_type = "keyboard"

enum COLLISION_LAYERS {
	Walking,
	Flying,
	Hitbox,
	Hurtbox,
	RoomDetection
}


onready var player : KinematicBody2D = null

export var pause_time: float = 0.2

func _ready() -> void:
	yield(get_tree().create_timer(0.01), "timeout")

	var player_camera = Game.get_node("PlayerCamera")
	var camera_effects_component = player_camera.get_node("TransitionEffectsComponent")
	var camera_effects_animation_player = camera_effects_component.get_node("AnimationPlayer")

	camera_effects_animation_player.play("RESET")
	camera_effects_component.show()

func change_room(room_position: Vector2, room_size: Vector2, fade := false, fade_time := 0.2) -> void:
	room_position = room_position - OptionsManager.tile_size/2

	Game.get_node("Player").velocity = Vector2.ZERO
 
	if fade == true:
		var player_camera = Game.get_node("PlayerCamera")
		var camera_effects_component = player_camera.get_node("TransitionEffectsComponent")
		var camera_effects_animation_player = camera_effects_component.get_node("AnimationPlayer")
		#var camera_smoothing = player_camera.smoothing

		camera_effects_animation_player.play("fade_out")

		yield( get_tree().create_timer( camera_effects_animation_player.get_animation("fade_out").length ),"timeout" )

		player_camera.smoothing_enabled = false
		player_camera.current_room_center = room_position
		player_camera.current_room_size = room_size

		yield( get_tree().create_timer( camera_effects_animation_player.get_animation("fade_in").length + fade_time ),"timeout" )

		if camera_effects_animation_player.assigned_animation == "fade_out":
			camera_effects_animation_player.play("fade_in")

		player_camera.smoothing_enabled = true

	else:
		Game.get_node("PlayerCamera").current_room_center = room_position
		Game.get_node("PlayerCamera").current_room_size = room_size

		self.game_is_paused = true
		yield(get_tree().create_timer( pause_time ),"timeout")
		self.game_is_paused = false
