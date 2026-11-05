class_name Level
extends Node2D

## The movable ground
@export var map: TileMapLayer

## The map of tiles that are not walkable
@export var wall_map: TileMapLayer

## The player, used to reach the camera and to listen for death
@export var player: Player

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("level_restart"):
		get_tree().reload_current_scene()

func _enter_tree() -> void:
	GridWorld.setup(map, wall_map)

func _ready() -> void:
	_apply_camera_limits()
	player.restart.connect(restart_level)

func _exit_tree() -> void:
	GridWorld.clear()

## Stops the player's camera from scrolling past the edge of the ground layer.
func _apply_camera_limits() -> void:
	var used_rect: Rect2i = map.get_used_rect()
	var tile_size: Vector2i = map.tile_set.tile_size

	var top_left_local: Vector2 = Vector2(used_rect.position * tile_size)
	var bottom_right_local: Vector2 = Vector2((used_rect.position + used_rect.size) * tile_size)

	var top_left: Vector2 = map.to_global(top_left_local)
	var bottom_right: Vector2 = map.to_global(bottom_right_local)

	player.camera.limit_left = int(top_left.x)
	player.camera.limit_top = int(top_left.y)
	player.camera.limit_right = int(bottom_right.x)
	player.camera.limit_bottom = int(bottom_right.y)

func restart_level() -> void:
	get_tree().reload_current_scene()
