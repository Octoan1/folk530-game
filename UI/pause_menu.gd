extends Control

@export var resume_button: Button
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var main_node: Node

#Button script
const UiButton: GDScript = preload("res://UI/ui_button.gd")
const UiSlider: GDScript = preload("res://UI/ui_slider.gd")

var music_bus_index:int =  AudioServer.get_bus_index("Music")
var sfx_bus_index:int =  AudioServer.get_bus_index("SFX")

func _ready() -> void:
	#sets up sliders
	music_slider.max_value = 2.0
	music_slider.step = .2
	sfx_slider.max_value = 2.0
	sfx_slider.step = .2
	
	#set sliders to current bus volume
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus_index)
	
	#assign button script
	var buttons : Array[Node] = find_children("*", "Button", true, false)
	for button: Button in buttons:
		button.set_script(UiButton)
		button.mouse_entered.connect(Callable(button, "_on_mouse_entered"))
		button.focus_entered.connect(Callable(button, "_on_focus_entered"))
		button.pressed.connect(Callable(button, "_on_pressed"))
		
	#assign button script
	var sliders : Array[Node] = find_children("*", "HSlider", true, false)
	for slider: HSlider in sliders:
		slider.set_script(UiSlider)
		slider.drag_started.connect(Callable(slider, "_on_drag_started"))
		slider.focus_entered.connect(Callable(slider, "_on_focus_entered"))
		slider.mouse_entered.connect(Callable(slider, "_on_mouse_entered"))
		slider.value_changed.connect(Callable(slider, "_on_value_changed"))
		
	#grab focus
	resume_button.grab_focus()
	
func _on_resume_button_pressed() -> void:
	UiManager.toggle_pause()
	
func _on_respawn_button_pressed() -> void:
	UiManager.pause_restart_UI.emit()
	
func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(snappedf(value,.20))
	print("Music Vol = " + str(AudioServer.get_bus_volume_linear(music_bus_index)))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(snappedf(value,.20))
	print("SFX Vol = " + str(AudioServer.get_bus_volume_linear(sfx_bus_index)))
