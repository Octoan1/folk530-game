class_name Player
extends Entity

@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var step_left: bool = false

signal restart

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
	position = GridWorld.cell_to_world(grid_position)
	attack = attack_scene.instantiate() as Attack
	add_sibling.call_deferred(attack)
	update_animation()
	sprite.animation_finished.connect(_on_attack_finish)
	anim_player = $AnimationPlayer
	anim_player.play("RESET")

## Handles input: validates a step, commits it, then advances the world.
## [param event] The input event received this frame.
func _unhandled_input(event: InputEvent) -> void:
	if health_component.is_dead or UpdateManager.is_busy() or LevelManager.is_transitioning:
		return

	var direction: Vector2i = _get_direction(event)
	if direction != Vector2i.ZERO:
		try_move(direction)
	
	if event.is_action_pressed("player_attack") and not event.is_echo():
		try_attack()

func update_animation() -> void:
	var anim_name: String = DIRECTION_ANIMATIONS[facing]
	sprite.play(anim_name)

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
	
	if GridWorld.is_goal(path.back()):
		await active_tween.finished
		if not health_component.is_dead:
			CheckpointManager.has_checkpoint = false
			LevelManager.next_level()
			
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

## The player attacks the tile right next to them
## If there is an [Entity] that where [member Entity.is_killable] == true, then that entity will run [member Entity.die()]
func try_attack() -> void:
	_set_animating(true)
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

## Unlocks input and and hides attack when the attack animation ends
func _on_attack_finish() -> void:
	if sprite.animation == "Attack":
		_set_animating(false)
		update_animation()

func die() -> void:
	health_component.is_dead = true
	restart.emit()


func _on_animated_sprite_2d_animation_finished() -> void:
	#var walk_anim: Array[String] = [
		#"StepDownLeft",
		#"StepDownRight"
	#]
	if sprite.animation.begins_with("Step"):
		update_animation()
		
func slide_along(path: Array[Vector2i], step_duration: float) -> void: 
	super(path, step_duration)
	sprite.play("Slide")
