class_name MovableRock
extends Entity

## Rocks never act on their own, so they stay out of the turn list.
func _init() -> void:
	takes_turns = false

## Snaps the rock to its starting cell.
func _ready() -> void:
	position = GridWorld.cell_to_world(grid_position)

## Slides one cell in the given direction if there is room.
## [param direction] The direction the bumping entity is moving.
## [return] True if the rock moved.
func on_bumped(direction: Vector2i) -> bool:
	# Your code: compute the cell behind the rock, check can_enter,
	# then move_entity + slide_to. Return whether it moved.
	var target_cell: Vector2i = grid_position + direction
	if GridWorld.can_enter(target_cell):
		var path: Array[Vector2i] = get_slide_path(grid_position, direction)
		if path.is_empty():
			return false

		GridWorld.move_entity(self, path.back())
		slide_along(path, SPEED)
		return true
	
	return false
