class_name HealthComponent
extends RefCounted

signal died ## Emitted once when health first reaches zero.
signal damaged ## Emitted every time damage is actually applied.

var max_health: float
var health: float
var is_dead: bool = false

## Creates a component at full health.
## [param starting_health] The maximum (and starting) health.
func _init(starting_health: float = 3.0) -> void:
	max_health = starting_health
	health = starting_health

## Subtracts health and emits died the first time it reaches zero.
## Does nothing once the component is already dead.
## [param amount] How much damage to apply.
func damage_health(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	damaged.emit()
	if health <= 0.0:
		is_dead = true
		died.emit()

## Restores health up to the maximum. Dead components can't be healed.
## [param amount] How much health to restore.
func heal_health(amount: float) -> void:
	if is_dead:
		return
	health = minf(health + amount, max_health)
