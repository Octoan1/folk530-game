class_name DialogBox
extends Control

@onready var name_label: Label = $Panel/Label
@onready var dialog_box: RichTextLabel = $Panel/RichTextLabel

signal finished

## Shows the conversation and starts the first line.
## [param data] The conversation to display.
func start(data: DialogData) -> void:
	visible = true
	name_label.text = data.speaker
	dialog_box.text = data.lines[0]
