class_name npc
extends Entity

@onready var prompt: Label = $InteractLabel

@export var dialog: DialogData

func _init() -> void:
	takes_turns = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	prompt.text = "Press " + UiManager.get_action_key_text("player_interact") + " to Talk!"

func can_interact() -> bool:
	return dialog != null and not dialog.lines.is_empty()

func interact() -> void:
	UiManager.start_dialog(dialog)

func show_prompt() -> void:
	if prompt != null:
		prompt.visible = true
	
func hide_prompt() -> void:
	if prompt != null:
		prompt.visible = false
