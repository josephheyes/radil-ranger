extends Node3D

const SPEED = 40.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

@export var damage := 1
var health = 6

signal body_part_hit(dam)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		ray.enabled = true
		if !ray.get_collider() is StaticBody3D:
			ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
		
func _on_timer_timeout():
	queue_free()
	
func hit():
	print("test")
	emit_signal("body_part_hit", damage)
	
func _on_area_3d_body_part_hit(dam):
	print(health)
	health -= dam
	if health <= 0:
		queue_free()
