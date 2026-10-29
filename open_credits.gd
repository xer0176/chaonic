extends Button

@onready var credits = $'../../Control4'
func _ready():
	pressed.connect(_on_self_pressed)

func _on_self_pressed():
	credits.visible = !credits.visible
