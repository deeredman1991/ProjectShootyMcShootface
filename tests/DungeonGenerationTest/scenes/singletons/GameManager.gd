extends Node


enum ROOM_TYPES {
	DEFAULT
	START
	BOSS
	TREASURE
	SECRET
	SHOP
	MINIBOSS
}

var ROOM_ICONS = [
	null,
	load("res://assets/images/IconStart.png"),
	load("res://assets/images/IconBoss.png"),
	load("res://assets/images/IconTreasure.png"),
	load("res://assets/images/IconSecret.png"),
	load("res://assets/images/IconShop.png"),
	load("res://assets/images/IconMiniBoss.png")
]

var DIRECTIONS = {
	NORTH = Vector2( 0, -1),
	EAST  = Vector2( 1,  0),
	SOUTH = Vector2( 0,  1),
	WEST  = Vector2(-1,  0)
}

func get_random_direction():
	return DIRECTIONS[ DIRECTIONS.keys()[ LevelManager.rng.randi() % DIRECTIONS.size() ] ]
