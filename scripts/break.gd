extends RigidBody3D

@onready var impactsound = $AudioStreamPlayer3D

func _on_body_entered(node: Node) -> void:
	var speed = linear_velocity.length()
	print(speed)
	if speed > 1.2:
		impactsound.volume_db = remap(speed, 1.2, 16.0, -14.0, 4.0)
		impactsound.play()
	if linear_velocity.length() > 10.0 and has_node('Generic6DOFJoint3D'):
		$Generic6DOFJoint3D.queue_free()
		print('3')
