class_name npc
extends Entity

@onready var prompt: Label = $InteractLabel

@export var dialog: DialogData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	prompt.text = "Press " + InputMap.action_get_events("player_interact")[0].as_text().substr(0,1) + " to talk"
	takes_turns = false

func can_interact() -> bool:
	return dialog != null

func interact() -> void:
	UiManager.start_dialog(dialog)

func show_prompt() -> void:
	if prompt != null:
		prompt.visible = true
	
func hide_prompt() -> void:
	if prompt != null:
		prompt.visible = false
