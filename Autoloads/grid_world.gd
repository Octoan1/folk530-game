extends Node

var map: TileMapLayer
var wall_map: TileMapLayer

## Stores the map layers for the current level.
## [param ground] The layer used for coordinate conversion and ground checks.
## [param walls] The layer whose tiles block movement.
func setup(ground: TileMapLayer, walls: TileMapLayer) -> void:
	map = ground
	wall_map = walls

## Clears the map references, for use when a level is unloaded.
func clear() -> void:
	map = null
	wall_map = null

## Converts a grid coordinate into the world position of that tile's center.
## [param cell] The grid coordinate to convert.
## [return] The world-space position of the cell's center.
func cell_to_world(cell: Vector2i) -> Vector2:
	assert(map != null)
	var world_position: Vector2 = map.map_to_local(cell)
	return world_position

## Returns whether the player is allowed to step into the given cell.
## [param cell] The grid coordinate to test.
## [return] True if the cell is free to walk on, false if it is blocked.
func is_walkable(cell: Vector2i) -> bool:
	assert(map != null)
	return wall_map.get_cell_source_id(cell) == -1 and map.get_cell_source_id(cell) != -1
