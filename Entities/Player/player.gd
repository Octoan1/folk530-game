class_name Player
extends Entity

@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var step_left: bool = false

const PLAYER_ATTACK:AudioStreamWAV = preload("res://Assets/Sounds/SFX/PlayerAttack.wav")
const SNOW_WALK: AudioStreamWAV = preload("res://Assets/Sounds/SFX/SnowWalk.wav")
const PLAYER_DAMAGED: AudioStreamWAV = preload("res://Assets/Sounds/SFX/PlayerDamaged.wav")
const PLAYER_DEATH: AudioStreamWAV = preload("res://Assets/Sounds/SFX/PlayerDeath.wav")


signal restart ## Emitted when the player wants the level to restart, such as dying
signal reached_goal ## emitted when the player reaches the goal

const DIRECTION_ANIMATIONS: Dictionary[Direction, String] = {
	Direction.LEFT: "IdleLeft",
	Direction.RIGHT: "IdleRight",
	Direction.UP: "IdleUp",
	Direction.DOWN: "IdleDown"
}

## Sets the player to act from input instead of from the turn list.
func _init() -> void:
	super()
	takes_turns = false

## Snaps the player to its starting grid cell.
func _ready() -> void:
	super()
	update_animation()
	anim_player = $AnimationPlayer
	anim_player.play("RESET")

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

## updates the idle animation to the direction the player is facing
func update_animation() -> void:
	var anim_name: String = DIRECTION_ANIMATIONS[facing]
	sprite.play(anim_name)

## Plays the attack animation, spawns the attacks markers
func play_attack_animation(cells: Array[Vector2i]) -> void:
	sprite.play("Attack")
	var attacks: Array[Attack] = spawn_attack_markers(cells)
	await get_tree().create_timer(0.1).timeout
	for att: Attack in attacks:
		att.end_attack()

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

	if GridWorld.is_checkpoint(path.back()):
		CheckpointManager.set_checkpoint(path.back())
		health_component.heal_health(health_component.max_health)
	
	GridWorld.move_entity(self, path.back())
	slide_along(path, SPEED)
	UpdateManager.run_turn()
	
	if path.size() > 2:
		sprite.play("Slide")
		await active_tween.finished
		update_animation()
	else:
		if facing == Direction.DOWN:
			sprite.play("StepDownLeft" if step_left else "StepDownRight")
			step_left = not step_left
		elif facing == Direction.UP:
			sprite.play("StepUpLeft" if step_left else "StepUpRight")
			step_left = not step_left
		elif facing == Direction.LEFT:
			sprite.play("StepLeft")
		elif facing == Direction.RIGHT:
			sprite.play("StepRight")
	
	if GridWorld.is_goal(path.back()):
		if active_tween.is_running():
			await active_tween.finished
		if not health_component.is_dead:
			reached_goal.emit()

## The player attacks according to their attack pattern
## If there is an [Entity] that [Entity] will run [member Entity.take_hit()]
func try_attack() -> void:
	_set_animating(true)
	AudioManager.play_sfx(PLAYER_ATTACK,randf_range(.8,1.0), .2)
	var attack_cells: Array[Vector2i] = get_attack_cells()
	for attack_cell: Vector2i in attack_cells:
		var entity_status: Entity = GridWorld.get_entity_at(attack_cell)
		if entity_status != null and entity_status.is_killable:
			entity_status.take_hit()
	await play_attack_animation(attack_cells)
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

func take_hit(_amount: int = 1) -> void:
	if self.health_component.health == 1:
			AudioManager.play_sfx(PLAYER_DEATH, randf_range(.9,1.0), .05)
	else:
		AudioManager.play_sfx(PLAYER_DAMAGED, randf_range(.9,1.0), .05)
	
	super()

## Restarts the level from the start or previous checkpoint
func die() -> void:
	restart.emit()

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.begins_with("Step"):
		update_animation()
	if sprite.animation == "Attack":
		_set_animating(false)
		update_animation()
	
func slide_along(path: Array[Vector2i], step_duration: float) -> void:
	AudioManager.play_sfx(SNOW_WALK,randf_range(.4,.8))
	super(path, step_duration)
	sprite.play("Slide")
