class_name Entity
extends Node2D

enum Direction { LEFT, RIGHT, UP, DOWN }
const SPEED: float = 0.15
const DIRECTION_VECTORS: Dictionary = {
	Direction.LEFT: Vector2i(-1, 0),
	Direction.RIGHT: Vector2i(1, 0),
	Direction.UP: Vector2i(0, -1),
	Direction.DOWN: Vector2i(0, 1)
}

## Lower numbers act first when UpdateManager runs a turn.
@export var priority: int = 0
@export var map: TileMapLayer
@export var wall_map: TileMapLayer
@export var grid_position: Vector2i = Vector2i(0, 0)
@export var facing: Direction = Direction.RIGHT:
	set(value):
			facing = value  # 1. Update the actual value first
			
			# 2. Trigger the animation immediately if the node is ready
			if is_node_ready(): 
				update_animation()

## Whether UpdateManager should call take_turn() on this entity.
## The player turns this off, since it acts from input instead.
var takes_turns: bool = true
var direction_vector: Vector2i:
	get:
		return DIRECTION_VECTORS[facing]

## Registers this entity with the UpdateManager when it enters the scene tree.
func _enter_tree() -> void:
	if takes_turns:
		UpdateManager.register(self)

## Unregisters this entity from the UpdateManager when it leaves the scene tree.
func _exit_tree() -> void:
	UpdateManager.unregister(self)

## Called once per world turn. Subclasses override this with their own behavior.
func take_turn() -> void:
	pass

## Converts a grid coordinate into the world position of that tile's center.
## [param cell] The grid coordinate to convert.
## [return] The world-space position of the cell's center.
func cell_to_world(cell: Vector2i) -> Vector2:
	var world_position: Vector2 = map.map_to_local(cell)
	return world_position

## Returns whether the player is allowed to step into the given cell.
## [param cell] The grid coordinate to test.
## [return] True if the cell is free to walk on, false if it is blocked.
func is_walkable(cell: Vector2i) -> bool:
	return wall_map.get_cell_source_id(cell) == -1

func update_animation() -> void:
	pass

func get_opposite_direction(dir: Direction) -> Direction:
	match dir:
		Direction.LEFT:
			return Direction.RIGHT
		Direction.RIGHT:
			return Direction.LEFT
		Direction.UP:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.UP
	return Direction.LEFT
