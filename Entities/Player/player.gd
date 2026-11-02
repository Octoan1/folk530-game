class_name Player
extends CharacterBody2D


const SPEED: float = 0.1

@export var map: TileMapLayer
@export var grid_position: Vector2i = Vector2i(0, 0)

var active_tween: Tween
var is_moving: bool = false

func _ready() -> void:
	position = cell_to_world(grid_position)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("player_left") or Input.is_action_just_pressed("player_right"):
		var h_dir: int = Input.get_axis("player_left", "player_right") as int
		grid_position += Vector2i(h_dir, 0)
	elif Input.is_action_just_pressed("player_up") or Input.is_action_just_pressed("player_down"):
		var v_dir: int = Input.get_axis("player_up", "player_down") as int
		grid_position += Vector2i(0, v_dir)
	
	slide_to(cell_to_world(grid_position), SPEED)

## Converts a grid coordinate into the world position of that tile's center.
## [param cell] The grid coordinate to convert.
## [return] The world-space position of the cell's center.
func cell_to_world(cell: Vector2i) -> Vector2:
	var world_position: Vector2 = map.map_to_local(cell)
	return world_position

## Slides this node to the given world position over a fixed duration.
## [param target] The world position to slide to.
## [param duration] How long the slide takes, in seconds.
func slide_to(target: Vector2, duration: float) -> void:
	is_moving = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target, duration)
