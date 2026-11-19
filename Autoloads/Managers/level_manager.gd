extends Node

const LEVELS: Array[String] = [
	"res://Scenes/Levels/tutorial_map.tscn",
	"res://Scenes/Testing/test_map.tscn"
]

var is_transitioning: bool = false

## Returns the loaded level's position in LEVELS, or -1 if it isn't listed.
## [return] The index of the current level.
func get_current_index() -> int:
	var curr_level: String = get_tree().current_scene.scene_file_path
	return LEVELS.find(curr_level)

## Loads the next level in the list, or handles reaching the end.
func next_level() -> void:
	var curr_index: int = get_current_index()
	if curr_index != -1:
		var next_index: int = (curr_index + 1) % LEVELS.size()
		is_transitioning = true
		await BlackFade.fade_out(0.5)
		get_tree().change_scene_to_file.call_deferred(LEVELS[next_index])
