class_name Projectile
extends Entity

## How many cells the projectile travels each turn.
@export var cells_per_turn: int = 1

## Moves the projectile forward, stopping at the first thing in its way.
func take_turn() -> void:
	pass

## Applies this projectile's damage to an entity, if the rules say it can be hurt.
## [param target] The entity the projectile ran into.
func _hit(target: Entity) -> void:
	pass
