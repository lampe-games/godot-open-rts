extends Camera3D

const Terrain = preload("res://source/match/Terrain.gd")
const Unit = preload("res://source/match/units/Unit.gd")

const Impact = preload("res://source/generic-scenes-and-nodes/3d/Impact.tscn")

@export var mouse_sensitivity = 0.0015
@export var reference_plane_for_rotation = Plane(Vector3.UP, 0.0)

@onready var _unit = get_parent()
@onready var _match = find_parent("Match")
@onready var _PSH = _match.find_child("ProjectileSystemHandler")

var _fire_free = false

func _physics_process(delta):
	if _fire_free:
		_fire_ray()
		#_fire_free = false

func _unhandled_input(event):
	if not current:
		return
		
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		_unit.rotation.y -= event.relative.x * mouse_sensitivity
	elif event.is_action_pressed("hold_for_command"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_released("hold_for_command"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif ( event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT 
	and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		_fire_free = true
	elif ( event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT 
	and not event.pressed and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		_fire_free = false

func get_ray_intersection(mouse_pos):
	return get_ray_intersection_with_plane(mouse_pos, reference_plane_for_rotation)

func get_ray_intersection_with_plane(mouse_pos, plane):
	return plane.intersects_ray(project_ray_origin(mouse_pos), project_ray_normal(mouse_pos))

func _fire_ray():
	var attack_range = _unit.attack_range
	if not attack_range:
		#unit cannot attack
		return
		
	var new_projectile = _PSH.Projectile.new_with_pos(global_position, -global_transform.basis.z, 1000)
	new_projectile.speed = _unit.projectile_speed
	_PSH._register_Projectile(new_projectile)
		
	#var space_state = get_world_3d().direct_space_state
	#var query = PhysicsRayQueryParameters3D.create(global_position,
	#			global_position - global_transform.basis.z * attack_range)
	#var collision = space_state.intersect_ray(query)
	#if not collision:
	#	return
	#	
	#print(collision)
	#if collision["collider"] is Terrain:
	#	_miss(collision["position"])
	#	return
	#
	#var _target_unit = collision["collider"].get_parent()
	#if _target_unit and _target_unit is Unit and _target_unit.player != Globals.player:
	#	_fire(_target_unit)

func _fire(_target_unit):
	var now = Time.get_ticks_msec()
	var next_attack_availability_time = _unit.get_meta("next_attack_availability_time", now)
	if next_attack_availability_time >= now:
		return
		
	_unit.set_meta(
		"next_attack_availability_time", Time.get_ticks_msec() + int(_unit.attack_interval * 1000.0)
	)
	
	var projectile = (
		load(
			Constants.Match.Units.PROJECTILES[_unit.get_script().resource_path.replace(
				".gd", ".tscn"
			)]
		)
		. instantiate()
	)
	projectile.target_unit = _target_unit
	_unit.add_child(projectile)

func _miss(pos):
	var impact = Impact.instantiate()
	get_tree().get_root().add_child(impact)
	impact.global_position = pos
