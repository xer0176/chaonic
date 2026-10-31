extends Node3D

func _ready() -> void:
	for child in get_children():
		if child is RigidBody3D:
			child.body_entered.connect(_on_any_part_impact.bind(child))

func _on_any_part_impact(collided_with: Node, bodyhit: RigidBody3D) -> void:
	var speed = bodyhit.linear_velocity.length()
	if speed > 3 and bodyhit.has_node('AudioStreamPlayer3D'):
		var hitsound = bodyhit.get_node('AudioStreamPlayer3D')
		hitsound.pitch_scale = randf_range(0.7, 1.2)
		hitsound.volume_db = randf_range(0.7, 1.2)
		hitsound.play()
	if speed > 10.0 and bodyhit.has_node('Generic6DOFJoint3D'):
		bodyhit.get_node('Generic6DOFJoint3D').queue_free()
