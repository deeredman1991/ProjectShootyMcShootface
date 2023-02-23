extends Node


var game_is_paused = false

enum COLLISION_LAYERS {
	Player,
	Enemy,
	Hitbox,
	Hurtbox,
	WalkingObstacle,
	FlyingObstacle,
	Door	
}
