extends WorldEnvironment

func _ready() -> void:
	call_deferred('rotate')

func rotate() -> void:
	while true:
		environment.sky_rotation.y += 0.0001
		await get_tree().create_timer(0.01).timeout
