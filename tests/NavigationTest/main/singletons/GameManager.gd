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

enum TILES {
	WALL,
	DOOR,
	FLOOR,
	PIT,
	SPIKE
}

var player : KinematicBody2D = null
var player_camera : Camera2D = null

var tilemap : TileMap = null
