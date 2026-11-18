class_name FollowEnemy
extends Skeleton

@export var max_sight_range: int = 100

## Resolves a pending attack, or moves and starts a new attack if the player is in front.
func take_turn() -> void:
	if is_telegraphing():
		resolve_telegraph()
		return

	await try_move()

	var target_cell: Vector2i = grid_position + direction_vector
	var in_front: Entity = GridWorld.get_entity_at(target_cell)
	if in_front is Player and start_telegraph():
		return
	
	var player_dir: Vector2i = GridWorld.get_sight_direction(grid_position, GridWorld.player.grid_position, max_sight_range)
	if player_dir != Vector2i.ZERO:
		facing = DIRECTION_VECTORS.find_key(player_dir)
	elif not GridWorld.can_enter(target_cell):
		facing = get_opposite_direction(facing)

## Slides one step (or along ice) in the facing direction, if the path is open.
func try_move() -> void:
	var path: Array[Vector2i] = get_slide_path(grid_position, direction_vector)
	if path.is_empty():
		return
	GridWorld.move_entity(self, path.back())
	slide_along(path, SPEED)
	await active_tween.finished
