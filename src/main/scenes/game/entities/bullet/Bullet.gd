extends KinematicBody2D


var direction_vector := Vector2.ZERO
var speed := 0.25

var damage = 2


func _physics_process(_delta: float) -> void:
	move_and_collide( direction_vector * speed * ((OptionsManager.tile_size.x + OptionsManager.tile_size.y)/2) )


func _on_Hitbox_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.has_node("CombatComponent"):
		body.get_node("CombatComponent").health -= damage
	queue_free()
