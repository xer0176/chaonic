extends CharacterBody3D

var playerspeed = 5.0
var playeroriginalspeed = playerspeed
var playersprintspeedmultiplier = 2.0
var playerjumpheight = 5.0
var playermousesensitivity = 0.003
var playeracceleration = 60.0 * playerspeed
var playerfriction = 45.0
var playerjumps = 0.0
var playeronfloor = false
var playerflyjump = false
var playerlastvelocity : Vector3 = Vector3.ZERO
var playerfirstperson = true
var playerstepcool = 0.0
var playerfov = 100.0
var playerfast = false
var playerdeltavelocity = 0.0
var playertweenzoom = null
var playerpushforce = 25.0
var playercrouched = false
var playercrouchspeedmultiplier = 2.0
var playersprinting = false
var playerslampower = 100.0
var playerslamming = false
var playerhealth = 100.0
var playerfallhealthloss = 0.0
var playerdoslams = true
var playerdead = false
var playerdirection = null
var mapfalllimit = 99999999.0
var playerfalldamage = false
var mapspawns = []
var playerspawnhealth = 100.0
var playernoclip = false
var mapautocleartimer = 0.0
var playerinmenu = true
var playercrouchsubtractor = 0.85
var playerisonbounce = false
var playerbouncemultiplier = 1.4
var playerinair = false

@onready var camera = $SpringArm3D/Camera3D
@onready var cameraarm = $SpringArm3D
@onready var jumpsound = $AudioStreamPlayer3D
@onready var menu = $CanvasLayer/Control
@onready var settings = $CanvasLayer/Control2
@onready var credits = $CanvasLayer/Control4
@onready var crosshair = $CanvasLayer/Control3
@onready var body = $MeshInstance3D
@onready var floorray = $RayCast3D
@onready var grasssound = $AudioStreamPlayer3D2
@onready var concretesound = $AudioStreamPlayer3D3
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var bodyshape: MeshInstance3D = $MeshInstance3D
@onready var notyoursteps = $AudioStreamPlayer3D4
const configurationpath = 'user://data/settings.cfg/'
var configuration = ConfigFile.new()

var playergravity = ProjectSettings.get_setting('physics/3d/default_gravity')

#have cameraFOV slider logic here ------------------------------------------------------------------------------------------------------------------------------------------------------

func _on_check_box_toggled(value: bool):
	playerflyjump = value

func _on_h_slider_value_changed(value: float):
	playerspeed = value
	playeracceleration = 32.0 * playerspeed
	
func _on_h_slider_2_value_changed(value: float):
	playerjumpheight = value
	
func _on_button_7_pressed():
	playerinmenu = false
	
func _on_check_box_2_toggled(value: bool):
	playerfirstperson = value
	if not playerfirstperson:
		body.visible = false
		cameraarm.spring_length = 0
		cameraarm.position.y -= 1
	else:
		body.visible = true
		cameraarm.spring_length = 2.5
		cameraarm.position.y += 1

func _ready():
	var mapallnodes = get_tree().current_scene.find_children('*', '', true, false)
	for node in mapallnodes:
		if node is CSGPrimitive3D:
			var mapbottomedge = node.global_position.y - (node.size.y)
			if mapbottomedge < mapfalllimit:
				mapfalllimit = mapbottomedge
		if 'Spawn' in node.name:
			mapspawns.append(node)
	configuration.load(configurationpath)
	set_process(true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DiscordRPC.app_id = 1564434861098410015
	DiscordRPC.details = get_tree().current_scene.scene_file_path.get_file()
	DiscordRPC.state = 'Shitting around as usual'
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
	
func _notification(event):
	if event != NOTIFICATION_PROCESS:
		return
	if Input.is_action_just_pressed('menu'):
		get_viewport().set_input_as_handled()
		menu.visible = !menu.visible
		if menu.visible and not get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			crosshair.visible = false
			get_tree().paused = true
		if not menu.visible:
			get_tree().paused = false
			settings.visible = false
			credits.visible = false
			crosshair.visible = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * playermousesensitivity)
		cameraarm.rotate_x(-event.relative.y * playermousesensitivity)
		#camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-89),deg_to_rad(89))
		cameraarm.rotation.x = clamp(cameraarm.rotation.x,deg_to_rad(-89),deg_to_rad(89))
			
func _physics_process(delta):
	if Engine.get_frames_per_second() < 1:
		mapautocleartimer += delta
		if mapautocleartimer > 3:
			get_tree().reload_current_scene()
	if menu.visible:
		return
	if not is_on_floor():
		if Input.is_action_just_pressed('slam') and not playerslamming and playerdoslams and velocity.length() > 20:
			velocity.y -= playerslampower
			playerslamming = true
		velocity.y -= playergravity * delta
		if velocity.y < -20 and playerfalldamage:
			playerfallhealthloss += 1
		if position.y < mapfalllimit:
			playerhealth = 0
			playerdead = true
	if is_on_floor():
		playerjumps = 0
		playerslamming = false
		playerhealth -= playerfallhealthloss
		if playerhealth <= 0:
			playerdead = true
		playerfallhealthloss = 0
	if not playerdead: # and not playerinmenu
		if Input.is_action_just_pressed('jump') and playerjumps < 2 and !menu.visible:
			velocity.y = playerjumpheight
			jumpsound.pitch_scale = randf_range(0.7, 1.2)
			jumpsound.volume_db = randf_range(0.5, 0.8)
			jumpsound.play()
			playerslamming = false
			if not playerflyjump:
				playerjumps += 1
		if Input.is_action_just_pressed('cross'):
			crosshair.visible = !crosshair.visible
		if Input.is_action_just_pressed('crouch') and (collision.shape.height - 0.5) > 0.01 and not playercrouched:
			cameraarm.position.y -= playercrouchsubtractor
			collision.position.y -= 0.4
			collision.shape.height -= playercrouchsubtractor
			bodyshape.mesh.height -= playercrouchsubtractor
			body.position.y -= 0.4
			playercrouched = true
			playerspeed /= playercrouchspeedmultiplier
		if Input.is_action_just_released('crouch') and playercrouched:
			cameraarm.position.y += 0.85
			collision.shape.height += 0.85
			bodyshape.mesh.height += 0.85
			body.position.y += 0.4
			collision.position.y += 0.4
			playercrouched = false
			playerspeed *= playercrouchspeedmultiplier
		if Input.is_action_just_pressed('sprint') and !menu.visible and not playersprinting:
			playerspeed *= playersprintspeedmultiplier
			playersprinting = true
		if Input.is_action_just_released('sprint') and playersprinting:
			playerspeed /= playersprintspeedmultiplier
			playersprinting = false
		if Input.is_action_just_pressed('killbind'):
			playerhealth = 0
			playerdead = true
		var playerinputdirection = Input.get_vector('moveleft','moveright','moveforward','movebackward')
		playerdirection = (transform.basis * Vector3(playerinputdirection.x,0,playerinputdirection.y)).normalized()
		if playerdirection and !menu.visible:
			velocity.x = move_toward(velocity.x,playerdirection.x * playerspeed,playeracceleration * delta)
			velocity.z = move_toward(velocity.z,playerdirection.z * playerspeed,playeracceleration * delta)
		else:
			velocity.x = move_toward(velocity.x,0,playerfriction * delta)
			velocity.z = move_toward(velocity.z,0,playerfriction * delta)
	if playerdead:
		body.rotation_degrees.x = 90
		collision.rotation_degrees.x = 90
		playerdirection = Vector3.ZERO
		playerfirstperson = false
		if is_on_floor():
			velocity.x = move_toward(velocity.x,0,playerfriction * delta)
			velocity.z = move_toward(velocity.z,0,playerfriction * delta)
		if Input.is_action_just_pressed('jump'):
			playerfirstperson = true
			var mapspawn = mapspawns.pick_random()
			body.rotation_degrees.x = 0
			collision.rotation_degrees.x = 0
			global_position = mapspawn.global_position
			playerdead = false
			playerhealth = playerspawnhealth
			velocity = Vector3.ZERO
			playerlastvelocity = Vector3.ZERO
			playerfallhealthloss = 0.0
			playerslamming = false
	var playertargetfov = (playerfov + 20) if velocity.length() > 20 else playerfov
	camera.fov = move_toward(camera.fov, playertargetfov, 40.0 * delta)
	if is_on_floor() and velocity.length() > 0.05 and not playerdead: 
		playerstepcool += delta 
		if playerstepcool > 2.5 / playerspeed: 
			playerstepcool = 0 
			floorray.force_raycast_update() 
			var playersurface = floorray.get_collider()  
			var playersurfacematerial: Material = null
			if playersurface and 'material' in playersurface: 
				playersurfacematerial = playersurface.material
				if not playersurfacematerial and playersurface.get_parent() and 'material' in playersurface.get_parent():
					playersurfacematerial = playersurface.get_parent().material
			if playersurfacematerial and playersurfacematerial.resource_path: 
				var playersurfacematerialpath = playersurfacematerial.resource_path.to_lower()
				if 'grass' in playersurfacematerialpath: 
					grasssound.pitch_scale = randf_range(0.7, 1.2)
					grasssound.volume_db = randf_range(0.5, 0.8)
					grasssound.play()
				if 'brick' or 'concrete' in playersurfacematerialpath: 
					concretesound.pitch_scale = randf_range(0.7, 1.2)
					concretesound.volume_db = randf_range(0.5, 0.8)
					concretesound.play()
				else: 
					concretesound.pitch_scale = randf_range(0.7, 1.2)
					concretesound.volume_db = randf_range(0.5, 0.8)
					concretesound.play()
	var playerearlyvelocity = velocity.length()
	playeronfloor = is_on_floor()
	move_and_slide()
	for i in get_slide_collision_count():
		var playercollision = get_slide_collision(i)
		if playercollision.get_collider() is RigidBody3D:
			var playerimpulsedirection = -playercollision.get_normal()
			playercollision.get_collider().apply_central_impulse(playerimpulsedirection * playerearlyvelocity * playerpushforce * delta)
	if playeronfloor and not is_on_floor() and playerlastvelocity.y > 0.1:
		velocity = playerlastvelocity
	playerlastvelocity = get_real_velocity()
