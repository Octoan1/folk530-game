class_name BlackFade
extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

var active_tween: Tween

## Fades the screen to black and returns once it is fully dark.
## [param duration] How long the fade takes, in seconds.
func fade_out(duration: float) -> void:
	_fade_to(1.0, duration)
	await active_tween.finished

## Fades the screen back in from black and returns once it is fully clear.
## [param duration] How long the fade takes, in seconds.
func fade_in(duration: float) -> void:
	_fade_to(0.0, duration)
	await active_tween.finished

## Fades the screen to the desired alpha value.
## [param alpha] The value it will tween to.
## [param duration] How long the fade takes, in seconds.
func _fade_to(alpha: float, duration: float) -> void:
	if active_tween != null:
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(rect, "modulate:a", alpha, duration)
