extends Node3D

@onready var _particles = find_child("GPUParticles3D")


func _ready():
	await get_tree().physics_frame  # wait one frame for transform to propagate
	_particles.emitting = true
