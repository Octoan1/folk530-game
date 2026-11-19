extends Node

@onready var black_fade: BlackFade = $BlackFade
@onready var level_container: Node = $LevelContainer

@export var levels: Array[PackedScene]
@export var start_index: int = 0

var current_level: Level
var current_index: int = 0

func _ready() -> void:
	load_level(start_index)
	

## Fades out, replaces the current level with the one at the given index, replaces the current index, then fades in.
## [param index] The position in levels to load.
func load_level(index: int) -> void:
	assert(index < levels.size() and index >= 0, "Index is out of bounds for levels!")
	UpdateManager.animation_started()
	await black_fade.fade_out(0.0)
	if current_level != null:
		level_container.remove_child(current_level)
		current_level.queue_free()
	var scene: PackedScene = levels[index]
	var level: Level = scene.instantiate() as Level
	level.completed.connect(next_level)
	level.restart_requested.connect(restart_level)
	level_container.add_child(level)
	current_index = index
	current_level = level
	await get_tree().process_frame
	await black_fade.fade_in(0.5)
	UpdateManager.animation_finished()
	

## Loads the level after the current one, or handles reaching the end.
func next_level() -> void:
	load_level((current_index + 1) % levels.size())

## Reloads the current level from scratch, keeping the checkpoint.
func restart_level() -> void:
	load_level(current_index)
