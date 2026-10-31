extends AudioStreamPlayer3D

var timeout = 0
@onready var menu = $'../CanvasLayer/Control'

func _ready() -> void:
	call_deferred('scary')

func scary() -> void:
	while true:
		if int(randf_range(0,8000)) == 1:
			timeout = randf_range(0.4, 0.8)
			self.position.x += randf_range(-10,10)
			self.position.z += randf_range(-10,10)
			for i in range(randf_range(3,8)):
				if not menu.visible:
					self.pitch_scale = randf_range(0.7, 1.2)
					self.volume_db = randf_range(0.2, 0.3) - (i / 10)
					self.play()
					await get_tree().create_timer(timeout).timeout
		await get_tree().create_timer(10.0).timeout
