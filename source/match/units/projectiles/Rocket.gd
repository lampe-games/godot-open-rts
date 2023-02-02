# TODO: use animation player for better animation
# TODO: add particles for trail
extends Node3D

const ANIMATION_DURATION_S = 0.5

var target_unit = null

@onready var _unit = get_parent()
@onready var _path = find_child("Path3D")
@onready var _path_follow = find_child("PathFollow3D")


func _ready():
	assert(target_unit != null)
	target_unit.died.connect(queue_free)
	_setup_path()


func _physics_process(delta):
	_path.curve.set_point_position(1, target_unit.global_position)
	var progress_ratio_delta = delta / ANIMATION_DURATION_S
	_path_follow.progress_ratio = min(1.0, _path_follow.progress_ratio + progress_ratio_delta)
	if _path_follow.progress_ratio + progress_ratio_delta >= 1.0:
		_handle_hit()


func _setup_path():
	var projectile_origin = (
		_unit.global_position
		if _unit.find_child("ProjectileOrigin") == null
		else _unit.find_child("ProjectileOrigin").global_position
	)
	_path.curve.set_point_position(0, projectile_origin)
	_path.curve.set_point_position(1, target_unit.global_position)


func _handle_hit():
	target_unit.hp -= _unit.attack_damage
