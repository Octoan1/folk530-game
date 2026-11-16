class_name Enemy
extends Entity


@export var attack_pattern: AttackPattern = preload("res://Data/Attack Patterns/front_1.tres") ## The attack pattern this enemy uses. Pick one from the list, or drag a pattern file in.
@export var damage: int = 1 ## How much damage the enemy does

var telegraphed_cells: Array[Vector2i] = [] ## The cells currently marked as dangerous. The attack lands on these next turn.
var attack_markers: Array[Attack] = [] ## The marker nodes that draw the telegraphed cells.

## Sets the enemy to act from the turn list and be hittable by the player.
func _init() -> void:
	super()
	takes_turns = true
	is_killable = true

## Snaps the enemy to its starting cell and warns about an empty attack list.
func _ready() -> void:
	position = GridWorld.cell_to_world(grid_position)
	if attack_pattern == null or attack_pattern.tiles.is_empty():
		push_warning("%s has no attack_tiles, so it will never attack." % name)

## Converts attack_tiles into grid cells for the direction the enemy is facing now.
## [return] The cells this enemy would attack, in the same order as attack_tiles.
func get_attack_cells() -> Array[Vector2i]:
	var forward: Vector2i = direction_vector
	var side: Vector2i = Vector2i(-forward.y, forward.x)
	var cells: Array[Vector2i] = []
	for offset: Vector2i in attack_pattern.tiles:
		var cell: Vector2i = grid_position + forward * offset.x + side * offset.y
		cells.append(cell)
	return cells

## Returns whether an attack is currently marked and waiting to land.
## [return] True if there are telegraphed cells.
func is_telegraphing() -> bool:
	return not telegraphed_cells.is_empty()

## Marks every attack cell that has ground and no wall, and remembers them.
## [return] True if at least one tile was marked, false if there was nothing to attack.
func start_telegraph() -> bool:
	assert(attack_scene != null, "%s has no attack_scene assigned" % name)
	clear_telegraph()
	for cell: Vector2i in get_attack_cells():
		if not GridWorld.is_walkable(cell):
			continue
		var marker: Attack = attack_scene.instantiate() as Attack
		get_parent().add_child(marker)
		marker.play_at(cell)
		attack_markers.append(marker)
		telegraphed_cells.append(cell)
	return is_telegraphing()

## Hits the player if they are standing on any marked cell, then removes the markers.
func resolve_telegraph() -> void:
	for cell: Vector2i in telegraphed_cells:
		var target: Entity = GridWorld.get_entity_at(cell)
		if target is Player:
			target.take_hit(damage)
			break
	clear_telegraph()

## Removes all attack markers and forgets the marked cells.
func clear_telegraph() -> void:
	for marker: Attack in attack_markers:
		if is_instance_valid(marker):
			marker.queue_free()
	attack_markers.clear()
	telegraphed_cells.clear()

## Removes any leftover markers, then removes the enemy.
func die() -> void:
	clear_telegraph()
	super()
