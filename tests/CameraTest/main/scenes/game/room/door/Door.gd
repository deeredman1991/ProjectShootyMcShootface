extends StaticBody2D


var room = null
var direction = null

func open_door():
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Walking, false )
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Flying, false )

func close_door():
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Walking, true )
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Flying, true )

func _ready():
	open_door()

func _on_Area2D_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	body.position = self.position + self.direction * OptionsManager.tile_size * 2
