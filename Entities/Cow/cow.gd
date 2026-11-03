class_name Cow
extends Entity

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const DIRECTION_ANIMATIONS: Dictionary = {
	Direction.LEFT: "MoveLeft",
	Direction.RIGHT: "MoveRight",
	Direction.UP: "MoveUp",
	Direction.DOWN: "MoveDown"
}

## Sets the cow to act from turn list instead of input
func _init() -> void:
	takes_turns = true
	is_killable = true

## Snaps the player to its starting grid cell.
func _ready() -> void:
	position = GridWorld.cell_to_world(grid_position)
	update_animation()

func take_turn() -> void:
	var target_cell: Vector2i = grid_position + direction_vector
	if not GridWorld.can_enter(target_cell):
		facing = get_opposite_direction(facing)
		return
	
	GridWorld.move_entity(self, target_cell)
	slide_to(GridWorld.cell_to_world(grid_position), SPEED)

func update_animation() -> void:
	var anim_name: String = DIRECTION_ANIMATIONS[facing]
	if anim_name == "MoveRight":
		sprite.flip_h = true
		sprite.play("MoveLeft")
	else:
		if sprite.flip_h:
			sprite.flip_h = false
		sprite.play(anim_name)
