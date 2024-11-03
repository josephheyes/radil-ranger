extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const RAY_LENGTH = 1000

@export var damage := 1
var health = 6

var bullet = load("res://bullet.tscn")
var instance

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck = $Neck
@onready var camera = $Neck/Camera3D
@onready var gun_anim = $Neck/Camera3D/Rifle/AnimationPlayer
@onready var gun_barrel = $Neck/Camera3D/Rifle/RayCast3D

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
			neck.rotate_y(-event.relative.x * 0.005)
			camera.rotate_x(-event.relative.y * 0.005)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("lidar_scan"):
		lidar_scan(delta)
	
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
		if !gun_anim.is_playing():
			gun_anim.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func lidar_scan(delta: float):

	var mousepos = get_viewport().get_mouse_position()
	point_mesh(mousepos, 0.05)	
	
	
func point_mesh(pos: Vector2, radius = 0.05, color = Color.RED):
	var sphere_mesh := SphereMesh.new()
	var multimesh := MultiMesh.new()
	var multimesh_instance := MultiMeshInstance3D.new()
	var material := ORMMaterial3D.new()
	
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = 3000
	
	multimesh.mesh = sphere_mesh
	multimesh_instance.multimesh = multimesh
	multimesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2
	sphere_mesh.material = material
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	var origin = camera.project_ray_origin(pos)
	var end = origin + camera.project_ray_normal(pos) * 2000
	
	for i in multimesh.instance_count:
		var rand = RandomNumberGenerator.new()
		var new_end = Vector3(rand.randf_range(end.x-400, end.x+400), rand.randf_range(end.y-500, end.y+500), rand.randf_range(end.z-500, end.z+500))
		
		var space_state = get_world_3d().direct_space_state	
		
		var query = PhysicsRayQueryParameters3D.create(origin, new_end)
		query.collide_with_areas = true

		var result = space_state.intersect_ray(query)
		if result:
			multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(result.position)))
	
	get_tree().get_root().add_child(multimesh_instance)
	await fade_mesh_instance(multimesh_instance)


func fade_mesh_instance(instance: MultiMeshInstance3D):
	await get_tree().create_timer(2).timeout
	instance.queue_free()

func on_hit() -> void:
	print(health)
	health -= damage
	if health <= 0:
		queue_free()
		
		# TODO: some kind of death screen
