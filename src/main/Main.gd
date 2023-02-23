extends Node2D


func _ready() -> void:
	SceneManager.load_scene( "game" )


# DEBUG CAMERA CONTROLS!
# TODO: Move to proper debug class.
export(NodePath) var camera_path
onready var camera = get_node(camera_path)
export(int) var speed = 16

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		camera.position += Vector2.UP * speed * LevelManager.room_size.y / 2
	if event.is_action_pressed("ui_down"):
		camera.position += Vector2.DOWN * speed * LevelManager.room_size.y / 2
	if event.is_action_pressed("ui_left"):
		camera.position += Vector2.LEFT * speed * LevelManager.room_size.x / 2
	if event.is_action_pressed("ui_right"):
		camera.position += Vector2.RIGHT * speed * LevelManager.room_size.x / 2
