extends Node2D


onready var root: Viewport = get_tree().get_root()

export var body_path: NodePath
onready var body: KinematicBody2D = get_node(body_path)

export var view_path: NodePath
onready var view: Node2D = get_node(view_path)

var bullet_scene: PackedScene = preload("res://Bullet.tscn")
export var bullet_spawner_path: NodePath
onready var bullet_spawner: Position2D = get_node(bullet_spawner_path)

export var global_cooldown := 1

var direction_vector := Vector2.ZERO
export var speed := 5

func _input(event: InputEvent) -> void:
	pass

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_arm_rotation()
	handle_shooting()

func handle_movement() -> void:
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("move_up", "move_down")

	direction_vector = Vector2(x, y)
	
	if direction_vector.length() > 1:
		direction_vector = direction_vector.normalized()
	
	#Move and slide handles framerate independence internally and 
	#	therefore does not need to be multiplied by delta time.
	body.move_and_slide( direction_vector * speed * 16)

func handle_arm_rotation():
	view.get_node("Arms").look_at( get_global_mouse_position() )

func handle_shooting():
	if Input.is_action_pressed("shoot") and $GlobalCooldownTimer.is_stopped():
		var bullet: KinematicBody2D = bullet_scene.instance()
		bullet.position = bullet_spawner.get_global_position()
		
		bullet.direction_vector = ( get_global_mouse_position() - bullet.position ).normalized()

		root.add_child(bullet)
		$GlobalCooldownTimer.start(global_cooldown)
