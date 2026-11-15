class_name HealthBar
extends Control

@onready var progress_bar: ProgressBar = $ProgressBar

var health_component: HealthComponent

## Finds the parent entity's health component and starts listening to it.
func _ready() -> void:
	var parent: Entity = get_parent() as Entity
	health_component = parent.health_component
	health_component.health_changed.connect(_refresh)
	
	progress_bar.max_value = health_component.max_health
	progress_bar.value = health_component.health

## Updates the bar to match the component's current health.
func _refresh() -> void:
	progress_bar.value = health_component.health
