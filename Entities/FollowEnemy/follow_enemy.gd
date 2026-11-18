extends Skeleton

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

	if not GridWorld.can_enter(target_cell):
		facing = get_opposite_direction(facing)

## Slides one step (or along ice) in the facing direction, if the path is open.
func try_move() -> void:
	var path: Array[Vector2i] = get_slide_path(grid_position, direction_vector)
	if path.is_empty():
		return
	GridWorld.move_entity(self, path.back())
	slide_along(path, SPEED)
	await active_tween.finished
