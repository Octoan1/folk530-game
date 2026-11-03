extends Node

var map: TileMapLayer
var wall_map: TileMapLayer
var occupants: Dictionary[Vector2i, Entity] = {}

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
	occupants.clear()

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
	assert(map != null and wall_map != null)
	return wall_map.get_cell_source_id(cell) == -1 and map.get_cell_source_id(cell) != -1

## Returns the entity standing on the given cell, or null if the cell is empty.
## [param cell] The grid coordinate to look up.
## [return] The entity on that cell, or null.
func get_entity_at(cell: Vector2i) -> Entity:
	var entity: Entity = occupants.get(cell, null)
	return entity

## Returns whether any entity is standing on the given cell.
func is_occupied(cell: Vector2i) -> bool:
	return occupants.has(cell)

## Returns whether an entity could step onto the cell (terrain is open and nothing is there).
func can_enter(cell: Vector2i) -> bool:
	return is_walkable(cell) and not is_occupied(cell)

## Moves an entity's claim from its old cell to a new one.
## [param entity] The entity to move.
## [param new_cell] The cell it should move to.
func move_entity(entity: Entity, new_cell: Vector2i) -> void:
	remove_entity(entity)
	place_entity(entity, new_cell)

## Claims a cell for an entity and updates the entity's grid_position to match.
## [param entity] The entity to place.
## [param cell] The cell to claim.
func place_entity(entity: Entity, cell: Vector2i) -> void:
	assert(not occupants.has(cell), "Cell %s is already occupied" % cell)
	occupants[cell] = entity
	entity.grid_position = cell

## Releases the cell the entity holds, if it actually holds one.
## [param entity] The entity to remove.
func remove_entity(entity: Entity) -> void:
	var cell: Vector2i = entity.grid_position
	if occupants.get(cell, null) == entity:
		occupants.erase(cell)
