class_name Projectile
extends Entity

## How many cells the projectile travels each turn.
@export var cells_per_turn: int = 1
## How long the projectile takes to cross one cell, in seconds.
@export var step_duration: float = 0.05

## True once the projectile has hit something and is waiting to disappear.
var is_spent: bool = false

## Sets the projectile to act from the turn list, before the enemies do.
func _init() -> void:
	super()
	takes_turns = true
	priority = -10

## Points the sprite the way the projectile is travelling.
func _ready() -> void:
	super()
	update_animation()

## Rotates the sprite to match the facing direction.
func update_animation() -> void:
	rotation = Vector2(direction_vector).angle()

## Moves the projectile forward, stopping at the first thing in its way.
func take_turn() -> void:
	if is_spent:
		return

	var path: Array[Vector2i] = []
	var current: Vector2i = grid_position
	var blocked: bool = false

	for _step: int in range(cells_per_turn):
		var next_cell: Vector2i = current + direction_vector
		if not GridWorld.is_walkable(next_cell):
			blocked = true
			break
		var target: Entity = GridWorld.get_entity_at(next_cell)
		if target != null:
			_hit(target)
			blocked = true
			break
		path.append(next_cell)
		current = next_cell

	if not path.is_empty():
		GridWorld.move_entity(self, path.back())
		if _is_move_visible(path):
			slide_along(path, step_duration)
		else:
			position = GridWorld.cell_to_world(grid_position)

	if blocked:
		_despawn()

## Applies this projectile's damage to an entity, if the rules say it can be hurt.
## [param target] The entity the projectile ran into.
func _hit(target: Entity) -> void:
	if target.is_killable:
		target.take_hit(damage)

## Removes the projectile from the game logic now, and from the screen once it
## has finished sliding.
func _despawn() -> void:
	is_spent = true
	GridWorld.remove_entity(self)
	UpdateManager.unregister(self)
	if active_tween != null and active_tween.is_running():
		active_tween.finished.connect(queue_free)
	else:
		queue_free()
