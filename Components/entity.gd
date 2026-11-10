class_name Entity
extends Node2D

enum Direction { LEFT, RIGHT, UP, DOWN }
const SPEED: float = 0.1
const MAX_SLIDE_LENGTH: int = 100
const DIRECTION_VECTORS: Dictionary[Direction, Vector2i] = {
	Direction.LEFT: Vector2i(-1, 0),
	Direction.RIGHT: Vector2i(1, 0),
	Direction.UP: Vector2i(0, -1),
	Direction.DOWN: Vector2i(0, 1)
}


@export var priority: int = 0 ## Lower numbers act first when UpdateManager runs a turn.
@export var facing: Direction = Direction.RIGHT: ## The direction that the player is facing
	set(value):
			facing = value  # 1. Update the actual value first
			
			# 2. Trigger the animation immediately if the node is ready
			if is_node_ready(): 
				update_animation()

var health_component: HealthComponent
var grid_position: Vector2i = Vector2i(0, 0) ## The position of the entity in relation to the map
var takes_turns: bool = true ## Whether UpdateManager should call take_turn() on this entity.The player turns this off, since it acts from input instead.
var is_killable: bool = false ## True if the player can attack them, false otherwise
var is_animating: bool = false
var active_tween: Tween ## The entity's active tween
var direction_vector: Vector2i: ## The [Vector2i] that corresponds to the entity's [member facing]
	get:
		return DIRECTION_VECTORS[facing]

## Registers this entity with the UpdateManager when it enters the scene tree.
func _enter_tree() -> void:
	grid_position = GridWorld.world_to_cell(global_position)
	GridWorld.place_entity(self, grid_position)
	if takes_turns:
		UpdateManager.register(self)
	
## Sets up HealthComponent
func _init() -> void:
	health_component = HealthComponent.new()
	health_component.died.connect(die)

## Unregisters this entity from the UpdateManager when it leaves the scene tree.
func _exit_tree() -> void:
	GridWorld.remove_entity(self)
	UpdateManager.unregister(self)
	_set_animating(false)

## Called once per world turn. Subclasses override this with their own behavior.
func take_turn() -> void:
	pass

## Animates this entity along a path of cells, one tween step per cell.
## Visual only: the caller must already have committed the move in GridWorld.
## [param path] The cells to pass through, in order, ending at the final cell.
## [param step_duration] How long each single-cell step takes, in seconds.
func slide_along(path: Array[Vector2i], step_duration: float) -> void:
	if path.is_empty():
		return
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	_set_animating(true)
	active_tween.set_trans(Tween.TRANS_LINEAR)
	for cell: Vector2i in path:
		var target: Vector2 = GridWorld.cell_to_world(cell)
		active_tween.tween_property(self, "position", target, step_duration)
	if not active_tween.finished.is_connected(_on_tween_end):
		active_tween.finished.connect(_on_tween_end)

## Updates the entity's animation status.
func _on_tween_end() -> void:
	_set_animating(false)

## Updates the animation of the entity
func update_animation() -> void:
	pass

## Returns the opposite direction of the given direction
## [param dir] The direction you want the opposite of
## [return] The opposite direction: Left<-->Right and Up<-->Down
func get_opposite_direction(dir: Direction) -> Direction:
	match dir:
		Direction.LEFT:
			return Direction.RIGHT
		Direction.RIGHT:
			return Direction.LEFT
		Direction.UP:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.UP
	return Direction.LEFT

## How the entity reacts to taking a hit
func take_hit() -> void:
	print("Took Hit")
	health_component.damage_health(1)

## Removes the entity from the scene
func die() -> void:
	GridWorld.remove_entity(self)
	self.queue_free()

## Called when another entity tries to walk into this one.
## Subclasses override this to be pushable, open, etc.
## [param direction] The direction the bumping entity is moving.
## [return] True if this entity vacated its cell, so the bumper may enter.
func on_bumped(_direction: Vector2i) -> bool:
	return false

## Works out where an entity ends up after stepping in a direction,
## including any sliding on ice.
## [param start] The cell the entity is leaving.
## [param direction] The direction of the step.
## [return] Every cell passed through, in order. Empty if the first step is blocked.
func get_slide_path(start: Vector2i, direction: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var current: Vector2i = start
	for _i: int in range(MAX_SLIDE_LENGTH):
		var next_cell: Vector2i = current + direction
		if not GridWorld.can_enter(next_cell):
			break
		cells.append(next_cell)
		current = next_cell
		if not GridWorld.is_ice(current):
			break
	return cells

## Updates this entity's animating flag and keeps UpdateManager's count in sync.
## Only reports when the value actually changes, so it can't double count.
## [param value] Whether this entity is now animating.
func _set_animating(value: bool) -> void:
	if value == is_animating:
		return
	is_animating = value
	if value:
		UpdateManager.animation_started()
	else:
		UpdateManager.animation_finished()
