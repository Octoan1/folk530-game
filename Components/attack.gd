class_name Attack
extends Node2D

func play_at(cell: Vector2i, facing: Vector2i) -> void:
	visible = true
	_rotate_by_vector(facing)
	position = GridWorld.cell_to_world(cell)

func end_attack() -> void:
	visible = false

func _rotate_by_vector(facing: Vector2i) -> void:
	if facing == Vector2i(1, 0):
		rotation = deg_to_rad(0.0)
	if facing == Vector2i(-1, 0):
		rotation = deg_to_rad(180.0)
	if facing == Vector2i(0, 1):
		rotation = deg_to_rad(90.0)
	if facing == Vector2i(0, -1):
		rotation = deg_to_rad(-90.0)
