extends Control

@onready var settings = $"../Control2"
@onready var crosshair = $"../Control3"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 

func _input(event):
	if event.is_action_pressed("menu") and get_tree().paused and visible:
		settings.visible = false
		crosshair.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
		visible = false
