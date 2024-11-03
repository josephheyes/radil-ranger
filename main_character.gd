extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var bullet = load("res://bullet.tscn")
var instance

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var mainchar= $"."
@onready var neck = $Neck
@onready var scientist=$scientist
@onready var camera = $Neck/Camera3D
@onready var gun_animation = $Neck/Camera3D/Rifle/Blahaj
@onready var gun_anim = $Neck/Camera3D/Rifle/AnimationPlayer
@onready var gun_barrel = $Neck/Camera3D/Rifle/RayCast3D
@onready var blahaj=$Neck/Camera3D/Rifle/Blahaj
@onready var rifle=$Neck/Camera3D/Rifle

	#camera.current=true
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
func _ready():
	if not is_multiplayer_authority():
		return
	camera.current=true

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			#neck.rotate_y(-event.relative.x * 0.005)
			##blahaj.rotate_y(-event.relative.x * 0.0005)
			#camera.rotate_x(-event.relative.y * 0.005)
			#scientist.rotate_y(-event.relative.x * 0.005)
			#rifle.rotate_y(-event.relative.x * 0.005)
			#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))
			##blahaj.rotation.x= clamp(blahaj.rotation.x, deg_to_rad(-30), deg_to_rad(60))
			#rifle.rotation.x = clamp(rifle.rotation.x, deg_to_rad(-30), deg_to_rad(60))
			#scientist.rotation.x = clamp(scientist.rotation.x, deg_to_rad(-30), deg_to_rad(60))
			mainchar.rotate_y(-event.relative.x * 0.005)
			mainchar.rotation.x = clamp(mainchar.rotation.x, deg_to_rad(-30), deg_to_rad(60))
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Shooot
	if Input.is_action_pressed("Shoot"):
		rpc("shoot")
		
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

@rpc("any_peer", "call_local", "reliable")
func shoot():
	#if not is_multiplayer_authority():
		#return
	print("test")
	if !gun_anim.is_playing():
		print("test")
		gun_anim.play("Shoot")
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
	
