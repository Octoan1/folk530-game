extends Control

@export var resume_button: Button
@export var music_slider: HSlider
@export var sfx_slider: HSlider

@onready var music_bus_index:int =  AudioServer.get_bus_index("MUSIC_BUS")
@onready var sfx_bus_index:int =  AudioServer.get_bus_index("SFX_BUS")

func _ready() -> void:
	#sets up sliders
	music_slider.max_value = 2.0
	music_slider.step = .2
	sfx_slider.max_value = 2.0
	sfx_slider.step = .2
	
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus_index)
	print(AudioServer.get_bus_volume_linear(music_bus_index))
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus_index)

func _process(delta: float) -> void:
	pass
	
func _on_music_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
