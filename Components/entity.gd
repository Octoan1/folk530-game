class_name Entity
extends Node2D

## Lower numbers act first when UpdateManager runs a turn.
@export var priority: int = 0
@export var map: TileMapLayer
@export var wall_map: TileMapLayer
@export var grid_position: Vector2i = Vector2i(0, 0)

## Whether UpdateManager should call take_turn() on this entity.
## The player turns this off, since it acts from input instead.
var takes_turns: bool = true

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
