extends Node

var map: TileMapLayer
var wall_map: TileMapLayer
var occupants: Dictionary[Vector2i, Entity] = {}
var player: Player

## Stores the map layers for the current level.
## [param ground] The layer used for coordinate conversion and ground checks.
## [param walls] The layer whose tiles block movement.
func setup(ground: TileMapLayer, walls: TileMapLayer) -> void:
	map = ground
	wall_map = walls

## Clears the map references, for use when a level is unloaded.
func clear() -> void:
	player = null
	map = null
	wall_map = null
	occupants.clear()

## Converts a grid coordinate into the world position of that tile's center.
## [param cell] The grid coordinate to convert.
## [return] The world-space position of the cell's center.
func cell_to_world(cell: Vector2i) -> Vector2:
	assert(map != null, "map is null! Make sure it is added to the levels export!")
	var world_position: Vector2 = map.map_to_local(cell)
	return world_position

## Converts a world position into the grid cell that contains it.
## [param world_position] The position to convert.
## [return] The cell containing that position.
func world_to_cell(world_position: Vector2) -> Vector2i:
	assert(map != null, "map is null! Make sure it is added to the levels export!")
	var cell: Vector2i = map.local_to_map(map.to_local(world_position))
	return cell

## Returns whether the entity is allowed to step into the given cell.
## [param cell] The grid coordinate to test.
## [return] True if the cell is free to walk on, false if it is blocked.
func is_walkable(cell: Vector2i) -> bool:
	assert(map != null and wall_map != null, "map or wall_map is null! Make sure they are added to the levels exports!")
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
	assert(not occupants.has(cell), "Cell %s is already occupied!" % cell)
	occupants[cell] = entity
	entity.grid_position = cell

## Releases the cell the entity holds, if it actually holds one.
## [param entity] The entity to remove.
func remove_entity(entity: Entity) -> void:
	var cell: Vector2i = entity.grid_position
	if occupants.get(cell, null) == entity:
		occupants.erase(cell)

## Returns whether the ground at the given cell is slippery.
## [param cell] The grid coordinate to test.
## [return] True if the cell has a ground tile marked as ice.
func is_ice(cell: Vector2i) -> bool:
	return _check_custom_data(cell, "is_ice")

## Returns whether the ground at the given cell is a checkpoint.
## [param cell] The grid coordinate to test.
## [return] True if the cell has a ground tile marked as checkpoint.
func is_checkpoint(cell: Vector2i) -> bool:
	return _check_custom_data(cell, "is_checkpoint")

## Returns whether the ground at the given cell is a goal.
## [param cell] The grid coordinate to test.
## [return] True if the cell has a ground tile marked as goal.
func is_goal(cell: Vector2i) -> bool:
	return _check_custom_data(cell, "is_goal")

## Helper function for the is_(data_name) functions.
## [param cell] The cell the function is checking
## [param data_name] The custom_data_name to check
func _check_custom_data(cell: Vector2i, data_name: String) -> bool:
	var tile: TileData = map.get_cell_tile_data(cell)
	if tile == null:
		return false
	if tile.get_custom_data(data_name):
		return true
	return false

## Looks from one cell toward another along a straight row or column.
## [param from] The cell doing the looking.
## [param to] The cell being looked for.
## [param max_range] The farthest distance, in cells, that can be seen.
## [return] The direction to face to see the target, or Vector2i.ZERO if it can't be seen.
func get_sight_direction(from: Vector2i, to: Vector2i, max_range: int) -> Vector2i:
	if from.x != to.x and from.y != to.y:
		return Vector2i.ZERO
	var distance: int = absi(from.y - to.y) if from.x == to.x else absi(from.x - to.x)
	if distance > max_range:
		return Vector2i.ZERO
	var direction: Vector2i = (to - from).sign()
	for i: int in range(1, distance):
		var target: Vector2i = from + (direction * i)
		var ent: Entity = get_entity_at(target)
		if wall_map.get_cell_tile_data(target) != null or (ent != null and ent.blocks_vision):
			return Vector2i.ZERO
	return direction
