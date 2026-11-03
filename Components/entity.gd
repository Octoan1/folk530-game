class_name Entity
extends Node2D

enum Direction { LEFT, RIGHT, UP, DOWN }
const SPEED: float = 0.15
const DIRECTION_VECTORS: Dictionary = {
	Direction.LEFT: Vector2i(-1, 0),
	Direction.RIGHT: Vector2i(1, 0),
	Direction.UP: Vector2i(0, -1),
	Direction.DOWN: Vector2i(0, 1)
}

## Lower numbers act first when UpdateManager runs a turn.
@export var priority: int = 0

## The position of the entity in relation to the map
@export var grid_position: Vector2i = Vector2i(0, 0)

## The direction that the player is facing
@export var facing: Direction = Direction.RIGHT:
	set(value):
			facing = value  # 1. Update the actual value first
			
			# 2. Trigger the animation immediately if the node is ready
			if is_node_ready(): 
				update_animation()

## Whether UpdateManager should call take_turn() on this entity.
## The player turns this off, since it acts from input instead.
var takes_turns: bool = true

## The [Vector2i] that corresponds to the entity's [member facing]
var direction_vector: Vector2i:
	get:
		return DIRECTION_VECTORS[facing]

## The entity's active tween
var active_tween: Tween

## Registers this entity with the UpdateManager when it enters the scene tree.
func _enter_tree() -> void:
	if takes_turns:
		UpdateManager.register(self)

## Unregisters this entity from the UpdateManager when it leaves the scene tree.
func _exit_tree() -> void:
	UpdateManager.unregister(self)

## Called once per world turn. Subclasses override this with their own behavior.
func take_turn() -> void:
	pass

## Slides the entity to the given target cell
## [param target] The cell that the entity will move to
## [param duration] How long the slide will take
func slide_to(target: Vector2, duration: float) -> void:
	active_tween = create_tween()
	active_tween.tween_property(self, "position", target, duration)

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
