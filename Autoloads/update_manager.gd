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
	pass
