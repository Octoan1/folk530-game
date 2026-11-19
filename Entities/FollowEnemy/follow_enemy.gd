class_name FollowEnemy
extends Skeleton

@export var max_sight_range: int = 100

## Resolves a pending attack, or moves and starts a new attack if the player is in front.
func take_turn() -> void:
	if is_telegraphing():
		resolve_telegraph()
		return
	
	_face_player()
	
	try_move()
	
	var target_cell: Vector2i = grid_position + direction_vector
	var in_front: Entity = GridWorld.get_entity_at(target_cell)
	if in_front is Player and start_telegraph():
		return
	
	_face_player()
	if not GridWorld.can_enter(target_cell):
		facing = get_opposite_direction(facing)

## Helper function that turns the enemy towards the player
func _face_player() -> void:
	var player_dir: Vector2i = GridWorld.get_sight_direction(grid_position, GridWorld.player.grid_position, max_sight_range) if is_instance_valid(GridWorld.player) else Vector2i.ZERO
	if player_dir != Vector2i.ZERO:
		facing = DIRECTION_VECTORS.find_key(player_dir)
