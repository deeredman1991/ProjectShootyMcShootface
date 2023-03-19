extends Node2D


export var health := 8

func death_check():
	if health <= 0:
		get_parent().queue_free()
		
func _physics_process(_delta: float) -> void:
	death_check()


func _on_Hurtbox_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	pass # Replace with function body.
