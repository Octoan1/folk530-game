class_name Skeleton
extends Enemy

@onready var sprite: Sprite2D = $Sprite2D
const SKELETON_DEATH: AudioStreamWAV = preload("res://Assets/Sounds/SFX/SkeletonDeath.wav")

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
	slide_along(path, SPEED)

## Flips the sprite to match the facing direction.
func update_animation() -> void:
	if facing == Direction.LEFT:
		sprite.flip_h = true
	if facing == Direction.RIGHT:
		sprite.flip_h = false

func die() -> void:
	AudioManager.play_sfx(SKELETON_DEATH)
	super()
