extends HSlider

const UI_HOVER: AudioStreamWAV = preload("res://Assets/Sounds/SFX/UIHover.wav")
const UI_SELECT: AudioStreamWAV = preload("res://Assets/Sounds/SFX/UISelect.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	AudioManager.play_sfx(UI_HOVER)
	
func  _on_focus_entered() -> void:
	AudioManager.play_sfx(UI_HOVER)
	
func _on_value_changed(value: float) -> void:
	AudioManager.play_sfx(UI_HOVER)

func  _on_drag_started() -> void:
	AudioManager.play_sfx(UI_SELECT)
