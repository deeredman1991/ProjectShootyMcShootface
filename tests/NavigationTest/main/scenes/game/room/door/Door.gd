extends StaticBody2D


var room = null

func open_door():
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Walking, false )
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Flying, false )

func close_door():
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Walking, true )
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Flying, true )

func _ready():
	open_door()

func _on_DoorTrigger_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	var room_pos = room.room_rect.position * room.room_rect.size * OptionsManager.tile_size
	var direction = (position - room_pos).normalized()

	body.position = (self.position + direction * OptionsManager.tile_size * 2) + (OptionsManager.tile_size/2)
