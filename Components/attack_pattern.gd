class_name AttackPattern
extends Resource

## Tiles this pattern attacks, relative to the way the enemy is facing.
## First number: how many tiles in front. Second number: how many tiles to the right.
@export var tiles: Array[Vector2i] = [Vector2i(1, 0)]
