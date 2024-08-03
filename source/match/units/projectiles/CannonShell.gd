extends Node3D

const Impact = preload("res://source/generic-scenes-and-nodes/3d/Impact.tscn")

var target_unit = null

@onready var _unit = get_parent()
@onready var _unit_particles = find_child("OriginParticles")
@onready var _timer = find_child("Timer")


func _ready():
	assert(target_unit != null, "target unit was not provided")
	_unit_particles.visible = _unit.visible
	_setup_unit_particles()
	_setup_timer()
	var impact = Impact.instantiate()
	get_tree().get_root().add_child(impact)
	if _calculate_hit():
		impact.global_position = target_unit.global_position
		target_unit.hp -= _unit.attack_damage
	else:
		impact.global_position = target_unit.global_position + Vector3(randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0))


func _setup_timer():
	_timer.timeout.connect(queue_free)
	_timer.start(_unit_particles.lifetime)


func _setup_unit_particles():
	await get_tree().physics_frame  # wait for rotation to kick in if remote transform is used
	var a_global_transform = (
		_unit.global_transform
		if _unit.find_child("ProjectileOrigin") == null
		else _unit.find_child("ProjectileOrigin").global_transform
	)
	_unit_particles.global_transform = a_global_transform
	_unit_particles.emitting = true

func _calculate_hit():
	var bad_luck = randf_range(0.0, 1.0)
	var range_bonus = 1.0 - ( _unit.attack_range - _unit.global_position_yless.distance_to(target_unit.global_position_yless) )
	var chance = bad_luck*range_bonus
	if chance < _unit.attack_aim:
		return true
	return false
