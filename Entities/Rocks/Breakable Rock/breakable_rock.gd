class_name BreakableRock
extends Entity

## Rocks never act on their own, so they stay out of the turn list.
func _init() -> void:
	takes_turns = false
	is_killable = true
	blocks_vision = true

## Snaps the rock to its starting cell.
func _ready() -> void:
	super()

func take_hit(_amount: int = 1) -> void:
	die()
