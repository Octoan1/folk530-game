extends CanvasLayer

var paused : bool = false

@onready var pause_menu: PackedScene = preload("uid://bga18orbjq57d")
@onready var dialog_screen: PackedScene = preload("uid://d4jc7npoer6kq")

var current_pause_menu: Control = null
var current_dialog_screen: DialogBox = null
var is_dialog_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		
func toggle_pause() -> void:
	if paused:
			paused = false
			get_tree().paused = false
			if current_pause_menu != null:
				current_pause_menu.queue_free()
				current_pause_menu = null
	else:
		current_pause_menu = pause_menu.instantiate()
		add_child(current_pause_menu)
		current_pause_menu.grab_focus()
		paused = true
		get_tree().paused = true

func start_dialog(data: DialogData) -> void:
	current_dialog_screen = dialog_screen.instantiate()
	add_child(current_dialog_screen)
	current_dialog_screen.finished.connect(end_dialog)
	current_dialog_screen.start(data)
	is_dialog_open = true

func end_dialog() -> void:
	if current_dialog_screen != null:
		current_dialog_screen.queue_free()
		current_dialog_screen = null
	is_dialog_open = false
	
