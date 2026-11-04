extends Node

var entities: Array[Entity] = []
var active_animations: int = 0

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
	var entities_copy: Array[Entity] = entities.duplicate()
	for entity: Entity in entities_copy:
		if is_instance_valid(entity) and not entity.is_queued_for_deletion():
			entity.take_turn()

## Returns whether entity a should act before entity b.
## [param a] The first entity to compare.
## [param b] The second entity to compare.
## [return] True if a has a lower priority number than b.
func _compare_priority(a: Entity, b: Entity) -> bool:
	return a.priority < b.priority

## Records that an entity has started animating.
func animation_started() -> void:
	active_animations += 1

## Records that an entity has finished animating.
func animation_finished() -> void:
	active_animations -= 1

## Returns whether any entity is still animating.
## [return] True if input should stay locked.
func is_busy() -> bool:
	return active_animations > 0
