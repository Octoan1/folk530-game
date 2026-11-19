class_name BlackFade
extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

var active_tween: Tween

## Fades the screen to black and returns once it is fully dark.
## [param duration] How long the fade takes, in seconds.
func fade_out(duration: float) -> void:
	active_tween = create_tween()
	active_tween.tween_property(rect, "modulate:a", 1, duration)
	await active_tween.finished

## Fades the screen back in from black and returns once it is fully clear.
## [param duration] How long the fade takes, in seconds.
func fade_in(duration: float) -> void:
	active_tween = create_tween()
	active_tween.tween_property(rect, "modulate:a", 0, duration)
	await active_tween.finished
