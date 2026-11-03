extends Node

var entities: Array[Entity] = []

## Adds an entity to the list of things that act each turn.
## [param entity] The entity to start tracking.
func register(entity: Entity) -> void:
	entities.append(entity)

## Removes an entity from the list so it no longer acts.
## [param entity] The entity to stop tracking.
func unregister(entity: Entity) -> void:
	entities.erase(entity)

## Runs one world turn, calling take_turn() on every tracked entity in priority order.
func run_turn() -> void:
	entities.sort_custom(_compare_priority)
	for entity: Entity in entities:
		entity.take_turn()

## Returns whether entity a should act before entity b.
## [param a] The first entity to compare.
## [param b] The second entity to compare.
## [return] True if a has a lower priority number than b.
func _compare_priority(a: Entity, b: Entity) -> bool:
	return a.priority < b.priority
