class_name Level
extends Node2D


@export var map: TileMapLayer ## The movable ground
@export var wall_map: TileMapLayer ## The map of tiles that are not walkable
@export var player: Player ## The player, used to reach the camera and to listen for death

signal completed ## Called when the [member player] emits [member Player.reached_goal]
signal restart_requested ## Called when the [member player] emits [member Player.restart]

func _enter_tree() -> void:
	GridWorld.setup(map, wall_map)
	GridWorld.player = player

func _ready() -> void:
	_apply_camera_limits()
	player.restart.connect(restart_requested.emit)
	player.reached_goal.connect(completed.emit)
	if CheckpointManager.has_checkpoint:
		GridWorld.move_entity(player, CheckpointManager.checkpoint_cell)
		player.position = GridWorld.cell_to_world(player.grid_position)
		player.camera.reset_smoothing()

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
