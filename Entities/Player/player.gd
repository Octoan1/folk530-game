class_name Player
extends Entity

## True if the player is in the middle of moving, false otherwise
var is_moving: bool = false

## Sets the player to act from input instead of from the turn list.
func _init() -> void:
	takes_turns = false

## Snaps the player to its starting grid cell.
func _ready() -> void:
	position = cell_to_world(grid_position)

## Handles input: validates a step, commits it, then advances the world.
## [param event] The input event received this frame.
func _unhandled_input(event: InputEvent) -> void:
	if is_moving:
		return

	var direction: Vector2i = _get_direction(event)
	if direction == Vector2i.ZERO:
		return

	var target_cell: Vector2i = grid_position + direction
	if not is_walkable(target_cell):
		return

	grid_position = target_cell
	slide_to(cell_to_world(grid_position), SPEED)
	UpdateManager.run_turn()

## Converts an input event into a grid direction.
## [param event] The input event to interpret.
## [return] A direction vector, or Vector2i.ZERO if the event isn't a move.
func _get_direction(event: InputEvent) -> Vector2i:
	if event.is_echo():
		return Vector2i.ZERO
	if event.is_action_pressed("player_left"):
		return Vector2i(-1, 0)
	if event.is_action_pressed("player_right"):
		return Vector2i(1, 0)
	if event.is_action_pressed("player_up"):
		return Vector2i(0, -1)
	if event.is_action_pressed("player_down"):
		return Vector2i(0, 1)
	return Vector2i.ZERO

## Slides this node to the given world position over a fixed duration.
## [param target] The world position to slide to.
## [param duration] How long the slide takes, in seconds.
func slide_to(target: Vector2, duration: float) -> void:
	is_moving = true
	super.slide_to(target, duration)
	active_tween.finished.connect(_on_tween_end)

## Unlocks input once the slide has finished.
func _on_tween_end() -> void:
	is_moving = false
