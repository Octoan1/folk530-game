extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

## Fades the screen to black and returns once it is fully dark.
## [param duration] How long the fade takes, in seconds.
func fade_out(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1, duration)

## Fades the screen back in from black and returns once it is fully clear.
## [param duration] How long the fade takes, in seconds.
func fade_in(duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0, duration)
