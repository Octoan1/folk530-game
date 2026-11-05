class_name BreakableRock
extends Entity

## Rocks never act on their own, so they stay out of the turn list.
func _init() -> void:
	takes_turns = false
	is_killable = true

## Snaps the rock to its starting cell.
func _ready() -> void:
	position = GridWorld.cell_to_world(grid_position)

func take_hit() -> void:
	die()
