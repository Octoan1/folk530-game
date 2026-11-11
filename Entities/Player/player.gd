class_name Player
extends Entity

@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal restart

const DIRECTION_ANIMATIONS: Dictionary = {
	Direction.LEFT: "WalkLeft",
	Direction.RIGHT: "WalkRight",
	Direction.UP: "WalkUp",
	Direction.DOWN: "WalkDown"
}

## Sets the player to act from input instead of from the turn list.
func _init() -> void:
	super()
	takes_turns = false

## Snaps the player to its starting grid cell.
func _ready() -> void:
	position = GridWorld.cell_to_world(grid_position)
	attack = attack_scene.instantiate() as Attack
	add_sibling.call_deferred(attack)
	update_animation()
	sprite.animation_finished.connect(_on_attack_finish)

## Handles input: validates a step, commits it, then advances the world.
## [param event] The input event received this frame.
func _unhandled_input(event: InputEvent) -> void:
	if health_component.is_dead or UpdateManager.is_busy():
		return

	var direction: Vector2i = _get_direction(event)
	if direction != Vector2i.ZERO:
		try_move(direction)
	
	if event.is_action_pressed("player_attack") and not event.is_echo():
		try_attack()

func update_animation() -> void:
	var anim_name: String = DIRECTION_ANIMATIONS[facing]
	if anim_name == "WalkLeft":
		sprite.flip_h = true
		sprite.play("WalkRight")
	else:
		if sprite.flip_h:
			sprite.flip_h = false
		sprite.play(anim_name)

func play_attack_animation(cell: Vector2i) -> void:
	sprite.play("IdleDown")
	attack.play_at(cell)

## Moves the player one step, sliding further if the path includes ice.
## If the step is blocked, nothing happens and no turn is spent.
## If an entity is in the way, it is asked to move aside first (e.g. a pushable rock).
## [param direction] The direction the player is trying to move.
func try_move(direction: Vector2i) -> void:
	var target_cell: Vector2i = grid_position + direction
	var blocker: Entity = GridWorld.get_entity_at(target_cell)
	if blocker != null:
		if not blocker.on_bumped(direction):
			return

	var path: Array[Vector2i] = get_slide_path(grid_position, direction)
	if path.is_empty():
		return

	GridWorld.move_entity(self, path.back())
	slide_along(path, SPEED)
	UpdateManager.run_turn()

## The player attacks the tile right next to them
## If there is an [Entity] that where [member Entity.is_killable] == true, then that entity will run [member Entity.die()]
func try_attack() -> void:
	_set_animating(true)
	var attack_cell: Vector2i = grid_position + DIRECTION_VECTORS[facing]
	play_attack_animation(attack_cell)
	var entity_status: Entity = GridWorld.get_entity_at(attack_cell)
	if entity_status != null and entity_status.is_killable:
		entity_status.take_hit()
	UpdateManager.run_turn()

## Converts an input event into a grid direction.
## [param event] The input event to interpret.
## [return] A direction vector, or Vector2i.ZERO if the event isn't a move.
func _get_direction(event: InputEvent) -> Vector2i:
	if event.is_echo():
		return Vector2i.ZERO
	if event.is_action_pressed("player_left"):
		facing = Direction.LEFT
		return Vector2i(-1, 0)
	if event.is_action_pressed("player_right"):
		facing = Direction.RIGHT
		return Vector2i(1, 0)
	if event.is_action_pressed("player_up"):
		facing = Direction.UP
		return Vector2i(0, -1)
	if event.is_action_pressed("player_down"):
		facing = Direction.DOWN
		return Vector2i(0, 1)
	return Vector2i.ZERO

## Unlocks input and and hides attack when the attack animation ends
func _on_attack_finish() -> void:
	if sprite.animation == "IdleDown":
		_set_animating(false)
		attack.end_attack()
		update_animation()

func die() -> void:
	health_component.is_dead = true
	restart.emit()
