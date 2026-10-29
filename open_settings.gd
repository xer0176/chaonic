extends Button

@onready var settings = $'../../Control2'
func _ready():
	pressed.connect(_on_self_pressed)

func _on_self_pressed():
	settings.visible = !settings.visible
