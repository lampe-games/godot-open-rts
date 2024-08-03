extends Node3D

@onready var _particles = find_child("GPUParticles3D")

func _ready():
	_particles.connect("finished", _on_finished)
	_particles.emitting = true

func _on_finished():
	queue_free()
