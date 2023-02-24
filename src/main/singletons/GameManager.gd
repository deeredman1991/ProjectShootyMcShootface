extends Node


var game_is_paused = false

var input_type = "keyboard"

enum COLLISION_LAYERS {
	Walking,
	Flying,
	Hitbox,
	Hurtbox
}
