extends Button

func _ready():
	pressed.connect(_on_self_pressed)

func _on_self_pressed():
	get_tree().quit() 
