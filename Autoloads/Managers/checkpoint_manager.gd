extends Node

var has_checkpoint: bool = false
var checkpoint_cell: Vector2i = Vector2i.ZERO
var level_path: String = ""

## Remembers a checkpoint for the level that is currently loaded.
## [param cell] The grid cell the player should respawn on.
func set_checkpoint(cell: Vector2i) -> void:
	checkpoint_cell = cell
	level_path = get_tree().current_scene.scene_file_path
	has_checkpoint = true 

## Returns whether a saved checkpoint applies to the level that is currently loaded.
## [return] True if there is a checkpoint saved for this level.
func has_checkpoint_here() -> bool:
	return has_checkpoint and level_path == get_tree().current_scene.scene_file_path
