class_name Attack
extends Node2D

func play_at(cell: Vector2i) -> void:
	visible = true
	position = GridWorld.cell_to_world(cell)

func end_attack() -> void:
	visible = false
