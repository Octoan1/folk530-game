class_name DialogBox
extends Control

const CHARS_PER_SEC: float = 15

@onready var name_label: Label = $Panel/NameLabel
@onready var dialog_box: RichTextLabel = $Panel/RichTextLabel
@onready var continue_label: Label = $Panel/ContinueLabel

var dialog: DialogData
var is_typing: bool = false
var active_tween: Tween
var curr_index: int = 0

signal finished

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	continue_label.text = "Press " + UiManager.get_action_key_text("player_interact") + " to continue. . ."

## Shows the conversation and starts the first line.
## [param data] The conversation to display.
func start(data: DialogData) -> void:
	dialog = data
	curr_index = 0
	visible = true
	name_label.text = data.speaker
	play_line(curr_index)

func play_line(index: int) -> void:
	continue_label.visible = false
	dialog_box.visible_ratio = 0.0
	dialog_box.text = dialog.lines[index]
	dynamic_typing(dialog_box.text.length() / CHARS_PER_SEC)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("player_interact"):
		if is_typing:
			_on_tween_end()
		elif dialog.lines.size() > curr_index:
			play_line(curr_index)
		else:
			finished.emit()
		get_viewport().set_input_as_handled()
	

func dynamic_typing(duration: float) -> void:
	is_typing = true
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(dialog_box, "visible_ratio", 1.0, duration)
	if not active_tween.finished.is_connected(_on_tween_end):
		active_tween.finished.connect(_on_tween_end)

func _on_tween_end() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	dialog_box.visible_ratio = 1.0
	continue_label.visible = true
	is_typing = false
	curr_index += 1
