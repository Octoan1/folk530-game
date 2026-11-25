class_name Skeleton
extends Enemy

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const SKELETON_DEATH: AudioStreamWAV = preload("res://Assets/Sounds/SFX/SkeletonDeath.wav")
const SKELETON_DAMAGED: AudioStreamWAV = preload("res://Assets/Sounds/SFX/SkeletonDamaged.wav")
var step_left: bool = false

const DIRECTION_ANIMATIONS: Dictionary[Direction, String] = {
	Direction.LEFT: "IdleLeft",
	Direction.RIGHT: "IdleRight",
	Direction.UP: "IdleUp",
	Direction.DOWN: "IdleDown"
}

## preload("uid://typniyua3q75")Sets up the sprite and the animation player.
func _ready() -> void:
	super()
	update_animation()
	anim_player = $AnimationPlayer
	anim_player.play("RESET")

## Resolves a pending attack, or moves and starts a new attack if the player is in front.
func take_turn() -> void:
	if is_telegraphing():
		resolve_telegraph()
		return

	try_move()

	var target_cell: Vector2i = grid_position + direction_vector
	var in_front: Entity = GridWorld.get_entity_at(target_cell)
	if in_front is Player and start_telegraph():
		return

	if not GridWorld.can_enter(target_cell):
		facing = get_opposite_direction(facing)

## Slides one step (or along ice) in the facing direction, if the path is open.
func try_move() -> void:
	var path: Array[Vector2i] = get_slide_path(grid_position, direction_vector)
	if path.is_empty():
		return
	GridWorld.move_entity(self, path.back())
	if _is_move_visible(path):
		slide_along(path, SPEED)
	else:
		position = GridWorld.cell_to_world(grid_position)
		
	if path.size() > 2:
		#sprite.play("Slide")
		#await active_tween.finished
		#update_animation()
		pass
	else:
		if facing == Direction.DOWN:
			sprite.play("WalkDown1" if step_left else "WalkDown2")
		elif facing == Direction.UP:
			sprite.play("WalkUp1" if step_left else "WalkUp2")
		elif facing == Direction.LEFT:
			sprite.play("WalkLeft1" if step_left else "WalkLeft2")
		elif facing == Direction.RIGHT:
			sprite.play("WalkRight1" if step_left else "WalkRight2")
		step_left = not step_left

## Flips the sprite to match the facing direction.
func update_animation() -> void:
	var anim_name: String = DIRECTION_ANIMATIONS[facing]
	sprite.play(anim_name)

func take_hit(damage: int = 1) -> void:
	AudioManager.play_sfx(SKELETON_DAMAGED, randf_range(.6,1.0), .3)
	super()

func die() -> void:
	AudioManager.play_sfx(SKELETON_DEATH, randf_range(.6,1.0), .3)
	super()


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.begins_with("Walk"):
		update_animation()
