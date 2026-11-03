class_name Level
extends Node2D

## The movable ground
@export var map: TileMapLayer

## The map of tiles that are not walkable
@export var wall_map: TileMapLayer

func _enter_tree() -> void:
	GridWorld.setup(map, wall_map)

func _exit_tree() -> void:
	GridWorld.clear()
