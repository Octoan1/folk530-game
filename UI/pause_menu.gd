extends Control

@export var resume_button: Button
@export var music_slider: HSlider
@export var sfx_slider: HSlider

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
	
func _on_resume_button_pressed() -> void:
	UiManager.toggle_pause()
	
func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.set_music_volume(snappedf(value,.20))
	print("Music Vol = " + str(AudioServer.get_bus_volume_linear(music_bus_index)))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.set_sfx_volume(snappedf(value,.20))
	print("SFX Vol = " + str(AudioServer.get_bus_volume_linear(sfx_bus_index)))
