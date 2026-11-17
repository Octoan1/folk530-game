extends CanvasLayer

var paused : bool = false

@onready var pause_menu: PackedScene = preload("uid://bga18orbjq57d")
var current_pause_menu: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
