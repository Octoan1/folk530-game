class_name Skeleton
extends Entity

@onready var sprite: Sprite2D = $Sprite2D

const DIRECTION_ANIMATIONS: Dictionary[Direction, String] = {
	Direction.LEFT: "MoveLeft",
	Direction.RIGHT: "MoveRight",
	Direction.UP: "MoveUp",
	Direction.DOWN: "MoveDown"
}

## Sets the cow to act from turn list instead of input
func _init() -> void:
	super()
	takes_turns = true
	is_killable = true

## Snaps the entity to its starting grid cell.
func _ready() -> void:
	attack = attack_scene.instantiate() as Attack
	add_sibling.call_deferred(attack)
	position = GridWorld.cell_to_world(grid_position)
	update_animation()
	anim_player = $AnimationPlayer
	anim_player.play("RESET")

func take_turn() -> void:
	
	if attack.visible:
		var ent: Entity = GridWorld.get_entity_at(GridWorld.world_to_cell(attack.position))
		if ent is Player:
			ent.take_hit()
			if ent.health_component.is_dead:
				return
		attack.end_attack()
	try_move()
	
	var target_cell: Vector2i = grid_position + direction_vector
	var entity: Entity = GridWorld.get_entity_at(target_cell)
	if entity != null and entity is Player:
		attack.play_at(target_cell)
		return
	
	
	if not GridWorld.can_enter(grid_position + direction_vector) and not attack.visible:
		facing = get_opposite_direction(facing)

func try_move() -> void:
	var path: Array[Vector2i] = get_slide_path(grid_position, direction_vector)
	
	if path.is_empty():
		return
	
	GridWorld.move_entity(self, path.back())
	slide_along(path, SPEED)

func update_animation() -> void:
	if facing == Direction.LEFT:
		sprite.flip_h = true
	if facing == Direction.RIGHT:
		sprite.flip_h = false

func die() -> void:
	attack.queue_free()
	super()
