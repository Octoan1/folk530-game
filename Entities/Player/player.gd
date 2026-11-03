class_name Player
extends Entity

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var attack_scene: PackedScene
var attack: Attack

const DIRECTION_ANIMATIONS: Dictionary = {
	Direction.LEFT: "WalkLeft",
	Direction.RIGHT: "WalkRight",
	Direction.UP: "WalkUp",
	Direction.DOWN: "WalkDown"
}

## True if the player is in the middle of moving, false otherwise
var is_moving: bool = false

## Sets the player to act from input instead of from the turn list.
func _init() -> void:
	takes_turns = false

## Snaps the player to its starting grid cell.
func _ready() -> void:
	position = GridWorld.cell_to_world(grid_position)
	attack = attack_scene.instantiate()
	add_sibling.call_deferred(attack)
	update_animation()
	sprite.animation_finished.connect(_on_attack_finish)

## Handles input: validates a step, commits it, then advances the world.
## [param event] The input event received this frame.
func _unhandled_input(event: InputEvent) -> void:
	if is_moving:
		return

	var direction: Vector2i = _get_direction(event)
	if direction != Vector2i.ZERO:
		try_move(direction)
	
	if event.is_action_pressed("player_attack") and not event.is_echo():
		try_attack()

## Slides this node to the given world position over a fixed duration.
## [param target] The world position to slide to.
## [param duration] How long the slide takes, in seconds.
func slide_to(target: Vector2, duration: float) -> void:
	is_moving = true
	super.slide_to(target, duration)
	active_tween.finished.connect(_on_tween_end)

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

## Moves the player to an open tile.
## If there is a wall, the player will not move into that spot
## [param direction] The direction that the player is trying to move
func try_move(direction: Vector2i) -> void:
	var target_cell: Vector2i = grid_position + direction
	if not GridWorld.can_enter(target_cell):
		return

	GridWorld.move_entity(self, target_cell)
	slide_to(GridWorld.cell_to_world(grid_position), SPEED)
	UpdateManager.run_turn()

## The player attacks the tile right next to them
## If there is an [Entity] that where [member Entity.is_killable] == true, then that entity will run [member Entity.die()]
func try_attack() -> void:
	is_moving = true
	var attack_cell: Vector2i = grid_position + DIRECTION_VECTORS[facing]
	play_attack_animation(attack_cell)
	var entity_status: Entity = GridWorld.get_entity_at(attack_cell)
	if entity_status != null and entity_status.is_killable:
		entity_status.die()
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

## Unlocks input once the slide has finished.
func _on_tween_end() -> void:
	is_moving = false

## Unlocks input and and hides attack when the attack animation ends
func _on_attack_finish() -> void:
	if sprite.animation == "IdleDown":
		is_moving = false
		attack.end_attack()
		update_animation()
	
