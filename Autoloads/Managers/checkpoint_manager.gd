extends Node

var has_checkpoint: bool = false
var checkpoint_cell: Vector2i = Vector2i.ZERO

## Remembers a checkpoint for the level that is currently loaded.
## [param cell] The grid cell the player should respawn on.
func set_checkpoint(cell: Vector2i) -> void:
	checkpoint_cell = cell
	has_checkpoint = true 

## Returns whether a saved checkpoint applies to the level that is currently loaded.
## [return] True if there is a checkpoint saved for this level.
func has_checkpoint_here() -> bool:
	return has_checkpoint

## Removes the current checkpoint.
func clear() -> void:
	has_checkpoint = false
