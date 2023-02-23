extends StaticBody2D


var room = null
var direction = null

func open_door():
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.WalkingObstacle, false )
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.FlyingObstacle, false )
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Player, false )

func close_door():
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.WalkingObstacle, true )
	set_collision_layer_bit( GameManager.COLLISION_LAYERS.FlyingObstacle, true )
	set_collision_mask_bit( GameManager.COLLISION_LAYERS.Player, true )

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	open_door()

func _on_Area2D_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	body.position = self.position + self.direction * OptionsManager.tile_size * 2
