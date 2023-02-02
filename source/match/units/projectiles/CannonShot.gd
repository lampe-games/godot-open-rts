extends Node3D

var target_unit = null

@onready var _unit = get_parent()
@onready var _unit_particles = find_child("OriginParticles")
@onready var _timer = find_child("Timer")


func _ready():
	assert(target_unit != null)
	_setup_unit_particles()
	_setup_timer()
	target_unit.hp -= _unit.attack_damage


func _setup_timer():
	_timer.timeout.connect(queue_free)
	_timer.start(_unit_particles.lifetime)


func _setup_unit_particles():
	var a_global_transform = (
		_unit.global_transform
		if _unit.find_child("ProjectileOrigin") == null
		else _unit.find_child("ProjectileOrigin").global_transform
	)
	_unit_particles.global_transform = a_global_transform
	_unit_particles.emitting = true
