extends Node

@onready var black_fade: BlackFade = $BlackFade
@onready var level_container: Node = $LevelContainer

@export var levels: Array[PackedScene]
@export var start_index: int = 0

var current_level: Level
var current_index: int = 0
var is_transitioning: bool = false

func _ready() -> void:
	load_level(start_index, 0.0)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("level_restart"):
		restart_level()
	
## Fades out, replaces the current level with the one at the given index, replaces the current index, then fades in.
## [param index] The position in levels to load.
## [param fade_our_dur] How long it takes to fade out. Default is 0.5
## [param fade_in_dur] How long it takes to fade in. Default is 0.5
func load_level(index: int, fade_out_dur: float = 0.5, fade_in_dur: float = 0.5) -> void:
	assert(index < levels.size() and index >= 0, "Index is out of bounds for levels!")
	if is_transitioning:
		return
	is_transitioning = true
	UpdateManager.animation_started()
	await black_fade.fade_out(fade_out_dur)
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
	await black_fade.fade_in(fade_in_dur)
	UpdateManager.animation_finished()
	is_transitioning = false
	

## Loads the level after the current one, or handles reaching the end.
func next_level() -> void:
	CheckpointManager.clear()
	load_level((current_index + 1) % levels.size())

## Reloads the current level from scratch, keeping the checkpoint.
func restart_level() -> void:
	load_level(current_index)
