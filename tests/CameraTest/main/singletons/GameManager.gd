extends Node


onready var Game : YSort = null

var game_is_paused = false

var input_type = "keyboard"

enum COLLISION_LAYERS {
	Walking,
	Flying,
	Hitbox,
	Hurtbox
}


### CAMERA TEST ###
onready var player : KinematicBody2D = null

export var pause_time: float = 0.2
 
enum {
	UP
	RIGHT
	DOWN
	LEFT
}
 
func change_room(room_position: Vector2, room_size: Vector2) -> void:
	room_position = room_position - OptionsManager.tile_size/2
	Game.get_node("PlayerCamera").current_room_center = room_position
	Game.get_node("PlayerCamera").current_room_size = room_size
 
	game_is_paused = true
	yield(get_tree().create_timer(pause_time),"timeout")
	game_is_paused = false
