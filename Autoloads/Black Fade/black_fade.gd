extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

## Fades the screen to black and returns once it is fully dark.
## [param duration] How long the fade takes, in seconds.
func fade_out(duration: float) -> void:
	pass

## Fades the screen back in from black and returns once it is fully clear.
## [param duration] How long the fade takes, in seconds.
func fade_in(duration: float) -> void:
	pass
